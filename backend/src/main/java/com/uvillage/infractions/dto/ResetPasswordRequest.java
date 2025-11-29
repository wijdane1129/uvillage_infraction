package com.uvillage.infractions.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public class ResetPasswordRequest {
    @NotBlank(message = "Enter a valid password")
    @Size(min = 8, message = "Password must be at least 8 characters")
    @Pattern(
        regexp = "^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%^&+=])(?=\\S+$).{8,}$",
        message = "Password must contain at least one digit, one lowercase, one uppercase, one special character"
    )
        private String password;

    @NotBlank(message = "Confirm password is required")
        private String confirmPassword;

    @NotBlank(message = "Reset token is required")
        private String token;
    
    public ResetPasswordRequest() {}

    public ResetPasswordRequest(String password, String confirmPassword, String token) {
        this.password = password;
        this.confirmPassword = confirmPassword;
        this.token = token;
    }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getConfirmPassword() { return confirmPassword; }
    public void setConfirmPassword(String confirmPassword) { this.confirmPassword = confirmPassword; }
    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }
}