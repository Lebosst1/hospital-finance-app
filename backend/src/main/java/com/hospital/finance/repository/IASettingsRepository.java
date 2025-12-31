package com.hospital.finance.repository;

import com.hospital.finance.entity.IASettings;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface IASettingsRepository extends JpaRepository<IASettings, Long> {
}
