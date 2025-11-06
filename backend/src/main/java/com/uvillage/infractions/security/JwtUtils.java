package com.uvillage.infractions.security;

import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;

/**
 * Utilitaires pour la manipulation des JSON Web Tokens (JWT).
 */
@Component
public class JwtUtils {

    // Clé secrète stockée dans application.properties
    @Value("${jwt.secret:defaultSecretKeyForDevelopmentOnlyPleaseChangeMeInProd}")
    private String jwtSecret;

    @Value("${jwt.expiration.ms:86400000}") // 24 hours
    private long jwtExpirationMs;

    // --- Génération de Token ---

    /**
     * Génère un JWT pour l'utilisateur.
     */
    public String generateToken(UserDetails userDetails) {
        Map<String, Object> claims = new HashMap<>();
        // Ajoutez l'email (username) au claims pour être sûr
        claims.put("email", userDetails.getUsername());
        return createToken(claims, userDetails.getUsername());
    }

    private String createToken(Map<String, Object> claims, String subject) {
        return Jwts.builder()
                .setClaims(claims)
                .setSubject(subject) // Le sujet est généralement l'email/ID de l'utilisateur
                .setIssuedAt(new Date(System.currentTimeMillis()))
                .setExpiration(new Date(System.currentTimeMillis() + jwtExpirationMs))
                .signWith(getSigningKey(), SignatureAlgorithm.HS256)
                .compact();
    }

    // --- Validation et Extraction ---

    public String extractUsername(String token) {
        return extractClaim(token, Claims::getSubject);
    }

    public Date extractExpiration(String token) {
        return extractClaim(token, Claims::getExpiration);
    }

    public <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = extractAllClaims(token);
        return claimsResolver.apply(claims);
    }

    private Claims extractAllClaims(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(getSigningKey())
                .build()
                .parseClaimsJws(token)
                .getBody();
    }

    // Dans com.uvillage.infractions.security.JwtUtils
// ...
private Key getSigningKey() {
    // Utiliser le décodeur BASE64URL pour décoder la clé.
    // BASE64URL gère les caractères '-' et '_' (URL-safe).
    // Ceci est la méthode recommandée par jjwt pour décoder les clés Base64.
    try {
        byte[] keyBytes = Decoders.BASE64URL.decode(jwtSecret);
        return Keys.hmacShaKeyFor(keyBytes);
    } catch (Exception e) {
        // Si la clé n'est pas une chaîne Base64 URL-safe valide (ex: c'est une chaîne brute),
        // nous utilisons la chaîne brute encodée en UTF-8.
        return Keys.hmacShaKeyFor(jwtSecret.getBytes(StandardCharsets.UTF_8));
    }
}
// ...

    private boolean isTokenExpired(String token) {
        return extractExpiration(token).before(new Date());
    }

    public boolean validateToken(String token, UserDetails userDetails) {
        final String username = extractUsername(token);
        return (username.equals(userDetails.getUsername()) && !isTokenExpired(token));
    }
}
