import 'package:flutter/material.dart';
import 'study_models.dart';
import 'study_service.dart';

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
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Question?'),
        content: const Text(
          'Are you sure you want to permanently delete this question?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm) {
      bool success = await _studyService.deleteQuestion(questionId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Question deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
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
              const Text(
                'Edit Question',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                decoration: const InputDecoration(
                  labelText: 'Question Text',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: answerController,
                decoration: const InputDecoration(
                  labelText: 'Correct Answer',
                  border: OutlineInputBorder(),
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
                      options:
                          question.options, // Basitlik adına şıkları koruyoruz
                      level: question.difficultyLevel,
                      questionType: question.questionType,
                    );

                    if (mounted && success) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Question updated! 🎉'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      _loadProfessorQuestions();
                    }
                  },
                  child: const Text('Save Changes'),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Manage My Questions')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _questions.isEmpty
          ? const Center(child: Text('You haven\'t added any questions yet.'))
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
                    subtitle: Text(
                      'Study: ${q.difficultyLevel} | Type: ${q.questionType}',
                      style: const TextStyle(color: Colors.grey),
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
  }
}
