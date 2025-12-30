package com.hospital.finance.controller;

import com.hospital.finance.entity.Alerte;
import com.hospital.finance.service.AlerteService;
import com.hospital.finance.ai.FinanceAIClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/alerte")

public class AlerteController {

    @ExceptionHandler(org.springframework.http.converter.HttpMessageNotReadableException.class)
    public ResponseEntity<String> handleDeserializationError(Exception ex) {
        ex.printStackTrace();
        return ResponseEntity.badRequest().body("Erreur de désérialisation : " + ex.getMessage());
    }


    @Autowired
    private AlerteService alerteService;

    @Autowired
    private FinanceAIClient financeAIClient;

    @GetMapping("/{id}")
    public ResponseEntity<Alerte> getAlerteById(@PathVariable Long id) {
        Alerte alerte = alerteService.getById(id);
        return alerte != null ? ResponseEntity.ok(alerte) : ResponseEntity.notFound().build();
    }

    @GetMapping("/all")
    public ResponseEntity<List<Alerte>> getAllAlertes() {
        List<Alerte> alertes = alerteService.getAllAlertes();
        return ResponseEntity.ok(alertes);
    }


    /**
     * Crée une alerte. Champs attendus :
     * - type : String (ex: Budget, Variation...)
     * - message : String
     * - niveau : String (INFO, WARNING, CRITIQUE)
     * - status : String (NOUVELLE, VALIDEE, EN_COURS, RESOLUE)
     * - dateAlerte : String (ISO)
     * - service : { idService: ... }
     */

    @PostMapping("/add")
    public ResponseEntity<Alerte> addAlerte(@RequestBody Alerte alerte) {
        // 1. Sauvegarde initiale
        Alerte createdAlerte = alerteService.createAlerte(alerte);

        // 2. Appel IA (envoi d'une seule alerte)
        FinanceAIClient.AlerteData ad = new FinanceAIClient.AlerteData();
        ad.setType(createdAlerte.getType());
        ad.setMessage(createdAlerte.getMessage());
        ad.setNiveau(createdAlerte.getNiveau());
        ad.setStatus(createdAlerte.getStatus());
        ad.setDateAlerte(createdAlerte.getDateAlerte() != null ? createdAlerte.getDateAlerte().toString() : null);

        // Dummy ServiceData (adapter si besoin)
        FinanceAIClient.ServiceData sd = new FinanceAIClient.ServiceData();
        if (createdAlerte.getService() != null) {
            sd.setNom(createdAlerte.getService().getNomService());
            sd.setBudget_mensuel(createdAlerte.getService().getBudgetMensuel());
            sd.setBudget_annuel(createdAlerte.getService().getBudgetAnnuel());
        }

        java.util.List<FinanceAIClient.ServiceData> services = new java.util.ArrayList<>();
        services.add(sd);
        java.util.List<FinanceAIClient.AlerteData> alertes = java.util.Collections.singletonList(ad);

        try {
            System.out.println("[AlerteController] Appel IA avec services=" + services + ", alertes=" + alertes);
            FinanceAIClient.AnalyseGlobalResult result = financeAIClient.analyseServicesWithAlertes(services, alertes);
            System.out.println("[AlerteController] Réponse IA: " + result);
            // 3. Met à jour le statut selon la réponse IA (exemple simple)
            if (result != null && result.getAlertes() != null && !result.getAlertes().isEmpty()) {
                createdAlerte.setStatus("VALIDEE");
                System.out.println("[AlerteController] Statut alerte mis à VALIDEE");
            } else {
                createdAlerte.setStatus("REJETEE");
                System.out.println("[AlerteController] Statut alerte mis à REJETEE");
            }
            createdAlerte = alerteService.updateAlerte(createdAlerte.getIdAlerte(), createdAlerte);
        } catch (Exception e) {
            // En cas d'erreur IA, on garde l'alerte en NOUVELLE
            System.err.println("[AlerteController] Erreur lors de l'appel IA: " + e.getMessage());
            e.printStackTrace();
        }
        return ResponseEntity.status(201).body(createdAlerte);
    }

    /**
     * Valide une alerte (change son statut à VALIDEE)
     */
    @PutMapping("/{id}/valider")
    public ResponseEntity<Alerte> validerAlerte(@PathVariable Long id) {
        Alerte alerte = alerteService.getById(id);
        alerte.setStatus("VALIDEE");
        Alerte updated = alerteService.updateAlerte(id, alerte);
        return ResponseEntity.ok(updated);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Alerte> updateAlerte(@PathVariable Long id, @RequestBody Alerte alerte) {
        Alerte updatedAlerte = alerteService.updateAlerte(id, alerte);
        return updatedAlerte != null ? ResponseEntity.ok(updatedAlerte) : ResponseEntity.notFound().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteAlerte(@PathVariable Long id) {
        alerteService.deleteAlerte(id);
        return ResponseEntity.noContent().build();
    }
}
