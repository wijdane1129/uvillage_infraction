// Fichier : src/main/java/com/uvillage/infractions/dto/ContraventionTypeDTO.java
package com.uvillage.infractions.dto;

import com.uvillage.infractions.entity.ContraventionType;

public class ContraventionTypeDTO {
    private String label; // Correspond à ContraventionType.label

    public ContraventionTypeDTO() {}

    public ContraventionTypeDTO(String label) { this.label = label; }

    public String getLabel() { return label; }
    public void setLabel(String label) { this.label = label; }

    public static ContraventionTypeDTO fromEntity(ContraventionType type) {
        ContraventionTypeDTO dto = new ContraventionTypeDTO();
        dto.setLabel(type == null ? null : type.getLabel());
        return dto;
    }
}