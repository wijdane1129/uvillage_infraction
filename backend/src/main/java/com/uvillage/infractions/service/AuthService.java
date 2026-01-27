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
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Random;
import java.util.regex.Pattern;

@Service
public class AuthService {

    private final Logger logger = LoggerFactory.getLogger(AuthService.class);

    private final UserRepository userRepository;
    private final JwtUtils jwtUtils;
    private final AuthenticationManager authenticationManager;
    private final PasswordEncoder passwordEncoder;
    private final EmailService emailService;
    private final Pattern responsiblePattern;

    @Autowired
    public AuthService(AuthenticationManager authenticationManager,
                       JwtUtils jwtUtils,
                       UserRepository userRepository,
                       PasswordEncoder passwordEncoder,
                       EmailService emailService,
                       @org.springframework.beans.factory.annotation.Value("${app.responsible.pattern:}") String responsiblePattern) {
        this.authenticationManager = authenticationManager;
        this.jwtUtils = jwtUtils;
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.emailService = emailService;
        if (responsiblePattern != null && !responsiblePattern.isBlank()) {
            this.responsiblePattern = Pattern.compile(responsiblePattern, Pattern.CASE_INSENSITIVE);
        } else {
            this.responsiblePattern = null;
        }
    }

    // --------------------
    // REGISTRATION
    // --------------------
    public AuthResponseDto register(CreateAccountRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            return AuthResponseDto.fail("Email is already in use");
        }

        if (!request.getPassword().equals(request.getConfirmPassword())) {
            return AuthResponseDto.fail("Passwords do not match");
        }

        validatePassword(request.getPassword());

        // Assign role based on configured responsible email pattern; default to AGENT
        String normalizedEmail = request.getEmail() != null ? request.getEmail().trim().toLowerCase() : "";
        boolean isResponsible = false;
        if (responsiblePattern != null) {
            isResponsible = responsiblePattern.matcher(normalizedEmail).matches();
        }

        User user = User.builder()
                .email(request.getEmail())
                .fullName(request.getFullName())
                .username(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .role(isResponsible ? User.Role.RESPONSABLE : User.Role.AGENT)
                .build();

        User savedUser = userRepository.save(user);
        logger.info("User registered successfully: {}", savedUser.getEmail());

        UserDetails ud = org.springframework.security.core.userdetails.User.builder()
                .username(savedUser.getEmail())
                .password(savedUser.getPassword())
                .roles(savedUser.getRole() != null ? savedUser.getRole().name() : "AGENT")
                .build();

        String token = jwtUtils.generateToken(ud);

        return AuthResponseDto.success("Registration successful", token);
    }

    // --------------------
    // LOGIN
    // --------------------
    public LoginResponse authenticateUser(LoginRequest request) throws AuthenticationException {
        logger.debug("[AUTH SERVICE] Attempt login for: {}", request.getEmail());

        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
        );

