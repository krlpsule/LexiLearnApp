package com.lexilearn;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class StudyDAO {

   public boolean insertStudy(int domainId, String title, String level) {
    String sql = "INSERT INTO Studies (domain_id, title, level) VALUES (?, ?, ?)";

        try (Connection conn = DatabaseManager.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, domainId);
            pstmt.setString(2, level);

            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}