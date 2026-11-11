import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_page.dart';
import 'reward_manager.dart';
import 'shop_page.dart';

const Color bg = Color(0xFF080B16);
const Color surface = Color(0xFF151B30);
const Color gold = Color(0xFFFFD166);
const Color cyan = Color(0xFF55D6FF);
const Color purple = Color(0xFF9B7BFF);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          primary: gold,
          secondary: cyan,
          surface: surface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: bg,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const SplashPage(),
    );
  }
}

// ================= SPLASH =================

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutBack,
    );

    controller.forward();

    Timer(const Duration(milliseconds: 2200), () {
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF101936), bg],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: animation,
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: cyan.withOpacity(.4)),
                  boxShadow: [
                    BoxShadow(
                      color: cyan.withOpacity(.12),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.psychology_alt_rounded,
                  size: 75,
                  color: cyan,
                ),
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              'BRAIN CLASH',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'صراع العقول',
              style: TextStyle(
                color: gold,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 45),
            const CircularProgressIndicator(color: cyan),
            const SizedBox(height: 25),
            const Text(
              'تطوير سجاد السعيدي',
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= WORLDS =================

class GameWorld {
  final int id;
  final String name;
  final String subtitle;
  final String emoji;
  final Color color;

  const GameWorld({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.emoji,
    required this.color,
  });
}

const List<GameWorld> worlds = [
  GameWorld(
    id: 1,
    name: 'عالم الذاكرة',
    subtitle: 'اختبر قوة ذاكرتك',
    emoji: '🧠',
    color: purple,
  ),
  GameWorld(
    id: 2,
    name: 'عالم الرياضيات',
    subtitle: 'حل العمليات الصعبة',
    emoji: '➗',
    color: cyan,
  ),
  GameWorld(
    id: 3,
    name: 'عالم الكلمات',
    subtitle: 'تحديات لغوية ذكية',
    emoji: '🔤',
    color: Colors.orange,
  ),
  GameWorld(
    id: 4,
    name: 'عالم المنطق',
    subtitle: 'اكتشف الحل الصحيح',
    emoji: '🧩',
    color: Colors.greenAccent,
  ),
  GameWorld(
    id: 5,
    name: 'عالم التركيز',
    subtitle: 'ركز قبل أن تختار',
    emoji: '🎯',
    color: Colors.pinkAccent,
  ),
  GameWorld(
    id: 6,
    name: 'عالم الأشكال',
    subtitle: 'أنماط وأشكال متغيرة',
    emoji: '🔷',
    color: Colors.blueAccent,
  ),
  GameWorld(
    id: 7,
    name: 'عالم الاستراتيجية',
    subtitle: 'خطط وفكر بذكاء',
    emoji: '♟️',
    color: gold,
  ),
  GameWorld(
    id: 8,
    name: 'عالم المعلومات',
    subtitle: 'اختبر معلوماتك العامة',
    emoji: '🌍',
    color: Colors.tealAccent,
  ),
];

// ================= HOME =================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int coins = 0;
  int xp = 0;
  int level = 1;
  int completed = 0;
  int totalStars = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  Future<void> refreshData() async {
    final prefs = await SharedPreferences.getInstance();

    final newCoins = await RewardManager.getCoins();
    final newXP = await RewardManager.getXP();
    final newLevel = await RewardManager.getPlayerLevel();

    int done = 0;
    int stars = 0;

    for (int w = 1; w <= 8; w++) {
      for (int s = 1; s <= 100; s++) {
        if (prefs.getBool('reward_w${w}_s$s') ?? false) {
          done++;
        }

        stars += prefs.getInt('stars_w${w}_s$s') ?? 0;
      }
    }

    if (!mounted) return;

    setState(() {
      coins = newCoins;
      xp = newXP;
      level = newLevel;
      completed = done;
      totalStars = stars;
      loading = false;
    });
  }

  Future<void> openShop() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ShopPage()),
    );

    await refreshData();
  }

  Future<void> openWorld(GameWorld world) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StagePage(worldIndex: world.id),
      ),
    );

    await refreshData();
  }

  Widget statCard(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: color.withOpacity(.25)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 25),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget worldCard(GameWorld world) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => openWorld(world),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: world.color.withOpacity(.35)),
          gradient: LinearGradient(
            colors: [
              world.color.withOpacity(.12),
              surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: world.color.withOpacity(.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                world.emoji,
                style: const TextStyle(fontSize: 27),
              ),
            ),
            const Spacer(),
            Text(
              world.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              world.subtitle,
              maxLines: 2,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: refreshData,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 45, 18, 25),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BRAIN CLASH',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'صراع العقول',
                        style: TextStyle(color: gold, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: openShop,
                  icon: const Icon(
                    Icons.shopping_bag_rounded,
                    color: gold,
                    size: 29,
                  ),
                  tooltip: 'المتجر',
                ),
              ],
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  colors: [Color(0xFF202B50), Color(0xFF171C32)],
                ),
                border: Border.all(color: cyan.withOpacity(.25)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.emoji_events_rounded,
                    color: gold,
                    size: 43,
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'رحلة العبقرية',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'أكمل المراحل وارفع مستوى ذكائك',
                          style: TextStyle(
                            color: Colors.white.withOpacity(.65),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: statCard(
                    Icons.monetization_on,
                    'العملات',
                    loading ? '...' : '$coins',
                    gold,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: statCard(
                    Icons.bolt,
                    'الخبرة',
                    loading ? '...' : '$xp',
                    cyan,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: statCard(
                    Icons.star,
                    'النجوم',
                    loading ? '...' : '$totalStars',
                    Colors.orangeAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(Icons.military_tech, color: purple, size: 27),
                  const SizedBox(width: 10),
                  Text(
                    'المستوى $level',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(
                    '$completed / 800 مرحلة',
                    style: const TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              'اختر عالمك',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 13),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: worlds.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.12,
              ),
              itemBuilder: (context, index) => worldCard(worlds[index]),
            ),
            const SizedBox(height: 25),
            const Center(
              child: Text(
                'تطوير سجاد السعيدي',
                style: TextStyle(
                  color: gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= STAGES =================

class StagePage extends StatefulWidget {
  final int worldIndex;

  const StagePage({
    super.key,
    required this.worldIndex,
  });

  @override
  State<StagePage> createState() => _StagePageState();
}

class _StagePageState extends State<StagePage> {
  List<int> stageStars = List.filled(100, 0);
  List<bool> completedStages = List.filled(100, false);
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadStages();
  }

  Future<void> loadStages() async {
    final prefs = await SharedPreferences.getInstance();

    final stars = <int>[];
    final completed = <bool>[];

    for (int stage = 1; stage <= 100; stage++) {
      stars.add(
        prefs.getInt('stars_w${widget.worldIndex}_s$stage') ?? 0,
      );

      completed.add(
        prefs.getBool('reward_w${widget.worldIndex}_s$stage') ?? false,
      );
    }

    if (!mounted) return;

    setState(() {
      stageStars = stars;
      completedStages = completed;
      loading = false;
    });
  }

  bool isUnlocked(int stage) {
    if (stage == 1) return true;
    return completedStages[stage - 2];
  }

  Future<void> openStage(int stage) async {
    if (!isUnlocked(stage)) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MiniGamePage(
          world: widget.worldIndex,
          stage: stage,
        ),
      ),
    );

    await loadStages();
  }

  @override
  Widget build(BuildContext context) {
    final world = worlds[widget.worldIndex - 1];

    return Scaffold(
      appBar: AppBar(
        title: Text(world.name),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: cyan))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 100,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: .95,
              ),
              itemBuilder: (context, index) {
                final stage = index + 1;
                final unlocked = isUnlocked(stage);
                final done = completedStages[index];
                final stars = stageStars[index];

                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: unlocked ? () => openStage(stage) : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: done
                          ? world.color.withOpacity(.18)
                          : surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: done
                            ? world.color
                            : unlocked
                                ? gold.withOpacity(.45)
                                : Colors.white12,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          done
                              ? Icons.check_circle_rounded
                              : unlocked
                                  ? Icons.play_circle_fill
                                  : Icons.lock_rounded,
                          color: done
                              ? world.color
                              : unlocked
                                  ? gold
                                  : Colors.white30,
                          size: 25,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$stage',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          done ? '⭐' * stars : ' ',
                          style: const TextStyle(fontSize: 10),
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
