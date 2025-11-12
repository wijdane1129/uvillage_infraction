package com.uvillage.infractions.config;

import java.util.List;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
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
        // Ant-style patterns: utilisez '*' pour tous ports
        configuration.setAllowedOriginPatterns(List.of("http://localhost:*", "http://127.0.0.1:*"));
        configuration.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        configuration.setAllowedHeaders(List.of("*"));
        configuration.setAllowCredentials(true);
        configuration.setExposedHeaders(List.of("Authorization"));

        configuration.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .cors(cors -> cors.configurationSource(corsConfigurationSource()))
                .csrf(AbstractHttpConfigurer::disable)
                
                // Configurer les autorisations
                .authorizeHttpRequests(auth -> auth
                        // Autoriser les requêtes preflight OPTIONS partout
                        .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()
                        
                        // Autoriser les endpoints de connexion et Swagger
                        .requestMatchers("/api/v1/auth/login",
                                         "/api/v1/auth/authenticate",
                                         "/api/v1/auth/register",
                                         "/swagger-ui/**", "/v3/api-docs/**").permitAll()
                        
                        // 🚨 CORRECTION : Autoriser l'accès aux endpoints de stats/historique
                        // 1. Endpoint /stats (si existait séparément)
                        .requestMatchers("/api/v1/stats") 
                            .hasAnyRole("AGENT", "RESPONSABLE", "ADMIN") 

                        // 2. Endpoints /contraventions/* (history, stats)
                        .requestMatchers("/api/v1/contraventions/history/**", 
                                         "/api/v1/contraventions/stats/**")
                            .hasAnyRole("AGENT", "RESPONSABLE", "ADMIN") 
                        
                        // Tous les autres chemins nécessitent une authentification
                        .anyRequest().authenticated()
                )
                
                // ... (reste de la configuration : sessionManagement, etc.) ...
                
                .authenticationProvider(authenticationProvider)
                .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);
                
        return http.build();
    }
}