package com.uvillage.infractions.config;

import com.uvillage.infractions.security.CustomUserDetailsService;
import com.uvillage.infractions.security.JwtAuthenticationFilter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity(prePostEnabled = true)
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthFilter;
    private final CustomUserDetailsService userDetailsService;

    public SecurityConfig(JwtAuthenticationFilter jwtAuthFilter,
                          CustomUserDetailsService userDetailsService) {
        this.jwtAuthFilter = jwtAuthFilter;
        this.userDetailsService = userDetailsService;
    }

    @Bean
    public AuthenticationManager authenticationManager(
            HttpSecurity http,
            PasswordEncoder passwordEncoder
    ) throws Exception {
        return http.getSharedObject(AuthenticationManagerBuilder.class)
                .userDetailsService(userDetailsService)
                .passwordEncoder(passwordEncoder)
                .and()
                .build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public SecurityFilterChain filterChain(
            HttpSecurity http,
            AuthenticationProvider authenticationProvider
    ) throws Exception {

        http
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .csrf(csrf -> csrf.disable())
            .exceptionHandling(handling -> handling
                .authenticationEntryPoint((request, response, authException) -> {
                    response.setContentType("application/json");
                    response.setStatus(401);
                    response.getWriter().write(
                        "{\"error\":\"Unauthorized\",\"message\":\"" +
                        authException.getMessage() + "\"}"
                    );
                })
            )
            .sessionManagement(management ->
                management.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            )
            .authorizeHttpRequests(requests -> requests
                // CORS preflight
                .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()

                // Auth endpoints (public)
                .requestMatchers(
                    "/api/auth/**",
                    "/api/v1/auth/**"
                ).permitAll()

                // Dashboard & config
                // - dashboard stats: accessible to authenticated users
                .requestMatchers("/api/dashboard/stats").authenticated()
                // - dashboard responsable: only responsable role
                .requestMatchers("/api/dashboard/responsable").hasRole("RESPONSABLE")
                // Motifs: allow GET for authenticated users, restrict modifications to responsable
                .requestMatchers(HttpMethod.GET, "/api/motifs/**").authenticated()
                .requestMatchers(HttpMethod.POST, "/api/motifs/**").hasRole("RESPONSABLE")
                .requestMatchers(HttpMethod.PUT, "/api/motifs/**").hasRole("RESPONSABLE")
                .requestMatchers(HttpMethod.DELETE, "/api/motifs/**").hasRole("RESPONSABLE")

                // Contravention endpoints
                .requestMatchers(HttpMethod.GET, "/api/v1/contraventions/**").authenticated()
                // Creating contraventions allowed for authenticated (agents)
                .requestMatchers(HttpMethod.POST, "/api/v1/contraventions").authenticated()
                // Confirming a contravention (invoice generation) reserved to responsable
                .requestMatchers(HttpMethod.POST, "/api/v1/contraventions/ref/**/confirm").hasRole("RESPONSABLE")

                // Swagger
                .requestMatchers("/swagger-ui/**", "/v3/api-docs/**").permitAll()

                // Everything else
                .anyRequest().authenticated()
            )
            .authenticationProvider(authenticationProvider)
            .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowCredentials(true);
        configuration.setAllowedOriginPatterns(Arrays.asList(
            "http://localhost:*",
            "http://127.0.0.1:*"
        ));
        configuration.setAllowedMethods(Arrays.asList(
            "GET", "POST", "PUT", "DELETE", "OPTIONS"
        ));
        configuration.setAllowedHeaders(Arrays.asList(
            "Authorization", "Content-Type"
        ));
        configuration.setExposedHeaders(Arrays.asList(
            "Authorization", "Content-Type"
        ));
        configuration.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source =
                new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}
