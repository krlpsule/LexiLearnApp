package com.lexilearn;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

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
}