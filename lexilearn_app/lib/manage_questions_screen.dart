import 'package:flutter/material.dart';
import 'study_models.dart';
import 'study_service.dart';
import 'language_manager.dart'; // Çoklu dil yöneticisi import edildi

class ManageQuestionsScreen extends StatefulWidget {
  final int userId;
  const ManageQuestionsScreen({super.key, required this.userId});

  @override
  State<ManageQuestionsScreen> createState() => _ManageQuestionsScreenState();
}

class _ManageQuestionsScreenState extends State<ManageQuestionsScreen> {
  final StudyService _studyService = StudyService();
  List<Question> _questions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfessorQuestions();
  }

  Future<void> _loadProfessorQuestions() async {
    try {
      final questions = await _studyService.getProfessorQuestions(
        widget.userId,
      );
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _deleteQuestion(int questionId) async {
    // Silme onay kutusundaki yönergeler dile göre dinamikleşti
    bool confirm =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(LanguageManager.getText('delete_question_title')),
            content: Text(LanguageManager.getText('delete_question_confirm')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(LanguageManager.getText('cancel')),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  LanguageManager.getText('delete'),
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      bool success = await _studyService.deleteQuestion(questionId);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                LanguageManager.getText('question_deleted_success'),
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
        _loadProfessorQuestions(); // Listeyi yenile
      }
    }
  }

  void _editQuestion(Question question) {
    final textController = TextEditingController(text: question.questionText);
    final answerController = TextEditingController(
      text: question.correctAnswer,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LanguageManager.getText('edit_question_title'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                decoration: InputDecoration(
                  labelText: LanguageManager.getText('question_text_label'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: answerController,
                decoration: InputDecoration(
                  labelText: LanguageManager.getText('correct_answer_label'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (textController.text.trim().isEmpty ||
                        answerController.text.trim().isEmpty)
                      return;

                    bool success = await _studyService.updateQuestion(
                      questionId: question.questionId,
                      text: textController.text.trim(),
                      answer: answerController.text.trim(),
                      options: question.options,
                      level: question.difficultyLevel,
                      questionType: question.questionType,
                    );

                    if (mounted && success) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            LanguageManager.getText('question_updated_success'),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                      _loadProfessorQuestions();
                    }
                  },
                  child: Text(LanguageManager.getText('save_changes_btn')),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dil değişimini anlık dinlemek için ValueListenableBuilder ile sarmalladık
    return ValueListenableBuilder<String>(
      valueListenable: LanguageManager.currentLang,
      builder: (context, lang, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(LanguageManager.getText('manage_questions_nav')),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _questions.isEmpty
              ? Center(
                  child: Text(LanguageManager.getText('no_questions_found')),
                )
              : ListView.builder(
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    final q = _questions[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(
                          q.questionText,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            '${LanguageManager.getText('level_label')}: ${q.difficultyLevel} | ${LanguageManager.getText('type_label')}: ${q.questionType}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editQuestion(q),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteQuestion(q.questionId),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
