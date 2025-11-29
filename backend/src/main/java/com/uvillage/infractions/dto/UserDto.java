package com.uvillage.infractions.dto;

import com.uvillage.infractions.entity.User;

/**
 * Simple DTO for User used in other DTO mappings.
 * Implemented without Lombok to avoid annotation-processing dependency issues
 * when the IDE annotation processor is unavailable.
 */
public class UserDto {
    // Fields to expose for the author (Agent)
    private Long id;
    private String username;
    private String fullName;
    private String email;
    private String role;

    public UserDto() {
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public static UserDto fromEntity(User user) {
        if (user == null) return null;
        UserDto dto = new UserDto();
        dto.setId(user.getId());
        dto.setUsername(user.getUsername());
        dto.setFullName(user.getFullName());
        dto.setEmail(user.getEmail());
        if (user.getRole() != null) dto.setRole(user.getRole().name());
        return dto;
    }
}
