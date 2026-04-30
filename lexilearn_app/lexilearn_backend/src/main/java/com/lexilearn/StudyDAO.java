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
        // DÜZELTME: SQL sorgusuna domain_id eklendi
        String sql = "SELECT study_id, title, domain_id FROM Studies";

        try (Connection conn = DatabaseManager.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql);
                ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> study = new HashMap<>();
                study.put("studyId", rs.getInt("study_id"));
                study.put("title", rs.getString("title"));
                // DÜZELTME: Flutter'ın filtreleme yapabilmesi için domainId JSON'a eklendi
                study.put("domainId", rs.getInt("domain_id"));
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
        // Query links Studies -> Domains (to find creator) and Studies -> User_Progress
        // (for stats)
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

    public List<Map<String, Object>> getOngoingStudies(int userId) {
        List<Map<String, Object>> studies = new ArrayList<>();

        String sql = "SELECT s.study_id, s.title, d.domain_name, s.level, p.completion_rate, p.last_updated " +
                "FROM Studies s " +
                "JOIN Domains d ON s.domain_id = d.domain_id " +
                "JOIN User_Progress p ON s.study_id = p.study_id " +
                "WHERE p.user_id = ?";

        try (Connection conn = DatabaseManager.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> study = new HashMap<>();
                    study.put("studyId", rs.getInt("study_id"));
                    study.put("title", rs.getString("title"));
                    study.put("domainName", rs.getString("domain_name"));
                    study.put("difficultyLevel", rs.getString("level"));
                    study.put("completionRate", rs.getDouble("completion_rate"));

                    java.sql.Timestamp timestamp = rs.getTimestamp("last_updated");
                    study.put("lastUpdated", timestamp != null ? timestamp.toString() : "");

                    studies.add(study);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return studies;
    }

    public List<Map<String, Object>> getAvailableStudies(int userId) {
        List<Map<String, Object>> studies = new ArrayList<>();

        String sql = "SELECT s.study_id, s.title, d.domain_name, s.level " +
                "FROM Studies s " +
                "JOIN Domains d ON s.domain_id = d.domain_id " +
                "WHERE s.study_id NOT IN (SELECT study_id FROM User_Progress WHERE user_id = ?)";

        try (Connection conn = DatabaseManager.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> study = new HashMap<>();
                    study.put("studyId", rs.getInt("study_id"));
                    study.put("title", rs.getString("title"));
                    study.put("domainName", rs.getString("domain_name"));
                    study.put("difficultyLevel", rs.getString("level"));
                    studies.add(study);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return studies;
    }

    public boolean startStudy(int userId, int studyId) {
        String sql = "INSERT INTO User_Progress (user_id, study_id, completion_rate) VALUES (?, ?, 0.0)";

        try (Connection conn = DatabaseManager.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, userId);
            pstmt.setInt(2, studyId);

            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public double submitAnswerAndUpdateProgress(int userId, int studyId, int questionId) {
        String checkSql = "SELECT COUNT(*) FROM User_Answers WHERE user_id = ? AND question_id = ?";
        String insertSql = "INSERT INTO User_Answers (user_id, question_id, is_marked_complete) VALUES (?, ?, TRUE)";

        try (Connection conn = DatabaseManager.getConnection()) {

            try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
                checkStmt.setInt(1, userId);
                checkStmt.setInt(2, questionId);
                ResultSet rs = checkStmt.executeQuery();
                if (rs.next() && rs.getInt(1) == 0) {
                    try (PreparedStatement insertStmt = conn.prepareStatement(insertSql)) {
                        insertStmt.setInt(1, userId);
                        insertStmt.setInt(2, questionId);
                        insertStmt.executeUpdate();
                    }
                }
            }

            int totalQuestions = 0;
            int answeredQuestions = 0;

            String totalSql = "SELECT COUNT(*) FROM Questions WHERE study_id = ?";
            try (PreparedStatement tStmt = conn.prepareStatement(totalSql)) {
                tStmt.setInt(1, studyId);
                ResultSet rs = tStmt.executeQuery();
                if (rs.next())
                    totalQuestions = rs.getInt(1);
            }

            String answeredSql = "SELECT COUNT(ua.answer_id) FROM User_Answers ua JOIN Questions q ON ua.question_id = q.question_id WHERE ua.user_id = ? AND q.study_id = ?";
            try (PreparedStatement aStmt = conn.prepareStatement(answeredSql)) {
                aStmt.setInt(1, userId);
                aStmt.setInt(2, studyId);
                ResultSet rs = aStmt.executeQuery();
                if (rs.next())
                    answeredQuestions = rs.getInt(1);
            }

            double completionRate = 0.0;
            if (totalQuestions > 0) {
                completionRate = ((double) answeredQuestions / totalQuestions) * 100.0;
            }

            String updateProgressSql = "UPDATE User_Progress SET completion_rate = ?, last_updated = CURRENT_TIMESTAMP WHERE user_id = ? AND study_id = ?";
            try (PreparedStatement upStmt = conn.prepareStatement(updateProgressSql)) {
                upStmt.setDouble(1, completionRate);
                upStmt.setInt(2, userId);
                upStmt.setInt(3, studyId);
                upStmt.executeUpdate();
            }

            return completionRate;

        } catch (SQLException e) {
            e.printStackTrace();
            return -1.0;
        }
    }
}