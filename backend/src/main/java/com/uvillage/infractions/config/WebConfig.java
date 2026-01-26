package com.uvillage.infractions.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        // CORS is configured in SecurityConfig - this method is left empty to avoid conflicts
        // Do not configure CORS here when using Spring Security's CORS configuration
    }
}