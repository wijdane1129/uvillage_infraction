package com.uvillage.infractions.controller;

import com.uvillage.infractions.dto.ContraventionDto;
import com.uvillage.infractions.service.ContraventionService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/contravention")
@CrossOrigin(origins = "*", maxAge = 3600)
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

	/**
	 * Confirme une contravention et génère une facture PDF
	 * @param ref La référence de la contravention
	 * @return La contravention confirmée avec l'URL du PDF généré
	 */
	@PostMapping("/{ref}/confirm")
	public ResponseEntity<?> confirmContravention(@PathVariable String ref) {
		try {
			logger.info("Confirming contravention with ref: {}", ref);
			ContraventionDto dto = contraventionService.confirmContravention(ref);
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
			ex.printStackTrace();
			return ResponseEntity.status(500).body(Map.of(
					"success", false,
					"message", "Erreur lors de la confirmation: " + ex.getClass().getSimpleName() + " - " + ex.getMessage()
			));
		}
	}
}

