package io.github.cyrenh.custodia.user.dto;

import io.github.cyrenh.custodia.user.UserRole;

import java.util.UUID;

public record UserResponse(
        UUID id,
        String email,
        String fullName,
        UserRole role
) {

    public static UserResponse from(io.github.cyrenh.custodia.user.User user) {
        return new UserResponse(
                user.getId(),
                user.getEmail(),
                user.getFullName(),
                user.getRole()
        );
    }
}