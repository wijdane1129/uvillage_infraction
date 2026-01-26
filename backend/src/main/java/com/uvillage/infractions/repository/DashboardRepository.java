package com.uvillage.infractions.repository;

import com.uvillage.infractions.entity.Contravention;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface DashboardRepository extends JpaRepository<Contravention, Long> {
    @Query("SELECT COUNT(c) FROM Contravention c")
    Long countInfraction();

    @Query("SELECT COUNT(c) FROM Contravention c WHERE c.statut = 'ACCEPTEE'")
    Long countResolvedInfractions();

    @Query("SELECT COUNT(c) FROM Contravention c WHERE c.statut = 'SOUS_VERIFICATION'")
    Long countPendingInfractions();

    @Query(value = "SELECT COUNT(*) FROM contraventions WHERE statut = 'ACCEPTEE' AND MONTH(date_creation) = MONTH(CURDATE()) AND YEAR(date_creation) = YEAR(CURDATE())", nativeQuery = true)
    Long countAcceptedThisMonth();

    @Query("SELECT MONTH(c.dateCreation), COUNT(c) FROM Contravention c GROUP BY MONTH(c.dateCreation)")
    List<Object[]> countByMonth();

    @Query("SELECT c.typeContravention.label, COUNT(c) FROM Contravention c GROUP BY c.typeContravention.label")
    List<Object[]> countByType();

    @Query("SELECT i.nom, COUNT(c) FROM Contravention c JOIN c.tiers r JOIN r.chambre ch JOIN ch.immeuble i GROUP BY i.nom")
    List<Object[]> countByZone();

    // Last 30 days infractions
    @Query(value = "SELECT * FROM contraventions WHERE date_creation >= CURDATE() - INTERVAL 30 DAY ORDER BY date_creation DESC", nativeQuery = true)
    List<Contravention> findLast30DaysInfractions();

    // Recent infractions (last 3)
    @Query(value = "SELECT * FROM contraventions ORDER BY date_creation DESC LIMIT 3", nativeQuery = true)
    List<Contravention> findRecentInfractions();

    // Infractions by status
    @Query(value = "SELECT COUNT(*) FROM contraventions WHERE statut = :statut AND date_creation >= CURDATE() - INTERVAL 30 DAY", nativeQuery = true)
    Long countByStatusLast30Days(@Param("statut") String statut);

    // Daily count for last 30 days
    @Query(value = "SELECT DATE(date_creation) as date, COUNT(*) as count FROM contraventions WHERE date_creation >= CURDATE() - INTERVAL 30 DAY GROUP BY DATE(date_creation) ORDER BY date ASC", nativeQuery = true)
    List<Object[]> countDailyLast30Days();
}
