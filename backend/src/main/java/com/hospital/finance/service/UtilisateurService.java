package com.hospital.finance.service;

import com.hospital.finance.entity.Utilisateur;

import java.util.List;

public interface UtilisateurService {

    Utilisateur createUser(Utilisateur utilisateur);

    Utilisateur updateUser(Long id, Utilisateur utilisateur);

    void deleteUser(Long id);

    Utilisateur getById(Long id);

    Utilisateur getByEmail(String email);

    List<Utilisateur> getAllUsers();
}
