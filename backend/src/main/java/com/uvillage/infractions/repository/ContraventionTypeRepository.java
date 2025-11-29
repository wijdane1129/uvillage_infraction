package com.uvillage.infractions.repository;

import com.uvillage.infractions.entity.ContraventionType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface ContraventionTypeRepository extends JpaRepository<ContraventionType, Long> {
    Optional<ContraventionType> findByLabel(String label);
}
