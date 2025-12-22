package com.hospital.finance.controller;

import com.hospital.finance.entity.Sejour;
import com.hospital.finance.service.SejourService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/sejour")
public class SejourController {

    @Autowired
    private SejourService sejourService;

    @GetMapping("/{id}")
    public ResponseEntity<Sejour> getSejourById(@PathVariable Long id) {
        Sejour sejour = sejourService.getById(id);
        return sejour != null ? ResponseEntity.ok(sejour) : ResponseEntity.notFound().build();
    }

    @GetMapping("/all")
    public ResponseEntity<List<Sejour>> getAllSejours() {
        List<Sejour> sejours = sejourService.getAll();
        return ResponseEntity.ok(sejours);
    }

    @PostMapping("/add")
    public ResponseEntity<Sejour> addSejour(@RequestBody Sejour sejour) {
        Sejour createdSejour = sejourService.createSejour(sejour);
        return ResponseEntity.status(201).body(createdSejour);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Sejour> updateSejour(@PathVariable Long id, @RequestBody Sejour sejour) {
        Sejour updatedSejour = sejourService.updateSejour(id, sejour);
        return updatedSejour != null ? ResponseEntity.ok(updatedSejour) : ResponseEntity.notFound().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteSejour(@PathVariable Long id) {
        sejourService.deleteSejour(id);
        return ResponseEntity.noContent().build();
    }
}
