package com.hospital.finance.service.impl;

import com.hospital.finance.entity.DepensePatient;
import com.hospital.finance.repository.DepensePatientRepository;
import com.hospital.finance.service.DepensePatientService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class DepensePatientServiceImpl implements DepensePatientService {
    @Autowired
    private DepensePatientRepository depensePatientRepository;

    @Override
    public List<DepensePatient> getAll() {
        return depensePatientRepository.findAll();
    }

    @Override
    public List<DepensePatient> getByService(Integer idService) {
        return depensePatientRepository.findByIdService(idService);
    }

    @Override
    public List<DepensePatient> getByPatient(Integer idPatient) {
        return depensePatientRepository.findByIdPatient(idPatient);
    }

    @Override
    public List<DepensePatient> getByServiceAndPatient(Integer idService, Integer idPatient) {
        return depensePatientRepository.findByIdServiceAndIdPatient(idService, idPatient);
    }
}
