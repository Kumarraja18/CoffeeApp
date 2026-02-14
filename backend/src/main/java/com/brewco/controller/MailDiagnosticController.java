package com.brewco.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.web.bind.annotation.*;

import java.util.LinkedHashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/debug")
@CrossOrigin(origins = "http://localhost:5173")
public class MailDiagnosticController {

    @Autowired(required = false)
    private JavaMailSender mailSender;

    @Value("${spring.mail.username:NOT_SET}")
    private String mailUsername;

    @Value("${spring.mail.password:NOT_SET}")
    private String mailPassword;

    @Value("${spring.mail.host:NOT_SET}")
    private String mailHost;

    @Value("${spring.mail.port:0}")
    private int mailPort;

    @GetMapping("/mail-config")
    public ResponseEntity<?> getMailConfig() {
        Map<String, Object> config = new LinkedHashMap<>();
        config.put("mailSenderAvailable", mailSender != null);
        config.put("mailHost", mailHost);
        config.put("mailPort", mailPort);
        config.put("mailUsername", mailUsername);
        config.put("mailPasswordSet",
                mailPassword != null && !mailPassword.isBlank() && !"NOT_SET".equals(mailPassword));
        config.put("mailPasswordLength", mailPassword != null ? mailPassword.length() : 0);
        config.put("mailSenderClass", mailSender != null ? mailSender.getClass().getName() : "null");
        return ResponseEntity.ok(config);
    }

    @PostMapping("/test-email")
    public ResponseEntity<?> testEmail(@RequestParam String to) {
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("to", to);
        result.put("from", mailUsername);

        if (mailSender == null) {
            result.put("status", "FAILED");
            result.put("error", "JavaMailSender bean is NULL");
            return ResponseEntity.ok(result);
        }

        if (mailUsername == null || mailUsername.isBlank() || "NOT_SET".equals(mailUsername)) {
            result.put("status", "FAILED");
            result.put("error", "MAIL_USERNAME is not configured");
            return ResponseEntity.ok(result);
        }

        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setFrom(mailUsername);
            message.setTo(to);
            message.setSubject("☕ Brew & Co — Test Email");
            message.setText("If you receive this, email is working!\n\nSent at: " + java.time.LocalDateTime.now());

            mailSender.send(message);

            result.put("status", "SUCCESS");
            result.put("message", "Email sent! Check inbox of: " + to);
        } catch (Exception e) {
            result.put("status", "FAILED");
            result.put("error", e.getMessage());
            result.put("errorType", e.getClass().getName());

            // Check for common issues
            if (e.getMessage() != null && e.getMessage().contains("AuthenticationFailedException")) {
                result.put("hint",
                        "Gmail credentials are wrong. Generate a new App Password at https://myaccount.google.com/apppasswords");
            } else if (e.getMessage() != null && e.getMessage().contains("ConnectException")) {
                result.put("hint", "Cannot reach SMTP server. Check firewall/internet.");
            }
        }

        return ResponseEntity.ok(result);
    }
}
