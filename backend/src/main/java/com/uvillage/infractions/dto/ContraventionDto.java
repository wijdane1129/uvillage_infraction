package com.uvillage.infractions.dto;

import lombok.*;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ContraventionDto {
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
    
}
