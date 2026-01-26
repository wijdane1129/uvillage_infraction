package com.uvillage.infractions.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;
import java.util.Map;

/**
 * Contrôleur pour gérer l'historique (History) des infractions des agents.
 * Chemin d'accès: /api/v1/contravention/history/{agentId}
 */
@RestController
@RequestMapping("/api/v1/contravention/history")
public class HistoryController {

    private static final Logger logger = LoggerFactory.getLogger(HistoryController.class);

    // Suppression de la référence à ContraventionService non existant

    /**
     * Récupère l'historique des infractions pour un agent spécifique.
     * @param agentId L'identifiant de l'agent demandé dans l'URL.
     * @param authentication Informations d'authentification de l'utilisateur.
     * @return Une liste des infractions de l'agent.
     */
    @GetMapping("/{agentId}")
    public ResponseEntity<?> getAgentHistory(@PathVariable Integer agentId,
                                            Authentication authentication) {
        
        String authenticatedUsername = authentication.getName();
        
        logger.info("Tentative de récupération de l'historique pour l'agent ID: {} par l'utilisateur: {}", agentId, authenticatedUsername);

        // 2. Logique Métier (Données simulées)
        // TODO: Implémenter la récupération réelle de l'historique
        List<Map<String, Object>> mockHistory = List.of(
            Map.ofEntries(
                Map.entry("ref", "REF-001"),
                Map.entry("statut", "SOUS_VERIFICATION"),
                Map.entry("dateHeure", "14/03/24 22:30"),
                Map.entry("typeContravention", Map.of("label", "Bruit")),
                Map.entry("userAuthor", Map.of("prenom", "Jean", "nom", "Dupont")),
                Map.entry("tiers", Map.of("prenom", "Marie", "nom", "Martin"))
            ),
            Map.ofEntries(
                Map.entry("ref", "REF-002"),
                Map.entry("statut", "ACCEPTEE"),
                Map.entry("dateHeure", "13/03/24 18:00"),
                Map.entry("typeContravention", Map.of("label", "Dégradation")),
                Map.entry("userAuthor", Map.of("prenom", "Pierre", "nom", "Bernard")),
                Map.entry("tiers", Map.of("prenom", "Sophie", "nom", "Leclerc"))
            ),
            Map.ofEntries(
                Map.entry("ref", "REF-003"),
                Map.entry("statut", "CLASSEE_SANS_SUITE"),
                Map.entry("dateHeure", "12/03/24 09:15"),
                Map.entry("typeContravention", Map.of("label", "Stationnement")),
                Map.entry("userAuthor", Map.of("prenom", "Claire", "nom", "Robert")),
                Map.entry("tiers", Map.of("prenom", "Luc", "nom", "Garcia"))
            )
        );

        return ResponseEntity.ok(mockHistory);
    }
}