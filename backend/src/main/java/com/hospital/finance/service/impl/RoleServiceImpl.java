package com.hospital.finance.service.impl;

import com.hospital.finance.entity.Role;
import com.hospital.finance.repository.RoleRepository;
import com.hospital.finance.service.RoleService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class RoleServiceImpl implements RoleService {

    private final RoleRepository roleRepository;

    @Override
    public Role createRole(Role role) {
        return roleRepository.save(role);
    }

    @Override
    public Role getById(Long id) {
        return roleRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Rôle introuvable"));
    }

    @Override
    public Role getByNom(String nomRole) {
        return roleRepository.findByNomRole(nomRole)
                .orElseThrow(() -> new RuntimeException("Rôle non trouvé : " + nomRole));
    }

    @Override
    public List<Role> getAll() {
        return roleRepository.findAll();
    }

    @Override
    public void deleteRole(Long id) {
        roleRepository.deleteById(id);
    }

    @Override
    public Role updateRole(Long id, Role role) {
        Role existing = roleRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Rôle introuvable"));

        existing.setNomRole(role.getNomRole());

        return roleRepository.save(existing);
    }

    @Override
    public List<Role> getAllRoles() {
        // utilisé par RoleController.getAllRoles()
        return roleRepository.findAll();
    }
}
