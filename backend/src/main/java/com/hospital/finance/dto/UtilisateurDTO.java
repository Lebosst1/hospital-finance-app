package com.hospital.finance.dto;

import lombok.Data;

@Data
public class UtilisateurDTO {
    private Long id;
    private String email;
    private String nom;
    private String prenom;
    private String password;  // Cette donnée ne doit pas être envoyée dans les réponses
}
