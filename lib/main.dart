
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'game_page.dart';
import 'reward_manager.dart';
import 'shop_page.dart';

void main() {
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
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          primary: gold,
          secondary: cyan,
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

const worlds = <World>[
  World('عالم الذاكرة', 'قوة ذاكرتك', '🧠', purple),
  World('عالم الرياضيات', 'تحديات الأرقام', '🔢', cyan),
  World('عالم الكلمات', 'ألغاز وحروف', '🔤', Colors.orange),
  World('عالم المنطق', 'فكر بذكاء', '🧩', Colors.greenAccent),
  World('عالم التركيز', 'لاحظ التفاصيل', '👁️', Colors.pinkAccent),
  World('عالم الأشكال', 'ذكاء بصري', '🔷', Colors.blueAccent),
  World('عالم الاستراتيجية', 'خطط للفوز', '♟️', Colors.amber),
  World('عالم المعلومات', 'معلومات عامة', '🌍', Colors.tealAccent),
];

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
        final value = prefs.getInt('world_${w}_stage_$s') ?? 0;

        if (value > 0) {
          done++;
        }

        earned += value;
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
                  const Icon(
                    Icons.psychology_alt,
                    color: gold,
                    size: 38,
                  ),
                  const SizedBox(width: 10),
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
                          style: TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: openShop,
                    icon: const Icon(Icons.shopping_bag),
                    color: gold,
                  ),
                ],
              ),

              const SizedBox(height: 22),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF29345F),
                      Color(0xFF171D38),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'مرحباً أيها العبقري',
                      style: TextStyle(color: Colors.white70),
                    ),
                    Text(
                      'المستوى $level',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.bolt, color: cyan),
                        Text('$xp XP'),
                        const Spacer(),
                        Text(
                          '$coins 🪙',
                          style: const TextStyle(color: gold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (xp % 100) / 100,
                      color: cyan,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _stat(
                      '$completed',
                      'مرحلة مكتملة',
                      cyan,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _stat(
                      '$stars',
                      'نجوم مكتسبة',
                      gold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              ElevatedButton.icon(
                onPressed: () => openWorld(0),
                icon: const Icon(Icons.play_arrow),
                label: const Text('ابدأ التحدي'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(17),
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'عوالم العقل',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: worlds.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (context, i) {
                  final world = worlds[i];

                  return InkWell(
                    onTap: () => openWorld(i),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: world.color.withOpacity(.35),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            world.emoji,
                            style: const TextStyle(fontSize: 32),
                          ),
                          const Spacer(),
                          Text(
                            world.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            world.subtitle,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '100 مرحلة',
                            style: TextStyle(
                              color: world.color,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 22),

              OutlinedButton.icon(
                onPressed: openShop,
                icon: const Icon(Icons.store, color: gold),
                label: const Text('متجر صراع العقول'),
              ),

              const SizedBox(height: 20),

              const Center(
                child: Text(
                  'BRAIN CLASH • TRAIN YOUR MIND',
                  style: TextStyle(
                    color: Colors.white24,
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

  Widget _stat(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class StagePage extends StatelessWidget {
  final int worldIndex;

  const StagePage({
    super.key,
    required this.worldIndex,
  });

  @override
  Widget build(BuildContext context) {
    final world = worlds[worldIndex - 1];

    return Scaffold(
      appBar: AppBar(
        title: Text(world.name),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 100,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (context, i) {
          return FutureBuilder<int>(
            future: SharedPreferences.getInstance().then(
              (p) => p.getInt(
                    'world_${worldIndex}_stage_${i + 1}',
                  ) ??
                  0,
            ),
            builder: (context, snapshot) {
              final done = (snapshot.data ?? 0) > 0;

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MiniGamePage(
                        world: worldIndex,
                        stage: i + 1,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: done
                        ? Colors.green.withOpacity(.2)
                        : surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: done
                          ? Colors.green
                          : world.color.withOpacity(.25),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: done
                            ? Colors.greenAccent
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
