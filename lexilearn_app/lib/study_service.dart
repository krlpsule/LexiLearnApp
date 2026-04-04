import 'dart:convert';
import 'package:http/http.dart' as http;
import 'study_models.dart';

class StudyService {
  static const String baseUrl = 'http://10.0.2.2:8080/api/student';

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
        throw Exception('Failed to load ongoing studies: ${response.statusCode}');
      }
    } catch (e) {
      print('Using mock data for ongoing studies: $e');
      return _getMockOngoingStudies();
    }
  }

  Future<List<AvailableStudy>> getAvailableStudies(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/available?userId=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => AvailableStudy.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load available studies: ${response.statusCode}');
      }
    } catch (e) {
      print('Using mock data for available studies: $e');
      return _getMockAvailableStudies();
    }
  }

  List<OngoingStudy> _getMockOngoingStudies() {
    return [
      OngoingStudy(
        studyId: 1,
        title: 'Biology Basics',
        domainName: 'Biology',
        difficultyLevel: 'Beginner',
        completionRate: 45.0,
        lastUpdated: '2024-01-15',
      ),
      OngoingStudy(
        studyId: 2,
        title: "Newton's Laws",
        domainName: 'Physics',
        difficultyLevel: 'Intermediate',
        completionRate: 80.0,
        lastUpdated: '2024-01-14',
      ),
    ];
  }

  List<AvailableStudy> _getMockAvailableStudies() {
    return [
      AvailableStudy(
        studyId: 3,
        title: 'Chemical Reactions',
        domainName: 'Chemistry',
        difficultyLevel: 'Advanced',
      ),
      AvailableStudy(
        studyId: 4,
        title: 'World History',
        domainName: 'History',
        difficultyLevel: 'Beginner',
      ),
    ];
  }
}
