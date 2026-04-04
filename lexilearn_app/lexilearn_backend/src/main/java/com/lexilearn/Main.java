package com.lexilearn;

import static spark.Spark.*;
import com.google.gson.Gson;
import java.util.HashMap;
import java.util.Map;

public class Main {
    public static void main(String[] args) {
        port(8080);

        before((req, res) -> {
            res.header("Access-Control-Allow-Origin", "*");
            res.header("Content-Type", "application/json");
        });

        Gson gson = new Gson();
        UserDAO userDAO = new UserDAO();

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

        DomainDAO domainDAO = new DomainDAO();
        StudyDAO studyDAO = new StudyDAO();
        QuestionDAO questionDAO = new QuestionDAO();

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
            String level = req.queryParams("level");
            boolean success = questionDAO.insertQuestion(studyId, text, answer, options, level);
            Map<String, Object> result = new HashMap<>();
            result.put("success", success);
            return gson.toJson(result);
        });
    }
}
