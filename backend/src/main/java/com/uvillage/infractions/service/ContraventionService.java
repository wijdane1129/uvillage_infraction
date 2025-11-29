// Fichier : src/main/java/com/uvillage/infractions/service/ContraventionService.java
package com.uvillage.infractions.service;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.temporal.TemporalAdjusters;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.uvillage.infractions.dto.ContraventionDTO;
import com.uvillage.infractions.repository.ContraventionRepository;

@Service
public class ContraventionService {
    // ... (Reste de la classe)

    
    private final ContraventionRepository contraventionRepository;

    public ContraventionService(ContraventionRepository contraventionRepository) {
        this.contraventionRepository = contraventionRepository;
    }

    // Récupère l'historique des infractions de l'agent
    public List<ContraventionDTO> getInfractionsHistoryByAgent(Long agentRowid) {
        return contraventionRepository.findByUserAuthor_IdOrderByDateCreationDesc(agentRowid)
                .stream()
                .map(ContraventionDTO::fromEntity) // Assurez-vous d'avoir adapté ContraventionDTO
                .collect(Collectors.toList());
    }

    // Calcule les statistiques Jour/Semaine
    public Map<String, Integer> getInfractionStatsForAgent(Long agentRowid) {
        LocalDate today = LocalDate.now();
        // Debug: log the agentRowid and today value
        System.out.println("[DEBUG] Stats calculation for agentRowid=" + agentRowid + ", today=" + today);

        // Définition de la semaine (Lundi à Dimanche)
        LocalDate startOfWeek = today.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
        LocalDate endOfWeek = today.with(TemporalAdjusters.nextOrSame(DayOfWeek.SUNDAY));

        // Debug: log week range
        System.out.println("[DEBUG] Week range: " + startOfWeek + " to " + endOfWeek);

        int todayCount = (int) contraventionRepository.countByUserAuthor_IdAndDateCreation(agentRowid, today);
        int weekCount = (int) contraventionRepository.countByUserAuthor_IdAndDateCreationBetween(agentRowid, startOfWeek, endOfWeek);

        // Debug: log query results
        System.out.println("[DEBUG] todayCount=" + todayCount + ", weekCount=" + weekCount);

        Map<String, Integer> stats = new HashMap<>();
        stats.put("todayCount", todayCount);
        stats.put("weekCount", weekCount);
        return stats;
    }

    // Create a new contravention from a simple request payload
    public ContraventionDTO createContravention(com.uvillage.infractions.dto.CreateContraventionRequest req,
                                               com.uvillage.infractions.repository.UserRepository userRepository,
                                               com.uvillage.infractions.repository.ContraventionTypeRepository typeRepo,
                                               com.uvillage.infractions.repository.ResidentRepository residentRepository,
                                               com.uvillage.infractions.repository.ContraventionRepository contraventionRepository) {

        // Basic validation
        if (req == null) throw new IllegalArgumentException("Request null");

        final com.uvillage.infractions.entity.Contravention c = new com.uvillage.infractions.entity.Contravention();
        c.setDescription(req.getDescription());
        c.setDateCreation(java.time.LocalDate.now());
        c.setRef("CV-" + System.currentTimeMillis());

        // userAuthor
        if (req.getUserAuthorId() != null) {
            userRepository.findById(req.getUserAuthorId()).ifPresent(c::setUserAuthor);
        }

        // type (validation explicite)
        if (req.getTypeLabel() != null && !req.getTypeLabel().isEmpty()) {
            var typeOpt = typeRepo.findByLabel(req.getTypeLabel());
            if (typeOpt.isPresent()) {
                c.setTypeContravention(typeOpt.get());
            } else {
                throw new IllegalArgumentException("Type d'infraction inconnu: '" + req.getTypeLabel() + "'. Vérifiez le label envoyé.");
            }
        } else {
            throw new IllegalArgumentException("Le champ typeLabel est obligatoire.");
        }

        // tiers/resident
        if (req.getTiersId() != null) {
            residentRepository.findById(req.getTiersId()).ifPresent(c::setTiers);
        }

        // Save contravention (cascade will handle media if provided later)
        final com.uvillage.infractions.entity.Contravention saved = contraventionRepository.save(c);

        return ContraventionDTO.fromEntity(saved);
    }

        // (Removed invalid Dart/Flutter code accidentally pasted here)
}