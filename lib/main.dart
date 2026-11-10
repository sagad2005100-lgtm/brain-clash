
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mini_game_page.dart';
import 'reward_manager.dart';
import 'shop_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BrainClashApp());
}

const bg = Color(0xFF080B16);
const surface = Color(0xFF12182A);
const surface2 = Color(0xFF1A2340);
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
        scaffoldBackgroundColor: bg,
        fontFamily: 'Arial',
        colorScheme: const ColorScheme.dark(
          primary: gold,
          secondary: cyan,
          surface: surface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: bg,
          elevation: 0,
          centerTitle: false,
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
  final IconData icon;

  const World(
    this.name,
    this.subtitle,
    this.emoji,
    this.color,
    this.icon,
  );
}

const worlds = [
  World('عالم الذاكرة', 'قوة ذاكرتك', '🧠', purple, Icons.psychology),
  World('عالم الرياضيات', 'تحديات الأرقام', '🔢', cyan, Icons.calculate),
  World('عالم الكلمات', 'ألغاز وحروف', '🔤', Colors.orange, Icons.text_fields),
  World('عالم المنطق', 'فكر بذكاء', '🧩', Colors.greenAccent, Icons.extension),
  World('عالم التركيز', 'لاحظ التفاصيل', '👁️', Colors.pinkAccent, Icons.visibility),
  World('عالم الأشكال', 'ذكاء بصري', '🔷', Colors.blueAccent, Icons.category),
  World('عالم الاستراتيجية', 'خطط للفوز', '♟️', Colors.amber, Icons.auto_awesome),
  World('عالم المعلومات', 'معلومات عامة', '🌍', Colors.tealAccent, Icons.public),
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int coins = 0;
  int xp = 0;
  int completed = 0;
  int stars = 0;
  int level = 1;

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
        final value = prefs.getInt('world_${w}_stage_$s') ?? 0;
        if (value > 0) done++;
        earnedStars += value;
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
    refreshData();
  }

  Future<void> openWorld(int index) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StagePage(worldIndex: index + 1),
      ),
    );
    refreshData();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (xp % 100) / 100;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: refreshData,
          color: gold,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 30),
            children: [
              // Header
              Row(
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [gold, Colors.orange],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.psychology_alt,
                      color: bg,
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
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.3,
                          ),
                        ),
                        Text(
                          'صراع العقول',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: openShop,
                    icon: const Icon(Icons.shopping_bag_outlined),
                    color: gold,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Hero card
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF29345F),
                      Color(0xFF171D38),
                      Color(0xFF101629),
                    ],
                  ),
                  border: Border.all(color: Colors.white.withOpacity(.08)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 58,
                          width: 58,
                          decoration: BoxDecoration(
                            color: gold.withOpacity(.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.workspace_premium,
                            color: gold,
                            size: 34,
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'مرحباً أيها العبقري',
                                style: TextStyle(color: Colors.white60),
                              ),
                              Text(
                                'المستوى $level',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: gold.withOpacity(.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.monetization_on,
                                color: gold,
                                size: 20,
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
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        const Icon(Icons.bolt, color: cyan, size: 20),
                        const SizedBox(width: 7),
                        Text(
                          '$xp XP',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(
                          '${xp % 100}/100',
                          style: const TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 9,
                        backgroundColor: Colors.white10,
                        color: cyan,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 17),

              // Stats
              Row(
                children: [
                  Expanded(
                    child: _stat(
                      Icons.flag_rounded,
                      '$completed',
                      'مرحلة مكتملة',
                      cyan,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _stat(
                      Icons.star_rounded,
                      '$stars',
                      'نجوم مكتسبة',
                      gold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 27),

              // Start challenge
              InkWell(
                onTap: () => openWorld(0),
                borderRadius: BorderRadius.circular(23),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(23),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7255E8), Color(0xFF4532A3)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: purple.withOpacity(.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ابدأ التحدي',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'اختبر قدراتك وارتقِ بمستواك',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 55,
                        width: 55,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.15),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          size: 38,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 29),

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
                    '8 عوالم',
                    style: TextStyle(color: Colors.white.withOpacity(.45)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'اختر مجال ذكائك وابدأ المغامرة',
                style: TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 17),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: worlds.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 13,
                  mainAxisSpacing: 13,
                  childAspectRatio: .91,
                ),
                itemBuilder: (context, index) {
                  final world = worlds[index];
                  return _worldCard(world, index);
                },
              ),

              const SizedBox(height: 25),

              // Shop banner
              InkWell(
                onTap: openShop,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(17),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: gold.withOpacity(.2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.storefront_rounded, color: gold, size: 30),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'متجر صراع العقول',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'تلميحات ومساعدات للتحديات',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 16, color: gold),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),
              const Center(
                child: Text(
                  'BRAIN CLASH  •  TRAIN YOUR MIND',
                  style: TextStyle(
                    color: Colors.white24,
                    letterSpacing: 1.2,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(.05)),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(.13),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _worldCard(World world, int index) {
    return InkWell(
      onTap: () => openWorld(index),
      borderRadius: BorderRadius.circular(23),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(23),
          border: Border.all(color: world.color.withOpacity(.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 54,
              width: 54,
              decoration: BoxDecoration(
                color: world.color.withOpacity(.13),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Text(
                  world.emoji,
                  style: const TextStyle(fontSize: 29),
                ),
              ),
            ),
            const Spacer(),
            Text(
              world.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              world.subtitle,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 13),
            Row(
              children: [
                Icon(Icons.bolt, size: 15, color: world.color),
                const SizedBox(width: 4),
                Text(
                  '100 مرحلة',
                  style: TextStyle(
                    color: world.color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
               
