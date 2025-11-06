package com.uvillage.infractions.repository;

import com.uvillage.infractions.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Repository pour l'entité User, permettant les opérations CRUD.
 */
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    /**
     * Recherche un utilisateur par son email (utilisé comme nom d'utilisateur).
     */
    Optional<User> findByEmail(String email);
    
    /**
     * Vérifie si un email existe déjà (utile pour l'inscription).
     */
    boolean existsByEmail(String email);
}
