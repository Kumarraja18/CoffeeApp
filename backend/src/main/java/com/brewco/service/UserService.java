package com.brewco.service;

import com.brewco.dto.LoginRequest;
import com.brewco.dto.RegisterRequest;
import com.brewco.dto.UserDto;
import com.brewco.entity.User;
import com.brewco.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.util.Optional;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    public User registerUser(RegisterRequest request) throws Exception {
        // Validate passwords match
        if (!request.getPassword().equals(request.getConfirmPassword())) {
            throw new Exception("Passwords do not match");
        }

        // Check if email already exists
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new Exception("Email already registered");
        }

        // Create new user
        User user = new User();
        user.setFirstName(request.getFirstName());
        user.setLastName(request.getLastName());
        user.setEmail(request.getEmail());
        user.setPassword(request.getPassword()); // In production, hash this password!
        user.setDateOfBirth(request.getDateOfBirth());
        user.setGender(request.getGender());
        user.setRole("CUSTOMER"); // Default role for new users
        user.setIsActive(true);

        return userRepository.save(user);
    }

    public User loginUser(LoginRequest request) throws Exception {
        Optional<User> user = userRepository.findByEmail(request.getEmail());

        if (user.isEmpty()) {
            throw new Exception("No account found with this email. Please sign up first.");
        }

        User existingUser = user.get();

        // Check activation status FIRST (before password check)
        // Pending users from multi-step registration have NULL passwords
        if (!existingUser.getIsActive()) {
            throw new Exception("Your account is pending admin approval. Please wait for approval.");
        }

        // Guard against null password (user approved without password somehow)
        if (existingUser.getPassword() == null || existingUser.getPassword().isBlank()) {
            throw new Exception("Your account has not been fully set up yet. Please contact admin.");
        }

        // Simple password check (in production, use BCrypt!)
        if (!existingUser.getPassword().equals(request.getPassword())) {
            throw new Exception("Invalid password");
        }

        // Cross-verify role if provided from frontend
        if (request.getRole() != null && !request.getRole().isEmpty()) {
            String selectedRole = request.getRole().toUpperCase().trim();
            String actualRole = existingUser.getRole().toUpperCase().trim();

            if (!selectedRole.equals(actualRole)) {
                String friendlyRole = actualRole.replace("_", " ").toLowerCase();
                throw new Exception("You are registered as '" + friendlyRole + "', not '"
                        + selectedRole.replace("_", " ").toLowerCase()
                        + "'. Please select the correct role.");
            }
        }

        // Record login details
        existingUser.setLastLoginAt(LocalDateTime.now());

        // Initialize loginCount if null
        if (existingUser.getLoginCount() == null) {
            existingUser.setLoginCount(1);
        } else {
            existingUser.setLoginCount(existingUser.getLoginCount() + 1);
        }

        return userRepository.save(existingUser);
    }

    public User loginUserWithIp(LoginRequest request, String ipAddress) throws Exception {
        User existingUser = loginUser(request);
        existingUser.setLastLoginIp(ipAddress);
        return userRepository.save(existingUser);
    }

    public User getUserById(Long id) throws Exception {
        Optional<User> user = userRepository.findById(id);
        if (user.isEmpty()) {
            throw new Exception("User not found");
        }
        return user.get();
    }

    public User updateUserProfile(Long id, User updatedUser) throws Exception {
        User user = getUserById(id);

        if (updatedUser.getPhoneNumber() != null) {
            user.setPhoneNumber(updatedUser.getPhoneNumber());
        }

        return userRepository.save(user);
    }

    public UserDto convertToDto(User user) {
        UserDto dto = new UserDto();
        dto.setId(user.getId());
        dto.setFirstName(user.getFirstName());
        dto.setLastName(user.getLastName());
        dto.setEmail(user.getEmail());
        dto.setRole(user.getRole());
        dto.setGender(user.getGender());
        dto.setIsActive(user.getIsActive());
        return dto;
    }
}
