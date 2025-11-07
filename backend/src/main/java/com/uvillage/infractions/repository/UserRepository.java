package com.uvillage.infractions.repository;

import com.uvillage.infractions.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Repository for the User entity, providing common lookup methods used by
 * authentication and password reset flows.
 */
@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    /**
     * Find a user by their email address.
     */
    Optional<User> findByEmail(String email);

    /**
     * Optional lookup used by reset password flow.
     */
    Optional<User> findByResetPasswordToken(String token);

    /**
     * Check whether an email is already registered.
     */
    boolean existsByEmail(String email);
}
