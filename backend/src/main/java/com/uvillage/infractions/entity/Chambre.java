package com.uvillage.infractions.entity;
import jakarta.persistence.*;
import lombok.*;
import java.util.List;

@Entity
@Table(name="chambres")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Chambre {
    @Id
    @GeneratedValue(strategy=GenerationType.IDENTITY)
    private Long id;

    @Column(nullable=false)
    private String numero;

    @ManyToOne
    @JoinColumn(name="fk_immeuble", nullable=false)
    private Immeuble immeuble;

    @OneToMany(mappedBy="chambre")
    private List<Resident> residents;

    public String getNumeroChambre() {
        return this.numero;
    }

    public void setNumeroChambre(String numero) {
        this.numero = numero;
    }
}