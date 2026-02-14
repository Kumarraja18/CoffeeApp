package com.brewco.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
public class EmailService {

    @Autowired(required = false)
    private JavaMailSender mailSender;

    public void sendApprovalEmail(String toEmail, String firstName, String password) {
        if (mailSender == null) {
            System.out.println("⚠ Mail sender not configured. Skipping email.");
            System.out.println("  Would have sent to: " + toEmail);
            System.out.println("  Generated password: " + password);
            return;
        }

        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setTo(toEmail);
            message.setSubject("☕ Brew & Co — Your Account Has Been Approved!");
            message.setText(
                    "Hello " + firstName + ",\n\n" +
                            "Great news! Your Brew & Co account has been approved by our admin team.\n\n" +
                            "Here are your login credentials:\n" +
                            "━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n" +
                            "  Email:    " + toEmail + "\n" +
                            "  Password: " + password + "\n" +
                            "━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n" +
                            "Please change your password after your first login for security.\n\n" +
                            "Login at: http://localhost:5173/login\n\n" +
                            "Welcome to the Brew & Co family! ☕\n\n" +
                            "Best regards,\n" +
                            "Brew & Co Admin Team");

            mailSender.send(message);
            System.out.println("✓ Approval email sent to: " + toEmail);
        } catch (Exception e) {
            System.err.println("✗ Failed to send email to " + toEmail + ": " + e.getMessage());
            // Don't throw — the user is already approved; log and continue
        }
    }

    public void sendRejectionEmail(String toEmail, String firstName) {
        if (mailSender == null) {
            System.out.println("⚠ Mail sender not configured. Skipping rejection email.");
            return;
        }

        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setTo(toEmail);
            message.setSubject("Brew & Co — Registration Update");
            message.setText(
                    "Hello " + firstName + ",\n\n" +
                            "We regret to inform you that your Brew & Co registration has not been approved at this time.\n\n"
                            +
                            "If you believe this was a mistake, please contact our support team.\n\n" +
                            "Best regards,\n" +
                            "Brew & Co Admin Team");

            mailSender.send(message);
        } catch (Exception e) {
            System.err.println("✗ Failed to send rejection email: " + e.getMessage());
        }
    }
}
