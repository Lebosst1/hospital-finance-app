package com.hospital.finance.dto;

import java.util.List;

public class AnalyseGlobaleDTO {
    public static class PatientOp {
        public Integer idPatient;
        public String nom;
        public String prenom;
        public String service;
        public Double totalDepenses;
        public Double totalGains;
        public List<OperationDTO> operations;
    }

    public static class OperationDTO {
        public String type; // 'depense' ou 'gain'
        public Double montant;
        public String date;
        public String description;
    }

    public Integer nombreTotalPatients;
    public Double depensesTotales;
    public Double gainsTotaux;
    public List<PatientOp> patients;
    public List<ServiceStats> services;
    public String tendance;
    public String alerte;
    public String conseil;

    public static class ServiceStats {
        public Integer idService;
        public String nomService;
        public Integer nombrePatients;
        public Double depensesService;
        public Double gainsService;
    }
}
