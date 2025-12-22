package com.hospital.finance.service.impl;

import com.hospital.finance.entity.Patient;
import com.hospital.finance.repository.PatientRepository;
import com.hospital.finance.service.PatientService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class PatientServiceImpl implements PatientService {

    private final PatientRepository patientRepository;

    @Override
    public Patient createPatient(Patient patient) {
        return patientRepository.save(patient);
    }

    @Override
    public Patient updatePatient(Long id, Patient patient) {
        Patient existing = patientRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Patient introuvable"));

        existing.setNom(patient.getNom());
        existing.setPrenom(patient.getPrenom());
        existing.setSexe(patient.getSexe());
        existing.setAdresse(patient.getAdresse());
        existing.setTelephone(patient.getTelephone());
        existing.setDateNaissance(patient.getDateNaissance());

        return patientRepository.save(existing);
    }

    @Override
    public void deletePatient(Long id) {
        patientRepository.deleteById(id);
    }

    @Override
    public Patient getPatientById(Long id) {
        return patientRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Patient introuvable"));
    }

    @Override
    public List<Patient> getAllPatients() {
        return patientRepository.findAll();
    }
}
