package com.hospital.finance.service;

import com.hospital.finance.entity.Patient;
import java.util.List;

public interface PatientService {

    Patient createPatient(Patient patient);

    Patient updatePatient(Long id, Patient patient);

    void deletePatient(Long id);

    Patient getPatientById(Long id);

    List<Patient> getAllPatients();
}
