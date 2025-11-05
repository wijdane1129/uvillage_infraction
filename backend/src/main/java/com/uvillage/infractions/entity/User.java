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
    @Column(name = "id")
    private Long id;

    private String email;
    private String fullName;
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
}