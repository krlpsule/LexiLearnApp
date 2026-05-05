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
  bool isAnswered; // YENİ EKLENEN KISIM

  Question({
    required this.questionId,
    required this.questionText,
    required this.correctAnswer,
    required this.options,
    required this.difficultyLevel,
    this.isAnswered = false, // YENİ EKLENEN KISIM
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      questionId: json['questionId'],
      questionText: json['text'],
      correctAnswer: json['answer'],
      options: List<String>.from(jsonDecode(json['options'])),
      difficultyLevel: json['level'],
      isAnswered: json['isAnswered'] ?? false, // YENİ EKLENEN KISIM
    );
  }
}
