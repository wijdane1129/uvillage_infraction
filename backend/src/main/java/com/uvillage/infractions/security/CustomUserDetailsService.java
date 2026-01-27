package com.uvillage.infractions.security;

import com.uvillage.infractions.entity.User;
import com.uvillage.infractions.repository.UserRepository;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import java.util.regex.Pattern;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import java.util.Arrays;
import java.util.Locale;

/**
 * Service pour charger les détails de l'utilisateur.
 * Spring Security l'utilise pour vérifier l'utilisateur pendant la connexion.
 */
public class CustomUserDetailsService implements UserDetailsService {

    private final UserRepository userRepository;
    private final Pattern responsiblePattern;

    /**
     * Constructor injection of UserRepository.
     */
    public CustomUserDetailsService(UserRepository userRepository, String responsiblePatternStr) {
        this.userRepository = userRepository;
        if (responsiblePatternStr != null && !responsiblePatternStr.isBlank()) {
            this.responsiblePattern = Pattern.compile(responsiblePatternStr, Pattern.CASE_INSENSITIVE);
        } else {
            this.responsiblePattern = null;
        }
    }

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {

        // Récupère l'utilisateur depuis la base par email (email = username dans notre système)
        // Use case-insensitive lookup to avoid mismatches between token subject
        // casing and stored email casing in the database.
        User user = userRepository.findByEmailIgnoreCase(email)
            .orElseThrow(() -> new UsernameNotFoundException(
                "Utilisateur non trouvé avec l'email: " + email
            ));

        // If the email matches the responsable pattern, persist the role
        if (responsiblePattern != null) {
            String userMail = user.getEmail() != null ? user.getEmail().trim().toLowerCase(Locale.ROOT) : "";
            boolean isResp = responsiblePattern.matcher(userMail).matches();

            if (isResp && user.getRole() != User.Role.RESPONSABLE) {
                user.setRole(User.Role.RESPONSABLE);
                userRepository.save(user);
            }
        }

        // Mappe le rôle de l'utilisateur vers Spring Security
        String role = user.getRole() != null ? user.getRole().name() : "AGENT";

        return org.springframework.security.core.userdetails.User.builder()
                .username(user.getEmail() != null ? user.getEmail() : user.getUsername())
                .password(user.getPassword())
                .authorities(new SimpleGrantedAuthority("ROLE_" + role))
                .accountExpired(false)
                .accountLocked(false)
                .credentialsExpired(false)
                .disabled(false)
                .build();
    }
}
