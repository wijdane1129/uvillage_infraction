package com.uvillage.infractions.dto;

public class EditProfileRequest {
    // The email of the user to update (used to look up the user). In a real app
    // you'd derive the user from the authenticated principal instead.
    private String email;

    private String fullName;

    private String password;

    private String language;

    private String username;

    public EditProfileRequest() {}

    public EditProfileRequest(String email, String fullName, String password, String language, String username) {
        this.email = email;
        this.fullName = fullName;
        this.password = password;
        this.language = language;
        this.username = username;
    }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getLanguage() { return language; }
    public void setLanguage(String language) { this.language = language; }
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
}
