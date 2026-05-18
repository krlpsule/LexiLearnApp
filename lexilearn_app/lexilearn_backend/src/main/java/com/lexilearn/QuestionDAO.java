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
            String difficultyLevel, String questionType) {

        String sql = "INSERT INTO Questions (study_id, question_text, correct_answer, options_json, difficulty_level, question_type) VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = DatabaseManager.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, studyId);
            pstmt.setString(2, questionText);
            pstmt.setString(3, correctAnswer);
            pstmt.setString(4, optionsJson);
            pstmt.setString(5, difficultyLevel);
            pstmt.setString(6, questionType);

            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Map<String, Object>> getQuestionsByStudy(int studyId, int userId) {
        List<Map<String, Object>> questions = new ArrayList<>();

        String sql = "SELECT q.question_id, q.question_text, q.correct_answer, q.options_json, q.difficulty_level, q.question_type, "
                +
                "(SELECT COUNT(*) FROM User_Answers ua WHERE ua.question_id = q.question_id AND ua.user_id = ?) as is_answered "
                +
                "FROM Questions q WHERE q.study_id = ?";

        try (Connection conn = DatabaseManager.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, userId);
            pstmt.setInt(2, studyId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> question = new HashMap<>();
                    question.put("questionId", rs.getInt("question_id"));
                    question.put("text", rs.getString("question_text"));
                    question.put("answer", rs.getString("correct_answer"));
                    question.put("options", rs.getString("options_json"));
                    question.put("level", rs.getString("difficulty_level"));
                    question.put("questionType", rs.getString("question_type"));
                    question.put("isAnswered", rs.getInt("is_answered") > 0);
                    questions.add(question);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return questions;
    }

    // Get Questions by Professor Method
    public List<Map<String, Object>> getQuestionsByProfessor(int professorId) {
        List<Map<String, Object>> questions = new ArrayList<>();
        String sql = "SELECT q.question_id, q.study_id, q.question_text, q.correct_answer, q.options_json, q.difficulty_level, q.question_type, s.title as study_title "
                +
                "FROM Questions q " +
                "JOIN Studies s ON q.study_id = s.study_id " +
                "JOIN Domains d ON s.domain_id = d.domain_id " +
                "WHERE d.created_by = ?";

        try (Connection conn = DatabaseManager.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, professorId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> question = new HashMap<>();
                    question.put("questionId", rs.getInt("question_id"));
                    question.put("studyId", rs.getInt("study_id"));
                    question.put("text", rs.getString("question_text"));
                    question.put("answer", rs.getString("correct_answer"));
                    question.put("options", rs.getString("options_json"));
                    question.put("level", rs.getString("difficulty_level"));
                    question.put("questionType", rs.getString("question_type"));
                    question.put("studyTitle", rs.getString("study_title"));
                    questions.add(question);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return questions;
    }

    // Update Question Method
    public boolean updateQuestion(int questionId, String questionText, String correctAnswer, String optionsJson,
            String difficultyLevel, String questionType) {
        String sql = "UPDATE Questions SET question_text = ?, correct_answer = ?, options_json = ?, difficulty_level = ?, question_type = ? WHERE question_id = ?";
        try (Connection conn = DatabaseManager.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, questionText);
            pstmt.setString(2, correctAnswer);
            pstmt.setString(3, optionsJson);
            pstmt.setString(4, difficultyLevel);
            pstmt.setString(5, questionType);
            pstmt.setInt(6, questionId);

            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Delete Question Method
    public boolean deleteQuestion(int questionId) {
        String sql = "DELETE FROM Questions WHERE question_id = ?";
        try (Connection conn = DatabaseManager.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, questionId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}