package com.uvillage.infractions.service;

import com.opencsv.CSVReader;
import com.opencsv.exceptions.CsvException;
import lombok.Data;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;

import javax.annotation.PostConstruct;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class ResidentMockService {
    
    private static final Logger logger = LoggerFactory.getLogger(ResidentMockService.class);
    
    @Data
    public static class MockResident {
        private String id;
        private String nom;
        private String prenom;
        private String sexe;
        private String filiere;
        private String batiment;
        private String numeroChambre;
        private String typeChambre;
        private String dateEntree;
        private String dateSortie;
        private String statutPaiement;
        
        public String getFullName() {
            return prenom + " " + nom;
        }
        
        public String getAdresse() {
            return "Chambre " + numeroChambre + ", Bâtiment " + batiment;
        }
    }
    
    private List<MockResident> residents = new ArrayList<>();
    private Map<String, MockResident> residentsById = new HashMap<>();
    // Map pour recherche rapide par chambre+bâtiment
    private Map<String, MockResident> residentsByRoomKey = new HashMap<>();
    
    @PostConstruct
    public void loadResidents() {
        try {
            ClassPathResource resource = new ClassPathResource("data/compus_euromed_chambres.csv");
            
            try (CSVReader reader = new CSVReader(new InputStreamReader(resource.getInputStream()))) {
                List<String[]> records = reader.readAll();
                
                // Skip header row
                for (int i = 1; i < records.size(); i++) {
                    String[] row = records.get(i);
                    if (row.length >= 11) {
                        MockResident resident = new MockResident();
                        resident.setId(row[0].trim());
                        resident.setNom(row[1].trim());
                        resident.setPrenom(row[2].trim());
                        resident.setSexe(row[3].trim());
                        resident.setFiliere(row[4].trim());
                        resident.setBatiment(row[5].trim());
                        resident.setNumeroChambre(row[6].trim());
                        resident.setTypeChambre(row[7].trim());
                        resident.setDateEntree(row[8].trim());
                        resident.setDateSortie(row[9].trim());
                        resident.setStatutPaiement(row[10].trim());
                        
                        residents.add(resident);
                        residentsById.put(resident.getId(), resident);
                        
                        // Index par chambre+bâtiment pour recherche rapide
                        String key = makeRoomKey(resident.getNumeroChambre(), resident.getBatiment());
                        residentsByRoomKey.put(key, resident);
                    }
                }
                
                logger.info("✅ Loaded {} mock residents from CSV", residents.size());
                logger.info("📋 Indexed {} room keys", residentsByRoomKey.size());
            }
        } catch (IOException | CsvException e) {
            logger.error("❌ Error loading residents CSV: {}", e.getMessage());
            e.printStackTrace();
        }
    }
    
    /**
     * Cherche un résident par numéro de chambre et bâtiment
     * C'est la méthode PRINCIPALE pour trouver le résident d'une contravention
     */
    public MockResident findByRoom(String numeroChambre, String batiment) {
        if (numeroChambre == null || batiment == null) {
            logger.warn("⚠️ findByRoom called with null parameters");
            return null;
        }
        
        String key = makeRoomKey(numeroChambre, batiment);
        MockResident resident = residentsByRoomKey.get(key);
        
        if (resident != null) {
            logger.debug("✅ Found resident {} for room {}", resident.getFullName(), key);
        } else {
            logger.warn("❌ No resident found for room key: {}", key);
        }
        
        return resident;
    }
    
    /**
     * Créer une clé unique pour chambre+bâtiment
     * Normalise les variations possibles (Bâtiment A, A, BATIMENT A, etc.)
     */
    private String makeRoomKey(String numeroChambre, String batiment) {
        String normalizedRoom = numeroChambre.trim().toUpperCase();
        String normalizedBat = normalizeBatiment(batiment);
        return normalizedRoom + "-" + normalizedBat;
    }
    
    /**
     * Normalise le nom du bâtiment
     * "Bâtiment A" → "A"
     * "BATIMENT B" → "B"
     * "Immeuble C" → "C"
     * "A" → "A"
     */
    private String normalizeBatiment(String batiment) {
        if (batiment == null || batiment.trim().isEmpty()) {
            return "";
        }
        
        String normalized = batiment.trim().toUpperCase();
        
        // Si c'est déjà une seule lettre, retourner
        if (normalized.length() == 1) {
            return normalized;
        }
        
        // Extraire la dernière lettre si format "Bâtiment A" ou "Immeuble A"
        String[] parts = normalized.split("\\s+");
        if (parts.length > 1) {
            String last = parts[parts.length - 1];
            if (last.length() == 1 && Character.isLetter(last.charAt(0))) {
                return last;
            }
        }
        
        // Sinon retourner tel quel
        return normalized;
    }
    
    public List<MockResident> getAllResidents() {
        return new ArrayList<>(residents);
    }
    
    public MockResident getResidentById(String id) {
        return residentsById.get(id);
    }
    
    /**
     * Pour fallback si on n'a pas de chambre/bâtiment
     * Sélection déterministe basée sur un index
     */
    public MockResident getResidentByIndex(int index) {
        if (residents.isEmpty()) return null;
        int safeIndex = Math.abs(index) % residents.size();
        return residents.get(safeIndex);
    }
    
    public List<String> getAllResidentNames() {
        return residents.stream()
                .map(MockResident::getFullName)
                .collect(Collectors.toList());
    }
    
    /**
     * Pour debug - affiche tous les résidents chargés
     */
    public void printLoadedResidents() {
        logger.info("=== RESIDENTS CHARGÉS ===");
        for (MockResident r : residents) {
            logger.info("  {} - Chambre {}, Bâtiment {}", 
                r.getFullName(), r.getNumeroChambre(), r.getBatiment());
        }
    }
}