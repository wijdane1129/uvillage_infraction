package com.uvillage.infractions.service;

import com.uvillage.infractions.entity.Contravention;
import com.uvillage.infractions.repository.ContraventionRepository;
import org.springframework.stereotype.Service;

@Service
public class ClasserSansSuiteService {

    private final ContraventionRepository contraventionRepository;

    public ClasserSansSuiteService(ContraventionRepository contraventionRepository) {
        this.contraventionRepository = contraventionRepository;
    }

    public void classerSansSuite(String ref, String motif) {
        Contravention contravention = contraventionRepository.findByRef(ref).orElse(null);
        if (contravention == null) {
            throw new IllegalArgumentException("Contravention not found: " + ref);
        }

        // Update status to CLASSEE_SANS_SUITE (matching Contravention.Status enum)
        contravention.setStatut(Contravention.Status.CLASSEE_SANS_SUITE);

        // Append motif to description so we don't rely on a missing field
        if (motif != null && !motif.isBlank()) {
            String prev = contravention.getDescription() == null ? "" : contravention.getDescription();
            String updated = prev.isEmpty() ? "Classement motif: " + motif : prev + "\nClassement motif: " + motif;
            contravention.setDescription(updated);
        }

        contraventionRepository.save(contravention);
    }
}