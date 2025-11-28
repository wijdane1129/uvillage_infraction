package com.uvillage.infractions.repository;
import com.uvillage.infractions.entity.Contravention;
import com.uvillage.infractions.entity.Resident;
import com.uvillage.infractions.entity.User;
import com.uvillage.infractions.entity.ContraventionType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;
@Repository
public interface ContraventionRepository extends JpaRepository<Contravention, Long>{
    Optional<Contravention> findByRef(String ref);
    Optional<Contravention> findByTiers(Resident tiers);
    Optional<Contravention> findByTypeContravention(ContraventionType typeContravention);
    Optional<Contravention> findByStatut(Contravention.Status statut);
    Optional<Contravention> findByDateCreation(java.time.LocalDate dateCreation);
    Optional<Contravention> findByUserAuthor(User userAuthor);
    Optional<Contravention> findByDescription(String description);
    // media is a collection; queries by media are not provided here
    Optional<Contravention> findByRowid(Long rowid);
    

}


