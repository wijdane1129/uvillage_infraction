package com.uvillage.infractions.service;
import com.uvillage.infractions.repository.ContraventionRepository;
import com.uvillage.infractions.dto.ContraventionDto;
import com.uvillage.infractions.entity.Contravention;
import com.uvillage.infractions.entity.ContraventionMedia;
import java.util.stream.Collectors;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class ContraventionService {
    @Autowired 
    private ContraventionRepository contraventionRepository;
    
    public ContraventionDto getByRef(String ref) {
        Contravention c = contraventionRepository.findByRef(ref).orElse(null);
        if (c == null) return null;

        List<String> media = (c.getMedia() == null) ? List.of() : c.getMedia().stream()
                .map(ContraventionMedia::getMediaUrl)
                .collect(Collectors.toList());

        String userAuthor = "";
        if (c.getUserAuthor() != null) {
            if (c.getUserAuthor().getFullName() != null && !c.getUserAuthor().getFullName().isEmpty()) {
                userAuthor = c.getUserAuthor().getFullName();
            } else {
                userAuthor = c.getUserAuthor().getUsername();
            }
        }

        return ContraventionDto.builder()
                .ref(c.getRef())
                .rowid(c.getRowid())
                .status(c.getStatut() != null ? c.getStatut().name() : "")
                .dateTime(c.getDateCreation() != null ? c.getDateCreation().toString() : "")
                .motif(c.getTypeContravention() != null ? c.getTypeContravention().getLabel() : "")
                .tiers(c.getTiers() != null ? c.getTiers().toString() : "")
                .userAuthor(userAuthor)
                .description(c.getDescription())
                .media(media)
                .build();
    }
    
}
