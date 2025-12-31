package com.hospital.finance.security.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .authorizeHttpRequests(auth -> auth
                // Routes publiques
                .requestMatchers("/auth/**", "/finance/**", "/alerte/all", "/services/all", "/patient/all").permitAll()
                // Routes admin protégées
                .requestMatchers("/role/**", "/utilisateur/**", "/services/add", "/services/{id}/analyse", "/services/{id}", "/services/{id}/delete", "/alerte/add", "/alerte/{id}/valider").hasRole("ADMIN")
                // Toutes les autres requêtes nécessitent authentification
                .anyRequest().authenticated()
            )
            // JWT filter à ajouter ici si existant
            ;

        return http.build();
    }

    // ✅ Bean nécessaire pour UtilisateurServiceImpl + AuthController
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
