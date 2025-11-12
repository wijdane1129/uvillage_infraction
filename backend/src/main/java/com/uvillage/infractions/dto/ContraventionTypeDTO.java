// Fichier : src/main/java/com/uvillage/infractions/dto/ContraventionTypeDTO.java
package com.uvillage.infractions.dto;

import com.uvillage.infractions.entity.ContraventionType;
import lombok.Data;

@Data
public class ContraventionTypeDTO {
    private String label; // Correspond à ContraventionType.label

    public static ContraventionTypeDTO fromEntity(ContraventionType type) {
        ContraventionTypeDTO dto = new ContraventionTypeDTO();
        dto.setLabel(type.getLabel());
        return dto;
    }
}