package com.example.demo;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class CorsConfig {

    @Bean
    public WebMvcConfigurer corsConfigurer() {
        return new WebMvcConfigurer() {
            @Override
            public void addCorsMappings(CorsRegistry registry) {
                registry.addMapping("/**")          // 允許所有 API 路徑
                        .allowedOriginPatterns("*") // 🎯 允許任何來源網域（支援帶憑證的請求）
                        .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS") // 允許所有請求方法
                        .allowedHeaders("*")        // 允許所有 Header
                        .allowCredentials(true);    // 允許攜帶 Cookie 或認證資訊
            }
        };
    }
}