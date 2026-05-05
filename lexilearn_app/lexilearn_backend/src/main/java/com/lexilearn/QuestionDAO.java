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

   // Metoda 'userId' parametresi ekledik ve SQL sorgusunu veritabanınla (options_json) uyumlu hale getirdik
    public List<Map<String, Object>> getQuestionsByStudy(int studyId, int userId) {
        List<Map<String, Object>> questions = new ArrayList<>();
        
        // HATA BURADAYDI: q.options yerine q.options_json olarak düzeltildi
        String sql = "SELECT q.question_id, q.question_text, q.correct_answer, q.options_json, q.difficulty_level, " +
                     "(SELECT COUNT(*) FROM User_Answers ua WHERE ua.question_id = q.question_id AND ua.user_id = ?) as is_answered " +
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
                    
                    // HATA BURADAYDI: rs.getString("options") yerine "options_json" yapıldı
                    question.put("options", rs.getString("options_json")); 
                    
                    question.put("level", rs.getString("difficulty_level"));
                    // Flutter'ın anlaması için true/false olarak isAnswered ekliyoruz
                    question.put("isAnswered", rs.getInt("is_answered") > 0);
                    questions.add(question);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return questions;
    }}