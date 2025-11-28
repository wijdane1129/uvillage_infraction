package com.uvillage.infractions.dto;
import lombok.*;
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ContraventionRecedivesDto {
    private String label;
    private int nombrerecidive;
    private int montant1;
    private int montant2;
    private int montant3;
    private int montant4;
}
