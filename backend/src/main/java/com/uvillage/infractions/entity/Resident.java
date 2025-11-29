package com.uvillage.infractions.entity;

import jakarta.persistence.*;
import java.util.List;

@Entity
@Table(name = "residents")
public class Resident {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String nom;

    @Column(nullable = false)
    private String prenom;

    @Column(unique = true)
    private String email;

    private String telephone;

    @ManyToOne
    @JoinColumn(name = "fk_chambre")
    private Chambre chambre;

    @OneToMany(mappedBy = "tiers")
    private List<Contravention> contraventions;

    @OneToMany(mappedBy = "resident")
    private List<Facture> factures;

    @OneToMany(mappedBy = "resident")
    private List<Recidive> recidives;

    public Resident() {
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getNom() {
        return nom;
    }

    public void setNom(String nom) {
        this.nom = nom;
    }

    public String getPrenom() {
        return prenom;
    }

    public void setPrenom(String prenom) {
        this.prenom = prenom;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getTelephone() {
        return telephone;
    }

    public void setTelephone(String telephone) {
        this.telephone = telephone;
    }

    public Chambre getChambre() {
        return chambre;
    }

    public void setChambre(Chambre chambre) {
        this.chambre = chambre;
    }

    public List<Contravention> getContraventions() {
        return contraventions;
    }

    public void setContraventions(List<Contravention> contraventions) {
        this.contraventions = contraventions;
    }

    public List<Facture> getFactures() {
        return factures;
    }

    public void setFactures(List<Facture> factures) {
        this.factures = factures;
    }

    public List<Recidive> getRecidives() {
        return recidives;
    }

    public void setRecidives(List<Recidive> recidives) {
        this.recidives = recidives;
    }
}