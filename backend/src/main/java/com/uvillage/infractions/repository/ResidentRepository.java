package com.uvillage.infractions.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import com.uvillage.infractions.entity.Resident;

@Repository
public interface ResidentRepository extends JpaRepository<Resident, Long> {
}
