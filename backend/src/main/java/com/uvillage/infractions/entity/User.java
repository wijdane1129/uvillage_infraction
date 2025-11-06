package com.uvillage.infractions.entity;
import jakarta.persistence.*;
import lombok.*;
import java.util.List;
import java.time.LocalDateTime;



@Entity
@Table(name="users")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
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
    @Builder.Default
    private boolean emailVerified = false;
    
    @Column(nullable = false)
    @Builder.Default
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
}