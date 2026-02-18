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
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.uvillage.infractions.dto.ContraventionDTO;
import com.uvillage.infractions.dto.CreateContraventionRequest;
import com.uvillage.infractions.entity.Contravention;
import com.uvillage.infractions.entity.ContraventionMedia;
import com.uvillage.infractions.entity.ContraventionType;
import com.uvillage.infractions.entity.Facture;
import com.uvillage.infractions.entity.Recidive;
import com.uvillage.infractions.entity.Resident;
import com.uvillage.infractions.repository.ContraventionMediaRepository;
import com.uvillage.infractions.repository.ContraventionRepository;
import com.uvillage.infractions.repository.ContraventionTypeRepository;
import com.uvillage.infractions.repository.FactureRepository;
import com.uvillage.infractions.repository.RecidiveRepository;
import com.uvillage.infractions.repository.ResidentRepository;
import com.uvillage.infractions.repository.UserRepository;

import java.io.IOException;

@Service
public class ContraventionService {

    private static final Logger logger = LoggerFactory.getLogger(ContraventionService.class);

    // ----- Repositories -----
    private final ContraventionRepository contraventionRepository;
    private final FactureRepository factureRepository;
    private final ContraventionMediaRepository mediaRepository;

    @Autowired
    private RecidiveRepository recidiveRepository;

    @Autowired
    private InvoicePdfService invoicePdfService;

    @Autowired
    private ResidentMockService residentMockService;

    @Autowired
    public ContraventionService(ContraventionRepository contraventionRepository,
            FactureRepository factureRepository,
            ContraventionMediaRepository mediaRepository) {
        this.contraventionRepository = contraventionRepository;
        this.factureRepository = factureRepository;
        this.mediaRepository = mediaRepository;
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
        int weekCount = (int) contraventionRepository.countByUserAuthor_IdAndDateCreationBetween(agentRowid,
                startOfWeek, endOfWeek);

        Map<String, Integer> stats = new HashMap<>();
        stats.put("todayCount", todayCount);
        stats.put("weekCount", weekCount);
        return stats;
    }

    // -------------------- CONTRAVENTION CRUD --------------------

    // Crée une nouvelle contravention
    @Transactional
    public ContraventionDTO createContravention(CreateContraventionRequest req,
            UserRepository userRepository,
            ContraventionTypeRepository typeRepo,
            ResidentRepository residentRepository,
            ContraventionRepository contraventionRepo) {
        if (req == null)
            throw new IllegalArgumentException("Request null");

        logger.info("🎯 [CREATE] Starting contravention creation");
        
        Contravention c = new Contravention();
        c.setDescription(req.getDescription());
        c.setDateCreation(LocalDate.now());
        c.setRef("CV-" + System.currentTimeMillis());
        c.setNumeroChambre(req.getNumeroChambre());
        c.setBatiment(req.getBatiment());

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
        logger.info("✅ [CREATE] Contravention saved with ref: {}", saved.getRef());

        // Link uploaded media records to this contravention
        if (req.getMediaUrls() != null && !req.getMediaUrls().isEmpty()) {
            logger.info("🔗 [CREATE] Linking {} media files to contravention", req.getMediaUrls().size());
            int linkedCount = 0;
            
            for (String mediaUrl : req.getMediaUrls()) {
                logger.info("🔍 [CREATE] Looking for media with URL: {}", mediaUrl);
                var mediaOpt = mediaRepository.findByMediaUrl(mediaUrl);
                
                if (mediaOpt.isPresent()) {
                    var media = mediaOpt.get();
                    logger.info("✅ [CREATE] Found media ID: {} - linking to contravention", media.getId());
                    media.setContravention(saved);
                    mediaRepository.save(media);
                    linkedCount++;
                    logger.info("✅ [CREATE] Media linked successfully");
                } else {
                    logger.warn("⚠️ [CREATE] Media NOT found for URL: {}", mediaUrl);
                }
            }
            
            logger.info("✅ [CREATE] Linked {}/{} media files", linkedCount, req.getMediaUrls().size());
        } else {
            logger.info("ℹ️ [CREATE] No media URLs provided");
        }

        // Reload contravention to ensure media list is populated
        Contravention reloaded = contraventionRepo.findByRef(saved.getRef()).orElse(saved);
        logger.info("✅ [CREATE] Reloaded contravention, media count: {}", 
            reloaded.getMedia() != null ? reloaded.getMedia().size() : 0);

        return ContraventionDTO.fromEntity(reloaded);
    }

    // Récupère une contravention par sa référence (DTO avec médias)
    public ContraventionDTO getByRef(String ref) {
        logger.info("🔍 [GET] Fetching contravention by ref: {}", ref);
        Contravention c = contraventionRepository.findByRef(ref).orElse(null);
        if (c == null) {
            logger.warn("⚠️ [GET] Contravention not found for ref: {}", ref);
            return null;
        }

        logger.info("✅ [GET] Found contravention - media count: {}", 
            c.getMedia() != null ? c.getMedia().size() : 0);

        // Use the DTO conversion helper (no Lombok builder available)
        return ContraventionDTO.fromEntity(c);
    }

    // Récupère la liste des contraventions pour un résident
    public List<ContraventionDTO> getContraventionsByResident(Long residentId) {
        if (residentId == null)
            return java.util.List.of();
        List<Contravention> list = contraventionRepository.findByTiers_IdOrderByDateCreationDesc(residentId);
        return list.stream().map(ContraventionDTO::fromEntity).collect(java.util.stream.Collectors.toList());
    }

