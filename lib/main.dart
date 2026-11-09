import 'package:flutter/material.dart';
import 'game_page.dart';
import 'multiplayer_page.dart';
import 'stage_progress.dart';

const gold = Color(0xFFFFC857);
const navy = Color(0xFF080D1B);
const panel = Color(0xFF121D33);

void main() {
  runApp(const BrainClashApp());
}

class BrainClashApp extends StatelessWidget {
  const BrainClashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Brain Clash',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: navy,
        colorScheme: ColorScheme.fromSeed(
          seedColor: gold,
          brightness: Brightness.dark,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void open(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.psychology_alt,
                color: gold,
                size: 95,
              ),
              const SizedBox(height: 15),
              const Text(
                'BRAIN CLASH',
                style: TextStyle(
                  color: gold,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const Text(
                'صراع العقول',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 45),
              _button(
                context,
                'ابدأ اللعب',
                Icons.play_arrow,
                () => open(context, const StagePage()),
              ),
              const SizedBox(height: 15),
              _button(
                context,
                'اللعب الجماعي',
                Icons.groups,
                () => open(context, const MultiplayerPage()),
              ),
              const SizedBox(height: 15),
              _button(
                context,
                'الإعدادات',
                Icons.settings,
                () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'Brain Clash',
                    applicationVersion: '1.0.0',
                    applicationLegalese: 'صراع العقول',
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _button(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback action,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 62,
      child: ElevatedButton.icon(
        onPressed: action,
        icon: Icon(icon, color: gold),
        label: Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: panel,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
      ),
    );
  }
}

class StagePage extends StatefulWidget {
  const StagePage({super.key});

  @override
  State<StagePage> createState() => _StagePageState();
}

class _StagePageState extends State<StagePage> {
  late Future<List<int>> starsFuture;
  late Future<int> unlockedFuture;

  @override
  void initState() {
    super.initState();
    refreshProgress();
  }

  void refreshProgress() {
    starsFuture = StageProgress.loadStars();
    unlockedFuture = StageProgress.unlockedStage();
  }

  Future<void> openStage(int stage) async {
    final unlocked = await StageProgress.unlockedStage();

    if (!mounted) return;

    if (stage > unlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('أكمل المرحلة السابقة أولاً!'),
        ),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GamePage(stageNumber: stage),
      ),
    );

    if (mounted) {
      setState(refreshProgress);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('خريطة المراحل'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<int>>(
        future: starsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: gold),
            );
          }

          final stars = snapshot.data!;

          return FutureBuilder<int>(
            future: unlockedFuture,
            builder: (context, unlockedSnapshot) {
              if (!unlockedSnapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: gold),
                );
              }

              final unlocked = unlockedSnapshot.data!;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: panel,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'تقدمك في اللعبة',
                            style: TextStyle(fontSize: 17),
                          ),
                          Text(
                            '$unlocked / 20',
                            style: const TextStyle(
                              color: gold,
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: 20,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 1.25,
                      ),
                      itemBuilder: (context, index) {
                        final stage = index + 1;
                        final isUnlocked = stage <= unlocked;
                        final stageStars = stars[index];

                        return InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => openStage(stage),
                          child: Container(
                            decoration: BoxDecoration(
                              color: panel,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isUnlocked
                                    ? gold
                                    : Colors.white12,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isUnlocked
                                      ? Icons.emoji_events
                                      : Icons.lock,
                                  size: 37,
                                  color: isUnlocked
                                      ? gold
                                      : Colors.white38,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'المرحلة $stage',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                Text(
                                  isUnlocked
                                      ? '⭐' * stageStars +
                                          '☆' * (3 - stageStars)
                                      : 'مقفلة',
                                  style: const TextStyle(
                                    color: gold,
                                    fontSize: 17,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  '100 سؤال',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
