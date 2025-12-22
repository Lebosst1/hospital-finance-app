package com.hospital.finance.repository;

import com.hospital.finance.entity.Prevision;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface PrevisionRepository extends JpaRepository<Prevision, Long> {

    List<Prevision> findByServiceIdService(Long idService);
}
