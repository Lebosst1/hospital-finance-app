package com.hospital.finance.service;

import com.hospital.finance.entity.DepensePatient;
import java.util.List;

public interface DepensePatientService {
    List<DepensePatient> getAll();
    List<DepensePatient> getByService(Integer idService);
    List<DepensePatient> getByPatient(Integer idPatient);
    List<DepensePatient> getByServiceAndPatient(Integer idService, Integer idPatient);
}
