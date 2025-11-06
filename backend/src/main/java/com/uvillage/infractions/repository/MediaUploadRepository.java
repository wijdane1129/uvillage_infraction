package com.uvillage.infractions.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import com.uvillage.infractions.entity.ContraventionMedia;

import java.util.Optional;

@Repository
public interface MediaUploadRepository extends JpaRepository<ContraventionMedia, Long> {
    Optional<ContraventionMedia> findByMediaUrl(String mediaUrl);
}