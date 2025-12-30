package com.hospital.finance.service;

import com.hospital.finance.dto.AnalyseGlobaleDTO;

public interface AnalyseFinanceService {
    AnalyseGlobaleDTO getAnalyseGlobale();
    AnalyseGlobaleDTO getAnalyseParService(Integer idService);
}
