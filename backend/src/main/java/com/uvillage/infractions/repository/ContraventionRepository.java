// Fichier : src/main/java/com/uvillage/infractions/repository/ContraventionRepository.java

package com.uvillage.infractions.repository;

import com.uvillage.infractions.entity.Contravention;
import org.springframework.data.jpa.repository.JpaRepository; 
import java.time.LocalDate; 
import java.util.List; 
import org.springframework.data.jpa.repository.Query; // L'annotation @Query pourrait nécessiter un import

public interface ContraventionRepository extends JpaRepository<Contravention, Long> {

    // Query methods using 'Id' instead of 'Rowid' (User entity uses 'id' field mapped to 'rowid' column)
    List<Contravention> findByUserAuthor_IdOrderByDateCreationDesc(Long userAuthorId); 

    long countByUserAuthor_IdAndDateCreation(Long userAuthorId, LocalDate dateCreation);

    long countByUserAuthor_IdAndDateCreationBetween(Long userAuthorId, LocalDate startDate, LocalDate endDate);
}