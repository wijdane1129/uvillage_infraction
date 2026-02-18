package com.uvillage.infractions.dto;

import com.uvillage.infractions.entity.Contravention;
import com.uvillage.infractions.entity.ContraventionMedia;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Contravention DTO with media support
 */
public class ContraventionDTO {
    private Long rowid;
    private String ref;
    private String description;
    private String statut;
    private String dateHeure;
    private ContraventionTypeDTO typeContravention;
    private UserDto userAuthor;
    private TiersDTO tiers;
    private List<MediaDTO> media;
    private String residentAdresse;
    private String facturePdfUrl;
    private Double montant;

    public ContraventionDTO() {
    }

    // Getters and Setters
    public Long getRowid() {
        return rowid;
    }

    public void setRowid(Long rowid) {
        this.rowid = rowid;
    }

    public String getRef() {
        return ref;
    }

    public void setRef(String ref) {
        this.ref = ref;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getResidentAdresse() {
        return residentAdresse;
    }

    public void setResidentAdresse(String residentAdresse) {
        this.residentAdresse = residentAdresse;
    }

    public String getFacturePdfUrl() {
        return facturePdfUrl;
    }

    public void setFacturePdfUrl(String facturePdfUrl) {
        this.facturePdfUrl = facturePdfUrl;
    }

    public Double getMontant() {
        return montant;
    }

    public void setMontant(Double montant) {
        this.montant = montant;
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

    public List<MediaDTO> getMedia() {
        return media;
    }

    public void setMedia(List<MediaDTO> media) {
        this.media = media;
    }

    public static ContraventionDTO fromEntity(Contravention contravention) {
        if (contravention == null)
            return null;

        ContraventionDTO dto = new ContraventionDTO();
        dto.setRowid(contravention.getRowid());
        dto.setRef(contravention.getRef());
        dto.setDescription(contravention.getDescription());

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

        // Set facture PDF URL and montant if available (wrapped in try-catch for lazy-loading
        // safety)
        try {
            if (contravention.getFacture() != null) {
                if (contravention.getFacture().getPdfUrl() != null) {
                    dto.setFacturePdfUrl(contravention.getFacture().getPdfUrl());
                }
                if (contravention.getFacture().getMontantTotal() != null) {
                    dto.setMontant(contravention.getFacture().getMontantTotal());
                }
            }
        } catch (Exception e) {
            // Facture not loaded (lazy init) — skip silently
        }

        // Convert media entities to DTOs
        if (contravention.getMedia() != null && !contravention.getMedia().isEmpty()) {
            dto.setMedia(
                    contravention.getMedia().stream()
                            .map(MediaDTO::fromEntity)
                            .collect(Collectors.toList()));
        }

        return dto;
    }

    /**
     * Nested DTO for media
     */
    public static class MediaDTO {
        private Long id;
        private String mediaUrl;
        private String mediaType;

        public MediaDTO() {
        }

        public MediaDTO(Long id, String mediaUrl, String mediaType) {
            this.id = id;
            this.mediaUrl = mediaUrl;
            this.mediaType = mediaType;
        }

        public Long getId() {
            return id;
        }

        public void setId(Long id) {
            this.id = id;
        }

        public String getMediaUrl() {
            return mediaUrl;
        }

        public void setMediaUrl(String mediaUrl) {
            this.mediaUrl = mediaUrl;
        }

        public String getMediaType() {
            return mediaType;
        }

        public void setMediaType(String mediaType) {
            this.mediaType = mediaType;
        }

        public static MediaDTO fromEntity(ContraventionMedia media) {
            if (media == null)
                return null;
            return new MediaDTO(
                    media.getId(),
                    media.getMediaUrl(),
                    media.getMediaType() != null ? media.getMediaType().toString() : "UNKNOWN");
        }
    }
}