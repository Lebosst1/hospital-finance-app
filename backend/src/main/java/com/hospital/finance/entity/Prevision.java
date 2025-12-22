package com.hospital.finance.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "prevision")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
public class Prevision {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idPrevision;

    private String periode; // JOUR, MOIS, ANNEE
    private Double coutPrevu;

    private LocalDateTime dateCalcul;

    @ManyToOne
    @JoinColumn(name = "id_service")
    private ServiceHospitalier service;
}
