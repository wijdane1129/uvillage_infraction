package com.uvillage.infractions.entity;

import jakarta.persistence.*;
import java.util.Objects;

@Entity
@Table(name="contravention_media")
public class ContraventionMedia {
    @Id
    @GeneratedValue(strategy=GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    @Column(nullable=false)
    private MediaType mediaType;

    @Column(nullable=false, length=500)
    private String mediaUrl;

    @ManyToOne
    @JoinColumn(name="fk_contravention", nullable=true)
    private Contravention contravention;

    public enum MediaType {
        PHOTO,
        VIDEO,
        AUDIO,
        DOCUMENT
    }

    public ContraventionMedia() {}

    public ContraventionMedia(Long id, MediaType mediaType, String mediaUrl, Contravention contravention) {
        this.id = id;
        this.mediaType = mediaType;
        this.mediaUrl = mediaUrl;
        this.contravention = contravention;
    }

    // Manual builder to replace Lombok
    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private Long id;
        private MediaType mediaType;
        private String mediaUrl;
        private Contravention contravention;

        public Builder id(Long id) { this.id = id; return this; }
        public Builder mediaType(MediaType mt) { this.mediaType = mt; return this; }
        public Builder mediaUrl(String url) { this.mediaUrl = url; return this; }
        public Builder contravention(Contravention c) { this.contravention = c; return this; }
        public ContraventionMedia build() { return new ContraventionMedia(id, mediaType, mediaUrl, contravention); }
    }

    // Getters / setters (explicit)
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public MediaType getMediaType() { return mediaType; }
    public void setMediaType(MediaType mediaType) { this.mediaType = mediaType; }
    public String getMediaUrl() { return mediaUrl; }
    public void setMediaUrl(String mediaUrl) { this.mediaUrl = mediaUrl; }
    public Contravention getContravention() { return contravention; }
    public void setContravention(Contravention contravention) { this.contravention = contravention; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        ContraventionMedia that = (ContraventionMedia) o;
        return Objects.equals(id, that.id);
    }

    @Override
    public int hashCode() { return Objects.hash(id); }
}