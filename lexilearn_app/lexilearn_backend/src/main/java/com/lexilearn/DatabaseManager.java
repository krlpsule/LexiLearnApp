package com.lexilearn;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseManager {
    // Update these with your local MySQL credentials
// Append &useUnicode=true&characterEncoding=utf8mb4 to the URL
    private static final String URL = "jdbc:mysql://avnadmin:AVNS_gSWs219QI_R5gSyb8_F@mysql-22586bd6-lexilearnapp.a.aivencloud.com:12421/defaultdb?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&useUnicode=true&characterEncoding=UTF-8";
    private static final String USER = "avnadmin";
    private static final String PASSWORD = "AVNS_gSWs219QI_R5gSyb8_F";

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }

}
