package com.hospital.finance.entity;

import jakarta.persistence.*;
import java.sql.Date;

@Entity
@Table(name = "depense_patient")
public class DepensePatient {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer idDepense;

    @Column(name = "id_patient")
    private Integer idPatient;

    @Column(name = "id_service")
    private Integer idService;

    private Double montant;
    private String type; // 'depense' ou 'gain'

    @Column(name = "date_operation")
    private Date dateOperation;

    private String description;

    // Getters & Setters
    public Integer getIdDepense() { return idDepense; }
    public void setIdDepense(Integer idDepense) { this.idDepense = idDepense; }
    public Integer getIdPatient() { return idPatient; }
    public void setIdPatient(Integer idPatient) { this.idPatient = idPatient; }
    public Integer getIdService() { return idService; }
    public void setIdService(Integer idService) { this.idService = idService; }
    public Double getMontant() { return montant; }
    public void setMontant(Double montant) { this.montant = montant; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public Date getDateOperation() { return dateOperation; }
    public void setDateOperation(Date dateOperation) { this.dateOperation = dateOperation; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
}
