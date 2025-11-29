package com.uvillage.infractions.dto;

import java.util.List;
import java.util.Map;

/**
 * Plain Java DTO for dashboard statistics with manual builder.
 */
public class DashboardStatsDto {
    private int totalInfractions;
    private int resolvedInfractions;
    private Map<String, Integer> monthlyInfractions;
    private List<TypeDistribution> typeDistribution;
    private Map<String, Integer> zoneInfractions;

    public DashboardStatsDto() {}

    public DashboardStatsDto(int totalInfractions, int resolvedInfractions, Map<String, Integer> monthlyInfractions,
                             List<TypeDistribution> typeDistribution, Map<String, Integer> zoneInfractions) {
        this.totalInfractions = totalInfractions;
        this.resolvedInfractions = resolvedInfractions;
        this.monthlyInfractions = monthlyInfractions;
        this.typeDistribution = typeDistribution;
        this.zoneInfractions = zoneInfractions;
    }

    public int getTotalInfractions() { return totalInfractions; }
    public void setTotalInfractions(int totalInfractions) { this.totalInfractions = totalInfractions; }
    public int getResolvedInfractions() { return resolvedInfractions; }
    public void setResolvedInfractions(int resolvedInfractions) { this.resolvedInfractions = resolvedInfractions; }
    public Map<String, Integer> getMonthlyInfractions() { return monthlyInfractions; }
    public void setMonthlyInfractions(Map<String, Integer> monthlyInfractions) { this.monthlyInfractions = monthlyInfractions; }
    public List<TypeDistribution> getTypeDistribution() { return typeDistribution; }
    public void setTypeDistribution(List<TypeDistribution> typeDistribution) { this.typeDistribution = typeDistribution; }
    public Map<String, Integer> getZoneInfractions() { return zoneInfractions; }
    public void setZoneInfractions(Map<String, Integer> zoneInfractions) { this.zoneInfractions = zoneInfractions; }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private int totalInfractions;
        private int resolvedInfractions;
        private Map<String, Integer> monthlyInfractions;
        private List<TypeDistribution> typeDistribution;
        private Map<String, Integer> zoneInfractions;

        public Builder totalInfractions(int v) { this.totalInfractions = v; return this; }
        public Builder resolvedInfractions(int v) { this.resolvedInfractions = v; return this; }
        public Builder monthlyInfractions(Map<String, Integer> m) { this.monthlyInfractions = m; return this; }
        public Builder typeDistribution(List<TypeDistribution> l) { this.typeDistribution = l; return this; }
        public Builder zoneInfractions(Map<String, Integer> z) { this.zoneInfractions = z; return this; }

        public DashboardStatsDto build() {
            return new DashboardStatsDto(totalInfractions, resolvedInfractions, monthlyInfractions, typeDistribution, zoneInfractions);
        }
    }

    public static class TypeDistribution {
        private String type;
        private int count;

        public TypeDistribution() {}

        public TypeDistribution(String type, int count) { this.type = type; this.count = count; }

        public String getType() { return type; }
        public void setType(String type) { this.type = type; }
        public int getCount() { return count; }
        public void setCount(int count) { this.count = count; }
    }
}
