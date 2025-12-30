package com.hospital.finance.service.impl;

import com.hospital.finance.dto.AnalyseGlobaleDTO;
import com.hospital.finance.entity.DepensePatient;
import com.hospital.finance.entity.Patient;
import com.hospital.finance.entity.ServiceHospitalier;
import com.hospital.finance.repository.DepensePatientRepository;
import com.hospital.finance.repository.PatientRepository;
import com.hospital.finance.repository.ServiceHospitalierRepository;
import com.hospital.finance.service.AnalyseFinanceService;
import org.springframework.beans.factory.annotation.Autowired;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.hospital.finance.service.IAService;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class AnalyseFinanceServiceImpl implements AnalyseFinanceService {
    @Autowired
    private DepensePatientRepository depensePatientRepository;
    @Autowired
    private PatientRepository patientRepository;
    @Autowired
    private ServiceHospitalierRepository serviceHospitalierRepository;
    @Autowired
    private IAService iaService;

    @Override
    public AnalyseGlobaleDTO getAnalyseGlobale() {
        List<DepensePatient> depenses = depensePatientRepository.findAll();
        List<Patient> patients = patientRepository.findAll();
        List<ServiceHospitalier> services = serviceHospitalierRepository.findAll();

        AnalyseGlobaleDTO dto = new AnalyseGlobaleDTO();
        dto.nombreTotalPatients = patients.size();
        dto.depensesTotales = depenses.stream().filter(d -> "depense".equals(d.getType())).mapToDouble(DepensePatient::getMontant).sum();
        dto.gainsTotaux = depenses.stream().filter(d -> "gain".equals(d.getType())).mapToDouble(DepensePatient::getMontant).sum();

        // Stats par service
        dto.services = new ArrayList<>();
        for (ServiceHospitalier s : services) {
            AnalyseGlobaleDTO.ServiceStats stats = new AnalyseGlobaleDTO.ServiceStats();
            stats.idService = s.getIdService() != null ? s.getIdService().intValue() : null;
            stats.nomService = s.getNomService();
            // Nombre de patients ayant au moins une dépense/gain dans ce service
            Set<Integer> patientIds = depenses.stream()
                .filter(d -> d.getIdService() != null && s.getIdService() != null && d.getIdService().intValue() == s.getIdService().intValue())
                .map(DepensePatient::getIdPatient)
                .filter(Objects::nonNull)
                .collect(Collectors.toSet());
            stats.nombrePatients = patientIds.size();
            stats.depensesService = depenses.stream().filter(d -> d.getIdService() != null && s.getIdService() != null && d.getIdService().intValue() == s.getIdService().intValue() && "depense".equals(d.getType())).mapToDouble(DepensePatient::getMontant).sum();
            stats.gainsService = depenses.stream().filter(d -> d.getIdService() != null && s.getIdService() != null && d.getIdService().intValue() == s.getIdService().intValue() && "gain".equals(d.getType())).mapToDouble(DepensePatient::getMontant).sum();
            dto.services.add(stats);
        }

        // Détail patients
        dto.patients = new ArrayList<>();
        for (Patient p : patients) {
            AnalyseGlobaleDTO.PatientOp pop = new AnalyseGlobaleDTO.PatientOp();
            pop.idPatient = p.getIdPatient() != null ? p.getIdPatient().intValue() : null;
            pop.nom = p.getNom();
            pop.prenom = p.getPrenom();
            // Trouver le service principal du patient via ses opérations (premier service trouvé)
            Integer idService = depenses.stream()
                .filter(d -> d.getIdPatient() != null && p.getIdPatient() != null && d.getIdPatient().intValue() == p.getIdPatient().intValue() && d.getIdService() != null)
                .map(DepensePatient::getIdService)
                .findFirst().orElse(null);
            ServiceHospitalier s = null;
            if (idService != null) {
                s = services.stream().filter(serv -> serv.getIdService() != null && serv.getIdService().intValue() == idService).findFirst().orElse(null);
            }
            pop.service = s != null ? s.getNomService() : null;
            List<DepensePatient> ops = depenses.stream().filter(d -> d.getIdPatient() != null && p.getIdPatient() != null && d.getIdPatient().intValue() == p.getIdPatient().intValue()).collect(Collectors.toList());
            pop.totalDepenses = ops.stream().filter(d -> "depense".equals(d.getType())).mapToDouble(DepensePatient::getMontant).sum();
            pop.totalGains = ops.stream().filter(d -> "gain".equals(d.getType())).mapToDouble(DepensePatient::getMontant).sum();
            pop.operations = ops.stream().map(d -> {
                AnalyseGlobaleDTO.OperationDTO op = new AnalyseGlobaleDTO.OperationDTO();
                op.type = d.getType();
                op.montant = d.getMontant();
                op.date = d.getDateOperation() != null ? d.getDateOperation().toString() : null;
                op.description = d.getDescription();
                return op;
            }).collect(Collectors.toList());
            dto.patients.add(pop);
        }

        // Appel IA
        try {
            ObjectMapper mapper = new ObjectMapper();
            String json = mapper.writeValueAsString(dto);
            String iaResult = iaService.analyseFinanceGlobale(json);
            // On peut stocker la réponse IA dans un champ du DTO si besoin
            dto.conseil = iaResult; // À adapter selon le format de la réponse IA
        } catch (Exception e) {
            dto.conseil = "Erreur IA : " + e.getMessage();
        }
        // IA : tendances, alertes, conseils (fallback simple)
        if (dto.conseil == null) {
            dto.tendance = dto.depensesTotales > dto.gainsTotaux ? "Dépenses supérieures aux gains" : "Gains supérieurs aux dépenses";
            dto.alerte = dto.depensesTotales > dto.gainsTotaux * 1.2 ? "Alerte : trop de dépenses !" : null;
            dto.conseil = dto.depensesTotales > dto.gainsTotaux ? "Réduire les dépenses ou augmenter les recettes." : "Situation saine.";
        }
        return dto;
    }

    @Override
    public AnalyseGlobaleDTO getAnalyseParService(Integer idService) {
        List<DepensePatient> depenses = depensePatientRepository.findByIdService(idService);
        // Trouver les patients ayant au moins une opération dans ce service
        Set<Integer> patientIds = depenses.stream()
            .map(DepensePatient::getIdPatient)
            .filter(Objects::nonNull)
            .collect(Collectors.toSet());
        List<Patient> patients = patientRepository.findAll().stream()
            .filter(p -> p.getIdPatient() != null && patientIds.contains(p.getIdPatient().intValue()))
            .collect(Collectors.toList());
        ServiceHospitalier s = serviceHospitalierRepository.findById(Long.valueOf(idService)).orElse(null);

        AnalyseGlobaleDTO dto = new AnalyseGlobaleDTO();
        dto.nombreTotalPatients = patients.size();
        dto.depensesTotales = depenses.stream().filter(d -> "depense".equals(d.getType())).mapToDouble(DepensePatient::getMontant).sum();
        dto.gainsTotaux = depenses.stream().filter(d -> "gain".equals(d.getType())).mapToDouble(DepensePatient::getMontant).sum();

        // Stats du service
        dto.services = new ArrayList<>();
        if (s != null) {
            AnalyseGlobaleDTO.ServiceStats stats = new AnalyseGlobaleDTO.ServiceStats();
            stats.idService = s.getIdService() != null ? s.getIdService().intValue() : null;
            stats.nomService = s.getNomService();
            stats.nombrePatients = patients.size();
            stats.depensesService = dto.depensesTotales;
            stats.gainsService = dto.gainsTotaux;
            dto.services.add(stats);
        }

        // Détail patients
        dto.patients = new ArrayList<>();
        for (Patient p : patients) {
            AnalyseGlobaleDTO.PatientOp pop = new AnalyseGlobaleDTO.PatientOp();
            pop.idPatient = p.getIdPatient() != null ? p.getIdPatient().intValue() : null;
            pop.nom = p.getNom();
            pop.prenom = p.getPrenom();
            pop.service = s != null ? s.getNomService() : null;
            List<DepensePatient> ops = depenses.stream().filter(d -> d.getIdPatient() != null && p.getIdPatient() != null && d.getIdPatient().intValue() == p.getIdPatient().intValue()).collect(Collectors.toList());
            pop.totalDepenses = ops.stream().filter(d -> "depense".equals(d.getType())).mapToDouble(DepensePatient::getMontant).sum();
            pop.totalGains = ops.stream().filter(d -> "gain".equals(d.getType())).mapToDouble(DepensePatient::getMontant).sum();
            pop.operations = ops.stream().map(d -> {
                AnalyseGlobaleDTO.OperationDTO op = new AnalyseGlobaleDTO.OperationDTO();
                op.type = d.getType();
                op.montant = d.getMontant();
                op.date = d.getDateOperation() != null ? d.getDateOperation().toString() : null;
                op.description = d.getDescription();
                return op;
            }).collect(Collectors.toList());
            dto.patients.add(pop);
        }

        // Appel IA
        try {
            ObjectMapper mapper = new ObjectMapper();
            String json = mapper.writeValueAsString(dto);
            String iaResult = iaService.analyseFinanceParService(json);
            dto.conseil = iaResult; // À adapter selon le format de la réponse IA
        } catch (Exception e) {
            dto.conseil = "Erreur IA : " + e.getMessage();
        }
        // IA : tendances, alertes, conseils (fallback simple)
        if (dto.conseil == null) {
            dto.tendance = dto.depensesTotales > dto.gainsTotaux ? "Dépenses supérieures aux gains" : "Gains supérieurs aux dépenses";
            dto.alerte = dto.depensesTotales > dto.gainsTotaux * 1.2 ? "Alerte : trop de dépenses !" : null;
            dto.conseil = dto.depensesTotales > dto.gainsTotaux ? "Réduire les dépenses ou augmenter les recettes." : "Situation saine.";
        }
        return dto;
    }
}
