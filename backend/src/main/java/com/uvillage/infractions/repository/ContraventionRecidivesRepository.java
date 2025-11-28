package com.uvillage.infractions.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import org.springframework.data.repository.query.Param;
import com.uvillage.infractions.entity.*;

@Repository
public interface ContraventionRecidivesRepository extends JpaRepository<ContraventionType, Long>{
    @Query("SELECT COUNT(c) FROM ContraventionType c WHERE c.label =:label")
    Long nombrerecidive(@Param("label") String label);
    java.util.Optional<ContraventionType> findByLabel(String label);
    
}
