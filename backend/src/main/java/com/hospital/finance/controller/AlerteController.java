package com.hospital.finance.controller;

import com.hospital.finance.entity.Alerte;
import com.hospital.finance.service.AlerteService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/alerte")
public class AlerteController {

    @Autowired
    private AlerteService alerteService;

    @GetMapping("/{id}")
    public ResponseEntity<Alerte> getAlerteById(@PathVariable Long id) {
        Alerte alerte = alerteService.getById(id);
        return alerte != null ? ResponseEntity.ok(alerte) : ResponseEntity.notFound().build();
    }

    @GetMapping("/all")
    public ResponseEntity<List<Alerte>> getAllAlertes() {
        List<Alerte> alertes = alerteService.getAllAlertes();
        return ResponseEntity.ok(alertes);
    }

    @PostMapping("/add")
    public ResponseEntity<Alerte> addAlerte(@RequestBody Alerte alerte) {
        Alerte createdAlerte = alerteService.createAlerte(alerte);
        return ResponseEntity.status(201).body(createdAlerte);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Alerte> updateAlerte(@PathVariable Long id, @RequestBody Alerte alerte) {
        Alerte updatedAlerte = alerteService.updateAlerte(id, alerte);
        return updatedAlerte != null ? ResponseEntity.ok(updatedAlerte) : ResponseEntity.notFound().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteAlerte(@PathVariable Long id) {
        alerteService.deleteAlerte(id);
        return ResponseEntity.noContent().build();
    }
}
