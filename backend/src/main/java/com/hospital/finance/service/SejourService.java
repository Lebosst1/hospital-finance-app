package com.hospital.finance.service;

import com.hospital.finance.entity.Sejour;
import java.util.List;

public interface SejourService {

    Sejour createSejour(Sejour sejour);

    Sejour updateSejour(Long id, Sejour sejour);

    void deleteSejour(Long id);

    Sejour getById(Long id);

    List<Sejour> getAll();

    List<Sejour> getSejoursByService(Long idService);

    List<Sejour> getSejoursByPatient(Long idPatient);
}
