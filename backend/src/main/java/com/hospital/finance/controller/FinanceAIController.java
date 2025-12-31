package com.hospital.finance.controller;

import com.hospital.finance.ai.FinanceAIClient;
import com.hospital.finance.entity.ServiceHospitalier;
import com.hospital.finance.service.ServiceHospitalierService;
import org.springframework.beans.factory.annotation.Autowired;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/finance")
public class FinanceAIController {
    private static final Logger logger = LoggerFactory.getLogger(FinanceAIController.class);
    @Autowired
    private ServiceHospitalierService serviceHospitalierService;
    @Autowired
    private FinanceAIClient financeAIClient;

    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/analyse")
    public ResponseEntity<?> analyseGlobale() {
        try {
            List<ServiceHospitalier> services = serviceHospitalierService.getAllServices();
            List<FinanceAIClient.ServiceData> data = new ArrayList<>();
            for (ServiceHospitalier s : services) {
                FinanceAIClient.ServiceData d = new FinanceAIClient.ServiceData();
                d.setNom(s.getNomService());
                d.setBudget_mensuel(s.getBudgetMensuel());
                d.setBudget_annuel(s.getBudgetAnnuel());
                // Ajout de l'historique des dépenses réelles
                List<Double> histo = new ArrayList<>();
                if (s.getSejours() != null) {
                    for (var sj : s.getSejours()) {
                        if (sj.getCout() != null) histo.add(sj.getCout());
                    }
                }
                d.setHistorique_depenses(histo);
                data.add(d);
            }
            FinanceAIClient.AnalyseGlobalResult result = financeAIClient.analyseServices(data);
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            logger.error("Accès refusé ou erreur lors de l'analyse IA globale", e);
            return ResponseEntity.status(403).body("Accès refusé ou erreur lors de l'analyse IA globale: " + e.getMessage());
        }
    }
}
