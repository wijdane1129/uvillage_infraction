package com.uvillage.infractions.controller;

import com.uvillage.infractions.service.ClasserSansSuiteService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/contravention")
public class ClasserSansSuiteController {

    private static final Logger logger = LoggerFactory.getLogger(ClasserSansSuiteController.class);

    private final ClasserSansSuiteService classerSansSuiteService;

    public ClasserSansSuiteController(ClasserSansSuiteService classerSansSuiteService) {
        this.classerSansSuiteService = classerSansSuiteService;
    }

    @PutMapping("/classer-sans-suite/{ref}")
    public ResponseEntity<?> classerSansSuite(@PathVariable String ref, @RequestBody(required = false) Map<String, String> payload) {
        String motif = null;
        if (payload != null) motif = payload.get("motif");
        try {
            classerSansSuiteService.classerSansSuite(ref, motif);
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
