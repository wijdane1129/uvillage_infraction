package com.uvillage.infractions.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.AuthenticationException;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.uvillage.infractions.dto.LoginRequest;
import com.uvillage.infractions.dto.LoginResponse;
import com.uvillage.infractions.service.AuthService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
// Lombok's @RequiredArgsConstructor removed; explicit constructor provided below

/**
 * Contrôleur REST pour la gestion de l'authentification (connexion).
 */
@RestController
@RequestMapping("/api/v1/auth")
@Tag(name = "Authentication", description = "Endpoints pour la connexion et l'inscription")
public class AuthController {

    private final AuthService authService;
    private static final Logger log = LoggerFactory.getLogger(AuthController.class);

    /**
     * Explicit constructor to satisfy IDEs/language servers that do not
     * process Lombok's @RequiredArgsConstructor. Spring will use this
     * constructor to inject the AuthService.
     */
    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    /**
     * Endpoint POST pour la connexion de l'utilisateur.
     * Accessible à l'adresse: /api/v1/auth/login
     */
    @Operation(summary = "Connexion utilisateur", description = "Authentifie un utilisateur et retourne un jeton JWT.")
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
}
