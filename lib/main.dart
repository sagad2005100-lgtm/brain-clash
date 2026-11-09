import 'package:flutter/material.dart';
import 'game_page.dart';
import 'multiplayer_page.dart';

const gold = Color(0xFFFFC857);
const navy = Color(0xFF080D1B);
const panel = Color(0xFF121D33);

void main() => runApp(const BrainClash());

class BrainClash extends StatelessWidget {
  const BrainClash({super.key});

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
        appBarTheme: const AppBarTheme(
          backgroundColor: navy,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void open(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: gold.withOpacity(.13),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: gold.withOpacity(.35)),
                    ),
                    child: const Icon(
                      Icons.psychology_alt,
                      color: gold,
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
                            letterSpacing: 2.2,
                            fontWeight: FontWeight.w900,
                            fontSize: 19,
                          ),
                        ),
                        Text(
                          'صراع العقول',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => open(
                      context,
                      const SettingsPage(),
                    ),
                    icon: const Icon(
                      Icons.settings_outlined,
                      color: gold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF24385D),
                      Color(0xFF111A2D),
                      Color(0xFF101729),
                    ],
                  ),
                  border: Border.all(
                    color: gold.withOpacity(.45),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: gold.withOpacity(.08),
                      blurRadius: 25,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.workspace_premium,
                      color: gold,
                      size: 72,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'مستعد للتحدّي؟',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'اختبر ذكاءك، اجمع النجوم، وافتح مراحل جديدة',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: const [
                        Expanded(
                          child: StatTile(
                            icon: Icons.star,
                            title: 'النجوم',
                            value: '0',
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: StatTile(
                            icon: Icons.bolt,
                            title: 'المستوى',
                            value: '1',
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: StatTile(
                            icon: Icons.flag,
                            title: 'المرحلة',
                            value: '1',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              _MainButton(
                title: 'ابدأ المغامرة',
                subtitle: 'ادخل إلى خريطة المراحل',
                icon: Icons.play_arrow_rounded,
                primary: true,
                onTap: () => open(
                  context,
                  const StagePage(),
                ),
              ),
              const SizedBox(height: 12),
              _MainButton(
                title: 'اللعب الجماعي',
                subtitle: 'تحدّ أصدقاءك عبر الشبكة المحلية',
                icon: Icons.groups_rounded,
                onTap: () => open(
                  context,
                  const MultiplayerPage(),
                ),
              ),
              const SizedBox(height: 12),
              _MainButton(
                title: 'المجالات',
                subtitle: 'علوم • تاريخ • رياضة • جغرافيا',
                icon: Icons.category_rounded,
                onTap: () => open(
                  context,
                  const CategoriesPage(),
                ),
              ),
              const SizedBox(height: 22),
              const Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: gold,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'رحلتك نحو العبقرية',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: panel,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.lock_open,
                      color: gold,
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'أكمل التحديات القادمة لتفتح مراحل أصعب!',
                        style: TextStyle(
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const StatTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 5,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(.18),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: gold, size: 20),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
}

class _MainButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool primary;
  final VoidCallback onTap;

  const _MainButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) => Material(
        color: primary ? gold : panel,
        borderRadius: BorderRadius.circular(19),
        child: InkWell(
          borderRadius: BorderRadius.circular(19),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(17),
            child: Row(
              children: [
                Container(
                  width: 49,
                  height: 49,
                  decoration: BoxDecoration(
                    color: primary
                        ? Colors.black.withOpacity(.10)
                        : gold.withOpacity(.13),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    icon,
                    color: primary ? navy : gold,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: primary ? navy : Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: primary
                              ? navy.withOpacity(.7)
                              : Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: primary ? navy : gold,
                ),
              ],
            ),
          ),
        ),
      );
}

class StagePage extends StatelessWidget {
  const StagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('خريطة المراحل'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'رحلة الذكاء',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'اختر تحدّيك الأول',
                style: TextStyle(color: Colors.white60),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              ...List.generate(20, (i) {
                final unlocked = i == 0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: panel,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: unlocked ? gold : Colors.white12,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor:
                          unlocked ? gold : Colors.white12,
                      foregroundColor:
                          unlocked ? navy : Colors.white38,
                      child: unlocked
                          ? const Icon(Icons.play_arrow)
                          : const Icon(Icons.lock),
                    ),
                    title: Text(
                      'المرحلة ${i + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      unlocked
                          ? 'متاحة الآن • تحدّي البداية'
                          : 'أكمل المرحلة السابقة لفتحها',
                    ),
                    trailing: Text(
                      unlocked ? '⭐ 0/3' : 'مقفلة',
                      style: TextStyle(
                        color: unlocked ? gold : Colors.white38,
                      ),
                    ),
                    onTap: unlocked
                        ? () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const GamePage(),
                              ),
                            )
                        : null,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  final categories = const [
    ('العلوم', Icons.science),
    ('التاريخ', Icons.account_balance),
    ('الجغرافيا', Icons.public),
    ('الرياضة', Icons.sports_soccer),
    ('الثقافة العامة', Icons.lightbulb),
    ('الذكاء', Icons.psychology),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('مجالات التحدّي'),
        ),
        body: SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: categories.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: 12),
            itemBuilder: (context, i) => Container(
              decoration: BoxDecoration(
                color: panel,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: gold.withOpacity(.2),
                ),
              ),
              child: ListTile(
                leading: Icon(
                  categories[i].$2,
                  color: gold,
                  size: 30,
                ),
                title: Text(
                  categories[i].$1,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: gold,
                ),
                onTap: () => ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      'اختيار المجال وربط أسئلته قيد التطوير',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('الإعدادات'),
        ),
        body: const Center(
          child: Text('إعدادات اللعبة ستضاف قريباً'),
        ),
      );
}
