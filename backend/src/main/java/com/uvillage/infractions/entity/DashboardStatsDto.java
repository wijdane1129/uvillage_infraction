package com.uvillage.infractions.entity;
import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.*;
import java.util.*;
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DashboardStatsDto {
    private Long totalInfractions;
    private Long resolvedInfractions;
    private Map<String,Long> monthlyInfractions;
    private List<TypeDistributionDTO> typeDistribution;
    private Map<String,Long> zoneInfractins;

    @Data
    @Builder
    public static class TypeDistributionDTO{
        private String type;
        private Long count;
        private String color;
    }



    
}
