package com.uvillage.infractions.dto;

import com.uvillage.infractions.entity.Contravention;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ContraventionDTO {
    private Long rowid;
    private String ref;
    private LocalDate dateCreation;
    private String description;
    private String statut;
    private String userAuthorName;
    private String tiersName;
    private Long tiersId;
    private String typeContraventionLabel;
    private Long typeContraventionId;
    private Double montantAmende;
    private Long factureId;

    /**
     * Convert a Contravention entity to a ContraventionDTO
     */
    public static ContraventionDTO fromEntity(Contravention entity) {
        if (entity == null) {
            return null;
        }

        return ContraventionDTO.builder()
                .rowid(entity.getRowid())
                .ref(entity.getRef())
                .dateCreation(entity.getDateCreation())
                .description(entity.getDescription())
                .statut(entity.getStatut() != null ? entity.getStatut().toString() : null)
                .userAuthorName(entity.getUserAuthor() != null ? entity.getUserAuthor().getFullName() : null)
                .tiersName(entity.getTiers() != null ? (entity.getTiers().getNom() + " " + entity.getTiers().getPrenom()) : null)
                .tiersId(entity.getTiers() != null ? entity.getTiers().getId() : null)
                .typeContraventionLabel(entity.getTypeContravention() != null ? entity.getTypeContravention().getLabel() : null)
                .typeContraventionId(entity.getTypeContravention() != null ? entity.getTypeContravention().getRowid() : null)
                .factureId(entity.getFacture() != null ? entity.getFacture().getId() : null)
                .build();
    }
}
