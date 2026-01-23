package com.uvillage.infractions.service;

import com.uvillage.infractions.entity.ContraventionType;
import com.uvillage.infractions.repository.ContraventionTypeRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class ContraventionTypeService {
    @Autowired
    private ContraventionTypeRepository contraventionTypeRepository;

    public List<ContraventionType> getAllMotifs() {
        return contraventionTypeRepository.findAllOrderByIdDesc();
    }

    public Optional<ContraventionType> getMotifById(Long id) {
        return contraventionTypeRepository.findById(id);
    }

    public Optional<ContraventionType> getMotifByLabel(String label) {
        return contraventionTypeRepository.findByLabel(label);
    }

    public List<ContraventionType> searchMotifs(String label) {
        return contraventionTypeRepository.searchByLabel(label);
    }

    public ContraventionType createMotif(String label, String description, Double montant1, 
                                         Double montant2, Double montant3, Double montant4) {
        // Vérifier si le label existe déjà
        if (contraventionTypeRepository.findByLabel(label).isPresent()) {
            throw new RuntimeException("Un motif avec ce nom existe déjà");
        }

        ContraventionType motif = ContraventionType.builder()
                .label(label)
                .description(description)
                .montant1(montant1)
                .montant2(montant2)
                .montant3(montant3)
                .montant4(montant4)
                .build();

        return contraventionTypeRepository.save(motif);
    }

    public ContraventionType updateMotif(Long id, String label, String description,
                                         Double montant1, Double montant2, 
                                         Double montant3, Double montant4) {
        Optional<ContraventionType> existingMotif = contraventionTypeRepository.findById(id);
        
        if (existingMotif.isEmpty()) {
            throw new RuntimeException("Motif non trouvé");
        }

        ContraventionType motif = existingMotif.get();
        motif.setLabel(label);
        motif.setDescription(description);
        motif.setMontant1(montant1);
        motif.setMontant2(montant2);
        motif.setMontant3(montant3);
        motif.setMontant4(montant4);

        return contraventionTypeRepository.save(motif);
    }

    public void deleteMotif(Long id) {
        if (!contraventionTypeRepository.existsById(id)) {
            throw new RuntimeException("Motif non trouvé");
        }
        contraventionTypeRepository.deleteById(id);
    }

    public long countMotifUsages(Long id) {
        Optional<ContraventionType> motif = contraventionTypeRepository.findById(id);
        if (motif.isPresent() && motif.get().getContraventions() != null) {
            return motif.get().getContraventions().size();
        }
        return 0;
    }
}
