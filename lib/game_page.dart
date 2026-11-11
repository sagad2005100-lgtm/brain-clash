
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'reward_manager.dart';

const gameBg = Color(0xFF080B16);
const gameCard = Color(0xFF151B30);
const gameGold = Color(0xFFFFD166);
const gameCyan = Color(0xFF55D6FF);
const gamePurple = Color(0xFF9B7BFF;

class MiniGamePage extends StatefulWidget {
  final int world;
  final int stage;

  const MiniGamePage({
    super.key,
    required this.world,
    required this.stage,
  });

  @override
  State<MiniGamePage> createState() => _MiniGamePageState();
}

class _MiniGamePageState extends State<MiniGamePage> {
  final Random random = Random();

  int questionIndex = 0;
  int score = 0;
  int selected = -1;
  int hintsCount = 0;
  int correctStreak = 0;

  bool answered = false;
  bool finished = false;
  bool hintUsed = false;
  bool saving = false;

  late List<String> options;
  late String question;
  late String correctAnswer;
  late String explanation;

  Map<String, int>? rewardResult;

  @override
  void initState() {
    super.initState();
    loadQuestion();
    loadHints();
  }

  int get difficulty => min(100, widget.stage + questionIndex);

  Color get worldColor {
    const colors = [
      gamePurple,
      gameCyan,
      Colors.orange,
      Colors.greenAccent,
      Colors.pinkAccent,
      Colors.blueAccent,
      gameGold,
      Colors.tealAccent,
    ];

    return colors[(widget.world - 1).clamp(0, 7)];
  }

  Future<void> loadHints() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      hintsCount = prefs.getInt('inventory_hints') ?? 0;
    });
  }

  int rand(int minValue, int maxValue) =>
      minValue + random.nextInt(maxValue - minValue + 1);

  List<String> choices(String answer, List<String> wrong) {
    final result = <String>{answer};

    for (final value in wrong) {
      if (value != answer) result.add(value);
    }

    while (result.length < 4) {
      result.add('${rand(10, 999)}');
    }

    final list = result.take(4).toList();
    list.shuffle(random);

    return list;
  }

  Map<String, dynamic> make(
    String q,
    String answer,
    String explanation,
    List<String> wrong,
  ) {
    return {
      'q': q,
      'a': answer,
      'e': explanation,
      'o': choices(answer, wrong),
    };
  }

  void loadQuestion() {
    final item = generateQuestion(difficulty);

    question = item['q'];
    correctAnswer = item['a'];
    explanation = item['e'];
    options = List<String>.from(item['o']);

    selected = -1;
    answered = false;
    hintUsed = false;
  }

  // ================= QUESTION ENGINE =================

  Map<String, dynamic> generateQuestion(int level) {
    final d = max(1, level);

    switch (widget.world) {
      // MEMORY
      case 1:
        final length = min(10, 3 + d ~/ 8);
        final sequence = List.generate(length, (_) => rand(0, 9));
        final answer = sequence.join();

        final wrong = <String>[];

        while (wrong.length < 3) {
          final alternative = List<int>.from(sequence);
          final index = rand(0, length - 1);

          alternative[index] =
              (alternative[index] + rand(1, 9)) % 10;

          final value = alternative.join();

          if (value != answer && !wrong.contains(value)) {
            wrong.add(value);
          }
        }

        return make(
          'اختبر ذاكرتك:\n\n'
          '$answer\n\n'
          'ما التسلسل الصحيح الذي شاهدته؟',
          answer,
          'التسلسل الأصلي هو $answer',
          wrong,
        );

      // MATHEMATICS
      case 2:
        final a = rand(10, 20 + d * 3);
        final b = rand(5, 15 + d);
        final c = rand(2, 10);
        final type = d < 8 ? 0 : rand(0, 3);

        int answer;
        String q;
        String exp;

        if (type == 0) {
          answer = a * b;
          q = 'احسب بدقة:\n$a × $b';
          exp = '$a × $b = $answer';
        } else if (type == 1) {
          answer = a * b + c;
          q = 'احسب:\n($a × $b) + $c';
          exp = '($a × $b) + $c = $answer';
        } else if (type == 2) {
          answer = a * b - c;
          q = 'احسب:\n($a × $b) - $c';
          exp = '($a × $b) - $c = $answer';
        } else {
          answer = a * a - b;
          q = 'احسب:\n$a² - $b';
          exp = '$a × $a - $b = $answer';
        }

        return make(
          q,
          '$answer',
          exp,
          [
            '${answer + c}',
            '${answer - b}',
            '${answer + a}',
            '${answer + rand(1, 9)}',
          ],
        );

      // WORDS
      case 3:
        final words = [
          'استراتيجية',
          'مستقبل',
          'عبقرية',
          'احتمالات',
          'استنتاج',
          'تكنولوجيا',
          'معلومات',
          'اكتشاف',
          'تحديات',
          'ابتكار',
          'معادلة',
          'ذاكرة',
          'منطق',
          'تفكير',
          'تركيز',
        ];

        final word = words[rand(0, words.length - 1)];
        final chars = word.split('');
        chars.shuffle(random);
        final scrambled = chars.join();

        final wrong = words.where((w) => w != word).toList()
          ..shuffle(random);

        return make(
          'كوّن الكلمة الصحيحة من الحروف:\n\n$scrambled',
          word,
          'الكلمة الصحيحة: $word',
          wrong.take(3).toList(),
        );

      // LOGIC
      case 4:
        final start = rand(2, 20);
        final step = rand(2, 5 + d ~/ 4);
        final multiplier = rand(2, 3);
        final type = d < 6 ? 0 : rand(0, 2);

        late List<int> sequence;
        late int answer;
        late String explanation;

        if (type == 0) {
          sequence = List.generate(4, (i) => start + step * i);
          answer = start + step * 4;
          explanation = 'نضيف $step في كل مرة';
        } else if (type == 1) {
          sequence = List.generate(
            4,
            (i) => start * pow(multiplier, i).toInt(),
          );
          answer = start * pow(multiplier, 4).toInt();
          explanation = 'نضرب كل رقم بـ $multiplier';
        } else {
          sequence = List.generate(
            4,
            (i) => start + i * i * step,
          );
          answer = start + 16 * step;
          explanation = 'الزيادة تعتمد على مربعات الأعداد';
        }

        return make(
          'اكتشف النمط وأكمله:\n\n'
          '${sequence.join('  •  ')}  •  ؟',
          '$answer',
          explanation,
          [
            '${answer + 1}',
            '${answer + step}',
            '${answer - step}',
          ],
        );

      // FOCUS
      case 5:
        final base = rand(10, 100 + d * 5);
        final type = rand(0, 2);

        late List<int> nums;
        late int odd;
        late String reason;

        if (type == 0) {
          nums = [
            base * 2,
            base * 4,
            base * 6,
            base * 2 + 1,
          ];
          odd = base * 2 + 1;
          reason = 'الأعداد الأخرى زوجية، وهذا العدد فردي';
        } else if (type == 1) {
          nums = [
            base * 3,
            base * 5,
            base * 7,
            base * 3 + 2,
          ];
          odd = base * 3 + 2;
          reason = 'الأعداد الأخرى تقبل القسمة على 3';
        } else {
          nums = [
            base * base,
            base * base + 1,
            base * base + 4,
            base * base + 9,
          ];
          odd = base * base + 1;
          reason = 'العدد المختلف ليس مربعاً كاملاً';
        }

        nums.shuffle(random);

        return make(
          'اكتشف العدد الذي لا ينتمي إلى المجموعة:\n\n'
          '${nums.join('     ')}',
          '$odd',
          reason,
          nums.where((n) => n != odd).map((n) => '$n').toList(),
        );

      // VISUAL PATTERNS
      case 6:
        final patterns = [
          ['🔴', '🔵', '🟢', '🟡'],
          ['▲', '■', '●', '◆'],
          ['⭐', '🌙', '☀️', '⚡'],
          ['⬆️', '➡️', '⬇️', '⬅️'],
        ];

        final p = patterns[rand(0, patterns.length - 1)];
        final step = rand(1, 3);

        final sequence = List.generate(
          5,
          (i) => p[(i * step) % p.length],
        );

        final answer = p[(5 * step) % p.length];

        return make(
          'اكتشف النمط البصري:\n\n'
          '${sequence.join('   ')}   ؟',
          answer,
          'يتكرر ترتيب الرموز وفق النمط نفسه',
          p.where((x) => x != answer).toList(),
        );

      // STRATEGY
      case 7:
        final step = rand(3, 10 + d);
        final moves = rand(3, 7);

        final forward = moves * step;
        final backward = (moves - 1) * (step - 2);
        final answer = forward - backward;

        return make(
          'تحدي التخطيط:\n'
          'تتحرك $moves مرات للأمام بمقدار $step، '
          'ثم تتراجع ${moves - 1} مرات بمقدار ${step - 2}.\n'
          'ما صافي الحركة؟',
          '$answer',
          '$forward - $backward = $answer',
          [
            '${answer + step}',
            '${answer - step}',
            '${answer + moves}',
          ],
        );

      // GENERAL KNOWLEDGE
      default:
        final facts = [
          ['ما العنصر الكيميائي الذي رمزه Fe؟', 'الحديد', 'Fe هو رمز الحديد'],
          ['ما أكبر محيط في العالم؟', 'المحيط الهادئ', 'المحيط الهادئ الأكبر'],
          ['كم عدد عظام جسم الإنسان البالغ تقريباً؟', '206', 'العدد المعتاد 206'],
          ['ما الغاز الأكثر وجوداً في الغلاف الجوي؟', 'النيتروجين', 'النيتروجين يشكل نحو 78%'],
          ['ما الكوكب الأقرب إلى الشمس؟', 'عطارد', 'عطارد أقرب الكواكب للشمس'],
          ['ما وحدة قياس شدة التيار الكهربائي؟', 'الأمبير', 'شدة التيار تقاس بالأمبير'],
          ['ما عاصمة اليابان؟', 'طوكيو', 'طوكيو عاصمة اليابان'],
          ['ما العضو المسؤول عن ضخ الدم؟', 'القلب', 'القلب يضخ الدم'],
          ['كم عدد أضلاع الشكل السداسي؟', '6', 'السداسي له ستة أضلاع'],
          ['ما أكبر قارة مساحة؟', 'آسيا', 'آسيا أكبر قارات العالم'],
          ['ما اللغة الرسمية في البرازيل؟', 'البرتغالية', 'البرازيل تتحدث البرتغالية'],
          ['ما الكوكب الذي يمتلك حلقات واضحة؟', 'زحل', 'زحل مشهور بحلقاته'],
        ];

        final f = facts[rand(0, facts.length - 1)];

        final wrong = facts.map((x) => x[1]).toSet().toList()
          ..remove(f[1])
          ..shuffle(random);

        return make(
          f[0],
          f[1],
          f[2],
          wrong.take(3).toList(),
        );
    }
  }

  // ================= HINT =================

  Future<void> useHint() async {
    if (answered || hintUsed) return;

    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt('inventory_hints') ?? 0;

    if (current <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا توجد تلميحات! اشترِ من المتجر 💡'),
        ),
      );
      return;
    }

    final wrong = options.where((x) => x != correctAnswer).toList()
      ..shuffle(random);

    final reduced = [correctAnswer, wrong.first]..shuffle(random);

    await prefs.setInt('inventory_hints', current - 1);

    if (!mounted) return;

    setState(() {
      options = reduced;
      hintsCount = current - 1;
      hintUsed = true;
    });
  }

  void chooseAnswer(int index) {
    if (answered || finished) return;

    setState(() {
      selected = index;
      answered = true;

      if (options[index] == correctAnswer) {
        score++;
        correctStreak++;
      } else {
        correctStreak = 0;
      }
    });
  }

  void nextQuestion() {
    if (questionIndex >= 9) {
      finishGame();
    } else {
      setState(() {
        questionIndex++;
        loadQuestion();
      });
    }
  }

  // ================= FINISH GAME =================

  Future<void> finishGame() async {
    if (saving || finished) return;

    setState(() {
      saving = true;
    });

    try {
      final result = await RewardManager.completeStage(
        widget.world,
        widget.stage,
        score,
      );

      if (!mounted) return;

      setState(() {
        rewardResult = result;
        finished = true;
        saving = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ أثناء حفظ المكافآت'),
        ),
      );
    }
  }

  String get worldName {
    const names = [
      'عالم الذاكرة',
      'عالم الرياضيات',
      'عالم الكلمات',
      'عالم المنطق',
      'عالم التركيز',
      'عالم الأشكال',
      'عالم الاستراتيجية',
      'عالم المعلومات',
    ];

    return names[(widget.world - 1).clamp(0, 7)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: gameBg,
      appBar: AppBar(
        backgroundColor: gameBg,
        title: Text(worldName),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: finished ? resultScreen() : gameScreen(),
        ),
      ),
    );
  }

  // ================= GAME UI =================

  Widget gameScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'المرحلة ${widget.stage}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              'السؤال ${questionIndex + 1}/10',
              style: TextStyle(color: worldColor),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: (questionIndex + 1) / 10,
            minHeight: 7,
            backgroundColor: Colors.white12,
            color: worldColor,
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: gameCard,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: worldColor.withOpacity(.3)),
          ),
          child: Column(
            children: [
              Icon(Icons.psychology_alt, color: worldColor, size: 32),
              const SizedBox(height: 12),
              Text(
                question,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: answered || hintUsed ? null : useHint,
          icon: const Icon(Icons.lightbulb, color: gameGold),
          label: Text(
            hintUsed ? 'تم استخدام التلميح' : 'تلميح ($hintsCount)',
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(options.length, (i) {
          final right = options[i] == correctAnswer;

          Color color = gameCard;
          Color border = Colors.white12;

          if (answered && right) {
            color = const Color(0xFF123D32);
            border = Colors.greenAccent;
          } else if (answered && selected == i) {
            color = const Color(0xFF4A1C2A);
            border = Colors.redAccent;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => chooseAnswer(i),
              borderRadius: BorderRadius.circular(17),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        options[i],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (answered && right)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.greenAccent,
                      ),
                    if (answered && selected == i && !right)
                      const Icon(
                        Icons.cancel,
                        color: Colors.redAccent,
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
        const Spacer(),
        if (answered)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: gameCard,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Column(
              children: [
                Text(
                  options[selected] == correctAnswer
                      ? 'إجابة صحيحة! 🔥'
                      : 'إجابة غير صحيحة',
                  style: TextStyle(
                    color: options[selected] == correctAnswer
                        ? Colors.greenAccent
                        : Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  explanation,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: worldColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.all(15),
                    ),
                    child: Text(
                      questionIndex == 9
                          ? 'إنهاء المرحلة'
                          : 'السؤال التالي',
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ================= RESULT UI =================

  Widget resultScreen() {
    final stars = score >= 9
        ? 3
        : score >= 7
            ? 2
            : score >= 5
                ? 1
                : 0;

    final coins = rewardResult?['coins'] ?? 0;
    final xp = rewardResult?['xp'] ?? 0;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: gameGold.withOpacity(.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                color: gameGold,
                size: 75,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'انتهى التحدي!',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$score / 10',
   
