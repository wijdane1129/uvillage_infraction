package com.uvillage.infractions.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ContraventionTypeDTO {
    private Long id;
    private String nom;
    private Double montant1;
    private Double montant2;
    private Double montant3;
    private Double montant4;
    private String description;
    private Long utilisations;
    private String dateCreation;
    private Boolean supprime;

    public static ContraventionTypeDTO fromEntity(com.uvillage.infractions.entity.ContraventionType entity, Long utilisations) {
        return ContraventionTypeDTO.builder()
                .id(entity.getRowid())
                .nom(entity.getLabel())
                .montant1(entity.getMontant1())
                .montant2(entity.getMontant2())
                .montant3(entity.getMontant3())
                .montant4(entity.getMontant4())
                .description(entity.getDescription())
                .utilisations(utilisations)
                .dateCreation(java.time.LocalDateTime.now().toString())
                .supprime(false)
                .build();
    }
}
