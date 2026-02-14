package com.brewco.repository;

import com.brewco.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);

    Boolean existsByEmail(String email);

    // For admin dashboard
    List<User> findByIsActiveFalseOrderByCreatedAtDesc();

    List<User> findAllByOrderByCreatedAtDesc();

    long countByIsActive(Boolean isActive);

    long countByRole(String role);

    long countByCreatedAtAfter(LocalDateTime dateTime);
}
