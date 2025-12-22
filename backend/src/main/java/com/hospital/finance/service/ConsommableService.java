package com.hospital.finance.service;

import com.hospital.finance.entity.Consommable;
import java.util.List;

public interface ConsommableService {

    Consommable create(Consommable c);
    Consommable update(Long id, Consommable c);
    void delete(Long id);
    Consommable getById(Long id);
    List<Consommable> getAll();
    List<Consommable> getByService(Long idService);
}
