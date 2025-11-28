package com.uvillage.infractions.controller;

import com.uvillage.infractions.dto.ContraventionDto;
import com.uvillage.infractions.service.ContraventionService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@RestController
@RequestMapping("/api/contravention")
public class ContraventionController {

	private static final Logger logger = LoggerFactory.getLogger(ContraventionController.class);

	private final ContraventionService contraventionService;

	public ContraventionController(ContraventionService contraventionService) {
		this.contraventionService = contraventionService;
	}

	@GetMapping("/{ref}")
	public ResponseEntity<?> getByRef(@PathVariable String ref) {
		try {
			ContraventionDto dto = contraventionService.getByRef(ref);
			if (dto == null) return ResponseEntity.notFound().build();
			return ResponseEntity.ok(dto);
		} catch (Exception ex) {
			logger.error("Error fetching contravention {}", ref, ex);
			return ResponseEntity.status(500).body("Internal error");
		}
	}
}
