import 'package:flutter/material.dart';
import 'study_models.dart';
import 'study_service.dart';
import 'language_manager.dart';

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

  // Boşluk doldurma (fill in the blank) soruları için text controller
  final TextEditingController _fillBlankController = TextEditingController();

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

  @override
  void dispose() {
    _fillBlankController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await _studyService.getQuestionsForStudy(
        widget.studyId,
        widget.userId,
      );

      if (!mounted) return;

      setState(() {
        _questions = questions;
        _isLoading = false;

        if (_questions.isNotEmpty) {
          // Çözülmemiş ilk soruyu bul
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

    // Boşluk doldurmada büyük/küçük harf duyarlılığını önlemek için toLowerCase yapıyoruz
    final isCorrect =
        selectedOption.trim().toLowerCase() ==
        currentQuestion.correctAnswer.trim().toLowerCase();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCorrect
              ? LanguageManager.getText('correct_exclamation')
              : '${LanguageManager.getText('incorrect_answer')} ${currentQuestion.correctAnswer}',
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
        _fillBlankController.clear(); // Sonraki soruya geçerken kutuyu temizle
      });
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(LanguageManager.getText('study_complete')),
          content: Text('${LanguageManager.getText('successfully_finished')} ${widget.studyTitle}.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, true);
              },
              child: Text(LanguageManager.getText('back_to_my_studies')),
            ),
          ],
        ),
      );
    }
  }

  // YENİ: Soru tipine göre (Multiple Choice, True/False, Fill Blank) arayüz oluşturan fonksiyon
  Widget _buildQuestionUI(Question question) {
    switch (question.questionType) {
      // 1. DOĞRU/YANLIŞ SORULARI
      case 'true_false':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [_buildOptionButton('True'), _buildOptionButton('False')],
        );

      // 2. BOŞLUK DOLDURMA SORULARI
      case 'fill_in_blank':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _fillBlankController,
              decoration: const InputDecoration(
                hintText: 'Type your answer here...',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  _submitAnswer(value);
                }
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
                      if (_fillBlankController.text.trim().isNotEmpty) {
                        _submitAnswer(_fillBlankController.text);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter an answer first.'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
              child: const Text(
                'Submit Answer',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );

      // 3. ÇOKTAN SEÇMELİ SORULAR (Varsayılan)
      case 'multiple_choice':
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: question.options.map((option) {
            return _buildOptionButton(option);
          }).toList(),
        );
    }
  }

  // Çoktan Seçmeli ve Doğru/Yanlış butonlarını çizen yardımcı fonksiyon
  Widget _buildOptionButton(String option) {
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
  }

 @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageManager.currentLang,
      builder: (context, lang, child) {
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
              ? Center(child: Text(LanguageManager.getText('no_questions_added')))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '${LanguageManager.getText('question_word')} ${_currentIndex + 1} ${LanguageManager.getText('of_word')} ${_questions.length}',
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
                        _buildQuestionUI(_questions[_currentIndex]),
                      ],
                    ),
                  ),
                ),
        );
      }
    );
  }
