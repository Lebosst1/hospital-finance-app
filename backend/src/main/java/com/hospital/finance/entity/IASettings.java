package com.hospital.finance.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "ia_settings")
public class IASettings {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private boolean activation;

    @Column(nullable = false)
    private double sensibilite;

    @Column(nullable = false)
    private int horizon;

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public boolean isActivation() { return activation; }
    public void setActivation(boolean activation) { this.activation = activation; }

    public double getSensibilite() { return sensibilite; }
    public void setSensibilite(double sensibilite) { this.sensibilite = sensibilite; }

    public int getHorizon() { return horizon; }
    public void setHorizon(int horizon) { this.horizon = horizon; }
}
