package com.hospital.finance.controller;

import com.hospital.finance.ai.FinanceAIClient;
import com.hospital.finance.entity.ServiceHospitalier;
import com.hospital.finance.service.ServiceHospitalierService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.http.ResponseEntity;

import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/finance")
public class FinanceAIController {
    @Autowired
    private ServiceHospitalierService serviceHospitalierService;
    @Autowired
    private FinanceAIClient financeAIClient;

    @GetMapping("/analyse")
    public ResponseEntity<?> analyseGlobale() {
        List<ServiceHospitalier> services = serviceHospitalierService.getAllServices();
        List<FinanceAIClient.ServiceData> data = new ArrayList<>();
        for (ServiceHospitalier s : services) {
            FinanceAIClient.ServiceData d = new FinanceAIClient.ServiceData();
            d.setNom(s.getNomService());
            d.setBudget_mensuel(s.getBudgetMensuel());
            d.setBudget_annuel(s.getBudgetAnnuel());
            d.setHistorique_depenses(null); // TODO: ajouter l'historique réel si dispo
            data.add(d);
        }
        FinanceAIClient.AnalyseGlobalResult result = financeAIClient.analyseServices(data);
        return ResponseEntity.ok(result);
    }
}
