package com.uvillage.infractions.service;

import com.uvillage.infractions.dto.*;
import com.uvillage.infractions.entity.User;
import com.uvillage.infractions.repository.UserRepository;
import com.uvillage.infractions.security.JwtUtils;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Random;
import java.util.regex.Pattern;

/**
 * Service pour la gestion de l'authentification et de la gestion du compte utilisateur.
 */
@Service
public class AuthService {

    private final Logger logger = LoggerFactory.getLogger(AuthService.class);

    @Autowired
    private UserRepository userRepository;

    @Autowired 
    private JwtUtils jwtUtils;

    @Autowired
    private EmailService emailService;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private AuthenticationManager authenticationManager;

    // --------------------
    // LOGIN
    // --------------------
    public LoginResponse authenticateUser(LoginRequest request) throws AuthenticationException {
        logger.debug("[AUTH SERVICE] Tentative d'authentification pour: {}", request.getEmail());

        Authentication authentication = authenticationManager.authenticate(
            new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
        );

        UserDetails userDetails = (UserDetails) authentication.getPrincipal();

        String token = jwtUtils.generateToken(userDetails);

        User user = userRepository.findByEmail(request.getEmail())
            .orElseThrow(() -> new UsernameNotFoundException("Utilisateur introuvable: " + request.getEmail()));

        String nomComplet = (user.getFullName() != null && !user.getFullName().isEmpty())
            ? user.getFullName()
            : user.getUsername();

        return LoginResponse.builder()
            .token(token)
            .email(user.getEmail())
            .agentRowid(user.getId())
            .nomComplet(nomComplet)
            .role(user.getRole().name())
            .build();
    }

    // --------------------
    // REGISTRATION
    // --------------------
    public AuthResponseDto register(CreateAcoountRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            return AuthResponseDto.builder()
                .success(false)
                .message("Email is already in use")
                .build();
        }

        if (!request.getPassword().equals(request.getConfirmPassword())) {
            return AuthResponseDto.builder()
                .success(false)
                .message("Passwords do not match")
                .build();
        }

        validatePassword(request.getPassword());

        User user = User.builder()
            .email(request.getEmail())
            .fullName(request.getFullName())
            .username(request.getEmail())
            .password(passwordEncoder.encode(request.getPassword()))
            .build();

        User savedUser = userRepository.save(user);
        logger.info("User registered successfully: {}", savedUser.getEmail());

