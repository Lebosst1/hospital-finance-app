package com.hospital.finance.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "utilisateur")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
public class Utilisateur {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idUtilisateur;

    private String nom;
    private String prenom;

    @Column(nullable = false, unique = true)
    private String email;

    private String motDePasse;
    private boolean actif = true;

    // Relation avec Role
    @ManyToOne
    @JoinColumn(name = "id_role")
    private Role role;

    // Relation optionnelle : Chef de service ?
    @ManyToOne
    @JoinColumn(name = "id_service", nullable = true)
    private ServiceHospitalier service;
}
