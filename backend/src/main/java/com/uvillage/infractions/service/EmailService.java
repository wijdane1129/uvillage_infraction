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

        // Also log verification code clearly for local/dev testing
        logger.info("Verification code for {} is {}", email, code);

        sendEmail(email, subject, content);
    }


    public void sendPasswordResetEmail(String email, String fullName, String code) {
        String subject = "Password Reset Request";
        String content = String.format(
            "Dear %s,\n\nYou have requested to reset your password. " +
            "Please use this verification code to complete the process: %s\n\n" +
            "This code will expire in 10 minutes.\n\n" +
            "If you did not request this, please ignore this email.\n\n" +
            "Best regards,\nYour Application Team",
            fullName, code
        );

        // Log the numeric code separately to make it obvious during local/dev testing
        logger.info("Password reset code for {} is {}", email, code);

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
            // Log the failure but do not throw — allow dev/testing to continue
            // even when an SMTP server isn't configured. The reset code/token
            // will still be present in the database and can be copied from logs
            // if needed.
            logger.error("Failed to send email to: {}. Email sending is disabled or misconfigured.", to, e);
            logger.info("(DEV) Email content for {}:\nSubject: {}\n{}", to, subject, content);
        }
    }
}