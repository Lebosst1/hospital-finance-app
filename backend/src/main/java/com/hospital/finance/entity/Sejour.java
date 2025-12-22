package com.hospital.finance.entity;

import jakarta.persistence.*;
import lombok.*;

import java.sql.Date;

@Entity
@Table(name = "sejour")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
public class Sejour {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idSejour;

    private int nbJours;
    private Double cout;

    private Date dateEntree;
    private Date dateSortie;

    @ManyToOne
    @JoinColumn(name = "id_service")
    private ServiceHospitalier service;

    @ManyToOne
    @JoinColumn(name = "id_patient")
    private Patient patient;
}
