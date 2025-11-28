package com.uvillage.infractions.controller;

import com.uvillage.infractions.dto.ContraventionRecedivesDto;
import com.uvillage.infractions.service.ContraventionRecediveSevice;

import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/recidives")
public class ContraventionRecidivesController {

    private static final Logger logger = LoggerFactory.getLogger(ContraventionRecidivesController.class);

    @Autowired
    private ContraventionRecediveSevice contraventionRecediveSevice;
    @Autowired 
    private ContraventionRecediveSevice confirmerAcceptationService;

    @GetMapping("/{label}")
    public ResponseEntity<?> getRecidiveByLabel(@PathVariable("label") String label) {
        try {
            ContraventionRecedivesDto dto = contraventionRecediveSevice.getRecidiveByLabel(label);
            if (dto == null) return ResponseEntity.notFound().build();
            return ResponseEntity.ok(dto);
        } catch (Exception ex) {
            logger.error("Error getting recidive for label {}", label, ex);
            return ResponseEntity.status(500).body("Internal error");
        }
    }
    @PutMapping("/confirmer-acceptation/{ref}")
    public ResponseEntity<?> confirmerAcceptation(@PathVariable String ref, @RequestBody(required = false) Map<String, String> payload) {
        String motif = null;
        if (payload != null) motif = payload.get("motif");
        try {
            confirmerAcceptationService.confirmerAcceptation(ref, motif);
            return ResponseEntity.ok(Map.of("success", true));
        } catch (IllegalArgumentException ex) {
            logger.warn("Classer sans suite failed for {}: {}", ref, ex.getMessage());
            return ResponseEntity.status(404).body(Map.of("success", false, "message", ex.getMessage()));
        } catch (Exception ex) {
            logger.error("Error while classer sans suite for {}", ref, ex);
            return ResponseEntity.status(500).body(Map.of("success", false, "message", "Internal error"));
        }
    }
}
