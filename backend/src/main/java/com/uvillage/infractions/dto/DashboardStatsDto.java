package com.uvillage.infractions.dto;

import lombok.Builder;
import lombok.Data;

import java.util.List;
import java.util.Map;

@Data
@Builder
public class DashboardStatsDto {
    private int totalInfractions;
    private int resolvedInfractions;
    private Map<String, Integer> monthlyInfractions;
    private List<TypeDistribution> typeDistribution;
    private Map<String, Integer> zoneInfractions;

    @Data
    @Builder
    public static class TypeDistribution {
        private String type;
        private int count;

        public TypeDistribution(String type, int count) {
            this.type = type;
            this.count = count;
        }
    }
}
