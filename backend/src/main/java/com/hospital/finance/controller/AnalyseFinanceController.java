package com.hospital.finance.controller;

import com.hospital.finance.dto.AnalyseGlobaleDTO;
import com.hospital.finance.service.AnalyseFinanceService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/finance")
public class AnalyseFinanceController {
    @Autowired
    private AnalyseFinanceService analyseFinanceService;

    @GetMapping("/analyse-globale")
    public AnalyseGlobaleDTO getAnalyseGlobale() {
        return analyseFinanceService.getAnalyseGlobale();
    }

    @GetMapping("/service/{idService}/analyse-detaillee")
    public AnalyseGlobaleDTO getAnalyseParService(@PathVariable Integer idService) {
        return analyseFinanceService.getAnalyseParService(idService);
    }
}
