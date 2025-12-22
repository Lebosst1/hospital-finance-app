package com.hospital.finance.service;

import com.hospital.finance.entity.Prevision;
import java.util.List;

public interface PrevisionService {

    Prevision createPrevision(Prevision prevision);

    Prevision updatePrevision(Long id, Prevision prevision);

    void deletePrevision(Long id);

    Prevision getById(Long id);

    List<Prevision> getAll();

    List<Prevision> getPrevisionsByService(Long idService);
}
