package com.uvillage.infractions.util;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

/**
 * Utility to hash passwords for database insertion.
 * Run: mvn exec:java -Dexec.mainClass="com.uvillage.infractions.util.PasswordHashUtil"
 */
public class PasswordHashUtil {
    public static void main(String[] args) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        
        // Use first CLI argument as the password if provided, otherwise use default
        String password = "TestPass123!";
        if (args != null && args.length > 0 && args[0] != null && !args[0].isEmpty()) {
            password = args[0];
        }
        String hashedPassword = encoder.encode(password);
        
        System.out.println("\n================================");
        System.out.println("PASSWORD HASHING UTILITY");
        System.out.println("================================");
        System.out.println("Original Password: " + password);
        System.out.println("Hashed Password:   " + hashedPassword);
        System.out.println("\nUse this SQL to insert a user:");
        System.out.println("================================");
        System.out.println("INSERT INTO users (email, full_name, username, password, role, email_verified, locked, language)");
        System.out.println("VALUES (");
        System.out.println("  'test@example.com',");
        System.out.println("  'Test User',");
        System.out.println("  'test@example.com',");
        System.out.println("  '" + hashedPassword + "',");
        System.out.println("  'AGENT',");
        System.out.println("  true,");
        System.out.println("  false,");
        System.out.println("  'en'");
        System.out.println(");");
        System.out.println("================================\n");
    }
}
