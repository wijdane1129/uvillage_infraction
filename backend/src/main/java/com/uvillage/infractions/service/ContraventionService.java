package com.uvillage.infractions.service;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.TemporalAdjusters;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.uvillage.infractions.dto.ContraventionDTO;
import com.uvillage.infractions.dto.CreateContraventionRequest;
import com.uvillage.infractions.entity.Contravention;
import com.uvillage.infractions.entity.ContraventionMedia;
import com.uvillage.infractions.entity.Facture;
import com.uvillage.infractions.repository.ContraventionRepository;
import com.uvillage.infractions.repository.ContraventionTypeRepository;
import com.uvillage.infractions.repository.FactureRepository;
import com.uvillage.infractions.repository.ResidentRepository;
import com.uvillage.infractions.repository.UserRepository;

import java.io.IOException;

@Service
public class ContraventionService {

    // ----- Repositories -----
    private final ContraventionRepository contraventionRepository;
    private final FactureRepository factureRepository;

    @Autowired
    private InvoicePdfService invoicePdfService;

    @Autowired
    public ContraventionService(ContraventionRepository contraventionRepository,
                                FactureRepository factureRepository) {
        this.contraventionRepository = contraventionRepository;
        this.factureRepository = factureRepository;
    }

    // -------------------- HISTORIQUE ET STATISTIQUES --------------------

    // Récupère l'historique des infractions de l'agent
    public List<ContraventionDTO> getInfractionsHistoryByAgent(Long agentRowid) {
        return contraventionRepository.findByUserAuthor_IdOrderByDateCreationDesc(agentRowid)
                .stream()
                .map(ContraventionDTO::fromEntity)
                .collect(Collectors.toList());
    }

    // Calcule les statistiques Jour/Semaine
    public Map<String, Integer> getInfractionStatsForAgent(Long agentRowid) {
        LocalDate today = LocalDate.now();
        LocalDate startOfWeek = today.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
        LocalDate endOfWeek = today.with(TemporalAdjusters.nextOrSame(DayOfWeek.SUNDAY));

        int todayCount = (int) contraventionRepository.countByUserAuthor_IdAndDateCreation(agentRowid, today);
        int weekCount = (int) contraventionRepository.countByUserAuthor_IdAndDateCreationBetween(agentRowid, startOfWeek, endOfWeek);

        Map<String, Integer> stats = new HashMap<>();
        stats.put("todayCount", todayCount);
        stats.put("weekCount", weekCount);
        return stats;
    }

    // -------------------- CONTRAVENTION CRUD --------------------

    // Crée une nouvelle contravention
    public ContraventionDTO createContravention(CreateContraventionRequest req,
                                               UserRepository userRepository,
                                               ContraventionTypeRepository typeRepo,
                                               ResidentRepository residentRepository,
                                               ContraventionRepository contraventionRepo) {
        if (req == null) throw new IllegalArgumentException("Request null");

        Contravention c = new Contravention();
        c.setDescription(req.getDescription());
        c.setDateCreation(LocalDate.now());
        c.setRef("CV-" + System.currentTimeMillis());

        if (req.getUserAuthorId() != null) {
            userRepository.findById(req.getUserAuthorId()).ifPresent(c::setUserAuthor);
        }

        if (req.getTypeLabel() != null && !req.getTypeLabel().isEmpty()) {
            var typeOpt = typeRepo.findByLabel(req.getTypeLabel());
            if (typeOpt.isPresent()) {
                c.setTypeContravention(typeOpt.get());
            } else {
                throw new IllegalArgumentException("Type d'infraction inconnu: '" + req.getTypeLabel() + "'");
            }
        } else {
            throw new IllegalArgumentException("Le champ typeLabel est obligatoire.");
        }

        if (req.getTiersId() != null) {
            residentRepository.findById(req.getTiersId()).ifPresent(c::setTiers);
        }

        Contravention saved = contraventionRepo.save(c);
        return ContraventionDTO.fromEntity(saved);
    }

    // Récupère une contravention par sa référence (DTO avec médias)
    public ContraventionDTO getByRef(String ref) {
        Contravention c = contraventionRepository.findByRef(ref).orElse(null);
        if (c == null) return null;

        List<String> media = (c.getMedia() == null) ? List.of() : c.getMedia().stream()
                .map(ContraventionMedia::getMediaUrl)
                .collect(Collectors.toList());

        String userAuthor = "";
        if (c.getUserAuthor() != null) {
            userAuthor = (c.getUserAuthor().getFullName() != null && !c.getUserAuthor().getFullName().isEmpty())
                    ? c.getUserAuthor().getFullName()
                    : c.getUserAuthor().getUsername();
        }

        return ContraventionDTO.builder()
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

    // -------------------- CONFIRMATION ET FACTURE --------------------

    /**
     * Confirme une contravention et génère une facture PDF
     * @param ref La référence de la contravention
     * @return La contravention mise à jour avec l'URL du PDF
     * @throws IOException En cas d'erreur lors de la génération du PDF
     */
    @Transactional
    public ContraventionDTO confirmContravention(String ref) throws IOException {
        Contravention contravention = contraventionRepository.findByRef(ref)
                .orElseThrow(() -> new RuntimeException("Contravention non trouvée: " + ref));

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
        contraventionRepository.save(contravention);

        return getByRef(ref);
    }
}
