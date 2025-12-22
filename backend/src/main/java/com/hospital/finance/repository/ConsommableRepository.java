package com.hospital.finance.repository;

import com.hospital.finance.entity.Consommable;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ConsommableRepository extends JpaRepository<Consommable, Long> {

    List<Consommable> findByServiceIdService(Long idService);
}
