package com.uvillage.infractions.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Map;

/**
 * Contrôleur pour gérer les statistiques (Stats) des agents.
 * Chemin d'accès: /api/v1/contravention/stats/{agentId}
 */
@RestController
@RequestMapping("/api/v1/contravention/stats")
public class StatsController {

    private static final Logger logger = LoggerFactory.getLogger(StatsController.class);

    // Suppression de la référence à AgentService non existant

    /**
     * Récupère les statistiques pour un agent spécifique.
     * Le chemin doit correspondre à celui protégé dans SecurityConfig.
     * @param agentId L'identifiant de l'agent demandé dans l'URL.
     * @param authentication Informations d'authentification de l'utilisateur.
     * @return Les statistiques de l'agent.
     */
    @GetMapping("/{agentId}")
    public ResponseEntity<?> getAgentStats(@PathVariable Integer agentId, 
                                           Authentication authentication) {
        
        // La ligne suivante démontre la vérification d'autorisation du côté du contrôleur
        // (En plus de la vérification de rôle effectuée par Spring Security).
        String authenticatedUsername = authentication.getName(); // Généralement l'email/username du JWT
        
        // NOTE IMPORTANTE : Nous allons simuler que l'Agent ID correspond au user ID.
        // Si vous avez besoin d'une vérification plus stricte (agent 8 ne voit que ses stats),
        // il faudra coder la recherche de l'ID réel à partir de 'authenticatedUsername'.
        
        logger.info("Tentative de récupération des statistiques pour l'agent ID: {} par l'utilisateur: {}", agentId, authenticatedUsername);

        // 2. Logique Métier (Données simulées)
        // TODO: Implémenter la récupération réelle des données de statistiques
        return ResponseEntity.ok(Map.of(
            "infractions_today", 5,
            "infractions_week", 25,
            "infractions_total", 120
        ));
    }
}