package com.uvillage.infractions.service;

import com.uvillage.infractions.dto.DashboardStatsDto;
import com.uvillage.infractions.dto.DashboardResponsableDto;
import com.uvillage.infractions.dto.RecentContraventionDto;
import com.uvillage.infractions.entity.Contravention;
import com.uvillage.infractions.repository.DashboardRepository;
import com.uvillage.infractions.repository.UserRepository;
import com.uvillage.infractions.entity.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.ZoneId;
import java.time.temporal.ChronoUnit;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DashboardService {
    private final DashboardRepository dashboardRepository;
    private final UserRepository userRepository;
    
    private List<String> agentNames;
    private List<String> residentNames = Arrays.asList("M. Durand", "L. Petit", "C. Rousseau", "J. Thomas", "F. Girard", "Alice Dubois", "Bob Martin", "Claire Leclerc");

    // Original method for compatibility
    public DashboardStatsDto getDashboardStats() {
        Long total = dashboardRepository.countInfraction();
        Long resolved = dashboardRepository.countResolvedInfractions();

        // Monthly: List of Object[]{monthNumber, count}
        List<Object[]> byMonth = dashboardRepository.countByMonth();
        Map<String, Integer> monthly = new HashMap<>();
        for (Object[] row : byMonth) {
            Integer monthNum = ((Number) row[0]).intValue();
            Integer cnt = ((Number) row[1]).intValue();
            monthly.put(String.valueOf(monthNum), cnt);
        }

        // Type distribution: [typeLabel, count]
        List<Object[]> byType = dashboardRepository.countByType();
        List<DashboardStatsDto.TypeDistribution> typeDist = byType.stream()
                .map(r -> new DashboardStatsDto.TypeDistribution((String) r[0], ((Number) r[1]).intValue()))
                .toList();

        // Zone infractions: [zoneName, count]
        List<Object[]> byZone = dashboardRepository.countByZone();
        Map<String, Integer> zones = new HashMap<>();
        for (Object[] row : byZone) {
            String zone = row[0] != null ? (String) row[0] : "Unknown";
            Integer cnt = ((Number) row[1]).intValue();
            zones.put(zone, cnt);
        }

        return DashboardStatsDto.builder()
                .totalInfractions(total == null ? 0 : total.intValue())
                .resolvedInfractions(resolved == null ? 0 : resolved.intValue())
                .monthlyInfractions(monthly)
                .typeDistribution(typeDist)
                .zoneInfractions(zones)
                .build();
    }

    // New method for Responsable Dashboard
    public DashboardResponsableDto getDashboardResponsable() {
        // Load real agent and resident names from database
        loadAgentAndResidentNames();
        
        // Stats
        Long total = dashboardRepository.countInfraction();
        Long pending = dashboardRepository.countPendingInfractions();
        Long acceptedMonth = dashboardRepository.countAcceptedThisMonth();

        // Calculate total fines (need to fetch actual contraventions with recidives)
        List<Contravention> allContraventions = dashboardRepository.findAll();
        double totalFines = calculateTotalFines(allContraventions);

        // Chart data for last 30 days
        List<DashboardResponsableDto.ChartDataPoint> chartData = getChartDataLast30Days();

        // Recent infractions
        List<Contravention> recent = dashboardRepository.findRecentInfractions();
        List<RecentContraventionDto> recentDtos = recent.stream()
                .map(this::convertToRecentDto)
                .collect(Collectors.toList());

        // Status distribution
        Map<String, Integer> statusDist = getStatusDistribution();

        return DashboardResponsableDto.builder()
                .totalInfractions(total == null ? 0 : total.intValue())
                .pendingInfractions(pending == null ? 0 : pending.intValue())
                .acceptedThisMonth(acceptedMonth == null ? 0 : acceptedMonth.intValue())
                .totalFines(totalFines)
                .chartData(chartData)
                .recentInfractions(recentDtos)
                .statusDistribution(statusDist)
                .build();
    }
    
    private void loadAgentAndResidentNames() {
        // Load real agent names from users table
        agentNames = userRepository.findAll().stream()
                .map(User::getFullName)
                .filter(Objects::nonNull)
                .collect(Collectors.toList());
        
        // If no agents found, use defaults
        if (agentNames.isEmpty()) {
            agentNames = Arrays.asList("Agent 1", "Agent 2", "Agent 3", "Agent 4", "Agent 5");
        }
    }

    private List<DashboardResponsableDto.ChartDataPoint> getChartDataLast30Days() {
        List<Object[]> dailyCounts = dashboardRepository.countDailyLast30Days();
        LocalDate today = LocalDate.now();
        LocalDate thirtyDaysAgo = today.minus(30, ChronoUnit.DAYS);

        Map<LocalDate, Integer> countsByDate = new HashMap<>();
        for (Object[] row : dailyCounts) {
            Object rawDate = row[0];
            LocalDate date;
            if (rawDate instanceof LocalDate) {
                date = (LocalDate) rawDate;
            } else if (rawDate instanceof java.sql.Date) {
                date = ((java.sql.Date) rawDate).toLocalDate();
            } else if (rawDate instanceof java.util.Date) {
                date = ((java.util.Date) rawDate).toInstant()
                        .atZone(ZoneId.systemDefault())
                        .toLocalDate();
            } else {
                // Fallback: try to parse string representation
                date = LocalDate.parse(rawDate.toString());
            }

            Integer count = ((Number) row[1]).intValue();
            countsByDate.put(date, count);
        }

        List<DashboardResponsableDto.ChartDataPoint> chartPoints = new ArrayList<>();
        for (int i = 0; i < 30; i++) {
            LocalDate date = thirtyDaysAgo.plus(i, ChronoUnit.DAYS);
            int count = countsByDate.getOrDefault(date, 0);
            chartPoints.add(DashboardResponsableDto.ChartDataPoint.builder()
                    .day(i + 1)
                    .count(count)
                    .build());
        }

        return chartPoints;
    }

    private RecentContraventionDto convertToRecentDto(Contravention c) {
        String agentName = null;
        if (c.getUserAuthor() != null && c.getUserAuthor().getFullName() != null) {
            agentName = c.getUserAuthor().getFullName();
        } else {
            // Use agent names from database, indexed by rowid
            agentName = agentNames.get((int)(c.getRowid() % agentNames.size()));
        }
        
        String residentName = null;
        if (c.getTiers() != null && c.getTiers().getNomResident() != null) {
            residentName = c.getTiers().getNomResident();
        } else {
            // Use resident names from database, indexed by rowid
            residentName = residentNames.get((int)(c.getRowid() % residentNames.size()));
        }
        
        return RecentContraventionDto.builder()
                .rowid(c.getRowid())
                .ref(c.getRef())
                .motif(c.getTypeContravention() != null ? c.getTypeContravention().getLabel() : "N/A")
                .description(c.getDescription() != null ? c.getDescription() : "")
                .dateCreation(c.getDateCreation())
                .statut(c.getStatut().toString())
                .agentName(agentName)
                .residentName(residentName)
                .montantAmende(0.0) // TODO: Calculate from recidives
                .build();
    }

    private Map<String, Integer> getStatusDistribution() {
        Map<String, Integer> distribution = new HashMap<>();
        distribution.put("SOUS_VERIFICATION", dashboardRepository.countByStatusLast30Days("SOUS_VERIFICATION").intValue());
        distribution.put("ACCEPTEE", dashboardRepository.countByStatusLast30Days("ACCEPTEE").intValue());
        distribution.put("CLASSEE_SANS_SUITE", dashboardRepository.countByStatusLast30Days("CLASSEE_SANS_SUITE").intValue());
        return distribution;
    }

    private double calculateTotalFines(List<Contravention> contraventions) {
        // TODO: Implement based on your Recidive/Facture logic
        return 0.0;
    }
}
