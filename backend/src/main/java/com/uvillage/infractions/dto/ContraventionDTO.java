package com.uvillage.infractions.dto;

import com.uvillage.infractions.entity.Contravention;
import com.uvillage.infractions.entity.Resident;
import com.uvillage.infractions.entity.StatutContravention; // Assurez-vous d'importer l'énumération StatutContravention si elle est utilisée
import lombok.Data;
import java.time.format.DateTimeFormatter;

@Data
public class ContraventionDTO {
    
    // Propriétés du DTO
    private String ref;
    private String statut;
    private String dateHeure; 
    
    // DTOs imbriqués pour les relations
    private ContraventionTypeDTO typeContravention;
    private UserDTO userAuthor;
    private TiersDTO tiers; 
    
    /**
     * Convertit une entité Contravention en objet ContraventionDTO.
     * Cette méthode statique est utilisée dans le service (via le .stream().map()).
     * @param contravention L'entité à convertir.
     * @return L'objet DTO formaté.
     */
    public static ContraventionDTO fromEntity(Contravention contravention) {
        ContraventionDTO dto = new ContraventionDTO();
        
        dto.setRef(contravention.getRef());
        
        // CORRECTION DE L'ERREUR DE TYPE (Ligne 34) :
        // On récupère la valeur de statut comme un Object
        // et on utilise .toString() pour la convertir en String pour le DTO.
        Object statutValue = contravention.getStatut();
        if (statutValue != null) {
            // Cela fonctionne que statutValue soit une Enum (imbriquée ou non) ou un String.
            dto.setStatut(statutValue.toString()); 
        } else {
            dto.setStatut("INCONNU"); 
        }
        
        // Formatage de la date pour l'affichage (jj/MM/aaaa)
        if (contravention.getDateCreation() != null) {
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
            dto.setDateHeure(contravention.getDateCreation().format(formatter));
        } else {
            dto.setDateHeure("Date non définie");
        }

        // Conversion des entités imbriquées en DTOs
        if (contravention.getTypeContravention() != null) {
            dto.setTypeContravention(ContraventionTypeDTO.fromEntity(contravention.getTypeContravention()));
        }
        if (contravention.getUserAuthor() != null) {
            dto.setUserAuthor(UserDTO.fromEntity(contravention.getUserAuthor()));
        }
        
        // Le "tiers" est l'entité Resident
        Resident resident = contravention.getTiers();
        if (resident != null) {
            dto.setTiers(TiersDTO.fromEntity(resident));
        }
        
        return dto;
    }
}