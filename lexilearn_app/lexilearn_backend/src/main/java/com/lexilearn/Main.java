package com.lexilearn;

import static spark.Spark.*;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import java.util.HashMap;
import java.util.Map;

public class Main {

    private static UserDAO userDAO;
    private static DomainDAO domainDAO;
    private static StudyDAO studyDAO;
    private static QuestionDAO questionDAO;

    public static void main(String[] args) {
        System.out.println("🚀🚀🚀 LEXILEARN BACKEND IS RUNNING 🚀🚀🚀");
        port(8080);

        // 1. CORS Settings
        options("/*", (req, res) -> {
            res.header("Access-Control-Allow-Origin", "*");
            res.header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
            res.header("Access-Control-Allow-Headers", "Content-Type, Authorization, Accept, Origin");

            String accessControlRequestHeaders = req.headers("Access-Control-Request-Headers");
            if (accessControlRequestHeaders != null) {
                res.header("Access-Control-Allow-Headers", accessControlRequestHeaders);
            }
            return "OK";
        });

        before((req, res) -> {
            System.out.println("INCOMING REQUEST: " + req.requestMethod() + " " + req.pathInfo());
            res.header("Access-Control-Allow-Origin", "*");
            if (!req.requestMethod().equals("OPTIONS")) {
                res.type("application/json");
            }
        });

        // 2. Initialize DAOs
        try {
            userDAO = new UserDAO();
            domainDAO = new DomainDAO();
            studyDAO = new StudyDAO();
            questionDAO = new QuestionDAO();
            System.out.println("✅ Database connections SUCCESSFUL!");
        } catch (Exception e) {
            System.out.println("🚨 Error occurred while initializing database!");
            e.printStackTrace();
        }

        Gson gson = new Gson();

        // ==========================================
        // AUTHENTICATION & PROFILE
        // ==========================================

        post("/register", (req, res) -> {
            JsonObject responseJson = new JsonObject();
            try {
                JsonObject body = gson.fromJson(req.body(), JsonObject.class);
                boolean isRegistered = userDAO.registerUser(
                        body.get("username").getAsString(),
                        body.get("email").getAsString(),
                        body.get("password").getAsString(),
                        body.get("role").getAsString());

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
                responseJson.addProperty("error", "Server error");
                e.printStackTrace();
            }
            return responseJson.toString();
        });

        post("/login", (req, res) -> {
            JsonObject responseJson = new JsonObject();
            try {
                JsonObject body = gson.fromJson(req.body(), JsonObject.class);
                User loggedInUser = userDAO.loginUser(
                        body.get("email").getAsString(),
                        body.get("password").getAsString());

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
                responseJson.addProperty("error", "Server error");
                e.printStackTrace();
            }
            return responseJson.toString();
        });

        // ==========================================
        // STUDENT STUDY ENDPOINTS
        // ==========================================

        get("/ongoing", (req, res) -> {
            int userId = Integer.parseInt(req.queryParams("userId"));
            return gson.toJson(studyDAO.getOngoingStudies(userId));
        });

        get("/available", (req, res) -> {
            int userId = Integer.parseInt(req.queryParams("userId"));
            return gson.toJson(studyDAO.getAvailableStudies(userId));
        });

        post("/start", (req, res) -> {
            JsonObject responseJson = new JsonObject();
            try {
                JsonObject body = gson.fromJson(req.body(), JsonObject.class);
                int userId = body.get("userId").getAsInt();
                int studyId = body.get("studyId").getAsInt();

                boolean success = studyDAO.startStudy(userId, studyId);

                if (success) {
                    res.status(200);
                    responseJson.addProperty("success", true);
                } else {
                    res.status(400);
                    responseJson.addProperty("success", false);
                }
            } catch (Exception e) {
                res.status(500);
                responseJson.addProperty("success", false);
                e.printStackTrace();
            }
            return responseJson.toString();
        });

        get("/questions", (req, res) -> {
            res.type("application/json");
            int studyId = Integer.parseInt(req.queryParams("studyId"));
            String userIdParam = req.queryParams("userId");
            int userId = userIdParam != null ? Integer.parseInt(userIdParam) : 0;
            return gson.toJson(questionDAO.getQuestionsByStudy(studyId, userId));
        });

        post("/submit-answer", (req, res) -> {
            JsonObject responseJson = new JsonObject();
            try {
                JsonObject body = gson.fromJson(req.body(), JsonObject.class);
                int userId = body.get("userId").getAsInt();
                int studyId = body.get("studyId").getAsInt();
                int questionId = body.get("questionId").getAsInt();

                double newRate = studyDAO.submitAnswerAndUpdateProgress(userId, studyId, questionId);

                if (newRate >= 0) {
                    res.status(200);
                    responseJson.addProperty("success", true);
                    responseJson.addProperty("newCompletionRate", newRate);
                } else {
                    res.status(400);
                    responseJson.addProperty("success", false);
                }
            } catch (Exception e) {
                res.status(500);
                responseJson.addProperty("success", false);
                e.printStackTrace();
            }
            return responseJson.toString();
        });

        // ==========================================
        // PROFESSOR & CONTENT MANAGEMENT
        // ==========================================

        post("/domain", (req, res) -> {
            String domainName = req.queryParams("domainName");
            boolean success = domainDAO.insertDomain(domainName);
            JsonObject result = new JsonObject();
            result.addProperty("success", success);
            return result.toString();
        });

        post("/study", (req, res) -> {
            int domainId = Integer.parseInt(req.queryParams("domainId"));
            String title = req.queryParams("title");
            String level = req.queryParams("level");
            boolean success = studyDAO.insertStudy(domainId, title, level);
            JsonObject result = new JsonObject();
            result.addProperty("success", success);
            return result.toString();
        });

        // Add a new question with professor's ID
        post("/question", (req, res) -> {
            int studyId = Integer.parseInt(req.queryParams("studyId"));
            String text = req.queryParams("text");
            String answer = req.queryParams("answer");
            String options = req.queryParams("options");

            if (options == null || options.trim().isEmpty()) {
                options = "[]";
            }

            String level = req.queryParams("level") != null ? req.queryParams("level") : "Beginner";
            String questionType = req.queryParams("questionType") != null ? req.queryParams("questionType")
                    : "multiple_choice";

            // Capture the professor's ID to set as created_by in the database
            int professorId = Integer.parseInt(req.queryParams("professorId"));

            boolean success = questionDAO.insertQuestion(studyId, text, answer, options, level, questionType,
                    professorId);
            JsonObject result = new JsonObject();
            result.addProperty("success", success);
            return result.toString();
        });

        // Get statistics for the professor's dashboard
        get("/professor/stats", (req, res) -> {
            int userId = Integer.parseInt(req.queryParams("userId"));
            return gson.toJson(studyDAO.getProfessorStatistics(userId));
        });

        // Get questions specifically created by the logged-in professor
        get("/professor/questions", (req, res) -> {
            int userId = Integer.parseInt(req.queryParams("userId"));
            return gson.toJson(questionDAO.getQuestionsByProfessor(userId));
        });

        // Update an existing question
        post("/question/update", (req, res) -> {
            int questionId = Integer.parseInt(req.queryParams("questionId"));
            String text = req.queryParams("text");
            String answer = req.queryParams("answer");
            String options = req.queryParams("options");
            String level = req.queryParams("level");
            String questionType = req.queryParams("questionType");

            boolean success = questionDAO.updateQuestion(questionId, text, answer, options, level, questionType);
            JsonObject result = new JsonObject();
            result.addProperty("success", success);
            return result.toString();
        });

        // Delete a specific question
        post("/question/delete", (req, res) -> {
            int questionId = Integer.parseInt(req.queryParams("questionId"));
            boolean success = questionDAO.deleteQuestion(questionId);
            JsonObject result = new JsonObject();
            result.addProperty("success", success);
            return result.toString();
        });

        // Get all available categories (domains)
        get("/domains", (req, res) -> gson.toJson(domainDAO.getAllDomains()));

        // Get all available studies
        get("/studies", (req, res) -> gson.toJson(studyDAO.getAllStudies()));
    }
}