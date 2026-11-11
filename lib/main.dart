
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'game_page.dart';
import 'reward_manager.dart';
import 'shop_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BrainClashApp());
}

const bg = Color(0xFF080B16);
const surface = Color(0xFF12182A);
const gold = Color(0xFFFFD166);
const cyan = Color(0xFF55D6FF);
const purple = Color(0xFF9B7BFF);

class BrainClashApp extends StatelessWidget {
  const BrainClashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brain Clash',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          primary: gold,
          secondary: cyan,
          surface: surface,
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

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

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
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF171D42),
              bg,
              Color(0xFF160D30),
            ],
          ),
        ),
        child: AnimatedBuilder(
          animation: controller,
          builder: (_, __) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.scale(
                  scale: Curves.easeOutBack.transform(controller.value),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      gradient: const LinearGradient(
                        colors: [purple, cyan],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: purple.withOpacity(.4),
                          blurRadius: 35,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.psychology_alt_rounded,
                      size: 75,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'BRAIN CLASH',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'صراع العقول',
                  style: TextStyle(
                    fontSize: 22,
                    color: cyan,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 45),
                const CircularProgressIndicator(color: gold),
                const SizedBox(height: 55),
                const Text(
                  'تطوير سجاد السعيدي',
                  style: TextStyle(
                    color: gold,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ================= WORLDS =================

class World {
  final String name;
  final String subtitle;
  final String emoji;
  final Color color;

  const World(
    this.name,
    this.subtitle,
    this.emoji,
    this.color,
  );
}

const worlds = <World>[
  World('عالم الذاكرة', 'اختبر قوة ذاكرتك', '🧠', purple),
  World('عالم الرياضيات', 'تحديات الأرقام', '🔢', cyan),
  World('عالم الكلمات', 'ألغاز وحروف', '🔤', Colors.orange),
  World('عالم المنطق', 'حل المستحيل', '🧩', Colors.greenAccent),
  World('عالم التركيز', 'لاحظ التفاصيل', '👁', Colors.pinkAccent),
  World('عالم الأشكال', 'ذكاء بصري', '🔷', Colors.blueAccent),
  World('عالم الاستراتيجية', 'خطط قبل الحركة', '♟', gold),
  World('عالم المعلومات', 'اختبر معلوماتك', '🌍', Colors.tealAccent),
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
  int stars = 0;

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  Future<void> refreshData() async {
    final prefs = await SharedPreferences.getInstance();

    int done = 0;
    int earnedStars = 0;

    for (int w = 1; w <= 8; w++) {
      for (int s = 1; s <= 100; s++) {
        if (prefs.getBool('reward_w${w}_s$s') ?? false {
          done++;
        }

        earnedStars += prefs.getInt('stars_w${w}_s$s') ?? 0;
      }
    }

    final c = await RewardManager.getCoins();
    final x = await RewardManager.getXP();
    final l = await RewardManager.getPlayerLevel();

    if (!mounted) return;

    setState(() {
      coins = c;
      xp = x;
      level = l;
      completed = done;
      stars = earnedStars;
    });
  }

  Future<void> openShop() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ShopPage()),
    );

    await refreshData();
  }

  Future<void> openWorld(int world) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StagePage(worldIndex: world),
      ),
    );

    await refreshData();
  }

  Widget statCard(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(.25)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 25),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: refreshData,
          color: gold,
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [purple, cyan],
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.psychology_alt_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BRAIN CLASH',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          'صراع العقول',
                          style: TextStyle(
                            color: cyan,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: openShop,
                    icon: const Icon(Icons.shopping_bag_rounded),
                    color: gold,
                  ),
                ],
              ),

              const SizedBox(height: 25),

              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF303B77),
                      Color(0xFF171D38),
                      Color(0xFF21163F),
                    ],
                  ),
                  border: Border.all(color: purple.withOpacity(.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'مرحباً أيها العبقري',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'المستوى $level',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.bolt_rounded, color: cyan),
                        const SizedBox(width: 5),
                        Text('$xp XP'),
                        const Spacer(),
                        const Icon(Icons.monetization_on, color: gold),
                        const SizedBox(width: 5),
                        Text(
                          '$coins',
                          style: const TextStyle(
                            color: gold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        minHeight: 7,
                        value: (xp % 100) / 100,
                        backgroundColor: Colors.white12,
                        color: cyan,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'واصل التحدي للوصول إلى المستوى التالي',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
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
                      Icons.flag_rounded,
                      '$completed',
                      'مرحلة مكتملة',
                      cyan,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: statCard(
                      Icons.star_rounded,
                      '$stars',
                      'نجوم مكتسبة',
                      gold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              InkWell(
                onTap: () => openWorld(1),
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 19,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [purple, Color(0xFF6551D9)],
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.play_circle_fill, size: 32),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ابدأ التحدي',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'اختبر قدرات عقلك الآن',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 17),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'عوالم العقل',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 15),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: worlds.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 13,
                  mainAxisSpacing: 13,
                  childAspectRatio: .92,
                ),
                itemBuilder: (context, i) {
                  final world = worlds[i];

                  return InkWell(
                    onTap: () => openWorld(i + 1),
                    borderRadius: BorderRadius.circular(23),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            world.color.withOpacity(.15),
                            surface,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(23),
                        border: Border.all(
                          color: world.color.withOpacity(.35),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: world.color.withOpacity(.12),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              world.emoji,
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            world.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
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
                },
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
      stars.add(prefs.getInt(
            'stars_w${widget.worldIndex}_s$stage',
          ) ??
          0);

      completed.add(
        prefs.getBool('reward_w${widget.worldIndex}_s$stage') ??
            false,
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

    return Sc
