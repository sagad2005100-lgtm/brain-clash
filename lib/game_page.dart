
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'reward_manager.dart';

const gameBg = Color(0xFF080B16);
const gameCard = Color(0xFF151B30);
const gameGold = Color(0xFFFFD166);
const gameCyan = Color(0xFF55D6FF);
const gamePurple = Color(0xFF9B7BFF);

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
  void initState() {
    super.initState();
    loadQuestion();
    loadHints();
  }

  Future<void> loadHints() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      hintsCount = prefs.getInt('inventory_hints') ?? 0;
    });
  }

  int rand(int minValue, int maxValue) {
    return minValue + random.nextInt(maxValue - minValue + 1);
  }

  List<String> choices(String answer, List<String> wrong) {
    final result = <String>{answer};

    for (final value in wrong) {
      if (value != answer) result.add(value);
    }

    while (result.length < 4) {
      final alternative = '${rand(10, 999)}';
      if (alternative != answer) result.add(alternative);
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

    question = item['q'] as String;
    correctAnswer = item['a'] as String;
    explanation = item['e'] as String;
    options = List<String>.from(item['o'] as List);

    selected = -1;
    answered = false;
    hintUsed = false;
  }

  // ================= QUESTION ENGINE =================

  Map<String, dynamic> generateQuestion(int level) {
    final d = max(1, level);

    switch (widget.world) {
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
          'اختبر ذاكرتك:\n\n$answer\n\nما التسلسل الصحيح الذي شاهدته؟',
          answer,
          'التسلسل الأصلي هو $answer',
          wrong,
        );

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
        final chars = word.split('')..shuffle(random);
        final wrong = words.where((w) => w != word).toList()
          ..shuffle(random);

        return make(
          'كوّن الكلمة الصحيحة من الحروف:\n\n${chars.join()}',
          word,
          'الكلمة الصحيحة: $word',
          wrong.take(3).toList(),
        );

      case 4:
        final start = rand(2, 20);
        final step = rand(2, 5 + d ~/ 4);
        final multiplier = rand(2, 3);
        final type = d < 6 ? 0 : rand(0, 2);

        late List<int> sequence;
        late int answer;
        late String exp;

        if (type == 0) {
          sequence = List.generate(4, (i) => start + step * i);
          answer = start + step * 4;
          exp = 'نضيف $step في كل مرة';
        } else if (type == 1) {
          sequence = List.generate(
            4,
            (i) => start * pow(multiplier, i).toInt(),
          );
          answer = start * pow(multiplier, 4).toInt();
          exp = 'نضرب كل رقم بـ $multiplier';
        } else {
          sequence = List.generate(4, (i) => start + i * i * step);
          answer = start + 16 * step;
          exp = 'الزيادة تعتمد على مربعات الأعداد';
        }

        return make(
          'اكتشف النمط وأكمله:\n\n${sequence.join('  •  ')}  •  ؟',
          '$answer',
          exp,
          [
            '${answer + 1}',
            '${answer + step}',
            '${answer - step}',
          ],
        );

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
          'اكتشف العدد الذي لا ينتمي إلى المجموعة:\n\n${nums.join('     ')}',
          '$odd',
          reason,
          nums.where((n) => n != odd).map((n) => '$n').toList(),
        );

      case 6:
        final patterns = [
          ['🔴', '🔵', '🟢', '🟡'],
          ['▲', '■', '●', '◆'],
          ['⭐', '🌙', '☀️', '⚡'],
          ['⬆️', '➡️', '⬇️', '⬅️'],
        ];

        final p = patterns[rand(0, patterns.length - 1)];
        final step = rand(1, 3);
        final sequence = List.generate(5, (i) => p[(i * step) % p.length]);
        final answer = p[(5 * step) % p.length];

        return make(
          'اكتشف النمط البصري:\n\n${sequence.join('   ')}   ؟',
          answer,
          'يتكرر ترتيب الرموز وفق النمط نفسه',
          p.where((x) => x != answer).toList(),
        );

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

      default:
        final facts = [
          ['ما العنصر الكيميائي الذي رمزه Fe؟', 'الحديد', 'Fe هو رمز الحديد'],
          ['ما أكبر محيط في العالم؟', 'المحيط الهادئ', 'المحيط الهادئ هو الأكبر'],
          ['كم عدد عظام جسم الإنسان البالغ تقريباً؟', '206', 'العدد المعتاد 206 عظمة'],
          ['ما الغاز الأكثر وجوداً في الغلاف الجوي؟', 'النيتروجين', 'النيتروجين يشكل نحو 78%'],
          ['ما الكوكب الأقرب إلى الشمس؟', 'عطارد', 'عطارد أقرب الكواكب إلى الشمس'],
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
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا توجد تلميحات! اشترِ من المتجر 💡'),
        ),
      );
      return;
    }

    final wrong = options.where((x) => x != correctAnswer).toList()
      ..shuffle(random);

    if (wrong.isEmpty) return;

    final reduced = [correctAnswer, wrong.first]..shuffle(random);

    await prefs.setInt('inventory_hints', current - 1);
    if (!mounted) return;

    setState(() {
      options = reduced;
      hintsCount = current - 1;
      hintUsed = true;
    });
  }

  // ================= ANSWERS =================

  void chooseAnswer(int index) {
    if (answered || finished || saving) return;

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
      return;
    }

    setState(() {
      questionIndex++;
      loadQuestion();
    });
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

  // ================= MAIN SCREEN =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: gameBg,
      appBar: AppBar(
        backgroundColor: gameBg,
        elevation: 0,
        title: Text(
          worldName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: finished ? resultScreen() : gameScreen(),
      ),
    );
  }

  // ================= GAME UI =================

  Widget gameScreen() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'المرحلة ${widget.stage}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              'السؤال ${questionIndex + 1}/10',
              style: TextStyle(
                color: worldColor,
                fontWeight: FontWeight.bold,
              ),
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
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: gameCard,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: worldColor.withOpacity(.35),
            ),
            boxShadow: [
              BoxShadow(
                color: worldColor.withOpacity(.08),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                Icons.psychology_alt_rounded,
                color: worldColor,
                size: 38,
              ),
              const SizedBox(height: 14),
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
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: answered || hintUsed ? null : useHint,
          icon: const Icon(Icons.lightbulb, color: gameGold),
          label: Text(
            hintUsed ? 'تم استخدام التلميح' : 'تلميح ($hintsCount)',
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: BorderSide(color: gameGold.withOpacity(.5)),
            padding: const EdgeInsets.all(13),
          ),
        ),
        const SizedBox(height: 14),
        ...List.generate(options.length, (i) {
          final right = options[i] == correctAnswer;

          Color cardColor = gameCard;
          Color borderColor = Colors.white12;

          if (answered && right) {
            cardColor = const Color(0xFF123D32);
            borderColor = Colors.greenAccent;
          } else if (answered && selected == i) {
            cardColor = const Color(0xFF4A1C2A);
            borderColor = Colors.redAccent;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 11),
            child: InkWell(
              onTap: () => chooseAnswer(i),
              borderRadius: BorderRadius.circular(17),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: borderColor, width: 1.4),
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
        if (answered) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: gameCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: worldColor.withOpacity(.25),
              ),
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
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  explanation,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: saving ? null : nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: worldColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.all(15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      questionIndex == 9
                          ? 'إنهاء المرحلة'
                          : 'السؤال التالي',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
   
