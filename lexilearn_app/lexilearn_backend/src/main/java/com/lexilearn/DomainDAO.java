package com.lexilearn;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class DomainDAO {

    public boolean insertDomain(String domainName) {
        String sql = "INSERT INTO Domains (domain_name) VALUES (?)";

        try (Connection conn = DatabaseManager.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, domainName);

            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}