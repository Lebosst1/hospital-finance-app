package com.hospital.finance.service.impl;

import com.hospital.finance.entity.Utilisateur;
import com.hospital.finance.repository.UtilisateurRepository;
import com.hospital.finance.service.UtilisateurService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class UtilisateurServiceImpl implements UtilisateurService {

    private final UtilisateurRepository utilisateurRepository;
    private final PasswordEncoder passwordEncoder;  // ✅ injecté

    @Override
    public Utilisateur createUser(Utilisateur utilisateur) {
        // ✅ très important : encoder le mot de passe AVANT de sauvegarder
        String rawPassword = utilisateur.getMotDePasse();
        utilisateur.setMotDePasse(passwordEncoder.encode(rawPassword));
        return utilisateurRepository.save(utilisateur);
    }

    @Override
    public Utilisateur updateUser(Long id, Utilisateur updated) {
        Utilisateur existing = utilisateurRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Utilisateur introuvable"));

        existing.setNom(updated.getNom());
        existing.setPrenom(updated.getPrenom());
        existing.setEmail(updated.getEmail());

        // si tu veux permettre de changer le mot de passe :
        if (updated.getMotDePasse() != null && !updated.getMotDePasse().isBlank()) {
            existing.setMotDePasse(passwordEncoder.encode(updated.getMotDePasse()));
        }

        existing.setActif(updated.isActif());
        existing.setRole(updated.getRole());
        existing.setService(updated.getService());

        return utilisateurRepository.save(existing);
    }

    @Override
    public void deleteUser(Long id) {
        utilisateurRepository.deleteById(id);
    }

    @Override
    public Utilisateur getById(Long id) {
        return utilisateurRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Utilisateur introuvable"));
    }

    @Override
    public Utilisateur getByEmail(String email) {
        return utilisateurRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Email introuvable"));
    }

    @Override
    public List<Utilisateur> getAllUsers() {
        return utilisateurRepository.findAll();
    }
}
