
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
        brightness: Brightness.dark,
        useMaterial3: true,
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
  late final Animation<double> scale;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    scale = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutBack,
    );

    controller.forward();

    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
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
              Color(0xFF20265A),
              bg,
              Color(0xFF1C1038),
            ],
          ),
        ),
        child: AnimatedBuilder(
          animation: scale,
          builder: (_, __) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.scale(
                scale: scale.value,
                child: Container(
                  width: 125,
                  height: 125,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [purple, cyan],
                    ),
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                        color: purple.withOpacity(.4),
                        blurRadius: 40,
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
                  color: cyan,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              const CircularProgressIndicator(color: gold),
              const SizedBox(height: 60),
              const Text(
                'تطوير سجاد السعيدي',
                style: TextStyle(
                  color: gold,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'TRAIN YOUR MIND',
                style: TextStyle(
                  color: Colors.white38,
                  letterSpacing: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= WORLD MODEL =================

class World {
  final String name;
  final String description;
  final String emoji;
  final Color color;

  const World(
    this.name,
    this.description,
    this.emoji,
    this.color,
  );
}

const worlds = <World>[
  World('عالم الذاكرة', 'اختبر قوة ذاكرتك', '🧠', purple),
  World('عالم الرياضيات', 'تحديات الأرقام', '🔢', cyan),
  World('عالم الكلمات', 'ألغاز وحروف', '🔤', Colors.orange),
  World('عالم المنطق', 'حل الأنماط المعقدة', '🧩', Colors.greenAccent),
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
    int totalStars = 0;

    for (int w = 1; w <= 8; w++) {
      for (int s = 1; s <= 100; s++) {
        if (prefs.getBool('reward_w${w}_s$s') ?? false {
          done++;
        }

        totalStars += prefs.getInt('stars_w${w}_s$s') ?? 0;
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
      stars = totalStars;
    });
  }

  Future<void> openShop() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ShopPage()),
    );
    refreshData();
  }

  Future<void> openWorld(int world) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StagePage(worldIndex: world),
      ),
    );
    refreshData();
  }

  Widget stat(
    IconData icon,
    String value,
    String title,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
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

              // PLAYER CARD
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF303B77),
                      Color(0xFF171D38),
                      Color(0xFF21163F),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: purple.withOpacity(.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'مرحباً أيها العبقري 🧠',
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
                        const Icon(Icons.bolt, color: cyan),
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
                      'واصل التحدي للوصول للمستوى التالي',
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
                    child: stat(
                      Icons.flag_rounded,
                      '$completed',
                      'مرحلة مكتملة',
                      cyan,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: stat(
                      Icons.star_rounded,
                      '$stars',
                      'نجوم مكتسبة',
                      gold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // PLAY BUTTON
              InkWell(
                onTap: () => openWorld(1),
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [purple, Color(0xFF6551D9)],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: purple.withOpacity(.25),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.play_circle_fill, size: 35),
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
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 16),
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
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            world.description,
                            maxLines: 2,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '100 مرحلة',
                                  style: TextStyle(
                                    color: world.color,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: world.color,
                                size: 12,
                              ),
                            ],
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
  final Map<int, int> stageStars = {};
  int unlocked = 1;
  bool loading = true;

  World get world => worlds[widget.worldIndex - 1];

  @override
  void initState() {
    super.initState();
    loadStages();
  }

  Future<void> loadStages() async {
    final prefs = await SharedPreferences.getInstance();

    int highest = 1;

    for (int s = 1; s <= 100; s++) {
      final completed =
          prefs.getBool('reward_w${widget.worldIndex}_s$s') ?? false;

      stageS
