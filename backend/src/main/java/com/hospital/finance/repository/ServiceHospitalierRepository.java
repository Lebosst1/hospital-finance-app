package com.hospital.finance.repository;

import com.hospital.finance.entity.ServiceHospitalier;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ServiceHospitalierRepository extends JpaRepository<ServiceHospitalier, Long> {
}
