package com.uvillage.infractions.entity;
import jakarta.persistence.*;
import lombok.*;
import java.util.List;

@Entity
@Table(name="residents")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Resident {
    @Id
    @GeneratedValue(strategy=GenerationType.IDENTITY)
    private Long id;

    @Column(nullable=false)
    private String nom;

    @Column(nullable=false)
    private String prenom;

    @Column(unique=true)
    private String email;

    private String telephone;

    @ManyToOne
    @JoinColumn(name="fk_chambre")
    private Chambre chambre;

    @OneToMany(mappedBy="tiers")
    private List<Contravention> contraventions;

    @OneToMany(mappedBy="resident")
    private List<Facture> factures;

    @OneToMany(mappedBy="resident")
    private List<Recidive> recidives;
}