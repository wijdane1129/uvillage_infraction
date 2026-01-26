package com.uvillage.infractions.dto;

import lombok.*;
import java.util.List;
import java.util.stream.Collectors;
import com.uvillage.infractions.entity.Contravention;
import com.uvillage.infractions.entity.ContraventionMedia;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ContraventionDTO {
    private String ref;
    private String tiers;
    private String motif;
    private String status;
    private String dateTime;
    private String userAuthor;
    private String description;
    // Expose media URLs to frontend as a list
    private List<String> media;
    private Long rowid;
    
    /**
     * Converts a Contravention entity to ContraventionDTO
     */
    public static ContraventionDTO fromEntity(Contravention c) {
        if (c == null) return null;
        
        List<String> media = (c.getMedia() == null) ? List.of() : c.getMedia().stream()
                .map(ContraventionMedia::getMediaUrl)
                .collect(Collectors.toList());
        
        String userAuthor = "";
        if (c.getUserAuthor() != null) {
            userAuthor = (c.getUserAuthor().getFullName() != null && !c.getUserAuthor().getFullName().isEmpty())
                    ? c.getUserAuthor().getFullName()
                    : c.getUserAuthor().getUsername();
        }
        
        return ContraventionDTO.builder()
                .ref(c.getRef())
                .rowid(c.getRowid())
                .status(c.getStatut() != null ? c.getStatut().name() : "")
                .dateTime(c.getDateCreation() != null ? c.getDateCreation().toString() : "")
                .motif(c.getTypeContravention() != null ? c.getTypeContravention().getLabel() : "")
                .tiers(c.getTiers() != null ? c.getTiers().toString() : "")
                .userAuthor(userAuthor)
                .description(c.getDescription())
                .media(media)
                .build();
    }
}
