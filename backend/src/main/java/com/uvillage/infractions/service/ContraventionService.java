// Fichier : src/main/java/com/uvillage/infractions/service/ContraventionService.java
package com.uvillage.infractions.service;

import com.uvillage.infractions.dto.ContraventionDTO;
import com.uvillage.infractions.repository.ContraventionRepository;
import org.springframework.stereotype.Service; 

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.temporal.TemporalAdjusters;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class ContraventionService {
    // ... (Reste de la classe)

    
    private final ContraventionRepository contraventionRepository;

    public ContraventionService(ContraventionRepository contraventionRepository) {
        this.contraventionRepository = contraventionRepository;
    }

    // Récupère l'historique des infractions de l'agent
    public List<ContraventionDTO> getInfractionsHistoryByAgent(Long agentRowid) {
        return contraventionRepository.findByUserAuthor_RowidOrderByDateCreationDesc(agentRowid)
                .stream()
                .map(ContraventionDTO::fromEntity) // Assurez-vous d'avoir adapté ContraventionDTO
                .collect(Collectors.toList());
    }

    // Calcule les statistiques Jour/Semaine
    public Map<String, Integer> getInfractionStatsForAgent(Long agentRowid) {
        LocalDate today = LocalDate.now();
        
        // Définition de la semaine (Lundi à Dimanche)
        LocalDate startOfWeek = today.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
        LocalDate endOfWeek = today.with(TemporalAdjusters.nextOrSame(DayOfWeek.SUNDAY));

        int todayCount = (int) contraventionRepository.countByUserAuthor_RowidAndDateCreation(agentRowid, today);
        int weekCount = (int) contraventionRepository.countByUserAuthor_RowidAndDateCreationBetween(agentRowid, startOfWeek, endOfWeek);

        Map<String, Integer> stats = new HashMap<>();
        stats.put("todayCount", todayCount);
        stats.put("weekCount", weekCount);
        
        return stats;
    }
}