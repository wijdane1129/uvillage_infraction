package com.uvillage.infractions.dto;

import com.uvillage.infractions.entity.Contravention;
import java.time.format.DateTimeFormatter;

/**
 * Contravention DTO implemented without Lombok.
 */
public class ContraventionDTO {
    private String ref;
    private String statut;
    private String dateHeure;
    private ContraventionTypeDTO typeContravention;
    private UserDto userAuthor;
    private TiersDTO tiers;

    public ContraventionDTO() {
    }

    public String getRef() {
        return ref;
    }

    public void setRef(String ref) {
        this.ref = ref;
    }

    public String getStatut() {
        return statut;
    }

    public void setStatut(String statut) {
        this.statut = statut;
    }

    public String getDateHeure() {
        return dateHeure;
    }

    public void setDateHeure(String dateHeure) {
        this.dateHeure = dateHeure;
    }

    public ContraventionTypeDTO getTypeContravention() {
        return typeContravention;
    }

    public void setTypeContravention(ContraventionTypeDTO typeContravention) {
        this.typeContravention = typeContravention;
    }

    public UserDto getUserAuthor() {
        return userAuthor;
    }

    public void setUserAuthor(UserDto userAuthor) {
        this.userAuthor = userAuthor;
    }

    public TiersDTO getTiers() {
        return tiers;
    }

    public void setTiers(TiersDTO tiers) {
        this.tiers = tiers;
    }

    public static ContraventionDTO fromEntity(Contravention contravention) {
        if (contravention == null) return null;
        ContraventionDTO dto = new ContraventionDTO();
        dto.setRef(contravention.getRef());

        Object statutValue = contravention.getStatut();
        dto.setStatut(statutValue != null ? statutValue.toString() : "INCONNU");

        if (contravention.getDateCreation() != null) {
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
            dto.setDateHeure(contravention.getDateCreation().format(formatter));
        } else {
            dto.setDateHeure("Date non définie");
        }

        if (contravention.getTypeContravention() != null) {
            dto.setTypeContravention(ContraventionTypeDTO.fromEntity(contravention.getTypeContravention()));
        }
        if (contravention.getUserAuthor() != null) {
            dto.setUserAuthor(UserDto.fromEntity(contravention.getUserAuthor()));
        }
        dto.setTiers(TiersDTO.fromEntity(contravention.getTiers()));
        return dto;
    }
}