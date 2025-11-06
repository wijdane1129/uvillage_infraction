package com.uvillage.infractions.repository;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import com.uvillage.infractions.entity.User;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByResetPasswordToken(String token);
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);
    Optional<User> findByFullName(String fullName);
    Optional<User> findByPassword(String password);
    Optional<User> findByLanguage(String language);
}