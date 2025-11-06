package com.uvillage.infractions.service;

import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import com.uvillage.infractions.dto.LoginRequest;
import com.uvillage.infractions.dto.LoginResponse;
import com.uvillage.infractions.entity.User;
import com.uvillage.infractions.repository.UserRepository;
import com.uvillage.infractions.security.JwtUtils;

// Lombok's @RequiredArgsConstructor removed because an explicit constructor is provided
// to satisfy IDEs/language servers that may not run annotation processing.

/**
 * Service pour la gestion de l'authentification (login).
 */
@Service
public class AuthService {

    private final AuthenticationManager authenticationManager;
    private final JwtUtils jwtUtils;
    private final UserRepository userRepository;

    /**
     * Explicit constructor to satisfy IDEs / language servers that do not
     * process Lombok's @RequiredArgsConstructor. Spring will use this
     * constructor to inject the required beans.
     */
    public AuthService(AuthenticationManager authenticationManager, JwtUtils jwtUtils, UserRepository userRepository) {
        this.authenticationManager = authenticationManager;
        this.jwtUtils = jwtUtils;
        this.userRepository = userRepository;
    }

    /**
     * Authentifie l'utilisateur et génère un jeton JWT.
     * @param request Les informations de connexion (email, mot de passe).
     * @return LoginResponse contenant le jeton.
     * @throws AuthenticationException Si l'authentification échoue.
     */
    public LoginResponse authenticateUser(LoginRequest request) throws AuthenticationException {
        // 1. Authentifier l'utilisateur via le AuthenticationManager
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getEmail(), // Email est le username
                        request.getPassword()
                )
        );

        // 2. Récupérer le UserDetails depuis l'objet Authentication renvoyé par Spring
        Object principal = authentication.getPrincipal();
        org.springframework.security.core.userdetails.UserDetails userDetails;
        if (principal instanceof org.springframework.security.core.userdetails.UserDetails) {
            userDetails = (org.springframework.security.core.userdetails.UserDetails) principal;
        } else {
            // Fallback: charger depuis la base si pour une raison quelconque le principal n'est pas un UserDetails
            User user = userRepository.findByEmail(request.getEmail())
                    .orElseThrow(() -> new UsernameNotFoundException("Utilisateur non trouvé après authentification."));
            userDetails = org.springframework.security.core.userdetails.User.builder()
                    .username(user.getEmail() != null ? user.getEmail() : user.getUsername())
                    .password(user.getPassword())
                    .roles(user.getRole() != null ? user.getRole().name() : "AGENT")
                    .build();
        }

        // 3. Générer le jeton JWT en utilisant l'instance UserDetails
        final String jwt = jwtUtils.generateToken(userDetails);

        // 4. Renvoyer la réponse
        return new LoginResponse(jwt, "Bearer", userDetails.getUsername());
    }
}
