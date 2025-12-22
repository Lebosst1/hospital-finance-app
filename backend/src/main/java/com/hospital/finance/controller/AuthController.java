// src/main/java/com/hospital/finance/controller/AuthController.java
package com.hospital.finance.controller;

import com.hospital.finance.entity.Role;
import com.hospital.finance.entity.Utilisateur;
import com.hospital.finance.repository.RoleRepository;
import com.hospital.finance.security.jwt.JwtUtil;
import com.hospital.finance.security.payload.AuthRequest;
import com.hospital.finance.security.payload.AuthResponse;
import com.hospital.finance.service.UtilisateurService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final UtilisateurService utilisateurService;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    // ✅ Création d’un admin
    @PostMapping("/register-admin")
    public ResponseEntity<?> registerAdmin(@RequestBody AuthRequest request) {

        // Vérifier que l’email n’existe pas déjà
        try {
            utilisateurService.getByEmail(request.getEmail());
            // Si on arrive ici, l’utilisateur existe déjà
            return ResponseEntity
                    .status(HttpStatus.BAD_REQUEST)
                    .body("Email déjà utilisé");
        } catch (RuntimeException e) {
            // OK : l’email n’existe pas, on peut créer
        }

        // Récupérer ou créer le rôle ADMIN
        Role adminRole = roleRepository.findByNomRole("ADMIN")
                .orElseGet(() -> {
                    Role r = new Role();
                    r.setNomRole("ADMIN");
                    return roleRepository.save(r);
                });

        Utilisateur admin = new Utilisateur();
        admin.setNom("Admin");
        admin.setPrenom("Principal");
        admin.setEmail(request.getEmail());
        // ⚠️ On laisse le password brut ici, il sera encodé dans createUser()
        admin.setMotDePasse(request.getPassword());
        admin.setActif(true);
        admin.setRole(adminRole);

        utilisateurService.createUser(admin);

        return ResponseEntity.ok("Admin créé avec succès");
    }

    // ✅ Login avec JWT + renvoi du rôle / nom / prénom
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody AuthRequest request) {
        try {
            // 1) Récupérer l'utilisateur par email
            Utilisateur utilisateur;
            try {
                utilisateur = utilisateurService.getByEmail(request.getEmail());
            } catch (RuntimeException e) {
                return ResponseEntity
                        .status(HttpStatus.UNAUTHORIZED)
                        .body("Email ou mot de passe incorrect");
            }

            // 2) Vérifier le mot de passe
            boolean ok = passwordEncoder.matches(
                    request.getPassword(),
                    utilisateur.getMotDePasse()
            );

            if (!ok) {
                return ResponseEntity
                        .status(HttpStatus.UNAUTHORIZED)
                        .body("Email ou mot de passe incorrect");
            }

            // 3) Générer le JWT
            String token = jwtUtil.generateToken(utilisateur.getEmail());

            // 4) Rôle + nom/prénom (pour Flutter)
            String role = (utilisateur.getRole() != null)
                    ? utilisateur.getRole().getNomRole()
                    : "USER";

            AuthResponse response = new AuthResponse(
                    token,
                    role,
                    utilisateur.getNom(),
                    utilisateur.getPrenom()
            );

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Erreur interne : " + e.getClass().getSimpleName() + " - " + e.getMessage());
        }
    }
}
