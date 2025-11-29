package com.uvillage.infractions.entity;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.util.List;

@Entity
@Table(name="contraventions")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Contravention {
    @Id
    @GeneratedValue(strategy=GenerationType.IDENTITY)
    private Long rowid;

    @Column(nullable=false, unique=true)
    private String ref;

    @Column(name="date_creation", nullable=false)
    private LocalDate dateCreation;

    @Column(columnDefinition="TEXT")
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(nullable=false)
    private Status statut = Status.SOUS_VERIFICATION;

    public enum Status {
        SOUS_VERIFICATION,
        ACCEPTEE,
        CLASSEE_SANS_SUITE
    }

    @ManyToOne
    @JoinColumn(name="fk_user_author", nullable=false)
    private User userAuthor;

    @ManyToOne
    @JoinColumn(name="fk_tiers")
    private Resident tiers;

    @ManyToOne
    @JoinColumn(name="fk_facture")
    private Facture facture;

    @ManyToOne
    @JoinColumn(name="fk_type_contravention", nullable=false)
    private ContraventionType typeContravention;

    @OneToMany(mappedBy="contravention", cascade=CascadeType.ALL)
    private List<ContraventionMedia> media;

    // Explicit accessors to avoid reliance on Lombok during IDE/processor issues
    public String getRef() {
        return this.ref;
    }

    public Status getStatut() {
        return this.statut;
    }

    public LocalDate getDateCreation() {
        return this.dateCreation;
    }

    public ContraventionType getTypeContravention() {
        return this.typeContravention;
    }

    public User getUserAuthor() {
        return this.userAuthor;
    }

    public Resident getTiers() {
        return this.tiers;
    }

    // Explicit setters to avoid Lombok reliance in IDE/processor
    public void setDescription(String description) {
        this.description = description;
    }

    public void setDateCreation(LocalDate dateCreation) {
        this.dateCreation = dateCreation;
    }

    public void setRef(String ref) {
        this.ref = ref;
    }

    public void setUserAuthor(User userAuthor) {
        this.userAuthor = userAuthor;
    }

    public void setTiers(Resident tiers) {
        this.tiers = tiers;
    }

    public void setTypeContravention(ContraventionType typeContravention) {
        this.typeContravention = typeContravention;
    }
}