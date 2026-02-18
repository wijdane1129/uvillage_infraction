package com.uvillage.infractions.repository;

import com.uvillage.infractions.entity.Recidive;
import com.uvillage.infractions.entity.Resident;
import com.uvillage.infractions.entity.ContraventionType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface RecidiveRepository extends JpaRepository<Recidive, Long> {

    /**
     * Find a Recidive record for a specific resident and contravention type
     */
    Optional<Recidive> findByResidentAndContraventionType(Resident resident, ContraventionType contraventionType);

    /**
     * Count recidives by resident ID and contravention type label
     */
    @Query("SELECT r.nbRecidives FROM Recidive r WHERE r.resident.id = :residentId AND r.contraventionType.label = :label")
    Optional<Integer> findNbRecidivesByResidentIdAndLabel(@Param("residentId") Long residentId, @Param("label") String label);

    /**
     * Count the number of ACCEPTEE contraventions for a given room/building and motif (for mock residents)
     */
    @Query("SELECT COUNT(c) FROM Contravention c WHERE c.numeroChambre = :numeroChambre AND c.batiment = :batiment " +
           "AND c.typeContravention.label = :label AND c.statut = 'ACCEPTEE'")
    long countAcceptedByRoomBuildingAndType(@Param("numeroChambre") String numeroChambre,
                                            @Param("batiment") String batiment,
                                            @Param("label") String label);

    /**
     * Count the number of ACCEPTEE contraventions for a given resident (fk_tiers) and motif label.
     * This is the primary recidive counting method — uses resident ID instead of room/building.
     */
    @Query("SELECT COUNT(c) FROM Contravention c WHERE c.tiers.id = :residentId " +
           "AND c.typeContravention.label = :label AND c.statut = 'ACCEPTEE'")
    long countAcceptedByResidentIdAndType(@Param("residentId") Long residentId,
                                          @Param("label") String label);
}
