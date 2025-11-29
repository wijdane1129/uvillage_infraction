package com.uvillage.infractions.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.lang.NonNull;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

/**
 * Filtre exécuté avant chaque requête pour valider le JWT dans l'en-tête Authorization.
 */
@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private static final Logger logger = LoggerFactory.getLogger(JwtAuthenticationFilter.class);

    private final JwtUtils jwtUtils;
    private final UserDetailsService userDetailsService;

    public JwtAuthenticationFilter(JwtUtils jwtUtils, UserDetailsService userDetailsService) {
        this.jwtUtils = jwtUtils;
        this.userDetailsService = userDetailsService;
    }

    @Override
    protected void doFilterInternal(
            @NonNull HttpServletRequest request,
            @NonNull HttpServletResponse response,
            @NonNull FilterChain filterChain
    ) throws ServletException, IOException {
        // Log request path for easier debugging
        logger.debug("[JWT FILTER] Incoming request: {} {}", request.getMethod(), request.getRequestURI());

        final String authHeader = request.getHeader("Authorization");
        final String jwt;
        final String username;

        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            logger.warn("[JWT FILTER] No or invalid Authorization header for request {}", request.getRequestURI());
            filterChain.doFilter(request, response);
            return;
        }

        jwt = authHeader.substring(7);
        // Extra debug: log a short prefix of the token and attempt to validate informingly
        try {
            final String tokenPreview = jwt.length() > 24 ? jwt.substring(0, 24) + "..." : jwt;
            logger.debug("[JWT FILTER] Received token (preview) for {}: {}", request.getRequestURI(), tokenPreview);

            // Quick validate to print any parsing exceptions
            boolean valid = false;
            try {
                valid = jwtUtils.validateToken(jwt);
                logger.debug("[JWT FILTER] jwtUtils.validateToken => {}", valid);
            } catch (Exception ex) {
                logger.error("[JWT FILTER] Token validation threw: {}", ex.getMessage(), ex);
            }

            username = jwtUtils.extractUsername(jwt);
            logger.debug("[JWT FILTER] Username extracted: {} (token valid={}) for request {}", username, valid, request.getRequestURI());
        } catch (Exception e) {
            logger.error("[JWT FILTER] Error extracting username from JWT", e);
            filterChain.doFilter(request, response);
            return;
        }

        if (username != null && SecurityContextHolder.getContext().getAuthentication() == null) {
            try {
                logger.debug("[JWT FILTER] Loading userDetails for username: {}", username);
                UserDetails userDetails = userDetailsService.loadUserByUsername(username);
                boolean tokenOk = false;
                try {
                    tokenOk = jwtUtils.isTokenValid(jwt, userDetails);
                } catch (Exception ex) {
                    logger.error("[JWT FILTER] isTokenValid threw: {}", ex.getMessage(), ex);
                }
                logger.debug("[JWT FILTER] isTokenValid result for {}: {}", username, tokenOk);
                if (tokenOk) {
                    UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(
                            userDetails,
                            null,
                            userDetails.getAuthorities()
                    );
                    authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                    SecurityContextHolder.getContext().setAuthentication(authToken);
                    logger.debug("[JWT FILTER] Authentication set for user: {} on {}", username, request.getRequestURI());
                } else {
                    logger.warn("[JWT FILTER] JWT validation failed for: {} on {}", username, request.getRequestURI());
                }
            } catch (Exception e) {
                logger.error("[JWT FILTER] Error during authentication for request {}", request.getRequestURI(), e);
            }
        }

        filterChain.doFilter(request, response);
    }
}
