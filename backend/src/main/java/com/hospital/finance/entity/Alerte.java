package com.hospital.finance.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "alerte")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
public class Alerte {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idAlerte;

    private String type;     // Budget, Variation, etc.
    private String message;
    private String niveau;    // INFO, WARNING, DANGER
    private String status;    // NOUVELLE, EN_COURS, RESOLUE

    private LocalDateTime dateAlerte;

    @ManyToOne
    @JoinColumn(name = "id_service")
    private ServiceHospitalier service;
}
