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
    // To enhance Prof's user page
    public List<Map<String, Object>> getProfessorStatistics(int userId) {
        List<Map<String, Object>> stats = new ArrayList<>();
        // Query links Studies -> Domains (to find creator) and Studies -> User_Progress (for stats)
        String sql = "SELECT s.study_id, s.title, " +
                     "COUNT(DISTINCT p.user_id) as student_count, " +
                     "IFNULL(AVG(p.completion_rate), 0) as avg_success " +
                     "FROM Studies s " +
                     "JOIN Domains d ON s.domain_id = d.domain_id " +
                     "LEFT JOIN User_Progress p ON s.study_id = p.study_id " +
                     "WHERE d.created_by = ? " +
                     "GROUP BY s.study_id, s.title";

        try (Connection conn = DatabaseManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> stat = new HashMap<>();
                    stat.put("studyId", rs.getInt("study_id"));
                    stat.put("title", rs.getString("title"));
                    stat.put("studentCount", rs.getInt("student_count"));
                    stat.put("avgSuccess", rs.getDouble("avg_success"));
                    stats.add(stat);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return stats;
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
