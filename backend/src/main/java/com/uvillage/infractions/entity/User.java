package com.uvillage.infractions.entity;
import jakarta.persistence.*;
import lombok.*;
import java.util.List;


@Entity
@Table(name="users")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {
    @Id
    @GeneratedValue(strategy=GenerationType.IDENTITY)
    private Long rowid;

    @Column(unique=true, nullable=false)
    private String username;

    @Column(nullable=false)
    private String password;

    private String nom;
    private String prenom;

    @Column(unique=true)
    private String email;

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