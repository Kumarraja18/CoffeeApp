package com.brewco.config;

import com.brewco.entity.User;
import com.brewco.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import java.time.LocalDateTime;

@Component
public class DataInitializer implements CommandLineRunner {

    @Autowired
    private UserRepository userRepository;

    @Override
    public void run(String... args) throws Exception {
        // Check if admin user already exists
        if (!userRepository.existsByEmail("v.kumarraja2018@gmail.com")) {
            User adminUser = new User();
            adminUser.setFirstName("Admin");
            adminUser.setLastName("BrewCo");
            adminUser.setEmail("v.kumarraja2018@gmail.com");
            adminUser.setPassword("kumar0237"); // In production, use BCrypt to hash this!
            adminUser.setGender("MALE");
            adminUser.setRole("ADMIN");
            adminUser.setIsActive(true);
            adminUser.setCreatedAt(LocalDateTime.now());
            adminUser.setUpdatedAt(LocalDateTime.now());
            adminUser.setLoginCount(0);

            userRepository.save(adminUser);
            System.out.println("✓ Default admin user created successfully!");
            System.out.println("  Email: v.kumarraja2018@gmail.com");
            System.out.println("  Password: kumar0237");
        } else {
            System.out.println("✓ Admin user already exists. Skipping initialization.");
        }
    }
}
