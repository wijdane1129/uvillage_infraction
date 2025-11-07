package com.uvillage.infractions.controller;

import com.uvillage.infractions.dto.*;
import com.uvillage.infractions.service.AuthService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.AuthenticationException;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * Contrôleur REST pour la gestion de l'authentification (connexion, inscription, mot de passe oublié).
 */
@RestController
@RequestMapping({"/api/v1/auth", "/api/auth"})
public class AuthController {

    private final AuthService authService;
    private static final Logger log = LoggerFactory.getLogger(AuthController.class);

    @Autowired
    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequest loginRequest) {
        try {
            LoginResponse response = authService.authenticateUser(loginRequest);
            return ResponseEntity.ok(response);
        } catch (AuthenticationException e) {
            // Mauvais identifiants (email ou mot de passe incorrect)
            return ResponseEntity.status(401).body("Email ou mot de passe invalide.");
        } catch (Exception e) {
            // Log the exception stacktrace to help debugging and return a generic 500
            log.error("Erreur interne lors de la tentative de connexion pour email={}", loginRequest.getEmail(), e);
            return ResponseEntity.status(500).body("Erreur interne du serveur lors de la connexion.");
        }
    }

    @PostMapping("/sign-up")
    public ResponseEntity<?> signUp(@Valid @RequestBody CreateAccountRequest request) {
        try {
            AuthResponseDto response = authService.register(request);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (IllegalArgumentException ex) {
            return ResponseEntity.badRequest().body(createErrorResponse(ex.getMessage()));
        } catch (Exception ex) {
            log.error("Erreur lors de l'inscription pour email={}", request.getEmail(), ex);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("An error occurred during sign up"));
        }
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<?> forgotPassword(@Valid @RequestBody ForgotPasswordRequest request) {
        try {
            authService.forgotPassword(request);
            return ResponseEntity.ok(createSuccessResponse("If your email exists, you will receive reset instructions"));
        } catch (Exception ex) {
            log.error("Erreur lors de la demande de mot de passe oublié pour email={}", request.getEmail(), ex);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("An error occurred"));
        }
    }

    @PostMapping("/verify-code")
    public ResponseEntity<?> verifyCode(@Valid @RequestBody VerificationCodeRequest request) {
        try {
            authService.verifyCode(request);
            return ResponseEntity.ok(createSuccessResponse("Email verified successfully"));
        } catch (IllegalArgumentException ex) {
            return ResponseEntity.badRequest().body(createErrorResponse(ex.getMessage()));
        } catch (Exception ex) {
            log.error("Erreur lors de la vérification du code pour email={}", request.getEmail(), ex);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("An error occurred during verification"));
        }
    }

    @PostMapping("/verify-reset-code")
    public ResponseEntity<?> verifyResetCode(@Valid @RequestBody VerificationCodeRequest request) {
        try {
            AuthResponseDto response = authService.verifyResetToken(request);
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException ex) {
            return ResponseEntity.badRequest().body(createErrorResponse(ex.getMessage()));
        } catch (Exception ex) {
            log.error("Erreur lors de la vérification du code de reset pour email={}", request.getEmail(), ex);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("An error occurred during reset code verification"));
        }
    }

    @PostMapping("/reset-password")
    public ResponseEntity<?> resetPassword(@Valid @RequestBody ResetPasswordRequest request) {
        try {
            authService.resetPassword(request);
            return ResponseEntity.ok(createSuccessResponse("Password reset successfully"));
        } catch (IllegalArgumentException ex) {
            return ResponseEntity.badRequest().body(createErrorResponse(ex.getMessage()));
        } catch (Exception ex) {
            log.error("Erreur lors de la réinitialisation du mot de passe", ex);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("An error occurred during password reset"));
        }
    }

    @PostMapping("/resend-code")
    public ResponseEntity<?> resendVerificationCode(@Valid @RequestBody Map<String, String> request) {
        try {
            String email = request.get("email");
            authService.resendVerificationCode(email);
            return ResponseEntity.ok(createSuccessResponse("Verification code sent to your email"));
        } catch (Exception ex) {
            log.error("Erreur lors du renvoi du code de vérification pour email={}", request.get("email"), ex);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("An error occurred"));
        }
    }

    private Map<String, Object> createErrorResponse(String message) {
        Map<String, Object> response = new HashMap<>();
        response.put("success", false);
        response.put("message", message);
        return response;
    }

    private Map<String, Object> createSuccessResponse(String message) {
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", message);
        return response;
    }
}