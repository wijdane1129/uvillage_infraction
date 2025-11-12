package com.uvillage.infractions.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


import java.security.Key;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;

@Service
public class JwtUtils {
    
    private static final Logger logger = LoggerFactory.getLogger(JwtUtils.class);

    // 🚨 CORRECTION : Utilise les noms de propriétés trouvés (jwt.secret)
    @Value("${jwt.secret}")
    private String secretKey;

    // 🚨 CORRECTION : Utilise les noms de propriétés trouvés (jwt.expiration.ms)
    @Value("${jwt.expiration.ms}")
    private long jwtExpiration;

    // --- 1. Extraction des Claims (Informations dans le Token) ---

    public String extractUsername(String token) {
        return extractClaim(token, Claims::getSubject);
    }

    public <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = extractAllClaims(token);
        return claimsResolver.apply(claims);
    }

    private Claims extractAllClaims(String token) {
        // Ajout d'un try-catch pour le débogage :
        try {
            return Jwts
                    .parserBuilder()
                    .setSigningKey(getSignInKey()) // Utilise la clé signée
                    .build()
                    .parseClaimsJws(token)
                    .getBody();
        } catch (io.jsonwebtoken.security.SignatureException e) {
            logger.error("Token signature is invalid or expired: {}", e.getMessage());
            throw new io.jsonwebtoken.security.SignatureException("Invalid JWT signature: " + e.getMessage());
        } catch (Exception e) {
            logger.error("Error extracting claims from token: {}", e.getMessage());
            throw e;
        }
    }

    // --- 2. Génération du Token ---
    
    public String generateToken(UserDetails userDetails) {
        return generateToken(new HashMap<>(), userDetails);
    }

    public String generateToken(
            Map<String, Object> extraClaims,
            UserDetails userDetails
    ) {
        return buildToken(extraClaims, userDetails, jwtExpiration);
    }

    private String buildToken(
            Map<String, Object> extraClaims,
            UserDetails userDetails,
            long expiration
    ) {
        return Jwts
                .builder()
                .setClaims(extraClaims)
                .setSubject(userDetails.getUsername())
                .setIssuedAt(new Date(System.currentTimeMillis()))
                .setExpiration(new Date(System.currentTimeMillis() + expiration))
                .signWith(getSignInKey(), SignatureAlgorithm.HS256)
                .compact();
    }

    // --- 3. Validation du Token ---

    public boolean isTokenValid(String token, UserDetails userDetails) {
        final String username = extractUsername(token);
        return (username.equals(userDetails.getUsername())) && !isTokenExpired(token);
    }

    private boolean isTokenExpired(String token) {
        return extractExpiration(token).before(new Date());
    }

    private Date extractExpiration(String token) {
        return extractClaim(token, Claims::getExpiration);
    }

    // --- 4. Méthode pour obtenir la clé (Génère la clé à partir d'une simple String) ---

    private Key getSignInKey() {
        logger.debug("Using JWT Secret Key: {}", secretKey); 
        byte[] keyBytes = secretKey.getBytes(); 
        return Keys.hmacShaKeyFor(keyBytes);
    }

    public boolean validateToken(String token, UserDetails userDetails) {
        final String username = extractUsername(token);
        return (username.equals(userDetails.getUsername())) && !isTokenExpired(token);
    }
}