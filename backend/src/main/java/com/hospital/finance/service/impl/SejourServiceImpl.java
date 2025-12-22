package com.hospital.finance.service.impl;

import com.hospital.finance.entity.Sejour;
import com.hospital.finance.repository.SejourRepository;
import com.hospital.finance.service.SejourService;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class SejourServiceImpl implements SejourService {

    private final SejourRepository repository;

    @Override
    public Sejour createSejour(Sejour sejour) {
        return repository.save(sejour);
    }

    @Override
    public Sejour updateSejour(Long id, Sejour updated) {
        Sejour existing = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Séjour introuvable"));

        existing.setNbJours(updated.getNbJours());
        existing.setCout(updated.getCout());
        existing.setDateEntree(updated.getDateEntree());
        existing.setDateSortie(updated.getDateSortie());
        existing.setService(updated.getService());
        existing.setPatient(updated.getPatient());

        return repository.save(existing);
    }

    @Override
    public void deleteSejour(Long id) {
        repository.deleteById(id);
    }

    @Override
    public Sejour getById(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Séjour introuvable"));
    }

    @Override
    public List<Sejour> getAll() {
        return repository.findAll();
    }

    @Override
    public List<Sejour> getSejoursByService(Long idService) {
        return repository.findByServiceIdService(idService);
    }

    @Override
    public List<Sejour> getSejoursByPatient(Long idPatient) {
        return repository.findByPatientIdPatient(idPatient);
    }
}
