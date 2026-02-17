package com.uvillage.infractions.controller;

import com.uvillage.infractions.entity.ContraventionMedia;
import com.uvillage.infractions.entity.Contravention;
import com.uvillage.infractions.repository.ContraventionMediaRepository;
import com.uvillage.infractions.repository.ContraventionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/media")
@CrossOrigin(origins = "*")
public class MediaUploadController {

    private static final Logger logger = LoggerFactory.getLogger(MediaUploadController.class);

    @Value("${uploads.dir:./uploads}")
    private String uploadsDir;

    @Autowired
    private ContraventionMediaRepository mediaRepository;

    @Autowired
    private ContraventionRepository contraventionRepository;

    /**
     * Upload a media file and optionally associate it with a contravention
     */
    @PostMapping(value = "/upload", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> uploadMedia(
            @RequestParam("file") MultipartFile file,
            @RequestParam("mediaType") String mediaType,
            @RequestParam(value = "contraventionRef", required = false) String contraventionRef) {
        
        try {
            logger.info("📤 Starting media upload - file: {}, type: {}, ref: {}", 
                file.getOriginalFilename(), mediaType, contraventionRef);

            // Create uploads directory if it doesn't exist
            File uploadDir = new File(uploadsDir);
            if (!uploadDir.exists()) {
                boolean created = uploadDir.mkdirs();
                logger.info("📁 Uploads directory: {} (created: {})", uploadsDir, created);
                if (!created && !uploadDir.exists()) {
                    logger.error("❌ Failed to create uploads directory: {}", uploadsDir);
                    return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                        .body(Map.of("success", false, "message", "Cannot create uploads directory"));
                }
            }

            // Validate file
            if (file.isEmpty()) {
                logger.error("❌ Uploaded file is empty");
                return ResponseEntity.badRequest()
                    .body(Map.of("success", false, "message", "File is empty"));
            }

            logger.info("✅ File size: {} bytes", file.getSize());

            // Generate unique filename
            String originalFilename = file.getOriginalFilename();
            String extension = "";
            if (originalFilename != null && originalFilename.contains(".")) {
                extension = originalFilename.substring(originalFilename.lastIndexOf("."));
            }
            String filename = UUID.randomUUID().toString() + extension;
            
            // Save file to disk
            Path targetPath = Paths.get(uploadsDir, filename);
            logger.info("💾 Saving file to: {}", targetPath.toAbsolutePath());
            Files.copy(file.getInputStream(), targetPath, StandardCopyOption.REPLACE_EXISTING);
            logger.info("✅ File saved successfully");

            // Create media URL (relative path that frontend can access)
            String mediaUrl = "uploads/" + filename;

            // Create media entity
            try {
                ContraventionMedia.MediaType type = ContraventionMedia.MediaType.valueOf(mediaType.toUpperCase());
                logger.info("✅ Media type parsed: {}", type);
                
                ContraventionMedia media = ContraventionMedia.builder()
                    .mediaUrl(mediaUrl)
                    .mediaType(type)
                    .build();

                // Associate with contravention if reference provided
                if (contraventionRef != null && !contraventionRef.isEmpty()) {
                    Contravention contravention = contraventionRepository.findByRef(contraventionRef)
                            .orElse(null);
                    if (contravention != null) {
                        media.setContravention(contravention);
                        logger.info("✅ Associated media with contravention: {}", contraventionRef);
                    } else {
                        logger.warn("⚠️ Contravention not found for ref: {}", contraventionRef);
                    }
                } else {
                    logger.info("ℹ️ No contravention ref provided - media created standalone");
                }

                media = mediaRepository.save(media);
                logger.info("✅ Media entity saved with ID: {}", media.getId());

                // Return response with media info
                Map<String, Object> response = new HashMap<>();
                response.put("success", true);
                response.put("id", media.getId());
                response.put("mediaUrl", mediaUrl);
                response.put("mediaType", mediaType);
                response.put("message", "Media uploaded successfully");

                return ResponseEntity.ok(response);
            } catch (IllegalArgumentException e) {
                logger.error("❌ Invalid media type: {}", mediaType, e);
                return ResponseEntity.badRequest()
                    .body(Map.of("success", false, "message", "Invalid media type: " + mediaType));
            }
        } catch (IOException e) {
            logger.error("❌ IOException during file upload", e);
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("message", "I/O Error: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        } catch (Exception e) {
            logger.error("❌ UNEXPECTED ERROR during media upload", e);
            e.printStackTrace();
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("message", "Server error: " + e.getClass().getSimpleName() + " - " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }

    /**
     * Get media file by ID (for downloading/viewing)
     */
    @GetMapping("/{id}")
    public ResponseEntity<?> getMedia(@PathVariable Long id) {
        try {
            ContraventionMedia media = mediaRepository.findById(id)
                    .orElseThrow(() -> new RuntimeException("Media not found"));

            Map<String, Object> response = new HashMap<>();
            response.put("id", media.getId());
            response.put("mediaUrl", media.getMediaUrl());
            response.put("mediaType", media.getMediaType().toString());

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            logger.error("❌ Error fetching media", e);
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("success", false, "message", "Media not found"));
        }
    }

    /**
     * Delete media by ID
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteMedia(@PathVariable Long id) {
        try {
            ContraventionMedia media = mediaRepository.findById(id)
                    .orElseThrow(() -> new RuntimeException("Media not found"));

            // Delete file from disk
            String mediaUrl = media.getMediaUrl();
            if (mediaUrl.startsWith("uploads/")) {
                Path filePath = Paths.get(uploadsDir, mediaUrl.substring(8));
                Files.deleteIfExists(filePath);
                logger.info("✅ Deleted file: {}", filePath);
            }

            // Delete from database
            mediaRepository.deleteById(id);
            logger.info("✅ Deleted media from database: {}", id);

            return ResponseEntity.ok(Map.of("success", true, "message", "Media deleted"));
        } catch (Exception e) {
            logger.error("❌ Error deleting media", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("success", false, "message", "Error deleting media"));
        }
    }
}