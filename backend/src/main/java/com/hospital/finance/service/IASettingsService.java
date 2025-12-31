package com.hospital.finance.service;

import com.hospital.finance.entity.IASettings;

public interface IASettingsService {
    IASettings getSettings();
    IASettings updateSettings(IASettings settings);
}
