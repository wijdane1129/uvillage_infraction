package com.uvillage.infractions.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import com.uvillage.infractions.dto.LoginRequest;
import com.uvillage.infractions.dto.LoginResponse;
import com.uvillage.infractions.entity.User;
import com.uvillage.infractions.repository.UserRepository;
import com.uvillage.infractions.security.JwtUtils;

/**
 * Service pour la gestion de l'authentification (login).
 * Encapsule la logique d'authentification et de génération de token.
 */
@Service
public class AuthService {
    private static final Logger logger = LoggerFactory.getLogger(AuthService.class);

    private final AuthenticationManager authenticationManager;
    private final JwtUtils jwtUtils;
    private final UserRepository userRepository;

    public AuthService(AuthenticationManager authenticationManager, 
                      JwtUtils jwtUtils, 
                      UserRepository userRepository) {
        this.authenticationManager = authenticationManager;
        this.jwtUtils = jwtUtils;
        this.userRepository = userRepository;
    }

    /**
     * Authentifie l'utilisateur et génère un jeton JWT avec les informations complètes.
     * @param request Les informations de connexion (email, mot de passe)
     * @return LoginResponse contenant le token et les informations utilisateur
     * @throws AuthenticationException Si l'authentification échoue
     */
    public LoginResponse authenticateUser(LoginRequest request) throws AuthenticationException {
        logger.debug("[AUTH SERVICE] Tentative d'authentification pour: {}", request.getEmail());

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
            .orElseThrow(() -> new UsernameNotFoundException("Utilisateur introuvable: " + request.getEmail()));
        
        // 5. Construire le nom complet
        String nomComplet = (user.getPrenom() != null && user.getNom() != null)
            ? user.getPrenom() + " " + user.getNom()
            : user.getUsername();

        // 6. Construire et retourner la réponse complète
        LoginResponse response = LoginResponse.builder()
            .token(token)
            .email(user.getEmail())
            .agentRowid(user.getRowid())
            .nomComplet(nomComplet)
            .role(user.getRole().name())
            .build();

        logger.debug("[AUTH SERVICE] Authentification réussie pour: {} (ID: {}, Role: {})", 
            user.getEmail(), user.getRowid(), user.getRole());

        return response;
    }
}
