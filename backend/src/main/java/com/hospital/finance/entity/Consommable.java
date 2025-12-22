package com.hospital.finance.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "consommable")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
public class Consommable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idConsommable;

    private String nom;
    private Double coutUnitaire;
    private Integer quantitePrevue;

    @ManyToOne
    @JoinColumn(name = "id_service")
    private ServiceHospitalier service;
}
