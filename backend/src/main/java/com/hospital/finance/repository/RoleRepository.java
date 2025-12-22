package com.hospital.finance.repository;

import com.hospital.finance.entity.Role;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface RoleRepository extends JpaRepository<Role, Long> {

    Optional<Role> findByNomRole(String nomRole);

}
