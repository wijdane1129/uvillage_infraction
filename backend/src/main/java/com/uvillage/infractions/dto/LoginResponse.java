package com.uvillage.infractions.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

/**
 * DTO utilisé pour renvoyer le jeton JWT à l'utilisateur après une connexion réussie.
 */
@Data
@AllArgsConstructor
public class LoginResponse {
    private String token;
    private String tokenType = "Bearer";
    private String email;
}
