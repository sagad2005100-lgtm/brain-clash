
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
        fontFamily: 'Roboto',
      ),
      home: const SplashPage(),
    );
  }
}

// ================= SPLASH SCREEN =================

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
      duration: const Duration(milliseconds: 1600),
    );

    animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutBack,
    );

    controller.forward();

    Timer(const Duration(milliseconds: 2500), () {
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 700),
          pageBuilder: (_, __, ___) => const HomePage(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
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
              Color(0xFF080B16),
              Color(0xFF160D30),
            ],
          ),
        ),
        child: AnimatedBuilder(
          animation: animation,
          builder: (_, __) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.scale(
                  scale: animation.value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(35),
                      gradient: const LinearGradient(
                        colors: [purple, cyan],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: purple.withOpacity(.4),
                          blurRadius: 45,
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
                const SizedBox(height: 32),
                const Text(
                  'BRAIN CLASH',
                  style: TextStyle(
                    fontSize: 35,
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
                const SizedBox(
                  width: 35,
                  height: 35,
                  child: CircularProgressIndicator(
                    color: gold,
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 65),
                const Text(
                  'تطوير سجاد السعيدي',
                  style: TextStyle(
                    color: gold,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'TRAIN YOUR MIND',
                  style: TextStyle(
                    color: Colors.white38,
                    letterSpacing: 3,
                    fontSize: 10,
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
  World('عالم التركيز', 'لاحظ ما لا يلاحظه الآخرون', '👁', Colors.pinkAccent),
  World('عالم الأشكال', 'ذكاء بصري', '🔷', Colors.blueAccent),
  World('عالم الاستراتيجية', 'خطط قبل أن تتحرك', '♟', Colors.amber),
  World('عالم المعلومات', 'اختبر معلوماتك', '🌍', Colors.tealAccent),
];

// ================= HOME PAGE =================

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
    int earned = 0;

    for (int w = 1; w <= 8; w++) {
      for (int s = 1; s <= 100; s++) {
        final isDone =
            prefs.getBool('reward_w${w}_s$s') ?? false;

        final stageStars =
            prefs.getInt('stars_w${w}_s$s') ?? 0;

        if (isDone) done++;
        earned += stageStars;
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
      stars = earned;
    });
  }

  Future<void> openShop() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ShopPage(),
      ),
    );

    await refreshData();
  }

  Future<void> openWorld(int worldIndex) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StagePage(
          worldIndex: worldIndex,
        ),
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
        border: Border.all(
          color: color.withOpacity(.25),
        ),
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
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
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
                  border: Border.all(
                    color: purple.withOpacity(.4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: purple.withOpacity(.12),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Expanded(
                          child: Text(
                            'مرحباً أيها العبقري',
                            style: TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.stars_rounded,
                          color: gold,
                        ),
                      ],
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
                        const Icon(
                          Icons.bolt_rounded,
                          color: cyan,
                        ),
                        const SizedBox(width: 5),
                        Text('$xp XP'),
                        const Spacer(),
                        const Icon(
                          Icons.monetization_on,
                          color: gold,
                        ),
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
                      colors: [
                        purple,
                        Color(0xFF6551D9),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: purple.withOpacity(.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.play_circle_fill,
                        size: 32,
                      ),
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
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 17,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'عوالم العقل',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    '08 عوالم',
                    style: TextStyle(
                      color: cyan.withOpacity(.8),
                      fontSize: 12,
                    ),
                  ),
                ],
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
                              style: const TextStyle(
      
