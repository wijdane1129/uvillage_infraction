package com.uvillage.infractions.dto;

/**
 * Plain Java implementation of AuthResponseDto with a simple builder.
 * This avoids Lombok dependency during IDE annotation-processing issues.
 */
public class AuthResponseDto {
    private boolean success;
    private String message;
    private String token;
    private Object data;

    public AuthResponseDto() {}

    public AuthResponseDto(boolean success, String message, String token, Object data) {
        this.success = success;
        this.message = message;
        this.token = token;
        this.data = data;
    }

    public boolean isSuccess() { return success; }
    public void setSuccess(boolean success) { this.success = success; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }

    public Object getData() { return data; }
    public void setData(Object data) { this.data = data; }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private boolean success;
        private String message;
        private String token;
        private Object data;

        public Builder success(boolean success) { this.success = success; return this; }
        public Builder message(String message) { this.message = message; return this; }
        public Builder token(String token) { this.token = token; return this; }
        public Builder data(Object data) { this.data = data; return this; }
        public AuthResponseDto build() { return new AuthResponseDto(success, message, token, data); }
    }

    // Convenience static factory methods
    public static AuthResponseDto ok(String message, String token, Object data) {
        return AuthResponseDto.builder().success(true).message(message).token(token).data(data).build();
    }

    public static AuthResponseDto success(String message) {
        return AuthResponseDto.builder().success(true).message(message).build();
    }

    public static AuthResponseDto success(String message, String token) {
        return AuthResponseDto.builder().success(true).message(message).token(token).build();
    }

    public static AuthResponseDto success(String message, String token, Object data) {
        return ok(message, token, data);
    }

    public static AuthResponseDto fail(String message) {
        return AuthResponseDto.builder().success(false).message(message).build();
    }
}
