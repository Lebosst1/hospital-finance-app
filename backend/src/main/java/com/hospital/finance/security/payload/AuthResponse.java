// src/main/java/com/hospital/finance/security/payload/AuthResponse.java
package com.hospital.finance.security.payload;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter @Setter
@AllArgsConstructor @NoArgsConstructor
public class AuthResponse {

    private String token;
    private String role;    // ex : "ADMIN" ou "USER"
    private String nom;
    private String prenom;
}
