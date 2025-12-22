package com.hospital.finance.service;

import com.hospital.finance.entity.Role;

import java.util.List;

public interface RoleService {

    Role createRole(Role role);

    Role getById(Long id);

    Role getByNom(String nomRole);

    List<Role> getAll();

    void deleteRole(Long id);

    Role updateRole(Long id, Role role);// ✅ pour RoleController

    List<Role> getAllRoles();

}
