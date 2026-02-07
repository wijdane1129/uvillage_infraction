package com.uvillage.infractions.controller;

import com.uvillage.infractions.dto.ContraventionDTO;
import com.uvillage.infractions.dto.CreateContraventionRequest;
import com.uvillage.infractions.repository.*;
import com.uvillage.infractions.service.ContraventionService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.security.access.prepost.PreAuthorize;

import java.net.URI;
import java.security.Principal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/v1/contraventions")
public class ContraventionController {

    private static final Logger logger = LoggerFactory.getLogger(ContraventionController.class);

    private final ContraventionService contraventionService;
    private final UserRepository userRepository;
    private final ContraventionTypeRepository typeRepo;
    private final ResidentRepository residentRepository;
    private final ContraventionRepository contraventionRepository;

    public ContraventionController(
            ContraventionService contraventionService,
            UserRepository userRepository,
            ContraventionTypeRepository typeRepo,
            ResidentRepository residentRepository,
            ContraventionRepository contraventionRepository
    ) {
        this.contraventionService = contraventionService;
        this.userRepository = userRepository;
        this.typeRepo = typeRepo;
        this.residentRepository = residentRepository;
        this.contraventionRepository = contraventionRepository;
    }

    // ---------- History ----------
    @GetMapping("/history/{agentRowid}")
    public ResponseEntity<List<ContraventionDTO>> getInfractionsHistoryByAgent(@PathVariable Long agentRowid) {
        List<ContraventionDTO> infractions = contraventionService.getInfractionsHistoryByAgent(agentRowid);
        return ResponseEntity.ok(infractions);
    }

    // ---------- Stats ----------
    @GetMapping("/stats/{agentRowid}")
    public ResponseEntity<Map<String, Integer>> getInfractionStatsForAgent(@PathVariable Long agentRowid) {
        Map<String, Integer> stats = contraventionService.getInfractionStatsForAgent(agentRowid);
        return ResponseEntity.ok(stats);
    }

    // ---------- Create ----------
    @PostMapping
    public ResponseEntity<ContraventionDTO> createContravention(@RequestBody CreateContraventionRequest req) {
        ContraventionDTO created = contraventionService.createContravention(
                req, this.userRepository, this.typeRepo,
                this.residentRepository, this.contraventionRepository
        );

        URI location = URI.create("/api/v1/contraventions/ref/" + (created != null ? created.getRef() : ""));
        return ResponseEntity.created(location).body(created);
    }

    // ---------- Get by reference ----------
    @GetMapping("/ref/{ref}")
    public ResponseEntity<?> getByRef(@PathVariable String ref) {
        try {
            ContraventionDTO dto = contraventionService.getByRef(ref);
            if (dto == null) return ResponseEntity.notFound().build();
            return ResponseEntity.ok(dto);
        } catch (Exception ex) {
            logger.error("Error fetching contravention {}", ref, ex);
            return ResponseEntity.status(500).body(Map.of("success", false, "message", "Internal error"));
        }
    }

    // ---------- Confirm contravention ----------
    @PostMapping("/ref/{ref}/confirm")
    @PreAuthorize("hasRole('RESPONSABLE')")
    public ResponseEntity<?> confirmContravention(
            @PathVariable String ref,
            @RequestParam(required = false) String numeroChambre,
            @RequestParam(required = false) String batiment) {
        try {
            logger.info("Confirming contravention with ref: {}", ref);
            ContraventionDTO dto = contraventionService.confirmContravention(ref, numeroChambre, batiment);
            logger.info("Contravention {} confirmed successfully", ref);

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Contravention confirmée et facture générée");
            response.put("contravention", dto);

            return ResponseEntity.ok(response);

        } catch (RuntimeException ex) {
            logger.error("Contravention not found: {}", ref, ex);
            return ResponseEntity.status(404).body(Map.of(
                    "success", false,
                    "message", "Contravention non trouvée: " + ex.getMessage()
            ));
        } catch (Exception ex) {
            logger.error("Error confirming contravention {}", ref, ex);
            return ResponseEntity.status(500).body(Map.of(
                    "success", false,
                    "message", "Erreur lors de la confirmation: " + ex.getClass().getSimpleName() + " - " + ex.getMessage()
            ));
        }
    }

    // ---------- Contravention types ----------
    @GetMapping("/types")
    public ResponseEntity<List<String>> getAllContraventionTypeLabels() {
        List<String> labels = typeRepo.findAll()
                .stream()
                .map(type -> type.getLabel())
                .collect(Collectors.toList());
        return ResponseEntity.ok(labels);
    }

    // ---------- Debug ----------
    @GetMapping("/debug/whoami")
    public ResponseEntity<?> whoAmI(Principal principal) {
        if (principal == null) {
            return ResponseEntity.status(401).body(Map.of("authenticated", false));
        }
        var auth = org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication();
        Object authorities = auth != null ? auth.getAuthorities() : null;
        return ResponseEntity.ok(Map.of(
                "authenticated", true,
                "principal", principal.getName(),
                "authorities", authorities
        ));
    }

    // ---------- By resident ----------
    @GetMapping("/resident/{residentId}")
    public ResponseEntity<List<ContraventionDTO>> getContraventionsByResident(@PathVariable Long residentId) {
        logger.info("🎯 [RESIDENT] Endpoint called for resident ID: {}", residentId);
        try {
            List<ContraventionDTO> dtos = contraventionService.getContraventionsByResident(residentId);
            logger.info("✅ [RESIDENT] Returning {} contraventions for resident {}", dtos.size(), residentId);
            return ResponseEntity.ok(dtos);
        } catch (Exception ex) {
            logger.error("Error fetching contraventions for resident {}", residentId, ex);
            return ResponseEntity.status(500).build();
        }
    }
}
