package com.uvillage.infractions.repository;

import com.uvillage.infractions.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface EditProfileRepository extends JpaRepository<User, Long> {
    // Repository methods here
}
