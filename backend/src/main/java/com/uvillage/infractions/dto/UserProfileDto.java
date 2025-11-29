package com.uvillage.infractions.dto;

public class UserProfileDto {
    private Long id;
    private String email;
    private String fullName;
    private String username;
    private String language;
    private boolean emailVerified;

    public UserProfileDto() {}

    public UserProfileDto(Long id, String email, String fullName, String username, String language, boolean emailVerified) {
        this.id = id;
        this.email = email;
        this.fullName = fullName;
        this.username = username;
        this.language = language;
        this.emailVerified = emailVerified;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getLanguage() { return language; }
    public void setLanguage(String language) { this.language = language; }
    public boolean isEmailVerified() { return emailVerified; }
    public void setEmailVerified(boolean emailVerified) { this.emailVerified = emailVerified; }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private Long id;
        private String email;
        private String fullName;
        private String username;
        private String language;
        private boolean emailVerified;

        public Builder id(Long id) { this.id = id; return this; }
        public Builder email(String email) { this.email = email; return this; }
        public Builder fullName(String fullName) { this.fullName = fullName; return this; }
        public Builder username(String username) { this.username = username; return this; }
        public Builder language(String language) { this.language = language; return this; }
        public Builder emailVerified(boolean emailVerified) { this.emailVerified = emailVerified; return this; }

        public UserProfileDto build() {
            return new UserProfileDto(id, email, fullName, username, language, emailVerified);
        }
    }
}
