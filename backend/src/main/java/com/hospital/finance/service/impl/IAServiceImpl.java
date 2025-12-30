package com.hospital.finance.service.impl;

import com.hospital.finance.service.IAService;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
public class IAServiceImpl implements IAService {
    private static final String IA_URL_GLOBALE = "http://localhost:8000/analyse";
    private static final String IA_URL_SERVICE = "http://localhost:8000/analyse";

    @Override
    public String analyseFinanceGlobale(String jsonData) {
        return callIa(jsonData, IA_URL_GLOBALE);
    }

    @Override
    public String analyseFinanceParService(String jsonData) {
        return callIa(jsonData, IA_URL_SERVICE);
    }

    private String callIa(String jsonData, String url) {
        RestTemplate restTemplate = new RestTemplate();
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        HttpEntity<String> request = new HttpEntity<>(jsonData, headers);
        ResponseEntity<String> response = restTemplate.postForEntity(url, request, String.class);
        return response.getBody();
    }
}
