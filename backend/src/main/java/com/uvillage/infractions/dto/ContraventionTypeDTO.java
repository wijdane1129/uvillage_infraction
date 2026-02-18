package com.uvillage.infractions.dto;

import com.uvillage.infractions.entity.ContraventionType;
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
    private String nom;           // Corresponds to label
    private Double montant1;
    private Double montant2;
    private Double montant3;
    private Double montant4;
    private String description;
    private Long utilisations;
    private String dateCreation;
    private Boolean supprime;

    // Minimal mapping from entity (includes montants for resident history)
    public static ContraventionTypeDTO fromEntity(ContraventionType type) {
        return type == null ? null : ContraventionTypeDTO.builder()
                .id(type.getRowid())
                .nom(type.getLabel())
                .montant1(type.getMontant1())
                .montant2(type.getMontant2())
                .montant3(type.getMontant3())
                .montant4(type.getMontant4())
                .build();
    }

    // Full mapping with utilisations
    public static ContraventionTypeDTO fromEntity(ContraventionType entity, Long utilisations) {
        if (entity == null) return null;
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
