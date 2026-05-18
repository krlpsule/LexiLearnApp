import 'package:flutter/material.dart';
import 'study_service.dart';
import 'study_models.dart';
import 'study_quiz_screen.dart'; 
import 'language_manager.dart';

class MyStudiesScreen extends StatefulWidget {
  final int userId;

  const MyStudiesScreen({super.key, required this.userId});

  @override
  State<MyStudiesScreen> createState() => _MyStudiesScreenState();
}

class _MyStudiesScreenState extends State<MyStudiesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<OngoingStudy>> _ongoingFuture;
  late Future<List<AvailableStudy>> _availableFuture;
  final StudyService _studyService = StudyService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  void _loadData() {
    _ongoingFuture = _studyService.getOngoingStudies(widget.userId);
    _availableFuture = _studyService.getAvailableStudies(widget.userId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

 @override
  Widget build(BuildContext context) {
    // ADDED: ValueListenableBuilder wrapper
    return ValueListenableBuilder<String>(
      valueListenable: LanguageManager.currentLang,
      builder: (context, lang, child) {
        return Scaffold(
          appBar: AppBar(
            // CHANGED: dynamic translated text
            title: Text(LanguageManager.getText('my_studies')),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                // CHANGED: dynamic translated text
                Tab(text: LanguageManager.getText('ongoing'), icon: const Icon(Icons.play_circle)),
                Tab(text: LanguageManager.getText('available'), icon: const Icon(Icons.library_books)),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [_buildOngoingList(), _buildAvailableList()],
          ),
        );
      }
    );
  }
