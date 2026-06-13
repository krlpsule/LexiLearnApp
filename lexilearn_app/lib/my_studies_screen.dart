import 'package:flutter/material.dart';
import 'study_service.dart';
import 'study_models.dart';
import 'study_quiz_screen.dart';
import 'language_manager.dart'; // Çoklu dil yöneticisi import edildi

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
    // Dil değiştiğinde sayfanın anında yenilenmesi için ValueListenableBuilder eklendi
    return ValueListenableBuilder<String>(
      valueListenable: LanguageManager.currentLang,
      builder: (context, lang, child) {
        return Scaffold(
          appBar: AppBar(
            // Başlıklar LanguageManager üzerinden dinamik çekiliyor
            title: Text(LanguageManager.getText('my_studies')),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  text: LanguageManager.getText('ongoing'),
                  icon: const Icon(Icons.play_circle),
                ),
                Tab(
                  text: LanguageManager.getText('available'),
                  icon: const Icon(Icons.library_books),
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [_buildOngoingList(), _buildAvailableList()],
          ),
        );
      },
    );
  }

  Widget _buildOngoingList() {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _loadData();
        });
      },
      child: FutureBuilder<List<OngoingStudy>>(
        future: _ongoingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _loadData();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final studies = snapshot.data!;
          if (studies.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No ongoing studies',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Start a new study from the Available tab',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: studies.length,
            itemBuilder: (context, index) {
              final study = studies[index];
              return _buildStudyCard(
                title: study.title,
                domain: study.domainName,
                difficulty: study.difficultyLevel,
                progress: study.completionRate,
                isOngoing: true,
                studyId: study.studyId,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAvailableList() {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _loadData();
        });
      },
      child: FutureBuilder<List<AvailableStudy>>(
        future: _availableFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _loadData();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final studies = snapshot.data!;
          if (studies.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.celebration_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No available studies',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Check back later for new content!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: studies.length,
            itemBuilder: (context, index) {
              final study = studies[index];
              return _buildStudyCard(
                title: study.title,
                domain: study.domainName,
                difficulty: study.difficultyLevel,
                progress: null,
                isOngoing: false,
                studyId: study.studyId,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStudyCard({
    required String title,
    required String domain,
    required String difficulty,
    double? progress,
    required bool isOngoing,
    required int studyId,
  }) {
    Color difficultyColor = Colors.green;
    if (difficulty == 'Intermediate') difficultyColor = Colors.orange;
    if (difficulty == 'Advanced') difficultyColor = Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _openStudy(studyId, title, progress ?? 0.0),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: difficultyColor.withOpacity(0.2),
                    child: Icon(
                      isOngoing ? Icons.play_arrow : Icons.add,
                      color: difficultyColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$domain • $difficulty',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isOngoing && progress != null)
                    Column(
                      children: [
                        Text(
                          '${progress.toInt()}%',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const Text('complete', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  if (!isOngoing)
                    ElevatedButton(
                      onPressed: () => _startStudy(studyId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Start'),
                    ),
                ],
              ),
              if (isOngoing && progress != null) ...[
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _startStudy(int studyId) async {
    bool success = await _studyService.startStudy(widget.userId, studyId);

    if (success && mounted) {
      setState(() {
        _loadData();
      });
      _tabController.animateTo(0);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Study started successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to start study.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _openStudy(int studyId, String title, double currentProgress) async {
    // Sınav ekranına gidiş
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudyQuizScreen(
          userId: widget.userId,
          studyId: studyId,
          studyTitle: title,
          initialProgress: currentProgress,
        ),
      ),
    );

    
    if (mounted) {
      setState(() {
        _loadData();
      });
    }
  }
}