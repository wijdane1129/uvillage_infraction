package com.uvillage.infractions.dto;
import jakarta.validation.constraints.*;
import lombok.*;
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ForgotPasswordRequest{
    @NotBlank(message="email is required")
    @Email(message="Enter a valid Email")
    private String email;
}