package com.hospital.finance.service.impl;

import com.hospital.finance.entity.ServiceHospitalier;
import com.hospital.finance.repository.ServiceHospitalierRepository;
import com.hospital.finance.service.ServiceHospitalierService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ServiceHospitalierServiceImpl implements ServiceHospitalierService {

    private final ServiceHospitalierRepository repository;

    @Override
    public ServiceHospitalier createService(ServiceHospitalier service) {
        return repository.save(service);
    }

    @Override
    public ServiceHospitalier updateService(Long id, ServiceHospitalier updated) {
        ServiceHospitalier existing = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Service introuvable"));

        existing.setNomService(updated.getNomService());
        existing.setBudgetMensuel(updated.getBudgetMensuel());
        existing.setBudgetAnnuel(updated.getBudgetAnnuel());
        existing.setSeuilAlerte(updated.getSeuilAlerte());

        return repository.save(existing);
    }

    @Override
    public void deleteService(Long id) {
        repository.deleteById(id);
    }

    @Override
    public ServiceHospitalier getById(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Service introuvable"));
    }

    @Override
    public List<ServiceHospitalier> getAll() {
        return repository.findAll();
    }

    @Override
    public List<ServiceHospitalier> getAllServices() {
        // utilisé par ServiceHospitalierController
        return repository.findAll();
    }
}
