import 'package:flutter/material.dart';
import 'study_models.dart';
import 'study_service.dart';

class StudyQuizScreen extends StatefulWidget {
  final int userId;
  final int studyId;
  final String studyTitle;
  final double initialProgress;

  const StudyQuizScreen({
    super.key,
    required this.userId,
    required this.studyId,
    required this.studyTitle,
    required this.initialProgress,
  });

  @override
  State<StudyQuizScreen> createState() => _StudyQuizScreenState();
}

class _StudyQuizScreenState extends State<StudyQuizScreen> {
  final StudyService _studyService = StudyService();
  List<Question> _questions = [];
  int _currentIndex = 0;
  double _currentProgress = 0.0;
  bool _isLoading = true;
  bool _isAnswering = false;

  @override
  void initState() {
    super.initState();
    _currentProgress = widget.initialProgress;
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await _studyService.getQuestionsForStudy(
        widget.studyId,
      );
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading questions: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _submitAnswer(String selectedOption) async {
    if (_isAnswering) return;
    setState(() => _isAnswering = true);

    final currentQuestion = _questions[_currentIndex];
    final isCorrect = selectedOption == currentQuestion.correctAnswer;

    // Kullanıcıya anlık geri bildirim ver
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCorrect
              ? 'Correct! 🎉'
              : 'Incorrect. The right answer was: ${currentQuestion.correctAnswer}',
        ),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );

    // Backend'e sonucu kaydet ve yeni progress'i al
    final newProgress = await _studyService.submitAnswer(
      widget.userId,
      widget.studyId,
      currentQuestion.questionId,
    );

    if (mounted && newProgress != null) {
      setState(() {
        _currentProgress = newProgress;
      });
    }

    // Biraz bekleyip diğer soruya geç
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _isAnswering = false;
      });
    } else {
      // Test bitti!
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Study Complete! 🎓'),
          content: Text('You have successfully finished ${widget.studyTitle}.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Dialogu kapat
                Navigator.pop(
                  context,
                  true,
                ); // Sayfayı kapatıp ana menüyü güncellemesi için "true" döndür
              },
              child: const Text('Back to My Studies'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.studyTitle),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6.0),
          child: LinearProgressIndicator(
            value: _currentProgress / 100, // Yüzdelik barı doldurur
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
            minHeight: 6.0,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _questions.isEmpty
          ? const Center(child: Text("No questions added for this study yet."))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Question ${_currentIndex + 1} of ${_questions.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _questions[_currentIndex].questionText,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ..._questions[_currentIndex].options.map((option) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isAnswering
                            ? null
                            : () => _submitAnswer(option),
                        child: Text(
                          option,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
    );
  }
}
