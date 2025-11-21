package com.uvillage.infractions.controller;

import com.uvillage.infractions.dto.*;
import com.uvillage.infractions.entity.User;
import com.uvillage.infractions.repository.UserRepository;
import com.uvillage.infractions.service.AuthService;
import com.uvillage.infractions.security.JwtUtils;

import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private static final Logger logger = LoggerFactory.getLogger(AuthController.class);

    private final AuthService authService;
    private final AuthenticationManager authenticationManager;
    private final JwtUtils jwtUtils;
    private final UserRepository userRepository;

    public AuthController(AuthService authService,
                          AuthenticationManager authenticationManager,
                          JwtUtils jwtUtils,
                          UserRepository userRepository) {
        this.authService = authService;
        this.authenticationManager = authenticationManager;
        this.jwtUtils = jwtUtils;
        this.userRepository = userRepository;
    }

    // --- Registration ---
    @PostMapping("/sign-up")
    public ResponseEntity<?> signUp(@Valid @RequestBody CreateAcoountRequest request) {
        try {
            AuthResponseDto response = authService.register(request);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (IllegalArgumentException ex) {
            return ResponseEntity.badRequest().body(createErrorResponse(ex.getMessage()));
        } catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("An error occurred during sign up"));
        }
    }

    // --- Login ---
    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequest request) {
        logger.info("[AUTH] Tentative de connexion pour: {}", request.getEmail());

        try {
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            request.getEmail(),
                            request.getPassword()
                    )
            );

            UserDetails userDetails = (UserDetails) authentication.getPrincipal();
            String token = jwtUtils.generateToken(userDetails);

            User user = userRepository.findByEmail(request.getEmail())
                    .orElseThrow(() -> new RuntimeException("Utilisateur introuvable"));

            String nomComplet = (user.getFullName() != null && !user.getFullName().isEmpty())
                    ? user.getFullName()
                    : user.getUsername();

            LoginResponse response = LoginResponse.builder()
                    .token(token)
                    .email(user.getEmail())
                    .agentRowid(user.getId())
                    .nomComplet(nomComplet)
                    .role(user.getRole().name())
                    .build();

            logger.info("[AUTH] ✅ Connexion réussie pour: {} (ID: {}, Role: {})",
                    user.getEmail(), user.getId(), user.getRole());

            return ResponseEntity.ok(response);

        } catch (AuthenticationException e) {
            logger.error("[AUTH] ❌ Échec de connexion pour: {} - Identifiants incorrects",
                    request.getEmail());
            return ResponseEntity.status(401).body("Identifiants incorrects");

        } catch (Exception e) {
            logger.error("[AUTH] ❌ Erreur interne pour: {}", request.getEmail(), e);
            return ResponseEntity.status(500)
                    .body("Une erreur interne s'est produite. Veuillez réessayer plus tard.");
        }
    }

    // --- Forgot Password ---
    @PostMapping("/forgot-password")
    public ResponseEntity<?> forgotPassword(@Valid @RequestBody ForgotPasswordRequest request) {
        try {
            authService.forgotPassword(request);
            return ResponseEntity.ok(createSuccessResponse(
                    "If your email exists, you will receive reset instructions"));
        } catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("An error occurred"));
        }
    }

    // --- Verify Email / Reset Codes ---
    @PostMapping("/verify-code")
    public ResponseEntity<?> verifyCode(@Valid @RequestBody VerificationCodeRequest request) {
        try {
            authService.verifyCode(request);
            return ResponseEntity.ok(createSuccessResponse("Email verified successfully"));
        } catch (IllegalArgumentException ex) {
            return ResponseEntity.badRequest().body(createErrorResponse(ex.getMessage()));
        } catch (Exception ex) {
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
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("An error occurred"));
        }
    }

    // --- Profile Management ---
    @PutMapping("/edit-profile")
    public ResponseEntity<?> editProfile(@Valid @RequestBody EditProfileRequest request) {
        try {
            AuthResponseDto response = authService.editProfile(request);
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException ex) {
            return ResponseEntity.badRequest().body(createErrorResponse(ex.getMessage()));
        } catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("An error occurred during profile update"));
        }
    }

    @PostMapping("/change-password")
    public ResponseEntity<?> changePassword(@RequestBody ChangePasswordRequest request,
                                            Principal principal,
                                            @RequestHeader(value = "Authorization", required = false) String authorizationHeader) {
        // Use authenticated principal (from JWT) as the trusted identity
        String email = null;
        if (principal != null) {
            email = principal.getName();
        } else if (authorizationHeader != null && authorizationHeader.startsWith("Bearer ")) {
            // If Principal is not populated (edge cases), try to extract the email from the JWT
            try {
                String token = authorizationHeader.substring(7);
                if (jwtUtils.validateToken(token)) {
                    email = jwtUtils.extractUsername(token);
                }
            } catch (Exception ex) {
                logger.warn("Failed to extract username from Authorization header", ex);
            }
        } else if (request.getEmail() != null) {
            // fallback to payload email (not recommended)
            email = request.getEmail();
        }

        if (email == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("success", false, "message", "Unauthenticated"));
        }

        boolean checkCurrent = request.getCurrentPassword() != null && !request.getCurrentPassword().isBlank();
        AuthResponseDto resp = authService.changePasswordAuthenticated(email, request.getCurrentPassword(), checkCurrent, request.getNewPassword());

        if (resp.isSuccess()) {
            return ResponseEntity.ok(Map.of("success", true, "message", resp.getMessage(), "token", resp.getToken()));
        }
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("success", false, "message", resp.getMessage()));
    }

    @GetMapping("/profile")
    public ResponseEntity<?> getProfile(Principal principal) {
        try {
            if (principal == null || principal.getName() == null) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(createErrorResponse("Unauthorized"));
            }
            String email = principal.getName();
            UserProfileDto profile = authService.getProfileByEmail(email);
            if (profile == null) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body(createErrorResponse("User not found"));
            }
            return ResponseEntity.ok(profile);
        } catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("An error occurred"));
        }
    }

    // --- Helper Methods ---
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
