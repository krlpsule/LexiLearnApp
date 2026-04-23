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

  Question({
    required this.questionId,
    required this.questionText,
    required this.correctAnswer,
    required this.options,
    required this.difficultyLevel,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    List<String> parsedOptions = [];
    try {
      if (json['optionsJson'] != null) {
        parsedOptions = List<String>.from(jsonDecode(json['optionsJson']));
      }
    } catch (e) {
      print("Error parsing options JSON: $e");
    }

    return Question(
      questionId: json['questionId'],
      questionText: json['questionText'],
      correctAnswer: json['correctAnswer'],
      options: parsedOptions,
      difficultyLevel: json['difficultyLevel'],
    );
  }
}
