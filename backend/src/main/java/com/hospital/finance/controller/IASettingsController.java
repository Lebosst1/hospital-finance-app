package com.hospital.finance.controller;

import com.hospital.finance.entity.IASettings;
import com.hospital.finance.service.IASettingsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/ia-settings")
public class IASettingsController {
    private final IASettingsService service;

    @Autowired
    public IASettingsController(IASettingsService service) {
        this.service = service;
    }

    @GetMapping
    public ResponseEntity<IASettings> getSettings() {
        return ResponseEntity.ok(service.getSettings());
    }

    @PutMapping
    public ResponseEntity<IASettings> updateSettings(@RequestBody IASettings settings) {
        return ResponseEntity.ok(service.updateSettings(settings));
    }
}
