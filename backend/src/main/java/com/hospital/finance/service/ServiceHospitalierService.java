package com.hospital.finance.service;

import com.hospital.finance.entity.ServiceHospitalier;
import java.util.List;

public interface ServiceHospitalierService {

    ServiceHospitalier createService(ServiceHospitalier service);
    ServiceHospitalier updateService(Long id, ServiceHospitalier service);
    void deleteService(Long id);
    ServiceHospitalier getById(Long id);
    List<ServiceHospitalier> getAll();
    List<ServiceHospitalier> getAllServices();   // ✅ pour ServiceHospitalierController
}
