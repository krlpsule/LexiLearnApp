package com.lexilearn;

import static spark.Spark.*;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import java.util.HashMap;
import java.util.Map;

public class Main {

    public static void main(String[] args) {
        port(8080);

        // Standard CORS setup for Flutter integration
        before((req, res) -> {
            res.header("Access-Control-Allow-Origin", "*");
            res.header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
            res.header("Access-Control-Allow-Headers", "Content-Type, Authorization");
            res.header("Content-Type", "application/json");
        });

        Gson gson = new Gson();
        
        // Initialize all your DAOs
        UserDAO userDAO = new UserDAO();
        DomainDAO domainDAO = new DomainDAO();
        StudyDAO studyDAO = new StudyDAO();
        QuestionDAO questionDAO = new QuestionDAO();

        // ==========================================
        // USER STORY 1: AUTHENTICATION (Restored)
        // Note: These parse JSON from the request body
        // ==========================================
        
        post("/register", (req, res) -> {
            JsonObject responseJson = new JsonObject();
            try {
                JsonObject body = gson.fromJson(req.body(), JsonObject.class);
                String username = body.get("username").getAsString();
                String email = body.get("email").getAsString();
                String password = body.get("password").getAsString(); 
                String role = body.get("role").getAsString();

                boolean isRegistered = userDAO.registerUser(username, email, password, role);

                if (isRegistered) {
                    res.status(201);
                    responseJson.addProperty("success", true);
                } else {
                    res.status(400);
                    responseJson.addProperty("success", false);
                    responseJson.addProperty("error", "Email might already exist.");
                }
            } catch (Exception e) {
                res.status(500);
                responseJson.addProperty("success", false);
                responseJson.addProperty("error", "Server error processing registration.");
            }
            return responseJson.toString();
        });

        post("/login", (req, res) -> {
            JsonObject responseJson = new JsonObject();
            try {
                JsonObject body = gson.fromJson(req.body(), JsonObject.class);
                String email = body.get("email").getAsString();
                String password = body.get("password").getAsString();

                // Uses the User model class from earlier
                User loggedInUser = userDAO.loginUser(email, password);

                if (loggedInUser != null) {
                    res.status(200);
                    responseJson.addProperty("success", true);
                    responseJson.addProperty("userId", loggedInUser.getUserId());
                    responseJson.addProperty("username", loggedInUser.getUsername());
                    responseJson.addProperty("role", loggedInUser.getRole());
                } else {
                    res.status(401);
                    responseJson.addProperty("success", false);
                    responseJson.addProperty("error", "Invalid credentials.");
                }
            } catch (Exception e) {
                res.status(500);
                responseJson.addProperty("success", false);
                responseJson.addProperty("error", "Server error processing login.");
            }
            return responseJson.toString();
        });

        // ==========================================
        // USER STORY 2: PROFILE MANAGEMENT (Your Code)
        // ==========================================

        put("/user/username", (req, res) -> {
            int userId = Integer.parseInt(req.queryParams("userId"));
            String newUsername = req.queryParams("newUsername");
            boolean success = userDAO.updateUsername(userId, newUsername);
            Map<String, Object> result = new HashMap<>();
            result.put("success", success);
            return gson.toJson(result);
        });

        put("/user/password", (req, res) -> {
            int userId = Integer.parseInt(req.queryParams("userId"));
            String currentHash = req.queryParams("currentHash");
            String newHash = req.queryParams("newHash");
            boolean success = userDAO.updatePassword(userId, currentHash, newHash);
            Map<String, Object> result = new HashMap<>();
            result.put("success", success);
            return gson.toJson(result);
        });

        // ==========================================
        // USER STORY 4: EDUCATIONAL CONTENT (Your Code)
        // ==========================================

        post("/domain", (req, res) -> {
            String domainName = req.queryParams("domainName");
            boolean success = domainDAO.insertDomain(domainName);
            Map<String, Object> result = new HashMap<>();
            result.put("success", success);
            return gson.toJson(result);
        });

        post("/study", (req, res) -> {
            int domainId = Integer.parseInt(req.queryParams("domainId"));
            String title = req.queryParams("title");
            String level = req.queryParams("level");
            boolean success = studyDAO.insertStudy(domainId, title, level);
            Map<String, Object> result = new HashMap<>();
            result.put("success", success);
            return gson.toJson(result);
        });

        post("/question", (req, res) -> {
            int studyId = Integer.parseInt(req.queryParams("studyId"));
            String text = req.queryParams("text");
            String answer = req.queryParams("answer");
            String options = req.queryParams("options");
            String level = req.queryParams("level"); // Wait, does the Question table have a level column?
            boolean success = questionDAO.insertQuestion(studyId, text, answer, options, level);
            Map<String, Object> result = new HashMap<>();
            result.put("success", success);
            return gson.toJson(result);
        });

        get("/domains", (req, res) -> {
            return gson.toJson(domainDAO.getAllDomains());
        });

        get("/studies", (req, res) -> {
            return gson.toJson(studyDAO.getAllStudies());
        });
    }
}
