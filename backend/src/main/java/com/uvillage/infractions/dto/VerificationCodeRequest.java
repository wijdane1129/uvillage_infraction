package com.uvillage.infractions.dto;
import jakarta.validation.constraints.*;
import lombok.*;
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class VerificationCodeRequest{
    @NotBlank(message="Email is required ")
    @Email(message="Please provide a valid email address")
    private String email;

    @NotBlank(message="Verification code is required")
    @Pattern(regexp="^[0-9]{6}$",message="Code must be exactly 6 digits")
    private String code;
}