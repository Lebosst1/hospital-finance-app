package com.hospital.finance.service;

import com.hospital.finance.entity.Alerte;
import java.util.List;

public interface AlerteService {

    Alerte createAlerte(Alerte alerte);

    Alerte updateAlerte(Long id, Alerte alerte);

    void deleteAlerte(Long id);

    Alerte getById(Long id);

    List<Alerte> getAll();

    List<Alerte> getAlertesByService(Long idService);

    List<Alerte> getAlertesByStatus(String status);

    List<Alerte> getAllAlertes();
}
