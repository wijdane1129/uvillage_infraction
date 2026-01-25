package com.uvillage.infractions.service;

import com.itextpdf.text.Document;
import com.itextpdf.text.DocumentException;
import com.itextpdf.text.Element;
import com.itextpdf.text.Font;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.pdf.PdfWriter;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;
import com.uvillage.infractions.entity.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.UUID;

@Service
public class InvoicePdfService {

    private static final Logger logger = LoggerFactory.getLogger(InvoicePdfService.class);

    @Value("${uploads.dir:./uploads}")
    private String uploadsDir;

    /**
     * Génère une facture PDF pour une contravention confirmée
     * @param contravention La contravention à facturer
     * @return Le chemin du fichier PDF généré
     * @throws IOException En cas d'erreur lors de la génération du PDF
     */
    public String generateInvoicePdf(Contravention contravention) throws IOException {
        logger.info("Starting PDF generation for contravention: {}", contravention.getRef());
        
        // Créer le répertoire s'il n'existe pas
        File uploadsDirectory = new File(uploadsDir);
        logger.info("Uploads directory: {}", uploadsDirectory.getAbsolutePath());
        
        if (!uploadsDirectory.exists()) {
            logger.info("Creating uploads directory...");
            uploadsDirectory.mkdirs();
        }

        // Générer le nom du fichier PDF
        String refFacture = "FAC-" + contravention.getRef() + "-" + UUID.randomUUID().toString().substring(0, 8);
        String fileName = refFacture + ".pdf";
        String filePath = uploadsDirectory.getAbsolutePath() + File.separator + fileName;
        logger.info("PDF file path: {}", filePath);

        // Créer le document PDF
        Document document = new Document();
        try {
            logger.info("Creating PDF writer for file: {}", filePath);
            PdfWriter.getInstance(document, new FileOutputStream(filePath));
            document.open();
            logger.info("Document opened successfully");
            
            // Ajouter le contenu du PDF
            logger.info("Adding content to PDF...");
            addInvoiceContent(document, contravention, refFacture);
            logger.info("Content added successfully");
            
            document.close();
            logger.info("PDF generated successfully at: {}", filePath);
        } catch (DocumentException e) {
            logger.error("DocumentException while generating PDF", e);
            throw new IOException("Erreur lors de la génération du PDF", e);
        }

        return "uploads/" + fileName;
    }

