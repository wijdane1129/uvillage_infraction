package com.uvillage.infractions.security;

import com.uvillage.infractions.entity.User;
import com.uvillage.infractions.repository.UserRepository;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

/**
 * Service pour charger les détails de l'utilisateur (implémentation UserDetailsService).
 * Spring Security l'utilise pour vérifier l'utilisateur pendant la connexion.
 */
@Service
public class CustomUserDetailsService implements UserDetailsService {

    private final UserRepository userRepository;

    /**
     * Explicit constructor to satisfy IDEs / language servers that do not
     * process Lombok's @RequiredArgsConstructor. Spring will use this
     * constructor to inject the repository.
     */
    public CustomUserDetailsService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        // L'email est utilisé comme le 'username' dans notre entité User
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("Utilisateur non trouvé avec l'email: " + email));

        // Mappez notre entité User vers un UserDetails Spring Security.
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
