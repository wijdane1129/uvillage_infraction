package com.uvillage.infractions.controller;

import com.uvillage.infractions.dto.ContraventionTypeDTO;
import com.uvillage.infractions.entity.ContraventionType;
import com.uvillage.infractions.service.ContraventionTypeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.security.access.prepost.PreAuthorize;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/motifs")
@CrossOrigin(origins = "*", maxAge = 3600)
public class ContraventionTypeController {

    @Autowired
    private ContraventionTypeService contraventionTypeService;

    /**
     * Récupérer tous les motifs
     */
    @GetMapping
    public ResponseEntity<List<ContraventionTypeDTO>> getAllMotifs() {
        try {
            List<ContraventionType> motifs = contraventionTypeService.getAllMotifs();
            List<ContraventionTypeDTO> dtos = motifs.stream()
                    .map(motif -> {
                        long utilisations = contraventionTypeService.countMotifUsages(motif.getRowid());
                        return ContraventionTypeDTO.fromEntity(motif, utilisations);
                    })
                    .collect(Collectors.toList());
            return ResponseEntity.ok(dtos);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Récupérer un motif par ID
     */
    @GetMapping("/{id}")
    public ResponseEntity<ContraventionTypeDTO> getMotifById(@PathVariable Long id) {
        try {
            return contraventionTypeService.getMotifById(id)
                    .map(motif -> {
                        long utilisations = contraventionTypeService.countMotifUsages(motif.getRowid());
                        return ResponseEntity.ok(ContraventionTypeDTO.fromEntity(motif, utilisations));
                    })
                    .orElse(ResponseEntity.notFound().build());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Créer un nouveau motif
     */
    @PostMapping
    @PreAuthorize("hasRole('RESPONSABLE')")
    public ResponseEntity<ContraventionTypeDTO> createMotif(@RequestBody Map<String, Object> request) {
        try {
            String nom = (String) request.get("nom");
            Double montant1 = ((Number) request.get("montant1")).doubleValue();
            Double montant2 = ((Number) request.get("montant2")).doubleValue();
            Double montant3 = ((Number) request.get("montant3")).doubleValue();
            Double montant4 = ((Number) request.get("montant4")).doubleValue();

            if (nom == null || nom.trim().isEmpty()) {
                return ResponseEntity.badRequest().build();
            }

            ContraventionType motif = contraventionTypeService.createMotif(
                    nom,
                    (String) request.getOrDefault("description", ""),
                    montant1,
                    montant2,
                    montant3,
                    montant4
            );

            ContraventionTypeDTO dto = ContraventionTypeDTO.fromEntity(motif, 0L);
            return ResponseEntity.status(HttpStatus.CREATED).body(dto);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Mettre à jour un motif
     */
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('RESPONSABLE')")
    public ResponseEntity<ContraventionTypeDTO> updateMotif(
            @PathVariable Long id,
            @RequestBody Map<String, Object> request) {
        try {
            String nom = (String) request.get("nom");
            Double montant1 = ((Number) request.get("montant1")).doubleValue();
            Double montant2 = ((Number) request.get("montant2")).doubleValue();
            Double montant3 = ((Number) request.get("montant3")).doubleValue();
            Double montant4 = ((Number) request.get("montant4")).doubleValue();

            if (nom == null || nom.trim().isEmpty()) {
                return ResponseEntity.badRequest().build();
            }

            ContraventionType motif = contraventionTypeService.updateMotif(
                    id,
                    nom,
                    (String) request.getOrDefault("description", ""),
                    montant1,
                    montant2,
                    montant3,
                    montant4
            );

            long utilisations = contraventionTypeService.countMotifUsages(motif.getRowid());
            ContraventionTypeDTO dto = ContraventionTypeDTO.fromEntity(motif, utilisations);
            return ResponseEntity.ok(dto);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Supprimer un motif
     */
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('RESPONSABLE')")
    public ResponseEntity<Void> deleteMotif(@PathVariable Long id) {
        try {
            contraventionTypeService.deleteMotif(id);
            return ResponseEntity.noContent().build();
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Rechercher des motifs par nom
     */
    @GetMapping("/search")
    public ResponseEntity<List<ContraventionTypeDTO>> searchMotifs(@RequestParam String q) {
        try {
            List<ContraventionType> motifs = contraventionTypeService.searchMotifs(q);
            List<ContraventionTypeDTO> dtos = motifs.stream()
                    .map(motif -> {
                        long utilisations = contraventionTypeService.countMotifUsages(motif.getRowid());
                        return ContraventionTypeDTO.fromEntity(motif, utilisations);
                    })
                    .collect(Collectors.toList());
            return ResponseEntity.ok(dtos);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Obtenir les statistiques
     */
    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getStats() {
        try {
            List<ContraventionType> motifs = contraventionTypeService.getAllMotifs();
            long totalMotifs = motifs.size();
            double amendeMoyenne = motifs.isEmpty() ? 0 :
                    motifs.stream()
                            .mapToDouble(ContraventionType::getMontant1)
                            .average()
                            .orElse(0.0);

            Map<String, Object> stats = new HashMap<>();
            stats.put("totalMotifs", totalMotifs);
            stats.put("amendeMoyenne", amendeMoyenne);

            return ResponseEntity.ok(stats);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
}