        String jwt = jwtUtils.generateToken(savedUser.getEmail());
        return AuthResponseDto.builder()
            .success(true)
            .token(jwt)
            .message("Registration successful")
            .build();
    }

    // --------------------
    // PASSWORD RESET
    // --------------------
    public void forgotPassword(ForgotPasswordRequest request) {
        User user = userRepository.findByEmail(request.getEmail()).orElse(null);
        if (user == null) {
            logger.warn("Password reset requested for non-existing email: {}", request.getEmail());
            return;
        }

        if (user.getResetToken() != null) {
            user.setResetToken(null);
            user.setResetTokenExpiry(null);
        }

        String resetCode = generateVerificationCode();
        user.setResetPasswordToken(resetCode);
        user.setResetTokenExpiryDate(LocalDateTime.now().plusMinutes(10));
        userRepository.save(user);

        emailService.sendPasswordResetEmail(user.getEmail(), user.getFullName(), resetCode);
        logger.info("Password reset code generated for user: {}", user.getEmail());
    }

    public AuthResponseDto verifyResetToken(VerificationCodeRequest request) {
        User user = userRepository.findByEmail(request.getEmail()).orElse(null);
        if (user == null || user.getResetPasswordToken() == null ||
            !user.getResetPasswordToken().equals(request.getCode())) {
            return AuthResponseDto.builder().success(false).message("Invalid reset token").build();
        }

        if (user.getResetTokenExpiryDate().isBefore(LocalDateTime.now())) {
            return AuthResponseDto.builder().success(false).message("Reset token has expired").build();
        }

        return AuthResponseDto.builder().success(true).message("Token verified successfully").build();
    }

    public AuthResponseDto resetPassword(ResetPasswordRequest request) {
        User user = userRepository.findByResetPasswordToken(request.getToken()).orElse(null);
        if (user == null) {
            return AuthResponseDto.builder().success(false).message("Invalid reset token").build();
        }

        if (!request.getPassword().equals(request.getConfirmPassword())) {
            return AuthResponseDto.builder().success(false).message("Passwords do not match").build();
        }

        validatePassword(request.getPassword());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setResetPasswordToken(null);
        user.setResetTokenExpiryDate(null);
        userRepository.save(user);

        String jwt = jwtUtils.generateToken(user.getEmail());
        return AuthResponseDto.builder().success(true).token(jwt).message("Password reset successful").build();
    }

    // --------------------
    // EMAIL VERIFICATION
    // --------------------
    public AuthResponseDto verifyCode(VerificationCodeRequest request) {
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        if (!user.getVerificationCode().equals(request.getCode())) {
            throw new IllegalArgumentException("Invalid verification code");
        }

        if (user.getCodeExpiryTime().isBefore(LocalDateTime.now())) {
            throw new IllegalArgumentException("Verification code has expired");
        }

        user.setEmailVerified(true);
        user.setVerificationCode(null);
        user.setCodeExpiryTime(null);
        userRepository.save(user);

        logger.info("Email verified successfully for user: {}", user.getEmail());
        return AuthResponseDto.builder().success(true).message("Email verified successfully").build();
    }

    public void resendVerificationCode(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        if (user.isEmailVerified()) {
            throw new IllegalArgumentException("Email is already verified");
        }

        String code = generateVerificationCode();
        user.setVerificationCode(code);
        user.setCodeExpiryTime(LocalDateTime.now().plusMinutes(15));
        userRepository.save(user);

        emailService.sendVerificationEmail(user.getEmail(), user.getFullName(), code);
        logger.info("Verification code resent to user: {}", email);
    }

    // --------------------
    // PROFILE MANAGEMENT
    // --------------------
    public AuthResponseDto editProfile(EditProfileRequest request) {
        User user = userRepository.findByEmail(request.getEmail()).orElse(null);
        if (user == null) {
            return AuthResponseDto.builder().success(false).message("User not found").build();
        }

        if (request.getEmail() != null && !request.getEmail().equals(user.getEmail()) &&
            userRepository.existsByEmail(request.getEmail())) {
            return AuthResponseDto.builder().success(false).message("Email is already in use").build();
        }

        try {
            editProfile(request, user);
            userRepository.save(user);
            logger.info("User profile updated: {}", user.getEmail());
            return AuthResponseDto.builder().success(true).message("Profile updated successfully").build();
        } catch (Exception ex) {
            logger.error("Error updating profile for {}", user.getEmail(), ex);
            return AuthResponseDto.builder().success(false).message("An error occurred while updating profile").build();
        }
    }

    public UserProfileDto getProfileByEmail(String email) {
        User user = userRepository.findByEmail(email).orElse(null);
        if (user == null) return null;
        return UserProfileDto.builder()
                .id(user.getId())
                .email(user.getEmail())
                .fullName(user.getFullName())
                .username(user.getUsername())
                .language(user.getLanguage())
                .emailVerified(user.isEmailVerified())
                .build();
    }

    // --------------------
    // UTILS
    // --------------------
    private String generateVerificationCode() {
        return String.format("%06d", new Random().nextInt(999999));
    }

    private void validatePassword(String password){
        if(password.length()<8) throw new IllegalArgumentException("Password must be at least 8 characters long");
        if(!Pattern.compile("[A-Z]").matcher(password).find()) throw new IllegalArgumentException("Password must contain at least one uppercase letter");
        if(!Pattern.compile("[a-z]").matcher(password).find()) throw new IllegalArgumentException("Password must contain at least one lowercase letter");
        if(!Pattern.compile("[0-9]").matcher(password).find()) throw new IllegalArgumentException("Password must contain at least one digit");
        if(!Pattern.compile("[^a-zA-Z0-9]").matcher(password).find()) throw new IllegalArgumentException("Password must contain at least one special character");
    }

    private void editProfile(EditProfileRequest request, User user){
        if(request.getFullName()!=null && !request.getFullName().isEmpty()) user.setFullName(request.getFullName());
        if(request.getLanguage()!=null && !request.getLanguage().isEmpty()) user.setLanguage(request.getLanguage());
        if(request.getEmail()!=null && !request.getEmail().isEmpty()) user.setEmail(request.getEmail());
        if(request.getUsername()!=null && !request.getUsername().isEmpty()) user.setUsername(request.getUsername());
        if(request.getPassword()!=null && !request.getPassword().isEmpty()) user.setPassword(passwordEncoder.encode(request.getPassword()));
    }
}
