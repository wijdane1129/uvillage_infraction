package com.uvillage.infractions.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EditProfileRequest {
    // The email of the user to update (used to look up the user). In a real app
    // you'd derive the user from the authenticated principal instead.
    private String email;

    private String fullName;

    private String password;

    private String language;

    private String username;
}
