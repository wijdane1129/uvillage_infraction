package com.uvillage.infractions.config;

import java.util.List;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import com.uvillage.infractions.security.JwtAuthenticationFilter;

/**
 * Configuration de la sécurité Spring Boot (JWT Stateless).
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthFilter;
    private final AuthenticationProvider authenticationProvider;

        // Explicit constructor to satisfy IDEs that do not run Lombok annotation processing
        public SecurityConfig(JwtAuthenticationFilter jwtAuthFilter,
                                                  AuthenticationProvider authenticationProvider) {
                this.jwtAuthFilter = jwtAuthFilter;
                this.authenticationProvider = authenticationProvider;
        }

    // Ajout du Bean pour la configuration CORS
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        // En dev, autoriser les origines locales sur n'importe quel port (localhost/127.0.0.1)
        // Utiliser allowedOriginPatterns pour accepter des patterns de ports
        configuration.setAllowedOriginPatterns(List.of("http://localhost:*", "http://127.0.0.1:*"));
        // Autoriser les méthodes courantes (incluant OPTIONS pour le preflight)
        configuration.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        // Autoriser tous les en-têtes
        configuration.setAllowedHeaders(List.of("*"));
        // Autoriser l'envoi de cookies/credentials depuis le front-end si nécessaire
        configuration.setAllowCredentials(true);
        // Exposer l'en-tête d'autorisation (nécessaire pour JWT)
        configuration.setExposedHeaders(List.of("Authorization"));

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        // Appliquer cette configuration à TOUTES les requêtes
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                // Activer CORS en utilisant la source définie ci-dessus
                .cors(cors -> cors.configurationSource(corsConfigurationSource()))
                
                // Désactiver CSRF car nous utilisons des jetons JWT (stateless)
                .csrf(AbstractHttpConfigurer::disable)
                
                // Configurer les autorisations
                .authorizeHttpRequests(auth -> auth
                        // Autoriser les requêtes preflight OPTIONS partout
                        .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()
                        // Autoriser TOUS les endpoints sous /api/v1/auth/ (login, authenticate, register, etc.)
                        .requestMatchers("/api/v1/auth/login",
                                         "/api/v1/auth/authenticate",
                                         "/api/v1/auth/register",
                                "/swagger-ui/**", "/v3/api-docs/**").permitAll() // OpenAPI/Swagger
                        
                        // Tous les autres chemins nécessitent une authentification
                        .anyRequest().authenticated()
                )
                
                // Configurer la gestion des sessions
                .sessionManagement(sess -> sess
                        // Rendre l'application stateless (sans session)
                        .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
                )
                
                // Définir le fournisseur d'authentification personnalisé
                .authenticationProvider(authenticationProvider)
                
                // Ajouter le filtre JWT avant le filtre par défaut
                .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}
