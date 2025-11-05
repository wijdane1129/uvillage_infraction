package com.uvillage.infractions.service;

import com.uvillage.infractions.dto.*;
import com.uvillage.infractions.entity.User;
import com.uvillage.infractions.repository.UserRepository;
import com.uvillage.infractions.security.JwtUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Random;
import java.util.UUID;
import java.util.regex.Pattern;

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

    //createAccount
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

    //forgotPassword
    public void forgotPassword(ForgotPasswordRequest request){
        User user=userRepository.findByEmail(request.getEmail()).orElse(null);
        if(user==null){
            logger.warn("Password reset requested for non-existing email:{}",request.getEmail());
            return;
        }
        String resetToken=generateResetToken();
        user.setResetToken(resetToken);
        user.setResetTokenExpiry(LocalDateTime.now().plusMinutes(10));
        userRepository.save(user);
        logger.info("Password reset token generated for user:{}",user.getEmail());
        emailService.sendPasswordResetEmail(user.getEmail(),user.getFullName(),resetToken);
    }

    //verificationToken
    public AuthResponseDto verifyResetToken(VerificationCodeRequest request) {
        User user = userRepository.findByEmail(request.getEmail()).orElse(null);
        if (user == null || user.getResetPasswordToken() == null || 
            !user.getResetPasswordToken().equals(request.getCode())) {
            return AuthResponseDto.builder()
                .success(false)
                .message("Invalid reset token")
                .build();
        }

        if (user.getResetTokenExpiryDate().isBefore(LocalDateTime.now())) {
            return AuthResponseDto.builder()
                .success(false)
                .message("Reset token has expired")
                .build();
        }

        return AuthResponseDto.builder()
            .success(true)
            .message("Token verified successfully")
            .build();
    }

    //resetPassword
    public AuthResponseDto resetPassword(ResetPasswordRequest request) {
        User user = userRepository.findByResetPasswordToken(request.getToken()).orElse(null);
        if (user == null) {
            return AuthResponseDto.builder()
                .success(false)
                .message("Invalid reset token")
                .build();
        }

        if (!request.getPassword().equals(request.getConfirmPassword())) {
            return AuthResponseDto.builder()
                .success(false)
                .message("Passwords do not match")
                .build();
        }

        validatePassword(request.getPassword());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setResetPasswordToken(null);
        user.setResetTokenExpiryDate(null);
        userRepository.save(user);

        logger.info("Password reset successfully for user: {}", user.getEmail());
        String jwt = jwtUtils.generateToken(user.getEmail());
        return AuthResponseDto.builder()
            .success(true)
            .token(jwt)
            .message("Password reset successful")
            .build();
    }

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
        return AuthResponseDto.builder()
                .success(true)
                .message("Email verified successfully")
                .build();
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

    private String generateResetToken(){
        return UUID.randomUUID().toString();
    }
    private String generateVerificationCode() {
        return String.format("%06d", new Random().nextInt(999999));
    }

    // method to validate password strength
    private void validatePassword(String password){
        if(password.length()<8){
            throw new IllegalArgumentException("Password must be at least 8 characters long");
        }
        Pattern upperCasePattern=Pattern.compile("[A-Z]");
        Pattern lowerCasePattern=Pattern.compile("[a-z]");
        Pattern digitPattern=Pattern.compile("[0-9]");
        Pattern specialCharPattern=Pattern.compile("[^a-zA-Z0-9]");
        if(!upperCasePattern.matcher(password).find()){
            throw new IllegalArgumentException("Password must contain at least one uppercase letter");
        }
        if(!lowerCasePattern.matcher(password).find()){
            throw new IllegalArgumentException("Password must contain at least one lowercase letter");
        }
        if(!digitPattern.matcher(password).find()){
            throw new IllegalArgumentException("Password must contain at least one digit");
        }
        if(!specialCharPattern.matcher(password).find()){
            throw new IllegalArgumentException("Password must contain at least one special character");
        }
    }




}