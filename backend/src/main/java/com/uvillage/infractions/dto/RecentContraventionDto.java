package com.uvillage.infractions.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RecentContraventionDto {
    private Long rowid;
    private String ref;
    private String motif;
    private String description;
    private LocalDate dateCreation;
    private String statut;
    private String agentName;
    private String residentName;
    private Double montantAmende; // if applicable
}
