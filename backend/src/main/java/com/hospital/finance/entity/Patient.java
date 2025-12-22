package com.hospital.finance.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "patient")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
public class Patient {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idPatient;

    @Column(nullable = false)
    private String nom;

    @Column(nullable = false)
    private String prenom;

    private String sexe; // 'H' ou 'F'
    private String telephone;
    private String adresse;

    @Column(name = "date_naissance")
    private java.sql.Date dateNaissance;
}
