// Fichier : src/main/java/com/uvillage/infractions/repository/ContraventionRepository.java

package com.uvillage.infractions.repository;

import com.uvillage.infractions.entity.Contravention;
import org.springframework.data.jpa.repository.JpaRepository; 
import java.time.LocalDate; 
import java.util.List; 
import org.springframework.data.jpa.repository.Query; // L'annotation @Query pourrait nécessiter un import

public interface ContraventionRepository extends JpaRepository<Contravention, Long> {

    // Suppression des commentaires ou du texte non valide :
    // findByUserAuthor_RowidOrderByDateCreationDesc est un Query Method Naming correct
    List<Contravention> findByUserAuthor_RowidOrderByDateCreationDesc(Long userAuthorRowid); 

    // Les lignes 15 et 18 étaient probablement ici et doivent être supprimées/nettoyées
    long countByUserAuthor_RowidAndDateCreation(Long userAuthorRowid, LocalDate dateCreation);

    long countByUserAuthor_RowidAndDateCreationBetween(Long userAuthorRowid, LocalDate startDate, LocalDate endDate);
}