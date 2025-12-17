// Fichier : src/main/java/com/uvillage/infractions/dto/UserDTO.java
package com.uvillage.infractions.dto;

import com.uvillage.infractions.entity.User; // Assurez-vous d'avoir l'entité User
import lombok.Data;

@Data
class UserDTO {
    // Champs à exposer pour l'auteur (Agent)
    private Long rowid;
    private String username;
    
    // Méthode de conversion statique
    public static UserDTO fromEntity(User user) {
        UserDTO dto = new UserDTO();
        dto.setRowid(user.getId());
        dto.setUsername(user.getUsername());
        return dto;
    }
}