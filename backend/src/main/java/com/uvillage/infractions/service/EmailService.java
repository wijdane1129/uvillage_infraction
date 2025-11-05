package com.uvillage.infractions.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
public class EmailService {
    private static final Logger logger = LoggerFactory.getLogger(EmailService.class);

    @Autowired
    private JavaMailSender mailSender;

    public void sendVerificationEmail(String email, String fullName, String code) {
        String subject = "Email Verification";
        String content = String.format(
            "Dear %s,\n\nPlease use this code to verify your email: %s\n\n" +
            "This code will expire in 15 minutes.\n\n" +
            "Best regards,\nYour Application Team",
            fullName, code
        );

        sendEmail(email, subject, content);
    }

    public void sendPasswordResetEmail(String email, String fullName, String token) {
        String subject = "Password Reset Request";
        String content = String.format(
            "Dear %s,\n\nYou have requested to reset your password. " +
            "Please use this token to complete the process: %s\n\n" +
            "This token will expire in 10 minutes.\n\n" +
            "If you did not request this, please ignore this email.\n\n" +
            "Best regards,\nYour Application Team",
            fullName, token
        );

        sendEmail(email, subject, content);
    }

    private void sendEmail(String to, String subject, String content) {
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setTo(to);
            message.setSubject(subject);
            message.setText(content);

            mailSender.send(message);
            logger.info("Email sent to: {}", to);
        } catch (Exception e) {
            logger.error("Failed to send email to: {}", to, e);
            throw new RuntimeException("Failed to send email", e);
        }
    }
}