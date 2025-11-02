package com.uvillage.infractions.entity;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name="contravention_media")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
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
    @JoinColumn(name="fk_contravention", nullable=false)
    private Contravention contravention;

    public enum MediaType {
        PHOTO,
        VIDEO,
        AUDIO,
        DOCUMENT
    }
}