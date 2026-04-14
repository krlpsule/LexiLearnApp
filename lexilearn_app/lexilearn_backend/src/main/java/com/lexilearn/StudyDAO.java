package com.lexilearn;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class StudyDAO {
    public List<Map<String, Object>> getAllStudies() {
    List<Map<String, Object>> studies = new ArrayList<>();
    String sql = "SELECT study_id, title FROM Studies";
    
    try (Connection conn = DatabaseManager.getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql);
         ResultSet rs = pstmt.executeQuery()) {
        
        while (rs.next()) {
            Map<String, Object> study = new HashMap<>();
            study.put("studyId", rs.getInt("study_id"));
            study.put("title", rs.getString("title"));
            studies.add(study);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return studies;
}

    public boolean insertStudy(int domainId, String title, String level) {
        String sql = "INSERT INTO Studies (domain_id, title, level) VALUES (?, ?, ?)";

        try (Connection conn = DatabaseManager.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, domainId);
            pstmt.setString(2, title);
            pstmt.setString(3, level);

            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}