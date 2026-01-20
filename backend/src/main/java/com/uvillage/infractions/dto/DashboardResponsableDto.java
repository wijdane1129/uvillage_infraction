package com.uvillage.infractions.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DashboardResponsableDto {
    // Statistics
    private int totalInfractions;
    private int pendingInfractions;
    private int acceptedThisMonth;
    private double totalFines;

    // Chart data (30 days evolution)
    private List<ChartDataPoint> chartData;

    // Recent infractions
    private List<RecentContraventionDto> recentInfractions;

    // Status distribution
    private Map<String, Integer> statusDistribution;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ChartDataPoint {
        private int day;
        private int count;
    }
}
