package com.hospital.finance.repository;

import com.hospital.finance.entity.Alerte;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface AlerteRepository extends JpaRepository<Alerte, Long> {

    List<Alerte> findByServiceIdService(Long idService);
    List<Alerte> findByStatus(String status);
}
