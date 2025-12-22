package com.hospital.finance.service.impl;

import com.hospital.finance.entity.Alerte;
import com.hospital.finance.repository.AlerteRepository;
import com.hospital.finance.service.AlerteService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class AlerteServiceImpl implements AlerteService {

    private final AlerteRepository alerteRepository;

    @Override
    public Alerte createAlerte(Alerte alerte) {
        return alerteRepository.save(alerte);
    }

    @Override
    public Alerte updateAlerte(Long id, Alerte alerte) {
        Alerte existing = alerteRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Alerte introuvable"));

        existing.setType(alerte.getType());
        existing.setMessage(alerte.getMessage());
        existing.setNiveau(alerte.getNiveau());
        existing.setStatus(alerte.getStatus());
        existing.setDateAlerte(alerte.getDateAlerte());
        existing.setService(alerte.getService());

        return alerteRepository.save(existing);
    }

    @Override
    public void deleteAlerte(Long id) {
        alerteRepository.deleteById(id);
    }

    @Override
    public Alerte getById(Long id) {
        return alerteRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Alerte introuvable"));
    }

    @Override
    public List<Alerte> getAll() {
        return alerteRepository.findAll();
    }

    @Override
    public List<Alerte> getAlertesByService(Long idService) {
        return alerteRepository.findByServiceIdService(idService);
    }

    @Override
    public List<Alerte> getAlertesByStatus(String status) {
        return alerteRepository.findByStatus(status);
    }

    @Override
    public List<Alerte> getAllAlertes() {
        return alerteRepository.findAll();
    }
}
