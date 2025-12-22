package com.hospital.finance.dto;

import lombok.Data;

@Data
public class SejourDTO {
    private Long id;
    private String serviceHospitalier;
    private Long patientId;
    private String dateEntree;
    private String dateSortie;
}
