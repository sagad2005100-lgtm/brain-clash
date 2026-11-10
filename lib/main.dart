
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mini_game_page.dart';
import 'reward_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BrainClashApp());
}

const gold = Color(0xFFFFC857);
const background = Color(0xFF10121C);
const panel = Color(0xFF1D2233);

class BrainClashApp extends StatelessWidget {
  const BrainClashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Brain Clash',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: gold,
          brightness: Brightness.dark,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class World {
  final String name;
  final String subtitle;
  final String emoji;
  final Color color;

  const World(this.name, this.subtitle, this.emoji, this.color);
}

const worlds = [
  World('عالم الذاكرة', 'اختبر قوة ذاكرتك', '🧠', Color(0xFF7667E8)),
  World('عالم الرياضيات', 'تحديات الأرقام والحساب', '🔢', Color(0xFF279CDA)),
  World('عالم الكلمات', 'اكتشف الكلمات والألغاز', '🔤', Color(0xFFDB8B42)),
  World('عالم المنطق', 'فكر خارج الصندوق', '🧩', Color(0xFF29A68A)),
  World('عالم التركيز', 'لاحظ التفاصيل بسرعة', '👁️', Color(0xFFD65D83)),
  World('عالم الأشكال', 'اختبر تفكيرك البصري', '🔷', Color(0xFF8C72D9)),
  World('عالم الاستراتيجية', 'خطط لكل حركة', '♟️', Color(0xFFB28A43)),
  World('عالم المعلومات', 'اختبر معلوماتك العامة', '🌍', Color(0xFF3C9D77)),
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int completed = 0;
  int totalStars = 0;
  int coins = 0;
  int xp = 0;
  int playerLevel = 1;

  @override
  void initState() {
    super.initState();
    loadProgress();
  }

  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();

    int stages = 0;
    int stars = 0;

    for (int w = 1; w <= 8; w++) {
      for (int s = 1; s <= 100; s++) {
        final value = prefs.getInt('world_${w}_stage_$s') ?? 0;
        if (value > 0) stages++;
        stars += value;
      }
    }

    final c = await RewardManager.getCoins();
    final x = await RewardManager.getXP();
    final level = await RewardManager.getPlayerLevel();

    if (!mounted) return;

    setState(() {
      completed = stages;
      totalStars = stars;
      coins = c;
      xp = x;
      playerLevel = level;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadProgress,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: gold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.psychology, color: gold, size: 30),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('BRAIN CLASH',
                            style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5)),
                        Text('صراع العقول',
                            style: TextStyle(color: Colors.white54)),
                      ],
                    ),
                  ),
                  const Icon(Icons.settings, color: Colors.white54),
                ],
              ),

              const SizedBox(height: 25),

              // بطاقة اللاعب
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(23),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF34304F), Color(0xFF202538)],
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          backgroundColor: Color(0xFFFFC857),
                          child: Icon(Icons.person, color: Colors.black, size: 30),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('اللاعب',
                                  style: TextStyle(color: Colors.white54)),
                              Text('المستوى $playerLevel',
                                  style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            const Icon(Icons.monetization_on,
                                color: gold, size: 28),
                            Text('$coins',
                                style: const TextStyle(
                                    color: gold,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.bolt, color: Colors.orangeAccent),
                        const SizedBox(width: 6),
                        Text('$xp XP',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        const Spacer(),
                        Text('${xp % 100}/100',
                            style: const TextStyle(color: Colors.white54)),
                      ],
                    ),
                    const SizedBox(height: 9),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (xp % 100) / 100,
                        minHeight: 8,
                        color: gold,
                        backgroundColor: Colors.white12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: panel,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('هل أنت مستعد للتحدي؟',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('درّب عقلك واجمع النجوم.',
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                              Icons.flag, '$completed / 800', 'مرحلة مكتملة'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _statCard(
                              Icons.star, '$totalStars', 'نجمة'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
              const Text('اختر عالمك',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('ثمانية عوالم تنتظرك',
                  style: TextStyle(color: Colors.white54)),
              const SizedBox(height: 17),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: worlds.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.12,
                ),
                itemBuilder: (context, index) {
                  final world = worlds[index];

                  return InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StagePage(worldIndex: index + 1),
                        ),
                      );
                      await loadProgress();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: panel,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: world.color.withOpacity(0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(world.emoji,
                              style: const TextStyle(fontSize: 34)),
                          const SizedBox(height: 9),
                          Text(world.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(world.subtitle,
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 11)),
                          const SizedBox(height: 9),
                          Text('100 مرحلة',
                              style: TextStyle(
                                  color: world.color,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),
              const Center(
                child: Text('BRAIN CLASH • TRAIN YOUR MIND',
                    style: TextStyle(color: Colors.white30, fontSize: 11)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.18),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: gold, size: 25),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 17)),
                Text(label,
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StagePage extends StatefulWidget {
  final int worldIndex;
  const StagePage({super.key, required this.worldIndex});

  @override
  State<StagePage> createState() => _StagePageState();
}

class _StagePageState extends State<StagePage> {
  Map<int, int> progress = {};
  bool loading = true;

  World get world => worlds[widget.worldIndex - 1];

  @override
  void initState() {
    super.initState();
    loadStages();
  }

  Future<void> loadStages() async {
    final prefs = await SharedPreferences.getInstance();
    final values = <int, int>{};

    for (int i = 1; i <= 100; i++) {
      values[i] =
          prefs.getInt('world_${widget.worldIndex}_stage_$i') ?? 0;
    }

    if (!mounted) return;
    setState(() {
      progress = values;
      loading = false;
    });
  }

  int get unlockedStage {
    for (int i = 1; i <= 100; i++) {
      if ((progress[i] ?? 0) == 0) return i;
    }
    return 100;
  }

  Future<void> openStage(int stage) async {
    if (stage > unlockedStage && (progress[stage] ?? 0) == 0) return;

    final result = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (_) => MiniGamePage(
          world: widget.worldIndex,
          stage: stage,
        ),
      ),
    );

    if (result == null) return;

    final rewards = await RewardManager.completeStage(
      widget.worldIndex,
      stage,
      result,
    );

    final stars = rewards['stars'] ?? 0;

    final prefs = await SharedPreferences.getInstance();
    final key = 'world_${widget.worldIndex}_stage_$stage';
    final previous = prefs.getInt(key) ?? 0;

    if (stars > previous) {
      await prefs.setInt(key, stars);
    }

    await loadStages();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: panel,
        title: const Text('مكافآت المرحلة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('⭐ $stars نجوم',
                style: const TextStyle(color: gold, fontSize: 22)),
            const SizedBox(height: 12),
            Text('🪙 ${rewards['coins']} عملة'),
            const SizedBox(height: 8),
            Text('⚡ ${rewards['xp']} XP'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('رائع!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(world.name), backgroundColor: background),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: gold))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Text(world.emoji,
                          style: const TextStyle(fontSize: 35)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(world.name,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            const Text('أكمل المراحل لتحصل على النجوم',
                                style: TextStyle(color: Colors.white54)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: 100,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemBuilder: (context, index) {
                      final stage = index + 1;
                      final stars = progress[stage] ?? 0;
                      final locked = stage > unlockedStage && stars == 0;

                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: locked ? null : () => openStage(stage),
                        child: Container(
                          decoration: BoxDecoration(
                            color: locked ? Colors.white10 : panel,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: stars > 0
                                  ? gold.withOpacity(0.7)
                                  : Colors.white12,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                locked ? Icons.lock : Icons.extension,
                                color: locked ? Colors.white30 : gold,
                                size: 23,
                              ),
                              const SizedBox(height: 5),
                              Text('$stage',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              if (stars > 0)
                                Text('★' * stars,
                                    style: const TextStyle(
                                        color: gold, fontSize: 12)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
