package com.uvillage.infractions.controller;

import com.uvillage.infractions.entity.ContraventionMedia;
import com.uvillage.infractions.service.MediaUploadService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/contravention/media")
public class MediaUploadController {

    @Autowired
    private MediaUploadService mediaUploadService;

    @PostMapping(value = "/upload/{contraventionId}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ContraventionMedia> uploadMedia(
            @PathVariable Long contraventionId,
            @RequestPart("file") MultipartFile file,
            @RequestPart("mediaType") String mediaType) {

        ContraventionMedia media = mediaUploadService.uploadMedia(contraventionId, file, mediaType);
        return new ResponseEntity<>(media, HttpStatus.CREATED);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ContraventionMedia> getMediaById(@PathVariable Long id) {
        ContraventionMedia media = mediaUploadService.getMediaById(id);
        if (media == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
        return ResponseEntity.ok(media);
    }

    @PutMapping("/{id}")
    public ResponseEntity<ContraventionMedia> updateMedia(@PathVariable Long id,
                                                          @RequestBody java.util.Map<String, String> body) {
        String mediaUrl = body.get("mediaUrl");
        String mediaType = body.get("mediaType");
        ContraventionMedia updated = mediaUploadService.updateMedia(id, mediaUrl, mediaType);
        if (updated == null) return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteMedia(@PathVariable Long id) {
        mediaUploadService.deleteMedia(id);
        return ResponseEntity.status(HttpStatus.NO_CONTENT).build();
    }
}