    // -------------------- CONFIRMATION ET FACTURE --------------------

    /**
     * Confirme une contravention et génère une facture PDF
     * Le montant est calculé automatiquement en fonction du nombre de récidives
     * pour le même résident et le même motif.
     */
    @Transactional
    public ContraventionDTO confirmContravention(String ref, String numeroChambre, String batiment) throws IOException {
        Contravention contravention = contraventionRepository.findByRef(ref)
                .orElseThrow(() -> new RuntimeException("Contravention non trouvée: " + ref));

        // NOTE: Do NOT set ACCEPTEE status yet — we must count recidives FIRST,
        // otherwise Hibernate auto-flush includes the current contravention in the count.

        // Store room and building info if provided
        if (numeroChambre != null && !numeroChambre.isEmpty()) {
            contravention.setNumeroChambre(numeroChambre);
        }
        if (batiment != null && !batiment.isEmpty()) {
            contravention.setBatiment(batiment);
        }

        // Load mock resident from CSV data using room/building info
        ResidentMockService.MockResident mockResident = null;
        String roomNum = contravention.getNumeroChambre();
        String building = contravention.getBatiment();
        if (roomNum != null && building != null) {
            mockResident = residentMockService.findByRoom(roomNum, building);
        }

        // ===== RECIDIVE LOGIC =====
        // Count previous ACCEPTEE contraventions with the same motif for the same resident
        // Priority: use fk_tiers (resident ID) if available, fallback to room/building
        ContraventionType contraventionType = contravention.getTypeContravention();
        int recidiveCount = 0;
        if (contraventionType != null) {
            Resident resident = contravention.getTiers();
            if (resident != null && resident.getId() != null) {
                // PRIMARY: Count by resident ID (fk_tiers) — works even when room/building are NULL
                recidiveCount = (int) recidiveRepository.countAcceptedByResidentIdAndType(
                        resident.getId(), contraventionType.getLabel());
                logger.info("🔄 [RECIDIVE] Count by residentId={}, motif={}: {}",
                        resident.getId(), contraventionType.getLabel(), recidiveCount);
            } else if (roomNum != null && building != null) {
                // FALLBACK: Count by room/building (for anonymous contraventions without a resident)
                recidiveCount = (int) recidiveRepository.countAcceptedByRoomBuildingAndType(
                        roomNum, building, contraventionType.getLabel());
                logger.info("🔄 [RECIDIVE] Count by room={}, building={}, motif={}: {}",
                        roomNum, building, contraventionType.getLabel(), recidiveCount);
            } else {
                logger.warn("⚠️ [RECIDIVE] No resident ID and no room/building — cannot count recidives");
            }
        }

        // recidiveCount = number of previously ACCEPTED contraventions with same motif for same resident
        // This current one makes it recidiveCount + 1 (1 = first time, 2 = 2nd time, etc.)
        int occurrence = recidiveCount + 1;

        // NOW set ACCEPTEE status (after counting, so the count is correct)
        contravention.setStatut(Contravention.Status.ACCEPTEE);
        logger.info("🔄 [RECIDIVE] This is occurrence #{} for motif '{}'", occurrence, 
                contraventionType != null ? contraventionType.getLabel() : "unknown");

        // Select the appropriate montant based on recidive count
        Double montant = 0.0;
        if (contraventionType != null) {
            switch (occurrence) {
                case 1:
                    montant = contraventionType.getMontant1();
                    break;
                case 2:
                    montant = contraventionType.getMontant2();
                    break;
                case 3:
                    montant = contraventionType.getMontant3();
                    break;
                default: // 4th time and beyond
                    montant = contraventionType.getMontant4();
                    break;
            }
            logger.info("💰 [RECIDIVE] Montant selected: {} DH (occurrence #{})", montant, occurrence);
        }

        // Générer le PDF avec les données du résident mock et le bon montant
        String pdfUrl = invoicePdfService.generateInvoicePdf(contravention, mockResident, montant, occurrence);

        // Créer et sauvegarder la facture avec le montant correct selon la récidive
        Facture facture = Facture.builder()
                .refFacture("FAC-" + contravention.getRef() + "-" + UUID.randomUUID().toString().substring(0, 8))
                .resident(contravention.getTiers())
                .dateCreation(LocalDateTime.now())
                .montantTotal(montant)
                .statut(Facture.Status.IMPAYE)
                .pdfUrl(pdfUrl)
                .build();

        Facture savedFacture = factureRepository.save(facture);

        // Associer la facture à la contravention
        contravention.setFacture(savedFacture);
        contraventionRepository.save(contravention);

        return getByRef(ref);
    }

    /**
     * Get the recidive count for a given room/building and contravention type label.
     * Returns the number of times this motif has been ACCEPTED for this location.
     */
    public int getRecidiveCount(String numeroChambre, String batiment, String motifLabel) {
        if (numeroChambre == null || batiment == null || motifLabel == null) {
            return 0;
        }
        return (int) recidiveRepository.countAcceptedByRoomBuildingAndType(numeroChambre, batiment, motifLabel);
    }

    /**
     * Get the recidive count for a given resident ID and contravention type label.
     * This is the PRIMARY method — uses resident ID (fk_tiers) to count previous ACCEPTEE contraventions.
     */
    public int getRecidiveCountByResident(Long residentId, String motifLabel) {
        if (residentId == null || motifLabel == null) {
            return 0;
        }
        return (int) recidiveRepository.countAcceptedByResidentIdAndType(residentId, motifLabel);
    }
}
