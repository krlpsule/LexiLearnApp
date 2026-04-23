package com.lexilearn;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class QuestionDAO {

    public boolean insertQuestion(int studyId, String questionText, String correctAnswer, String optionsJson,
            String difficultyLevel) {
        String sql = "INSERT INTO Questions (study_id, question_text, correct_answer, options_json, difficulty_level) VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = DatabaseManager.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, studyId);
            pstmt.setString(2, questionText);
            pstmt.setString(3, correctAnswer);
            pstmt.setString(4, optionsJson);
            pstmt.setString(5, difficultyLevel);

            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Map<String, Object>> getQuestionsForStudy(int studyId) {
        List<Map<String, Object>> questions = new ArrayList<>();
        String sql = "SELECT question_id, question_text, correct_answer, options_json, difficulty_level FROM Questions WHERE study_id = ?";

        try (Connection conn = DatabaseManager.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, studyId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> q = new HashMap<>();
                    q.put("questionId", rs.getInt("question_id"));
                    q.put("questionText", rs.getString("question_text"));
                    q.put("correctAnswer", rs.getString("correct_answer"));
                    q.put("optionsJson", rs.getString("options_json"));
                    q.put("difficultyLevel", rs.getString("difficulty_level"));
                    questions.add(q);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return questions;
    }
}