package com.hospital.finance.dto;

import lombok.Data;

@Data
public class PatientDTO {
    private Long id;
    private String nom;
    private String prenom;
    private String adresse;
}
