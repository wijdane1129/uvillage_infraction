package com.uvillage.infractions.service;

import com.uvillage.infractions.dto.DashboardStatsDto;
import com.uvillage.infractions.repository.DashboardRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class DashboardService {
    private final DashboardRepository dashboardRepository;

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
}
