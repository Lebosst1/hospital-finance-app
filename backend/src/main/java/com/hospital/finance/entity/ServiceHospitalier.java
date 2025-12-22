package com.hospital.finance.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;
import java.util.List;

@Entity
@Table(name = "service_hospitalier")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
public class ServiceHospitalier {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idService;

    @Column(nullable = false)
    private String nomService;

    private Double budgetMensuel;
    private Double budgetAnnuel;
    private Double seuilAlerte;

    // Chef de service (optionnel)
    //@OneToOne(mappedBy = "service")
    //@JsonIgnore   // 🔴 on ne renvoie pas ça dans le JSON
    //private Utilisateur chefService;

    // Relations
    @OneToMany(mappedBy = "service")
    @JsonIgnore
    private List<Sejour> sejours;

    @OneToMany(mappedBy = "service")
    @JsonIgnore
    private List<Prevision> previsions;

    @OneToMany(mappedBy = "service")
    @JsonIgnore
    private List<Alerte> alertes;

    @OneToMany(mappedBy = "service")
    @JsonIgnore
    private List<Consommable> consommables;
}
