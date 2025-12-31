package com.hospital.finance.service.impl;

import com.hospital.finance.entity.IASettings;
import com.hospital.finance.repository.IASettingsRepository;
import com.hospital.finance.service.IASettingsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import jakarta.transaction.Transactional;
import java.util.Optional;

@Service
public class IASettingsServiceImpl implements IASettingsService {
    private final IASettingsRepository repository;

    @Autowired
    public IASettingsServiceImpl(IASettingsRepository repository) {
        this.repository = repository;
    }

    @Override
    public IASettings getSettings() {
        return repository.findAll().stream().findFirst().orElseGet(() -> {
            IASettings def = new IASettings();
            def.setActivation(true);
            def.setSensibilite(0.5);
            def.setHorizon(30);
            return repository.save(def);
        });
    }

    @Override
    @Transactional
    public IASettings updateSettings(IASettings settings) {
        IASettings current = getSettings();
        current.setActivation(settings.isActivation());
        current.setSensibilite(settings.getSensibilite());
        current.setHorizon(settings.getHorizon());
        return repository.save(current);
    }
}
