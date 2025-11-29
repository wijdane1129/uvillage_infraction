package com.uvillage.infractions.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.uvillage.infractions.entity.Resident;

public interface ResidentRepository extends JpaRepository<Resident, Long> {
}
