package com.uvillage.infractions.dto;

import com.uvillage.infractions.entity.Resident; // Importe l'entité Resident
import lombok.Data;

@Data
public class TiersDTO {
    
    // Les champs de base de l'entité Resident à exposer
    private Long id;
    private String nom;
    private String prenom;
    private String email;
    private String telephone;
    
    // NOTE : Nous n'incluons PAS les listes de relations (contraventions, factures, recidives)
    // pour garder le DTO léger et éviter les boucles de sérialisation.

    /**
     * Convertit une entité Resident en objet TiersDTO.
     * C'est la méthode de conversion requise par ContraventionDTO.
     * * @param resident L'entité Resident à convertir.
     * @return Le TiersDTO créé.
     */
    public static TiersDTO fromEntity(Resident resident) {
        TiersDTO dto = new TiersDTO();
        
        dto.setId(resident.getId());
        dto.setNom(resident.getNom());
        dto.setPrenom(resident.getPrenom());
        dto.setEmail(resident.getEmail());
        dto.setTelephone(resident.getTelephone());
        
        // La relation Chambre pourrait nécessiter un ChambreDTO ici si vous voulez 
        // les détails de la chambre, mais pour la simplicité, nous laissons de côté.
        
        return dto;
    }
}