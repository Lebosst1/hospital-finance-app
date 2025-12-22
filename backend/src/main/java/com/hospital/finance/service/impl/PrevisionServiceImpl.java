package com.hospital.finance.service.impl;

import com.hospital.finance.entity.Prevision;
import com.hospital.finance.repository.PrevisionRepository;
import com.hospital.finance.service.PrevisionService;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class PrevisionServiceImpl implements PrevisionService {

    private final PrevisionRepository repository;

    @Override
    public Prevision createPrevision(Prevision prevision) {
        return repository.save(prevision);
    }

    @Override
    public Prevision updatePrevision(Long id, Prevision updated) {
        Prevision existing = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Prévision introuvable"));

        existing.setCoutPrevu(updated.getCoutPrevu());
        existing.setPeriode(updated.getPeriode());
        existing.setDateCalcul(updated.getDateCalcul());
        existing.setService(updated.getService());

        return repository.save(existing);
    }

    @Override
    public void deletePrevision(Long id) {
        repository.deleteById(id);
    }

    @Override
    public Prevision getById(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Prévision introuvable"));
    }

    @Override
    public List<Prevision> getAll() {
        return repository.findAll();
    }

    @Override
    public List<Prevision> getPrevisionsByService(Long idService) {
        return repository.findByServiceIdService(idService);
    }
}
