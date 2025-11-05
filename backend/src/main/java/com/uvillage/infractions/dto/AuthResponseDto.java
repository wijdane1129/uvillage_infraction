package com.uvillage.infractions.dto;
import lombok.*;
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AuthResponseDto {
    private boolean success;
    private String message;
    private String token;
    private Object data;
    public static AuthResponseDto ok(String message,String token,Object data ){
        return AuthResponseDto.builder().success(true).message(message).token(token).data(data).build();
    }
    public static AuthResponseDto fail(String message){
        return AuthResponseDto.builder().success(false).message(message).build();
    }

}