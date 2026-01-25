package com.uvillage.infractions.service;
import com.uvillage.infractions.repository.ContraventionRepository;
import com.uvillage.infractions.repository.FactureRepository;
import com.uvillage.infractions.dto.ContraventionDto;
import com.uvillage.infractions.entity.Contravention;
import com.uvillage.infractions.entity.ContraventionMedia;
import com.uvillage.infractions.entity.Facture;
import java.util.stream.Collectors;
import java.util.List;
import java.time.LocalDateTime;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.io.IOException;
import java.util.UUID;

@Service
public class ContraventionService {
    @Autowired 
    private ContraventionRepository contraventionRepository;
    
    @Autowired
    private FactureRepository factureRepository;
    
    @Autowired
    private InvoicePdfService invoicePdfService;
    
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
    
    /**
     * Confirme une contravention et génère une facture PDF
     * @param ref La référence de la contravention
     * @return La contravention mise à jour avec l'URL du PDF
     * @throws IOException En cas d'erreur lors de la génération du PDF
     */
    @Transactional
    @SuppressWarnings("null")
    public ContraventionDto confirmContravention(String ref) throws IOException {
        Contravention contravention = contraventionRepository.findByRef(ref)
                .orElseThrow(() -> new RuntimeException("Contravention non trouvée: " + ref));
        
        // Mettre à jour le statut
        contravention.setStatut(Contravention.Status.ACCEPTEE);
        
        // Générer le PDF
        String pdfUrl = invoicePdfService.generateInvoicePdf(contravention);
        
        // Créer et sauvegarder la facture
        Facture facture = Facture.builder()
                .refFacture("FAC-" + contravention.getRef() + "-" + UUID.randomUUID().toString().substring(0, 8))
                .resident(contravention.getTiers())
                .dateCreation(LocalDateTime.now())
                .montantTotal(contravention.getTypeContravention() != null 
                        ? contravention.getTypeContravention().getMontant1() 
                        : 0.0)
                .statut(Facture.Status.IMPAYE)
                .pdfUrl(pdfUrl)
                .build();
        
        Facture savedFacture = factureRepository.save(facture);
        
        // Associer la facture à la contravention
        contravention.setFacture(savedFacture);
        contravention = contraventionRepository.save(contravention);
        
        // Retourner le DTO mise à jour
        return getByRef(ref);
    }
    
}

