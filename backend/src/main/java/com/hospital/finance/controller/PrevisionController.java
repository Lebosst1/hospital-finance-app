package com.hospital.finance.controller;

import com.hospital.finance.entity.Prevision;
import com.hospital.finance.service.PrevisionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/prevision")   // ⚠️ doit matcher ApiService ("/prevision/...")
@RequiredArgsConstructor
public class PrevisionController {

    private final PrevisionService previsionService;

    // Récupérer une prévision par id
    @GetMapping("/{id}")
    public ResponseEntity<Prevision> getById(@PathVariable Long id) {
        Prevision p = previsionService.getById(id);
        return ResponseEntity.ok(p);
    }

    // Toutes les prévisions
    // -> utilisé par ApiService.getPrevisions()
    @GetMapping("/all")
    public ResponseEntity<List<Prevision>> getAll() {
        List<Prevision> list = previsionService.getAll();
        return ResponseEntity.ok(list);
    }

    // Prévisions d'un service
    @GetMapping("/service/{idService}")
    public ResponseEntity<List<Prevision>> getByService(@PathVariable Long idService) {
        List<Prevision> list = previsionService.getPrevisionsByService(idService);
        return ResponseEntity.ok(list);
    }

    // Créer une prévision
    // -> utilisé par ApiService.createPrevision()
    @PostMapping("/add")
    public ResponseEntity<Prevision> add(@RequestBody Prevision prevision) {

        // si dateCalcul pas envoyée depuis Flutter, on met "maintenant"
        if (prevision.getDateCalcul() == null) {
            prevision.setDateCalcul(LocalDateTime.now());
        }

        Prevision created = previsionService.createPrevision(prevision);
        return ResponseEntity.status(201).body(created);
    }

    // Mettre à jour
    // -> ApiService.updatePrevision() appelle /prevision/{id}
    @PutMapping("/{id}")
    public ResponseEntity<Prevision> update(
            @PathVariable Long id,
            @RequestBody Prevision prevision
    ) {
        Prevision updated = previsionService.updatePrevision(id, prevision);
        return ResponseEntity.ok(updated);
    }

    // Supprimer
    // -> ApiService.deletePrevision()
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        previsionService.deletePrevision(id);
        return ResponseEntity.noContent().build();
    }
}
