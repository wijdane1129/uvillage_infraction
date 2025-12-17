package com.uvillage.infractions.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

import com.uvillage.infractions.repository.UserRepository;
import com.uvillage.infractions.security.CustomUserDetailsService;

// Lombok's @RequiredArgsConstructor removed because explicit constructor is provided
// to satisfy IDEs/language servers that may not run annotation processing.

/**
 * Configuration des Beans pour l'authentification et la sécurité.
 */
@Configuration
public class ApplicationConfig {

    private final UserRepository userRepository;

    /**
     * Explicit constructor to satisfy IDEs / language servers that do not
     * process Lombok's @RequiredArgsConstructor. Spring will use this
     * constructor to inject the repository and other final beans.
     */
    public ApplicationConfig(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Bean
    public UserDetailsService userDetailsService() {
        // Utilise notre CustomUserDetailsService qui charge l'utilisateur par email
        return new CustomUserDetailsService(userRepository);
    }

    @Bean
    public AuthenticationProvider authenticationProvider() {
        DaoAuthenticationProvider authProvider = new DaoAuthenticationProvider();
        authProvider.setUserDetailsService(userDetailsService());
        authProvider.setPasswordEncoder(passwordEncoder());
        return authProvider;
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }

    @Bean
    @ConditionalOnMissingBean(PasswordEncoder.class)
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    /**
     * Temporary diagnostic runner (DEV) to verify that the stored BCrypt hash
     * for the test user matches the plain password "test1234". Runs at startup.
     * Remove this bean after debugging.
     */
    @Bean
    public CommandLineRunner passwordHashChecker(PasswordEncoder encoder, UserRepository repo) {
        final Logger log = LoggerFactory.getLogger(ApplicationConfig.class);
        return args -> {
            repo.findByEmail("test@uvillage.com").ifPresentOrElse(user -> {
                boolean matches = encoder.matches("test1234", user.getPassword());
                log.info("Password match for test@uvillage.com: {}", matches);
                // Also log the stored hash length for verification
                log.info("Stored password hash length: {}", user.getPassword() != null ? user.getPassword().length() : 0);
            }, () -> log.warn("User test@uvillage.com not found (passwordHashChecker)"));
        };
    }

    /**
     * Temporary helper to print a BCrypt hash for a plain password provided via
     * system property 'password.to.hash' or env var 'PASSWORD_TO_HASH'.
     * Falls back to 'test1234' if not provided. Remove after use in production.
     */
    @Bean
    public CommandLineRunner printTestHash(PasswordEncoder encoder) {
        final Logger log = LoggerFactory.getLogger(ApplicationConfig.class);
        return args -> {
            String fromProp = System.getProperty("password.to.hash");
            String fromEnv = System.getenv("PASSWORD_TO_HASH");
            String plain = fromProp != null && !fromProp.isBlank()
                    ? fromProp
                    : (fromEnv != null && !fromEnv.isBlank() ? fromEnv : "test1234");
            String hash = encoder.encode(plain);
            log.info("Generated BCrypt hash for '{}': {}", plain, hash);
        };
    }
}
