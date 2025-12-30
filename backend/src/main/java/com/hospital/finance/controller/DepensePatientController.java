package com.hospital.finance.controller;

import com.hospital.finance.entity.DepensePatient;
import com.hospital.finance.service.DepensePatientService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/depenses-patient")
public class DepensePatientController {
    @Autowired
    private DepensePatientService depensePatientService;

    @GetMapping
    public List<DepensePatient> getAll() {
        return depensePatientService.getAll();
    }

    @GetMapping("/service/{idService}")
    public List<DepensePatient> getByService(@PathVariable Integer idService) {
        return depensePatientService.getByService(idService);
    }

    @GetMapping("/patient/{idPatient}")
    public List<DepensePatient> getByPatient(@PathVariable Integer idPatient) {
        return depensePatientService.getByPatient(idPatient);
    }

    @GetMapping("/service/{idService}/patient/{idPatient}")
    public List<DepensePatient> getByServiceAndPatient(@PathVariable Integer idService, @PathVariable Integer idPatient) {
        return depensePatientService.getByServiceAndPatient(idService, idPatient);
    }
}
