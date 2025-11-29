package com.uvillage.infractions.entity;

import jakarta.persistence.*;
import java.util.List;
import java.time.LocalDateTime;



@Entity
@Table(name="users")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    // Map the entity id to the existing database primary key column `rowid`.
    // The DB already has `rowid` as AUTO_INCREMENT, so mapping avoids Hibernate
    // attempting to create a second auto column named `id`.
    @Column(name = "rowid")
    private Long id;

    private String email;
    @Column(name = "full_name")
    private String fullName;
    
    @Column(name = "username", nullable = false)
    private String username;
    private String password;

    private String resetToken;
    private LocalDateTime resetTokenExpiry;
    private String resetPasswordToken;
    private LocalDateTime resetTokenExpiryDate;
    private String verificationCode;
    private LocalDateTime codeExpiryTime;

    @Column(nullable = false)
    private boolean emailVerified = false;
    
    @Column(nullable = false)
    private boolean locked = false;

    @Enumerated(EnumType.STRING)
    private Role role;

    @OneToMany(mappedBy="userAuthor")
    private List<Contravention> contraventions;

    public enum Role{
        ADMIN,
        AGENT,
        RESPONSABLE
    }

    private String language;

    public User() {}

    public User(Long id, String email, String fullName, String username, String password, String resetToken,
                LocalDateTime resetTokenExpiry, String resetPasswordToken, LocalDateTime resetTokenExpiryDate,
                String verificationCode, LocalDateTime codeExpiryTime, boolean emailVerified, boolean locked,
                Role role, List<Contravention> contraventions, String language) {
        this.id = id;
        this.email = email;
        this.fullName = fullName;
        this.username = username;
        this.password = password;
        this.resetToken = resetToken;
        this.resetTokenExpiry = resetTokenExpiry;
        this.resetPasswordToken = resetPasswordToken;
        this.resetTokenExpiryDate = resetTokenExpiryDate;
        this.verificationCode = verificationCode;
        this.codeExpiryTime = codeExpiryTime;
        this.emailVerified = emailVerified;
        this.locked = locked;
        this.role = role;
        this.contraventions = contraventions;
        this.language = language;
    }

    // Manual builder to avoid Lombok dependency during compilation
    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private Long id;
        private String email;
        private String fullName;
        private String username;
        private String password;
        private String resetToken;
        private LocalDateTime resetTokenExpiry;
        private String resetPasswordToken;
        private LocalDateTime resetTokenExpiryDate;
        private String verificationCode;
        private LocalDateTime codeExpiryTime;
        private boolean emailVerified = false;
        private boolean locked = false;
        private Role role;
        private List<Contravention> contraventions;
        private String language;

        public Builder id(Long id) { this.id = id; return this; }
        public Builder email(String email) { this.email = email; return this; }
        public Builder fullName(String fullName) { this.fullName = fullName; return this; }
        public Builder username(String username) { this.username = username; return this; }
        public Builder password(String password) { this.password = password; return this; }
        public Builder resetToken(String resetToken) { this.resetToken = resetToken; return this; }
        public Builder resetTokenExpiry(LocalDateTime dt) { this.resetTokenExpiry = dt; return this; }
        public Builder resetPasswordToken(String token) { this.resetPasswordToken = token; return this; }
        public Builder resetTokenExpiryDate(LocalDateTime dt) { this.resetTokenExpiryDate = dt; return this; }
        public Builder verificationCode(String code) { this.verificationCode = code; return this; }
        public Builder codeExpiryTime(LocalDateTime dt) { this.codeExpiryTime = dt; return this; }
        public Builder emailVerified(boolean v) { this.emailVerified = v; return this; }
        public Builder locked(boolean v) { this.locked = v; return this; }
        public Builder role(Role role) { this.role = role; return this; }
        public Builder contraventions(List<Contravention> list) { this.contraventions = list; return this; }
        public Builder language(String language) { this.language = language; return this; }

        public User build() {
            return new User(id, email, fullName, username, password, resetToken, resetTokenExpiry,
                    resetPasswordToken, resetTokenExpiryDate, verificationCode, codeExpiryTime,
                    emailVerified, locked, role, contraventions, language);
        }
    }

    // Explicit getter/setter for `password` to ensure IDEs and the compiler
    // can access the property even if Lombok annotation processing fails
    // in the development environment.
    public String getPassword() {
        return this.password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public Long getId() {
        return this.id;
    }

    public String getEmail() {
        return this.email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getFullName() {
        return this.fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getUsername() {
        return this.username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getResetToken() {
        return this.resetToken;
    }

    public void setResetToken(String resetToken) {
        this.resetToken = resetToken;
    }

    public LocalDateTime getResetTokenExpiry() {
        return this.resetTokenExpiry;
    }

    public void setResetTokenExpiry(LocalDateTime resetTokenExpiry) {
        this.resetTokenExpiry = resetTokenExpiry;
    }

    public String getResetPasswordToken() {
        return this.resetPasswordToken;
    }

    public void setResetPasswordToken(String resetPasswordToken) {
        this.resetPasswordToken = resetPasswordToken;
    }

    public LocalDateTime getResetTokenExpiryDate() {
        return this.resetTokenExpiryDate;
    }

    public void setResetTokenExpiryDate(LocalDateTime resetTokenExpiryDate) {
        this.resetTokenExpiryDate = resetTokenExpiryDate;
    }

    public String getVerificationCode() {
        return this.verificationCode;
    }

    public void setVerificationCode(String verificationCode) {
        this.verificationCode = verificationCode;
    }

    public LocalDateTime getCodeExpiryTime() {
        return this.codeExpiryTime;
    }

    public void setCodeExpiryTime(LocalDateTime codeExpiryTime) {
        this.codeExpiryTime = codeExpiryTime;
    }

    public boolean isEmailVerified() {
        return this.emailVerified;
    }

    public void setEmailVerified(boolean emailVerified) {
        this.emailVerified = emailVerified;
    }

    public boolean isLocked() {
        return this.locked;
    }

    public void setLocked(boolean locked) {
        this.locked = locked;
    }

    public Role getRole() {
        return this.role;
    }

    public void setRole(Role role) {
        this.role = role;
    }

    public String getLanguage() {
        return this.language;
    }

    public void setLanguage(String language) {
        this.language = language;
    }
}