package com.uvillage.infractions.controller;

import com.uvillage.infractions.dto.*;
import com.uvillage.infractions.entity.User;
import com.uvillage.infractions.repository.UserRepository;
import com.uvillage.infractions.security.JwtUtils;
import com.uvillage.infractions.service.AuthService;
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
import org.springframework.security.core.context.SecurityContextHolder;
import java.util.stream.Collectors;

/**
 * REST controller for authentication and profile management.
 */
@RestController
@RequestMapping({"/api/v1/auth", "/api/auth"})
public class AuthController {

    private static final Logger logger = LoggerFactory.getLogger(AuthController.class);

    private final AuthService authService;
    private final AuthenticationManager authenticationManager;
    private final JwtUtils jwtUtils;
    private final UserRepository userRepository;

    public AuthController(
            AuthService authService,
            AuthenticationManager authenticationManager,
            JwtUtils jwtUtils,
            UserRepository userRepository
    ) {
        this.authService = authService;
        this.authenticationManager = authenticationManager;
        this.jwtUtils = jwtUtils;
        this.userRepository = userRepository;
    }

    // ---------- Registration ----------
    @PostMapping("/sign-up")
    public ResponseEntity<?> signUp(@Valid @RequestBody CreateAccountRequest request) {
        try {
            AuthResponseDto response = authService.register(request);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (IllegalArgumentException ex) {
            return ResponseEntity.badRequest().body(createErrorResponse(ex.getMessage()));
        } catch (Exception ex) {
            logger.error("Error during sign up for email={}", request.getEmail(), ex);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("An error occurred during sign up"));
        }
    }

