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

  // Fill in the blank için text controller
  final TextEditingController _fillController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentProgress = widget.initialProgress;
    _loadQuestions();
  }

  @override
  void dispose() {
    _fillController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await _studyService.getQuestionsForStudy(
        widget.studyId,
        widget.userId,
      );

      setState(() {
        _questions = questions;
        _isLoading = false;

        if (_questions.isNotEmpty) {
          int resumeIndex = _questions.indexWhere((q) => q.isAnswered == false);
          if (resumeIndex != -1) {
            _currentIndex = resumeIndex;
          } else {
            _currentIndex = _questions.length - 1;
          }
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading questions: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _submitAnswer(String selectedOption) async {
    if (_isAnswering) return;
    setState(() => _isAnswering = true);

    final currentQuestion = _questions[_currentIndex];

    // Fill in the blank için büyük/küçük harf farkını görmezden gel
    final bool isCorrect =
        selectedOption.trim().toLowerCase() ==
        currentQuestion.correctAnswer.trim().toLowerCase();

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

    final newProgress = await _studyService.submitAnswer(
      widget.userId,
      widget.studyId,
      currentQuestion.questionId,
    );

    if (mounted && newProgress != null) {
      setState(() {
        _currentProgress = newProgress;
        _questions[_currentIndex].isAnswered = true;
      });
    }

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _isAnswering = false;
        _fillController.clear(); // Sonraki soruya geçince text'i temizle
      });
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Study Complete! 🎓'),
          content: Text(
            'You have successfully finished ${widget.studyTitle}.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, true);
              },
              child: const Text('Back to My Studies'),
            ),
          ],
        ),
      );
    }
  }

  // ──────────────────────────────────────────────────
  // Soru tipine göre doğru widget'ı seç
  // ──────────────────────────────────────────────────
  Widget _buildQuestionWidget(Question question) {
    switch (question.questionType) {
      case 'true_false':
        return _buildTrueFalseWidget();
      case 'fill_in_blank':
        return _buildFillInBlankWidget();
      default:
        return _buildMultipleChoiceWidget(question);
    }
  }

  // ──────────────────────────────────────────────────
  // Multiple Choice widget (mevcut mantık)
  // ──────────────────────────────────────────────────
  Widget _buildMultipleChoiceWidget(Question question) {
    return Column(
      children: question.options.map((option) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _isAnswering ? null : () => _submitAnswer(option),
            child: Text(option, style: const TextStyle(fontSize: 18)),
          ),
        );
      }).toList(),
    );
  }

  // ──────────────────────────────────────────────────
  // True / False widget
  // ──────────────────────────────────────────────────
  Widget _buildTrueFalseWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // TRUE butonu
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                backgroundColor: Colors.green.shade50,
                foregroundColor: Colors.green.shade800,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.green.shade300, width: 2),
                ),
              ),
              onPressed: _isAnswering ? null : () => _submitAnswer('true'),
              icon: const Icon(Icons.check_circle_outline, size: 28),
              label: const Text(
                'True',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        // FALSE butonu
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red.shade800,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.red.shade300, width: 2),
                ),
              ),
              onPressed: _isAnswering ? null : () => _submitAnswer('false'),
              icon: const Icon(Icons.cancel_outlined, size: 28),
              label: const Text(
                'False',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────
  // Fill in the Blank widget
  // ──────────────────────────────────────────────────
  Widget _buildFillInBlankWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _fillController,
          enabled: !_isAnswering,
          decoration: InputDecoration(
            hintText: 'Type your answer here...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: const TextStyle(fontSize: 18),
          onSubmitted: (_) {
            if (!_isAnswering) _submitAnswer(_fillController.text);
          },
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16),
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _isAnswering
              ? null
              : () {
                  if (_fillController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please type an answer first.'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }
                  _submitAnswer(_fillController.text.trim());
                },
          child: const Text(
            'Submit Answer',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────
  // Ana build
  // ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.studyTitle),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6.0),
          child: LinearProgressIndicator(
            value: _currentProgress / 100,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
            minHeight: 6.0,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _questions.isEmpty
          ? const Center(
              child: Text('No questions added for this study yet.'),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Soru sayacı
                  Text(
                    'Question ${_currentIndex + 1} of ${_questions.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Soru tipi etiketi
                  _buildTypeChip(_questions[_currentIndex].questionType),
                  const SizedBox(height: 16),

                  // Soru metni
                  Text(
                    _questions[_currentIndex].questionText,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Soru tipine göre widget
                  _buildQuestionWidget(_questions[_currentIndex]),
                ],
              ),
            ),
    );
  }

  // Soru tipini gösteren küçük renkli etiket
  Widget _buildTypeChip(String type) {
    String label;
    Color color;

    switch (type) {
      case 'true_false':
        label = 'True / False';
        color = Colors.green;
        break;
      case 'fill_in_blank':
        label = 'Fill in the Blank';
        color = Colors.orange;
        break;
      default:
        label = 'Multiple Choice';
        color = Colors.blue;
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Chip(
        label: Text(label, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }
}