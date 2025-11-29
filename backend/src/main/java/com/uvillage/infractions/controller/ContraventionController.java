package com.uvillage.infractions.controller;

import java.net.URI;
import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.uvillage.infractions.dto.ContraventionDTO;
import com.uvillage.infractions.dto.CreateContraventionRequest;
import com.uvillage.infractions.service.ContraventionService;
import com.uvillage.infractions.repository.UserRepository;
import com.uvillage.infractions.repository.ContraventionTypeRepository;
import com.uvillage.infractions.repository.ResidentRepository;
import com.uvillage.infractions.repository.ContraventionRepository;

@RestController
@RequestMapping("/api/v1/contraventions")
public class ContraventionController {

    private final ContraventionService contraventionService;
    private final UserRepository userRepository;
    private final ContraventionTypeRepository typeRepo;
    private final ResidentRepository residentRepository;
    private final ContraventionRepository contraventionRepository;

    public ContraventionController(ContraventionService contraventionService,
                                  UserRepository userRepository,
                                  ContraventionTypeRepository typeRepo,
                                  ResidentRepository residentRepository,
                                  ContraventionRepository contraventionRepository) {
        this.contraventionService = contraventionService;
        this.userRepository = userRepository;
        this.typeRepo = typeRepo;
        this.residentRepository = residentRepository;
        this.contraventionRepository = contraventionRepository;
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

    // Create a new contravention
    @PostMapping
    public ResponseEntity<ContraventionDTO> createContravention(@RequestBody CreateContraventionRequest req) {
        ContraventionDTO created = contraventionService.createContravention(req, this.userRepository, this.typeRepo,
                this.residentRepository, this.contraventionRepository);
        // Build location URI for created resource (use its rowid if available)
        // ContraventionDTO does not expose the numeric rowid; use the reference instead
        URI location = URI.create("/api/v1/contraventions/ref/" + (created != null ? created.getRef() : ""));
        return ResponseEntity.created(location).body(created);
    }

    // Endpoint pour obtenir tous les labels de types d'infraction
    @GetMapping("/types")
    public ResponseEntity<List<String>> getAllContraventionTypeLabels() {
        List<String> labels = typeRepo.findAll()
            .stream()
            .map(type -> type.getLabel())
            .collect(java.util.stream.Collectors.toList());
        return ResponseEntity.ok(labels);
    }

    // Debug: returns the authenticated principal and authorities for this path
    @GetMapping("/debug/whoami")
    public ResponseEntity<?> whoAmI(java.security.Principal principal) {
        if (principal == null) {
            return ResponseEntity.status(401).body(Map.of("authenticated", false));
        }
        // Include authorities if available
        org.springframework.security.core.Authentication auth = org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication();
        Object authorities = auth != null ? auth.getAuthorities() : null;
        return ResponseEntity.ok(Map.of("authenticated", true, "principal", principal.getName(), "authorities", authorities));
    }
}