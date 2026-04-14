
package com.lexilearn;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UserDAO {

    // 1. Register Method (INSERT)
    public boolean registerUser(String username, String email, String passwordHash, String role) {
        String sql = "INSERT INTO Users (username, email, password_hash, role) VALUES (?, ?, ?, ?)";

        try (Connection conn = DatabaseManager.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, username);
            pstmt.setString(2, email);
            pstmt.setString(3, passwordHash);
            pstmt.setString(4, role);

            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // 2. Login Method (SELECT)
    public User loginUser(String email, String inputPasswordHash) {
        String sql = "SELECT user_id, username, password_hash, role FROM Users WHERE email = ?";

        try (Connection conn = DatabaseManager.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, email);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                String storedPasswordHash = rs.getString("password_hash");

                // Verify password matches
                if (storedPasswordHash.equals(inputPasswordHash)) {
                    return new User(
                            rs.getInt("user_id"),
                            rs.getString("username"),
                            email,
                            storedPasswordHash,
                            rs.getString("role"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null; // Login failed (wrong email or password)
    }

    public boolean updateUsername(int userId, String newUsername) {
        String sql = "UPDATE Users SET username = ? WHERE user_id = ?";

        try (Connection conn = DatabaseManager.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, newUsername);
            pstmt.setInt(2, userId);

            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updatePassword(int userId, String currentPassword, String newPassword) {
        String checkSql = "SELECT password_hash FROM Users WHERE user_id = ?";
        String updateSql = "UPDATE Users SET password_hash = ? WHERE user_id = ?";

        try (Connection conn = DatabaseManager.getConnection();
                PreparedStatement checkStmt = conn.prepareStatement(checkSql);
                PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {

            checkStmt.setInt(1, userId);
            ResultSet rs = checkStmt.executeQuery();

            if (rs.next()) {
                String storedPassword = rs.getString("password_hash");

                if (storedPassword.equals(currentPassword)) {
                    updateStmt.setString(1, newPassword);
                    updateStmt.setInt(2, userId);

                    int affectedRows = updateStmt.executeUpdate();
                    return affectedRows > 0;
                }
            }
            return false;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
