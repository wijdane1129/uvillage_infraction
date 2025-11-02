package com.uvillage.infractions.entity;
import jakarta.persistence.*;
import lombok.*;
import java.util.List;

@Entity
@Table(name="contravention_types")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ContraventionType {
    @Id
    @GeneratedValue(strategy=GenerationType.IDENTITY)
    private Long rowid;

    @Column(nullable=false, unique=true)
    private String label;

    private String description;

    @Column(nullable=false)
    private Double montant1; 

    @Column(nullable=false)
    private Double montant2; 

    @Column(nullable=false)
    private Double montant3; 

    @Column(nullable=false)
    private Double montant4; 

    @OneToMany(mappedBy="typeContravention")
    private List<Contravention> contraventions;

    @OneToMany(mappedBy="contraventionType")
    private List<Recidive> recidives;
}