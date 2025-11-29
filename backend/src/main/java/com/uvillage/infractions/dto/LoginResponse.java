package com.uvillage.infractions.dto;

/**
 * Plain LoginResponse with manual builder to avoid Lombok.
 */
public class LoginResponse {
    private String token;
    private String email;
    private Long agentRowid;
    private String nomComplet;
    private String role;

    public LoginResponse() {}

    public LoginResponse(String token, String email, Long agentRowid, String nomComplet, String role) {
        this.token = token;
        this.email = email;
        this.agentRowid = agentRowid;
        this.nomComplet = nomComplet;
        this.role = role;
    }

    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public Long getAgentRowid() { return agentRowid; }
    public void setAgentRowid(Long agentRowid) { this.agentRowid = agentRowid; }
    public String getNomComplet() { return nomComplet; }
    public void setNomComplet(String nomComplet) { this.nomComplet = nomComplet; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private String token;
        private String email;
        private Long agentRowid;
        private String nomComplet;
        private String role;

        public Builder token(String token) { this.token = token; return this; }
        public Builder email(String email) { this.email = email; return this; }
        public Builder agentRowid(Long agentRowid) { this.agentRowid = agentRowid; return this; }
        public Builder nomComplet(String nomComplet) { this.nomComplet = nomComplet; return this; }
        public Builder role(String role) { this.role = role; return this; }

        public LoginResponse build() { return new LoginResponse(token, email, agentRowid, nomComplet, role); }
    }
}
