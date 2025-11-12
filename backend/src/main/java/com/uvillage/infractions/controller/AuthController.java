package com.uvillage.infractions.controller;

import com.uvillage.infractions.dto.LoginRequest;
import com.uvillage.infractions.dto.LoginResponse;
import com.uvillage.infractions.entity.User;
import com.uvillage.infractions.repository.UserRepository;
import com.uvillage.infractions.security.JwtUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

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

    private static final Logger logger = LoggerFactory.getLogger(AuthController.class);

    private final AuthenticationManager authenticationManager;
    private final JwtUtils jwtUtils;
    private final UserRepository userRepository;

    public AuthController(AuthenticationManager authenticationManager,
                         JwtUtils jwtUtils,
                         UserRepository userRepository) {
        this.authenticationManager = authenticationManager;
        this.jwtUtils = jwtUtils;
        this.userRepository = userRepository;
    }

    /**
     * Endpoint de connexion (login).
     * 
     * @param request Contient email et password
     * @return JWT token + informations utilisateur
     */
    @Operation(summary = "Connexion utilisateur", 
              description = "Authentifie un utilisateur et retourne un jeton JWT avec les informations de l'utilisateur.")
    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequest request) {
        logger.info("[AUTH] Tentative de connexion pour: {}", request.getEmail());

        try {
            // 1. Authentifier l'utilisateur
            Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                    request.getEmail(),
                    request.getPassword()
                )
            );

            // 2. Récupérer les détails de l'utilisateur
            UserDetails userDetails = (UserDetails) authentication.getPrincipal();
            
            // 3. Générer le token JWT
            String token = jwtUtils.generateToken(userDetails);
            
            // 4. Récupérer l'utilisateur complet depuis la base de données
            User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("Utilisateur introuvable"));
            
            // 5. Construire le nom complet
            String nomComplet = (user.getPrenom() != null && user.getNom() != null)
                ? user.getPrenom() + " " + user.getNom()
                : user.getUsername();
            
            // 6. Créer la réponse avec TOUTES les informations nécessaires
            LoginResponse response = LoginResponse.builder()
                .token(token)
                .email(user.getEmail())
                .agentRowid(user.getRowid())
                .nomComplet(nomComplet)
                .role(user.getRole().name())
                .build();

            logger.info("[AUTH] ✅ Connexion réussie pour: {} (ID: {}, Role: {})", 
                user.getEmail(), user.getRowid(), user.getRole());

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
}