    /**
     * Ajoute le contenu de la facture au document PDF
     */
    private void addInvoiceContent(Document document, Contravention contravention, String refFacture) throws DocumentException {
        DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
        
        Font titleFont = new Font(Font.FontFamily.HELVETICA, 18, Font.BOLD);
        Font headerFont = new Font(Font.FontFamily.HELVETICA, 12, Font.BOLD);
        Font normalFont = new Font(Font.FontFamily.HELVETICA, 11);
        Font smallFont = new Font(Font.FontFamily.HELVETICA, 9);

        // En-tête
        Paragraph title = new Paragraph("FACTURE D'INFRACTION", titleFont);
        title.setAlignment(Element.ALIGN_CENTER);
        document.add(title);
        document.add(new Paragraph("\n"));

        // Bloc de référence
        PdfPTable refTable = new PdfPTable(2);
        refTable.setWidthPercentage(100);
        
        PdfPCell cell1 = new PdfPCell(new Paragraph("Référence facture:", headerFont));
        PdfPCell cell2 = new PdfPCell(new Paragraph(refFacture, normalFont));
        PdfPCell cell3 = new PdfPCell(new Paragraph("Date:", headerFont));
        PdfPCell cell4 = new PdfPCell(new Paragraph(LocalDateTime.now().format(dateFormatter), normalFont));
        
        refTable.addCell(cell1);
        refTable.addCell(cell2);
        refTable.addCell(cell3);
        refTable.addCell(cell4);
        
        document.add(refTable);
        document.add(new Paragraph("\n"));

        // Section détails de la contravention
        Paragraph sectionHeader = new Paragraph("DÉTAILS DE LA CONTRAVENTION", headerFont);
        document.add(sectionHeader);

        PdfPTable detailsTable = new PdfPTable(2);
        detailsTable.setWidthPercentage(100);

        // Référence contravention
        addTableRow(detailsTable, "Référence contravention:", contravention.getRef(), headerFont, normalFont);

        // Motif
        String motif = contravention.getTypeContravention() != null
                ? contravention.getTypeContravention().getLabel()
                : "Non spécifié";
        addTableRow(detailsTable, "Motif:", motif, headerFont, normalFont);

        // Description
        String description = contravention.getDescription() != null && !contravention.getDescription().isEmpty()
                ? contravention.getDescription()
                : "Aucune description";
        addTableRow(detailsTable, "Description:", description, headerFont, normalFont);

        // Date de création
        String dateCreation = contravention.getDateCreation() != null
                ? contravention.getDateCreation().toString()
                : "Non spécifié";
        addTableRow(detailsTable, "Date de l'infraction:", dateCreation, headerFont, normalFont);

        // Agent
        String agent = contravention.getUserAuthor() != null
                ? (contravention.getUserAuthor().getFullName() != null
                ? contravention.getUserAuthor().getFullName()
                : contravention.getUserAuthor().getUsername())
                : "Non spécifié";
        addTableRow(detailsTable, "Agent:", agent, headerFont, normalFont);

        document.add(detailsTable);
        document.add(new Paragraph("\n"));

        // Section resident
        Paragraph residentHeader = new Paragraph("INFORMATIONS DU RÉSIDENT", headerFont);
        document.add(residentHeader);

        PdfPTable residentTable = new PdfPTable(2);
        residentTable.setWidthPercentage(100);

        if (contravention.getTiers() != null) {
            Resident resident = contravention.getTiers();
            addTableRow(residentTable, "Nom:", resident.getNomResident() != null ? resident.getNomResident() : "Non spécifié", headerFont, normalFont);
            addTableRow(residentTable, "Email:", resident.getEmail() != null ? resident.getEmail() : "Non spécifié", headerFont, normalFont);
            addTableRow(residentTable, "Téléphone:", resident.getTelephone() != null ? resident.getTelephone() : "Non spécifié", headerFont, normalFont);
            if (resident.getChambre() != null) {
                addTableRow(residentTable, "Chambre:", resident.getChambre().toString(), headerFont, normalFont);
            }
        } else {
            addTableRow(residentTable, "Résident:", "Non spécifié", headerFont, normalFont);
        }

        document.add(residentTable);
        document.add(new Paragraph("\n"));

        // Section montant
        Paragraph montantHeader = new Paragraph("MONTANT DE L'INFRACTION", headerFont);
        document.add(montantHeader);

        PdfPTable montantTable = new PdfPTable(2);
        montantTable.setWidthPercentage(100);

        String montant = contravention.getTypeContravention() != null && contravention.getTypeContravention().getMontant1() != null
                ? contravention.getTypeContravention().getMontant1() + " DH"
                : "À déterminer";

        PdfPCell montantLabelCell = new PdfPCell(new Paragraph("Montant:", headerFont));
        PdfPCell montantValueCell = new PdfPCell(new Paragraph(montant, new Font(Font.FontFamily.HELVETICA, 14, Font.BOLD)));

        montantTable.addCell(montantLabelCell);
        montantTable.addCell(montantValueCell);

        document.add(montantTable);
        document.add(new Paragraph("\n"));

        // Statut
        Paragraph statut = new Paragraph("STATUT: " + (contravention.getStatut() != null ? contravention.getStatut().name() : "NON DÉFINI"), headerFont);
        statut.setAlignment(Element.ALIGN_CENTER);
        document.add(statut);

        // Pied de page
        document.add(new Paragraph("\n\n"));
        Paragraph footerNote1 = new Paragraph("Ce document est généré automatiquement et fait foi de l'infraction consignée.", smallFont);
        footerNote1.setAlignment(Element.ALIGN_CENTER);
        document.add(footerNote1);
        
        Paragraph footerNote2 = new Paragraph("Pour toute contestation, veuillez contacter les autorités compétentes.", smallFont);
        footerNote2.setAlignment(Element.ALIGN_CENTER);
        document.add(footerNote2);
    }

    /**
     * Ajoute une ligne à un tableau
     */
    private void addTableRow(PdfPTable table, String label, String value, Font labelFont, Font valueFont) {
        PdfPCell labelCell = new PdfPCell(new Paragraph(label, labelFont));
        PdfPCell valueCell = new PdfPCell(new Paragraph(value, valueFont));
        table.addCell(labelCell);
        table.addCell(valueCell);
    }
}
