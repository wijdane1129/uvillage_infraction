package com.uvillage.infractions.service;

import com.uvillage.infractions.entity.Contravention;
import com.uvillage.infractions.entity.ContraventionMedia;
import com.uvillage.infractions.repository.MediaUploadRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;

@Service
public class MediaUploadService {

    @Autowired
    private MediaUploadRepository mediaUploadRepository;

    private final Path uploadRoot = Path.of(System.getProperty("user.dir"), "uploads");

    public MediaUploadService() {
        try {
            Files.createDirectories(uploadRoot);
        } catch (IOException e) {
            // ignore for now
        }
    }

    public ContraventionMedia uploadMedia(Long contraventionId, MultipartFile file, String mediaType) {
        try {
            String filename = System.currentTimeMillis() + "_" + file.getOriginalFilename();
            Path target = uploadRoot.resolve(filename);
            Files.copy(file.getInputStream(), target, StandardCopyOption.REPLACE_EXISTING);

            ContraventionMedia media = ContraventionMedia.builder()
                    .mediaUrl(filename)
                    .mediaType(ContraventionMedia.MediaType.valueOf(mediaType))
                    .build();

            // If contravention entity is needed, it can be set here. For simplicity
            // we leave it null (the FK was relaxed to nullable). Optionally, you
            // can fetch Contravention by id and set it.

            return mediaUploadRepository.save(media);
        } catch (IOException ex) {
            throw new RuntimeException("Failed to store file", ex);
        }
    }

    public ContraventionMedia getMediaById(Long id) {
        return mediaUploadRepository.findById(id).orElse(null);
    }

    public void deleteMedia(Long id) {
        mediaUploadRepository.deleteById(id);
    }

    public ContraventionMedia updateMedia(Long id, String mediaUrl, String mediaType) {
        var existing = mediaUploadRepository.findById(id).orElse(null);
        if (existing == null)
            return null;
        existing.setMediaUrl(mediaUrl);
        existing.setMediaType(ContraventionMedia.MediaType.valueOf(mediaType));
        return mediaUploadRepository.save(existing);
    }
}
