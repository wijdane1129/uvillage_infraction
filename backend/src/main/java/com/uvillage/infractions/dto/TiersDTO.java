package com.uvillage.infractions.dto;

import com.uvillage.infractions.entity.Resident;

/**
 * DTO representation of a Resident (Tiers) without Lombok to avoid annotation-processing issues.
 */
public class TiersDTO {

    private Long id;
    private String nom;
    private String prenom;
    private String email;
    private String telephone;

    public TiersDTO() {
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

    /**
     * Convert an entity Resident to a TiersDTO.
     */
    public static TiersDTO fromEntity(Resident resident) {
        if (resident == null) return null;
        TiersDTO dto = new TiersDTO();
        dto.setId(resident.getId());
        dto.setNom(resident.getNom());
        dto.setPrenom(resident.getPrenom());
        dto.setEmail(resident.getEmail());
        dto.setTelephone(resident.getTelephone());
        return dto;
    }
}