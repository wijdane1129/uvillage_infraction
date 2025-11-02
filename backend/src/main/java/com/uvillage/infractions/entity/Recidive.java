package com.uvillage.infractions.entity;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name="recidives")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Recidive {
    @Id
    @GeneratedValue(strategy=GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name="fk_resident", nullable=false)
    private Resident resident;

    @ManyToOne
    @JoinColumn(name="fk_contravention_type", nullable=false)
    private ContraventionType contraventionType;

    @Column(nullable=false)
    private Integer nbRecidives = 0;
}