    // ---------- Login ----------
    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequest request) {
        logger.info("[AUTH] Attempting login for: {}", request.getEmail());

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
                    .orElseThrow(() -> new RuntimeException("User not found"));

            String nomComplet = (user.getFullName() != null && !user.getFullName().isBlank())
                    ? user.getFullName()
                    : user.getUsername();

            LoginResponse response = LoginResponse.builder()
                    .token(token)
                    .email(user.getEmail())
                    .agentRowid(user.getId())
                    .nomComplet(nomComplet)
                    .role(user.getRole() != null ? user.getRole().name() : "AGENT")
                    .build();

            logger.info("[AUTH] ✅ Login successful for: {} (ID: {}, Role: {})",
                    user.getEmail(), user.getId(), user.getRole());

            return ResponseEntity.ok(response);

        } catch (AuthenticationException e) {
            logger.warn("[AUTH] ❌ Invalid credentials for: {}", request.getEmail());
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(createErrorResponse("Invalid credentials"));

        } catch (Exception e) {
            logger.error("[AUTH] ❌ Internal error for: {}", request.getEmail(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("An internal error occurred"));
        }
    }

    // ---------- Forgot Password ----------
    @PostMapping("/forgot-password")
    public ResponseEntity<?> forgotPassword(@Valid @RequestBody ForgotPasswordRequest request) {
        try {
            authService.forgotPassword(request);
            return ResponseEntity.ok(
                    createSuccessResponse("If your email exists, you will receive reset instructions")
            );
        } catch (Exception ex) {
            logger.error("Error during forgot password for email={}", request.getEmail(), ex);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("An error occurred"));
        }
    }

    // ---------- Verify Codes ----------
    @PostMapping("/verify-code")
    public ResponseEntity<?> verifyCode(@Valid @RequestBody VerificationCodeRequest request) {
        try {
            authService.verifyCode(request);
            return ResponseEntity.ok(createSuccessResponse("Email verified successfully"));
        } catch (IllegalArgumentException ex) {
            return ResponseEntity.badRequest().body(createErrorResponse(ex.getMessage()));
        } catch (Exception ex) {
            logger.error("Error verifying code for email={}", request.getEmail(), ex);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("Verification error"));
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
            logger.error("Error verifying reset code for email={}", request.getEmail(), ex);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("Reset code verification failed"));
        }
    }

    // ---------- Reset Password ----------
    @PostMapping("/reset-password")
    public ResponseEntity<?> resetPassword(@Valid @RequestBody ResetPasswordRequest request) {
        try {
            authService.resetPassword(request);
            return ResponseEntity.ok(createSuccessResponse("Password reset successfully"));
        } catch (IllegalArgumentException ex) {
            return ResponseEntity.badRequest().body(createErrorResponse(ex.getMessage()));
        } catch (Exception ex) {
            logger.error("Error resetting password", ex);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("Password reset failed"));
        }
    }

    // ---------- Resend Code ----------
    @PostMapping("/resend-code")
    public ResponseEntity<?> resendVerificationCode(@RequestBody Map<String, String> request) {
        try {
            authService.resendVerificationCode(request.get("email"));
            return ResponseEntity.ok(createSuccessResponse("Verification code sent"));
        } catch (Exception ex) {
            logger.error("Error resending verification code", ex);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("An error occurred"));
        }
    }

    // ---------- Profile ----------
    @GetMapping("/profile")
    public ResponseEntity<?> getProfile(Principal principal) {
        try {
            if (principal == null || principal.getName() == null) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(createErrorResponse("Unauthorized"));
            }

            UserProfileDto profile = authService.getProfileByEmail(principal.getName());
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

    // ---------- Change Password ----------
    @PostMapping("/change-password")
    public ResponseEntity<?> changePassword(
            @RequestBody ChangePasswordRequest request,
            Principal principal,
            @RequestHeader(value = "Authorization", required = false) String authHeader
    ) {

        String email = principal != null ? principal.getName() : null;

        if (email == null && authHeader != null && authHeader.startsWith("Bearer ")) {
            try {
                String token = authHeader.substring(7);
                if (jwtUtils.validateToken(token)) {
                    email = jwtUtils.extractUsername(token);
                }
            } catch (Exception ex) {
                logger.warn("JWT extraction failed", ex);
            }
        }

        if (email == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(createErrorResponse("Unauthenticated"));
        }

        boolean checkCurrent =
                request.getCurrentPassword() != null && !request.getCurrentPassword().isBlank();

        AuthResponseDto resp = authService.changePasswordAuthenticated(
                email,
                request.getCurrentPassword(),
                checkCurrent,
                request.getNewPassword()
        );

        if (resp.isSuccess()) {
            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "message", resp.getMessage(),
                    "token", resp.getToken()
            ));
        }

        return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", resp.getMessage()
        ));
    }

    // ---------- Debug ----------
    @GetMapping("/debug/token")
    public ResponseEntity<?> debugToken(
            @RequestHeader(name = "Authorization", required = false) String authHeader
    ) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return ResponseEntity.badRequest()
                    .body(Map.of("valid", false, "message", "No Bearer token"));
        }

        String token = authHeader.substring(7);
        try {
            boolean valid = jwtUtils.validateToken(token);
            String username = jwtUtils.extractUsername(token);
            return ResponseEntity.ok(Map.of("valid", valid, "username", username));
        } catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("valid", false, "error", ex.getMessage()));
        }
    }

        /**
         * Debug endpoint that returns the current SecurityContext authentication
         * information (principal name and granted authorities). Useful to verify
         * whether the JWT filter set the Authentication for the incoming request.
         */
        @GetMapping("/debug/whoami")
        public ResponseEntity<?> debugWhoAmI() {
        var auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(Map.of("authenticated", false));
        }

        var authorities = auth.getAuthorities() == null ? java.util.List.of() :
            auth.getAuthorities().stream().map(Object::toString).collect(Collectors.toList());

        return ResponseEntity.ok(Map.of(
            "authenticated", auth.isAuthenticated(),
            "principal", auth.getName(),
            "authorities", authorities
        ));
        }

    // ---------- Helpers ----------
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
