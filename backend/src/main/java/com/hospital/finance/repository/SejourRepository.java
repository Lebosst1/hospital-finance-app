package com.hospital.finance.repository;

import com.hospital.finance.entity.Sejour;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface SejourRepository extends JpaRepository<Sejour, Long> {

    List<Sejour> findByServiceIdService(Long idService);
    List<Sejour> findByPatientIdPatient(Long idPatient);
}
