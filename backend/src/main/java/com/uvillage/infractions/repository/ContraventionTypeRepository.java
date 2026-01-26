package com.uvillage.infractions.repository;

import com.uvillage.infractions.entity.ContraventionType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ContraventionTypeRepository extends JpaRepository<ContraventionType, Long> {

    // Find by exact label
    Optional<ContraventionType> findByLabel(String label);

    // Search by label (case-insensitive, partial match)
    @Query("SELECT ct FROM ContraventionType ct WHERE LOWER(ct.label) LIKE LOWER(CONCAT('%', :label, '%'))")
    List<ContraventionType> searchByLabel(@Param("label") String label);

    // Get all types ordered by rowid descending
    @Query("SELECT ct FROM ContraventionType ct ORDER BY ct.rowid DESC")
    List<ContraventionType> findAllOrderByIdDesc();
}