        UserDetails userDetails = (UserDetails) authentication.getPrincipal();
        String token = jwtUtils.generateToken(userDetails);

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new UsernameNotFoundException("User not found: " + request.getEmail()));

        String fullName = (user.getFullName() != null && !user.getFullName().isEmpty())
                ? user.getFullName()
                : user.getUsername();

        return LoginResponse.builder()
                .token(token)
                .email(user.getEmail())
                .agentRowid(user.getId())
                .nomComplet(fullName)
                .role(user.getRole().name())
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

        // clear old tokens
        user.setResetPasswordToken(null);
        user.setResetTokenExpiryDate(null);

        String resetCode = generateVerificationCode();
        user.setResetPasswordToken(resetCode);
        user.setResetTokenExpiryDate(LocalDateTime.now().plusMinutes(10));
        userRepository.save(user);

        emailService.sendPasswordResetEmail(user.getEmail(), user.getFullName(), resetCode);
        logger.info("Password reset code generated for user: {}", user.getEmail());
    }

    public AuthResponseDto verifyResetToken(VerificationCodeRequest request) {
        User user = userRepository.findByEmail(request.getEmail()).orElse(null);

        if (user == null ||
                user.getResetPasswordToken() == null ||
                !user.getResetPasswordToken().equals(request.getCode())) {
            return AuthResponseDto.fail("Invalid reset token");
        }

        if (user.getResetTokenExpiryDate().isBefore(LocalDateTime.now())) {
            return AuthResponseDto.fail("Reset token has expired");
        }

        return AuthResponseDto.success("Token verified successfully");
    }

    public AuthResponseDto resetPassword(ResetPasswordRequest request) {
        User user = userRepository.findByResetPasswordToken(request.getToken()).orElse(null);
        if (user == null) {
            return AuthResponseDto.fail("Invalid reset token");
        }

        if (!request.getPassword().equals(request.getConfirmPassword())) {
            return AuthResponseDto.fail("Passwords do not match");
        }

        validatePassword(request.getPassword());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setResetPasswordToken(null);
        user.setResetTokenExpiryDate(null);
        userRepository.save(user);

        UserDetails ud = org.springframework.security.core.userdetails.User.builder()
                .username(user.getEmail())
                .password(user.getPassword())
                .roles(user.getRole() != null ? user.getRole().name() : "AGENT")
                .build();

        String jwt = jwtUtils.generateToken(ud);

        return AuthResponseDto.success("Password reset successful", jwt);
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
            throw new IllegalArgumentException("Verification code expired");
        }

        user.setEmailVerified(true);
        user.setVerificationCode(null);
        user.setCodeExpiryTime(null);
        userRepository.save(user);

        logger.info("Email verified: {}", user.getEmail());
        return AuthResponseDto.success("Email verified successfully");
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
        logger.info("Verification code resent to: {}", email);
    }

    // --------------------
    // PROFILE MANAGEMENT
    // --------------------
    public AuthResponseDto editProfile(EditProfileRequest request) {
        User user = userRepository.findByEmail(request.getEmail()).orElse(null);
        if (user == null) return AuthResponseDto.fail("User not found");

        if (request.getEmail() != null &&
                !request.getEmail().equals(user.getEmail()) &&
                userRepository.existsByEmail(request.getEmail())) {
            return AuthResponseDto.fail("Email already in use");
        }

        try {
            editProfileFields(request, user);
            userRepository.save(user);
            logger.info("Profile updated: {}", user.getEmail());
            return AuthResponseDto.success("Profile updated successfully");
        } catch (Exception ex) {
            logger.error("Error updating profile {}", user.getEmail(), ex);
            return AuthResponseDto.fail("Error updating profile");
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
    // CHANGE PASSWORD (Authenticated)
    // --------------------
    public AuthResponseDto changePasswordAuthenticated(
            String email, String currentPassword, boolean checkCurrent, String newPassword) {

        User user = userRepository.findByEmail(email).orElse(null);
        if (user == null) return AuthResponseDto.fail("User not found");

        if (checkCurrent) {
            if (currentPassword == null || !passwordEncoder.matches(currentPassword, user.getPassword())) {
                return AuthResponseDto.fail("Current password incorrect");
            }
        }

        try {
            validatePassword(newPassword);
        } catch (IllegalArgumentException ex) {
            return AuthResponseDto.fail(ex.getMessage());
        }

        user.setPassword(passwordEncoder.encode(newPassword));
        userRepository.save(user);

        UserDetails ud = org.springframework.security.core.userdetails.User.builder()
                .username(user.getEmail())
                .password(user.getPassword())
                .roles(user.getRole() != null ? user.getRole().name() : "AGENT")
                .build();

        String jwt = jwtUtils.generateToken(ud);

        return AuthResponseDto.success("Password changed successfully", jwt);
    }

    // --------------------
    // UTILS
    // --------------------
    private String generateVerificationCode() {
        return String.format("%06d", new Random().nextInt(999999));
    }

    private void validatePassword(String password) {
        if (password.length() < 8)
            throw new IllegalArgumentException("Password must be at least 8 characters");

        if (!Pattern.compile("[A-Z]").matcher(password).find())
            throw new IllegalArgumentException("Password must contain uppercase");
        if (!Pattern.compile("[a-z]").matcher(password).find())
            throw new IllegalArgumentException("Password must contain lowercase");
        if (!Pattern.compile("[0-9]").matcher(password).find())
            throw new IllegalArgumentException("Password must contain digit");
        if (!Pattern.compile("[^a-zA-Z0-9]").matcher(password).find())
            throw new IllegalArgumentException("Password must contain special character");
    }

    private void editProfileFields(EditProfileRequest request, User user) {
        if (request.getFullName() != null && !request.getFullName().isEmpty())
            user.setFullName(request.getFullName());

        if (request.getLanguage() != null && !request.getLanguage().isEmpty())
            user.setLanguage(request.getLanguage());

        if (request.getEmail() != null && !request.getEmail().isEmpty())
            user.setEmail(request.getEmail());

        if (request.getUsername() != null && !request.getUsername().isEmpty())
            user.setUsername(request.getUsername());

        if (request.getPassword() != null && !request.getPassword().isEmpty())
            user.setPassword(passwordEncoder.encode(request.getPassword()));
    }
}
