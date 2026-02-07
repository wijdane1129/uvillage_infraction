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
    private ResidentMockService residentMockService;

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
        return ContraventionDTO.fromEntity(saved);
    }

    // Récupère une contravention par sa référence (DTO avec médias)
    public ContraventionDTO getByRef(String ref) {
        Contravention c = contraventionRepository.findByRef(ref).orElse(null);
        if (c == null) return null;

        // Use the DTO conversion helper (no Lombok builder available)
        return ContraventionDTO.fromEntity(c);
    }

    // Récupère la liste des contraventions pour un résident
    public List<ContraventionDTO> getContraventionsByResident(Long residentId) {
        if (residentId == null) return java.util.List.of();
        List<Contravention> list = contraventionRepository.findByTiers_IdOrderByDateCreationDesc(residentId);
        return list.stream().map(ContraventionDTO::fromEntity).collect(java.util.stream.Collectors.toList());
    }

    // -------------------- CONFIRMATION ET FACTURE --------------------

    /**
     * Confirme une contravention et génère une facture PDF
     * @param ref La référence de la contravention
     * @param numeroChambre Le numéro de chambre du résident (optionnel)
     * @param batiment Le bâtiment du résident (optionnel)
     * @return La contravention mise à jour avec l'URL du PDF
     * @throws IOException En cas d'erreur lors de la génération du PDF
     */
    @Transactional
    public ContraventionDTO confirmContravention(String ref, String numeroChambre, String batiment) throws IOException {
        Contravention contravention = contraventionRepository.findByRef(ref)
                .orElseThrow(() -> new RuntimeException("Contravention non trouvée: " + ref));

        contravention.setStatut(Contravention.Status.ACCEPTEE);
        
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

        // Générer le PDF avec les données du résident mock
        String pdfUrl = invoicePdfService.generateInvoicePdf(contravention, mockResident);

        // Créer et sauvegarder la facture (resident peut être null pour maintenant)
        Facture facture = Facture.builder()
                .refFacture("FAC-" + contravention.getRef() + "-" + UUID.randomUUID().toString().substring(0, 8))
                .resident(contravention.getTiers())  // Laisse null pour maintenant
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
