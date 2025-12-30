package com.hospital.finance.repository;

import com.hospital.finance.entity.DepensePatient;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface DepensePatientRepository extends JpaRepository<DepensePatient, Integer> {
    List<DepensePatient> findByIdService(Integer idService);
    List<DepensePatient> findByIdPatient(Integer idPatient);
    List<DepensePatient> findByIdServiceAndIdPatient(Integer idService, Integer idPatient);
}
