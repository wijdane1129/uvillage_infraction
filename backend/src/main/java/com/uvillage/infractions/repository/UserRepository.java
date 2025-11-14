package com.uvillage.infractions.repository;

import com.uvillage.infractions.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Repository pour l'entité User, permettant les opérations CRUD et la recherche spécifique.
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

    /**
     * Recherche un utilisateur par son token de réinitialisation de mot de passe.
     */
    Optional<User> findByResetPasswordToken(String token);

    /**
     * Recherche un utilisateur par son nom complet.
     */
    Optional<User> findByFullName(String fullName);

    /**
     * Recherche un utilisateur par son mot de passe.
     */
    Optional<User> findByPassword(String password);

    /**
     * Recherche un utilisateur par sa langue.
     */
    Optional<User> findByLanguage(String language);
}
