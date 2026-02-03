package com.uvillage.infractions.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

// Cette classe configure CORS (Cross-Origin Resource Sharing) 
// pour permettre aux requêtes provenant du développement Flutter Web (localhost)
// d'atteindre le serveur Spring Boot.
@Configuration
public class CorsConfig implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/v1/**") // Appliquer la règle à tous les endpoints sous /api/v1
                .allowedOriginPatterns(
                    "http://localhost:*", 
                    "http://127.0.0.1:*",
                    "http://192.168.68.119:*"
                )
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS") // Autoriser les méthodes HTTP
                .allowedHeaders("*") // Autoriser tous les headers dans la requête
                .exposedHeaders("Authorization") // Exposer le header Authorization
                .allowCredentials(true); // Autoriser l'envoi de cookies et d'authentification
    }
}