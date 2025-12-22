package com.hospital.finance.dto;

import lombok.Data;

@Data
public class AlerteDTO {
    private Long id;
    private String message;
    private String type; // Example: "DANGER", "WARNING"
    private Long patientId;
    private Long serviceHospitalierId;
}
