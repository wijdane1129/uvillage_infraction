package com.uvillage.infractions.entity;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name="password_reset_tokens")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PasswordResetToken {
    @Id
    @GeneratedValue(strategy=GenerationType.IDENTITY)
    private Long id;

    @Column(nullable=false, unique=true)
    private String token;

    @Column(nullable=false)
    private String code; 

    @ManyToOne
    @JoinColumn(name="fk_user", nullable=false)
    private User user;

    @Column(nullable=false)
    private LocalDateTime expiryDate;

    @Column(nullable=false)
    private Boolean used = false;
}