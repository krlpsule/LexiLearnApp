import 'dart:convert';

class OngoingStudy {
  final int studyId;
  final String title;
  final String domainName;
  final String difficultyLevel;
  final double completionRate;
  final String lastUpdated;

  OngoingStudy({
    required this.studyId,
    required this.title,
    required this.domainName,
    required this.difficultyLevel,
    required this.completionRate,
    required this.lastUpdated,
  });

  factory OngoingStudy.fromJson(Map<String, dynamic> json) {
    return OngoingStudy(
      studyId: json['studyId'],
      title: json['title'],
      domainName: json['domainName'],
      difficultyLevel: json['difficultyLevel'],
      completionRate: json['completionRate'].toDouble(),
      lastUpdated: json['lastUpdated'],
    );
  }
}

class AvailableStudy {
  final int studyId;
  final String title;
  final String domainName;
  final String difficultyLevel;

  AvailableStudy({
    required this.studyId,
    required this.title,
    required this.domainName,
    required this.difficultyLevel,
  });

  factory AvailableStudy.fromJson(Map<String, dynamic> json) {
    return AvailableStudy(
      studyId: json['studyId'],
      title: json['title'],
      domainName: json['domainName'],
      difficultyLevel: json['difficultyLevel'],
    );
  }
}

class Question {
  final int questionId;
  final String questionText;
  final String correctAnswer;
  final List<String> options;
  final String difficultyLevel;
  final String questionType; // 'multiple_choice', 'true_false', 'fill_in_blank'
  bool isAnswered;

  Question({
    required this.questionId,
    required this.questionText,
    required this.correctAnswer,
    required this.options,
    required this.difficultyLevel,
    this.questionType = 'multiple_choice',
    this.isAnswered = false,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    List<String> parsedOptions = [];
    if (json['options'] != null && json['options'].toString().isNotEmpty) {
      try {
        parsedOptions = List<String>.from(jsonDecode(json['options']));
      } catch (_) {
        parsedOptions = [];
      }
    }

    return Question(
      questionId: json['questionId'],
      questionText: json['text'],
      correctAnswer: json['answer'],
      options: parsedOptions,
      difficultyLevel: json['level'] ?? '',
      questionType: json['questionType'] ?? 'multiple_choice',
      isAnswered: json['isAnswered'] ?? false,
    );
  }
}