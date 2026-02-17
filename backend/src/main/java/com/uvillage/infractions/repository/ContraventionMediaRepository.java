package com.uvillage.infractions.repository;

import com.uvillage.infractions.entity.ContraventionMedia;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Repository for ContraventionMedia entity
 * Extends JpaRepository to inherit CRUD operations (save, findById, deleteById, etc.)
 */
@Repository
public interface ContraventionMediaRepository extends JpaRepository<ContraventionMedia, Long> {
    
    /**
     * Find media by URL
     */
    Optional<ContraventionMedia> findByMediaUrl(String mediaUrl);
    
    /**
     * Find all media for a contravention by its reference
     */
    List<ContraventionMedia> findByContravention_Ref(String contraventionRef);
    
    /**
     * Find all media for a contravention by its rowid
     */
    List<ContraventionMedia> findByContravention_Rowid(Long contraventionRowid);
}