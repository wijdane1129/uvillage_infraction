package com.uvillage.infractions.entity;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name="factures")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Facture {
    @Id
    @GeneratedValue(strategy=GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name="fk_resident", nullable=false)
    private Resident resident;

    @Column(name="date_creation", nullable=false)
    private LocalDateTime dateCreation;

    @Column(nullable=false)
    private Double montantTotal;

    @Enumerated(EnumType.STRING)
    @Column(nullable=false)
    private Status statut = Status.IMPAYE;

    @Column(unique=true, nullable=false)
    private String refFacture;

    @Column(length=500)
    private String pdfUrl;

    @OneToMany(mappedBy="facture")
    private List<Contravention> contraventions;

    public enum Status {
        PAYE,
        IMPAYE
    }
}