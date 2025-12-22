package com.hospital.finance.service.impl;

import com.hospital.finance.entity.Consommable;
import com.hospital.finance.repository.ConsommableRepository;
import com.hospital.finance.service.ConsommableService;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ConsommableServiceImpl implements ConsommableService {

    private final ConsommableRepository repository;

    @Override
    public Consommable create(Consommable c) {
        return repository.save(c);
    }

    @Override
    public Consommable update(Long id, Consommable newC) {
        Consommable existing = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Consommable introuvable"));

        existing.setNom(newC.getNom());
        existing.setCoutUnitaire(newC.getCoutUnitaire());
        existing.setQuantitePrevue(newC.getQuantitePrevue());
        existing.setService(newC.getService());

        return repository.save(existing);
    }

    @Override
    public void delete(Long id) {
        repository.deleteById(id);
    }

    @Override
    public Consommable getById(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Consommable introuvable"));
    }

    @Override
    public List<Consommable> getAll() {
        return repository.findAll();
    }

    @Override
    public List<Consommable> getByService(Long idService) {
        return repository.findByServiceIdService(idService);
    }
}
