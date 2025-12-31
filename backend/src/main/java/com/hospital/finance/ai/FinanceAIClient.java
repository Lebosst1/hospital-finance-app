
package com.hospital.finance.ai;

import lombok.Data;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;
import java.util.*;

@Component
public class FinanceAIClient {
    @Value("${ai.service.url}")
    private String AI_URL;
    private final RestTemplate restTemplate = new RestTemplate();


    public AnalyseGlobalResult analyseServices(List<ServiceData> services) {
        return analyseServicesWithAlertes(services, null);
    }

    public AnalyseGlobalResult analyseServicesWithAlertes(List<ServiceData> services, List<AlerteData> alertes) {
        Map<String, Object> req = new HashMap<>();
        req.put("services", services);
        if (alertes != null) {
            req.put("alertes", alertes);
        }
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(req, headers);
        ResponseEntity<AnalyseGlobalResult> resp = restTemplate.exchange(
                AI_URL,
                HttpMethod.POST,
                entity,
                AnalyseGlobalResult.class
        );
        return resp.getBody();
    }

    @Data
    public static class ServiceData {
        private String nom;
        private Double budget_mensuel;
        private Double budget_annuel;
        private List<Double> historique_depenses;
    }

    @Data
    public static class AlerteData {
        private String type;
        private String message;
        private String niveau;
        private String status;
        private String dateAlerte;
    }

    @Data
    public static class AnalyseResult {
        private String nom;
        private Double depense_prevue;
        private String alerte;
        private String conseil;
        private String tendance;
    }

    @Data
    public static class AnalyseGlobalResult {
        private Double total_depense_prevue;
        private List<String> alertes;
        private List<String> conseils;
        private List<String> tendances;
        private List<AnalyseResult> details;
    }
}
