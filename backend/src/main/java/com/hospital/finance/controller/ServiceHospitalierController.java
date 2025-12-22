package com.hospital.finance.controller;

import com.hospital.finance.entity.ServiceHospitalier;
import com.hospital.finance.service.ServiceHospitalierService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/services")   // 👈 c'est ce chemin que Flutter appelle
public class ServiceHospitalierController {

    @Autowired
    private ServiceHospitalierService serviceHospitalierService;

    @GetMapping("/{id}")
    public ResponseEntity<ServiceHospitalier> getServiceById(@PathVariable Long id) {
        ServiceHospitalier serviceHospitalier = serviceHospitalierService.getById(id);
        return serviceHospitalier != null
                ? ResponseEntity.ok(serviceHospitalier)
                : ResponseEntity.notFound().build();
    }

    @GetMapping("/all")
    public ResponseEntity<List<ServiceHospitalier>> getAllServices() {
        List<ServiceHospitalier> services = serviceHospitalierService.getAllServices();
        return ResponseEntity.ok(services);
    }

    @PostMapping("/add")
    public ResponseEntity<ServiceHospitalier> addService(@RequestBody ServiceHospitalier serviceHospitalier) {
        ServiceHospitalier createdService = serviceHospitalierService.createService(serviceHospitalier);
        return ResponseEntity.status(201).body(createdService);
    }

    @PutMapping("/{id}")
    public ResponseEntity<ServiceHospitalier> updateService(
            @PathVariable Long id,
            @RequestBody ServiceHospitalier serviceHospitalier
    ) {
        ServiceHospitalier updatedService = serviceHospitalierService.updateService(id, serviceHospitalier);
        return updatedService != null
                ? ResponseEntity.ok(updatedService)
                : ResponseEntity.notFound().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteService(@PathVariable Long id) {
        serviceHospitalierService.deleteService(id);
        return ResponseEntity.noContent().build();
    }
}
