package com.uvillage.infractions.repository;

import com.uvillage.infractions.entity.Contravention;
import com.uvillage.infractions.entity.Resident;
import com.uvillage.infractions.entity.User;
import com.uvillage.infractions.entity.ContraventionType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface ContraventionRepository extends JpaRepository<Contravention, Long> {

    // Find by unique reference
    Optional<Contravention> findByRef(String ref);

    // Find by resident
    Optional<Contravention> findByTiers(Resident tiers);

    // Find all contraventions for a resident (by resident id), ordered by creation date
    List<Contravention> findByTiers_IdOrderByDateCreationDesc(Long tiersId);

    // Find by contravention type
    Optional<Contravention> findByTypeContravention(ContraventionType typeContravention);

    // Find by status
    Optional<Contravention> findByStatut(Contravention.Status statut);

    // Find by creation date
    Optional<Contravention> findByDateCreation(LocalDate dateCreation);

    // Find by author
    Optional<Contravention> findByUserAuthor(User userAuthor);

    // Find by description
    Optional<Contravention> findByDescription(String description);

    // Find by rowid
    Optional<Contravention> findByRowid(Long rowid);

    // History queries
    List<Contravention> findByUserAuthor_IdOrderByDateCreationDesc(Long userAuthorId);

    long countByUserAuthor_IdAndDateCreation(Long userAuthorId, LocalDate dateCreation);

    long countByUserAuthor_IdAndDateCreationBetween(Long userAuthorId, LocalDate startDate, LocalDate endDate);
}
