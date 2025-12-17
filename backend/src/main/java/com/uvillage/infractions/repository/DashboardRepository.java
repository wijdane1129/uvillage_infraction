package com.uvillage.infractions.repository;

import com.uvillage.infractions.entity.Contravention;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface DashboardRepository extends JpaRepository<Contravention, Long> {
    @Query("SELECT COUNT(c) FROM Contravention c")
    Long countInfraction();

    @Query("SELECT COUNT(c) FROM Contravention c WHERE c.statut = 'ACCEPTEE'")
    Long countResolvedInfractions();

    @Query("SELECT MONTH(c.dateCreation), COUNT(c) FROM Contravention c GROUP BY MONTH(c.dateCreation)")
    List<Object[]> countByMonth();

    @Query("SELECT c.typeContravention.label, COUNT(c) FROM Contravention c GROUP BY c.typeContravention.label")
    List<Object[]> countByType();

    @Query("SELECT i.nom, COUNT(c) FROM Contravention c JOIN c.tiers r JOIN r.chambre ch JOIN ch.immeuble i GROUP BY i.nom")
    List<Object[]> countByZone();
}
