package com.uvillage.infractions.service;

import com.uvillage.infractions.dto.ContraventionRecedivesDto;
import com.uvillage.infractions.entity.Contravention;
import com.uvillage.infractions.entity.ContraventionType;
import com.uvillage.infractions.repository.ContraventionRecidivesRepository;
import com.uvillage.infractions.repository.ContraventionRepository;
import com.uvillage.infractions.repository.RecidiveRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class ContraventionRecediveSevice {

    @Autowired
    private ContraventionRecidivesRepository recidivesRepository;

    @Autowired
    private ContraventionRepository contraventionRepository;

    @Autowired
    private RecidiveRepository recidiveRepository;

    /**
     * Returns recidive DTO for a given contravention label (motif) and room/building.
     * The recidive count is based on previous ACCEPTED contraventions for the same room/building and motif.
     */
    public ContraventionRecedivesDto getRecidiveByLabelAndLocation(String label, String numeroChambre, String batiment) {
        Optional<ContraventionType> opt = recidivesRepository.findByLabel(label);
        if (opt.isEmpty()) return null;

        ContraventionType type = opt.get();

        int nombrerecidive = 0;
        if (numeroChambre != null && batiment != null) {
            nombrerecidive = (int) recidiveRepository.countAcceptedByRoomBuildingAndType(
                    numeroChambre, batiment, label);
        }

        int montant1 = type.getMontant1() != null ? type.getMontant1().intValue() : 0;
        int montant2 = type.getMontant2() != null ? type.getMontant2().intValue() : 0;
        int montant3 = type.getMontant3() != null ? type.getMontant3().intValue() : 0;
        int montant4 = type.getMontant4() != null ? type.getMontant4().intValue() : 0;

        return ContraventionRecedivesDto.builder()
                .label(type.getLabel())
                .nombrerecidive(nombrerecidive)
                .montant1(montant1)
                .montant2(montant2)
                .montant3(montant3)
                .montant4(montant4)
                .build();
    }

    /**
     * Returns recidive DTO for a given contravention label (legacy - global count).
     */
    public ContraventionRecedivesDto getRecidiveByLabel(String label) {
        Optional<ContraventionType> opt = recidivesRepository.findByLabel(label);
        if (opt.isEmpty()) return null;

        ContraventionType type = opt.get();

        int nombrerecidive = 0;
        if (type.getRecidives() != null) {
            nombrerecidive = type.getRecidives().size();
        }

        int montant1 = type.getMontant1() != null ? type.getMontant1().intValue() : 0;
        int montant2 = type.getMontant2() != null ? type.getMontant2().intValue() : 0;
        int montant3 = type.getMontant3() != null ? type.getMontant3().intValue() : 0;
        int montant4 = type.getMontant4() != null ? type.getMontant4().intValue() : 0;

        return ContraventionRecedivesDto.builder()
                .label(type.getLabel())
                .nombrerecidive(nombrerecidive)
                .montant1(montant1)
                .montant2(montant2)
                .montant3(montant3)
                .montant4(montant4)
                .build();
    }

    public void confirmerAcceptation(String ref, String motif) {
        Contravention contravention = contraventionRepository.findByRef(ref).orElse(null);
        if (contravention == null) {
            throw new IllegalArgumentException("Contravention not found: " + ref);
        }

        contravention.setStatut(Contravention.Status.ACCEPTEE);

        if (motif != null && !motif.isBlank()) {
            String prev = contravention.getDescription() == null ? "" : contravention.getDescription();
            String updated = prev.isEmpty() ? "Classement motif: " + motif : prev + "\nClassement motif: " + motif;
            contravention.setDescription(updated);
        }

        contraventionRepository.save(contravention);
    }
}
