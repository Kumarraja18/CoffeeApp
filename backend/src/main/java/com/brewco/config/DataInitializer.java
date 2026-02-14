package com.brewco.config;

import com.brewco.entity.User;
import com.brewco.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import java.time.LocalDateTime;

@Component
public class DataInitializer implements CommandLineRunner {

    @Autowired
    private UserRepository userRepository;

    @Value("${ADMIN_EMAIL:admin@brewco.com}")
    private String adminEmail;

    @Value("${ADMIN_PASSWORD:admin123}")
    private String adminPassword;

    @Override
    public void run(String... args) throws Exception {
        try {
            // Check if admin user already exists
            if (!userRepository.existsByEmail(adminEmail)) {
                User adminUser = new User();
                adminUser.setFirstName("Admin");
                adminUser.setLastName("BrewCo");
                adminUser.setEmail(adminEmail);
                adminUser.setPassword(adminPassword);
                adminUser.setGender("MALE");
                adminUser.setRole("ADMIN");
                adminUser.setIsActive(true);
                adminUser.setCreatedAt(LocalDateTime.now());
                adminUser.setUpdatedAt(LocalDateTime.now());
                adminUser.setLoginCount(0);

                userRepository.save(adminUser);
                System.out.println("============================================");
                System.out.println("✓ Default admin user created successfully!");
                System.out.println("  Email:    " + adminEmail);
                System.out.println("  Password: " + adminPassword);
                System.out.println("============================================");
            } else {
                System.out.println("✓ Admin user already exists. Skipping initialization.");
            }
        } catch (Exception e) {
            System.err.println("⚠ DataInitializer warning: " + e.getMessage());
            System.err.println("  The app will still work. You can create admin manually.");
        }
    }
}
