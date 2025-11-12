package com.uvillage.infractions.controller;

import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.uvillage.infractions.dto.ContraventionDTO;
import com.uvillage.infractions.service.ContraventionService;

@RestController
@RequestMapping("/api/v1/contraventions")
public class ContraventionController {

    private final ContraventionService contraventionService;

    public ContraventionController(ContraventionService contraventionService) {
        this.contraventionService = contraventionService;
    }

    // Endpoint pour l'historique : GET /api/v1/contraventions/history/{agentRowid}
    @GetMapping("/history/{agentRowid}")
    public ResponseEntity<List<ContraventionDTO>> getInfractionsHistoryByAgent(@PathVariable Long agentRowid) {
        List<ContraventionDTO> infractions = contraventionService.getInfractionsHistoryByAgent(agentRowid);
        return ResponseEntity.ok(infractions);
    }

    // Endpoint pour les statistiques : GET /api/v1/contraventions/stats/{agentRowid}
    @GetMapping("/stats/{agentRowid}")
    public ResponseEntity<Map<String, Integer>> getInfractionStatsForAgent(@PathVariable Long agentRowid) {
        Map<String, Integer> stats = contraventionService.getInfractionStatsForAgent(agentRowid);
        return ResponseEntity.ok(stats);
    }
}