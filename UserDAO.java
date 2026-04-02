import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UserDAO {

    // Handles the Sign-Up process (Task 1.2 & 1.3)
    public boolean registerUser(String username, String email, String passwordHash, String role) {
        String sql = "INSERT INTO Users (username, email, password_hash, role) VALUES (?, ?, ?, ?)";

        try (Connection conn = DatabaseManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, username);
            pstmt.setString(2, email);
            pstmt.setString(3, passwordHash);
            pstmt.setString(4, role); // 'Student' or 'Professor'

            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0; // Returns true if the user was successfully added

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Handles the Login process (Task 1.2 & 1.3)
    public User loginUser(String email, String inputPasswordHash) {
        String sql = "SELECT user_id, username, password_hash, role FROM Users WHERE email = ?";

        try (Connection conn = DatabaseManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, email);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                String storedPasswordHash = rs.getString("password_hash");
                
                // Check if the provided password matches the one in the database
                if (storedPasswordHash.equals(inputPasswordHash)) {
                    return new User(
                        rs.getInt("user_id"),
                        rs.getString("username"),
                        email,
                        storedPasswordHash,
                        rs.getString("role")
                    );
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null; // Returns null if login fails
    } 
    // Updates username (Task 2.2)
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

// Updates password (Task 2.2)
public boolean updatePassword(int userId, String currentPasswordHash, String newPasswordHash) {
    String checkSql = "SELECT password_hash FROM Users WHERE user_id = ?";
    try (Connection conn = DatabaseManager.getConnection();
         PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
        
        checkStmt.setInt(1, userId);
        ResultSet rs = checkStmt.executeQuery();
        if (rs.next()) {
            String storedHash = rs.getString("password_hash");
            if (!storedHash.equals(currentPasswordHash)) {
                return false;
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
        return false;
    }

    String updateSql = "UPDATE Users SET password_hash = ? WHERE user_id = ?";
    try (Connection conn = DatabaseManager.getConnection();
         PreparedStatement pstmt = conn.prepareStatement(updateSql)) {
        
        pstmt.setString(1, newPasswordHash);
        pstmt.setInt(2, userId);
        int affectedRows = pstmt.executeUpdate();
        return affectedRows > 0;
    } catch (SQLException e) {
        e.printStackTrace();
        return false;
    }
}
}