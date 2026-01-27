package com.uvillage.infractions.repository;

import com.uvillage.infractions.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Repository for the User entity, providing CRUD operations and common lookup methods
 * used by authentication, password reset, and profile management flows.
 */
@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    /**
     * Find a user by their email address.
     */
    Optional<User> findByEmail(String email);

    /**
     * Check whether an email is already registered.
     */
    boolean existsByEmail(String email);

    /**
     * Case-insensitive lookup by email. Useful to avoid authentication failures
     * when email case normalization differs between token subject and stored value.
     */
    Optional<User> findByEmailIgnoreCase(String email);

    /**
     * Find a user by their reset password token.
     */
    Optional<User> findByResetPasswordToken(String token);

    /**
     * Find a user by their full name.
     */
    Optional<User> findByFullName(String fullName);

    /**
     * Find a user by their password.
     * (Use cautiously; typically not used for authentication)
     */
    Optional<User> findByPassword(String password);

    /**
     * Find a user by their language preference.
     */
    Optional<User> findByLanguage(String language);
}
