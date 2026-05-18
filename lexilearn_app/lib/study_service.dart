import 'dart:convert';
import 'package:http/http.dart' as http;
import 'study_models.dart';

class StudyService {
  // Base URL for the backend API.
  // Note: 10.0.2.2 is used for Android emulators to access the host machine's localhost.
  static const String baseUrl = 'http://10.0.2.2:8080';

  /// Fetches the list of studies the user has already started (Ongoing).
  Future<List<OngoingStudy>> getOngoingStudies(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/ongoing?userId=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => OngoingStudy.fromJson(data)).toList();
      } else {
        throw Exception(
          'Failed to load ongoing studies: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching ongoing studies: $e');
      // Rethrowing the exception so the FutureBuilder in UI shows the error state
      throw Exception(
        'Failed to fetch ongoing studies. Please check your connection.',
      );
    }
  }

  /// Fetches the list of available studies that the user hasn't started yet.
  Future<List<AvailableStudy>> getAvailableStudies(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/available?userId=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse
            .map((data) => AvailableStudy.fromJson(data))
            .toList();
      } else {
        throw Exception(
          'Failed to load available studies: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching available studies: $e');
      // Rethrowing the exception so the FutureBuilder in UI shows the error state
      throw Exception(
        'Failed to fetch available studies. Please check your connection.',
      );
    }
  }

  /// Starts a new study by sending a POST request to the backend.
  /// This inserts a record into the User_Progress table with 0% completion.
  Future<bool> startStudy(int userId, int studyId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/start'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId, 'studyId': studyId}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error starting study: $e');
      return false;
    }
  }

  // userId eklendi ve URL güncellendi
  Future<List<Question>> getQuestionsForStudy(int studyId, int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/questions?studyId=$studyId&userId=$userId'),
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Question.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load questions');
    }
  }

  Future<double?> submitAnswer(int userId, int studyId, int questionId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/submit-answer'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'studyId': studyId,
          'questionId': questionId,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return (jsonResponse['newCompletionRate'] as num).toDouble();
        }
      }
      return null;
    } catch (e) {
      print('Error submitting answer: $e');
      return null;
    }
  }

  // Hocanın sorularını getir
  Future<List<Question>> getProfessorQuestions(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/professor/questions?userId=$userId'),
    );
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Question.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load professor questions');
    }
  }

  // Soruyu sil
  Future<bool> deleteQuestion(int questionId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/question/delete?questionId=$questionId'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['success'] ?? false;
    }
    return false;
  }

  // Soruyu güncelle
  Future<bool> updateQuestion({
    required int questionId,
    required String text,
    required String answer,
    required List<String> options,
    required String level,
    required String questionType,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/question/update?questionId=$questionId&text=$text&answer=$answer&options=${jsonEncode(options)}&level=$level&questionType=$questionType',
      ),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['success'] ?? false;
    }
    return false;
  }
}
