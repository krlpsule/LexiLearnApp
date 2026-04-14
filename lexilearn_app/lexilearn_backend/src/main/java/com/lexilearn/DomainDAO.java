package com.lexilearn;

import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class DomainDAO {

    public List<Map<String, Object>> getAllDomains() {
        List<Map<String, Object>> domains = new ArrayList<>();
        String sql = "SELECT domain_id, domain_name FROM Domains";

        try (Connection conn = DatabaseManager.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql);
                ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> domain = new HashMap<>();
                domain.put("domainId", rs.getInt("domain_id"));
                domain.put("domainName", rs.getString("domain_name"));
                domains.add(domain);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return domains;
    }

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