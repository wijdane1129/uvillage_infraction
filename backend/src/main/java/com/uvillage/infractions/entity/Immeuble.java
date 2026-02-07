package com.uvillage.infractions.entity;
import jakarta.persistence.*;
import lombok.*;
import java.util.List;

@Entity
@Table(name="immeubles")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Immeuble {
    @Id
    @GeneratedValue(strategy=GenerationType.IDENTITY)
    private Long id;

    @Column(nullable=false)
    private String nom;

    private String adresse;

    @OneToMany(mappedBy="immeuble")
    private List<Chambre> chambres;

    public String getNom() {
        return this.nom;
    }

    public void setNom(String nom) {
        this.nom = nom;
    }
}