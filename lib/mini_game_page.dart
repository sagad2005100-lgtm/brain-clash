
import 'dart:math';
import 'package:flutter/material.dart';

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
  bool answered = false;
  bool finished = false;

  late List<String> options;
  late String question;
  late String correctAnswer;
  late String explanation;

  @override
  void initState() {
    super.initState();
    loadQuestion();
  }

  void loadQuestion() {
    final level = widget.stage + questionIndex;
    final item = generateQuestion(level);

    question = item['q'];
    correctAnswer = item['a'];
    explanation = item['e'];
    options = List<String>.from(item['o']);
    options.shuffle(random);

    selected = -1;
    answered = false;
  }

  Map<String, dynamic> generateQuestion(int level) {
    final n = max(1, level);

    switch (widget.world) {
      case 1:
        final a = random.nextInt(9) + 1;
        final b = random.nextInt(9) + 1;
        final c = random.nextInt(9) + 1;
        final seq = '$a,$b,$c';
        final choices = [
          seq,
          '$b,$a,$c',
          '$c,$b,$a',
          '$a,$c,$b'
        ];
        return {
          'q': 'اختبر ذاكرتك: ما الترتيب الصحيح للأرقام؟',
          'a': seq,
          'e': 'الترتيب هو $seq',
          'o': choices
        };

      case 2:
        final a = random.nextInt(n * 2 + 10) + 2;
        final b = random.nextInt(9) + 2;
        final answer = a * b;
        return {
          'q': 'كم يساوي $a × $b ؟',
          'a': '$answer',
          'e': '$a × $b = $answer',
          'o': [
            '$answer',
            '${answer + b}',
            '${answer - b}',
            '${answer + a}'
          ]
        };

      case 3:
        final words = [
          ['باتك', 'كتاب'],
          ['ةسردم', 'مدرسة'],
          ['ملق', 'قلم'],
          ['باب', 'باب'],
          ['سمش', 'شمس'],
          ['رمق', 'قمر'],
          ['ةرجش', 'شجرة'],
          ['ةذفان', 'نافذة'],
        ];
        final w = words[random.nextInt(words.length)];
        return {
          'q': 'رتّب الحروف لتكوين كلمة: ${w[0]}',
          'a': w[1],
          'e': 'الكلمة الصحيحة هي ${w[1]}',
          'o': [w[1], 'كتاب', 'قلم', 'شمس']
        };

      case 4:
        final start = random.nextInt(15) + 1;
        final step = random.nextInt(5) + 2;
        final answer = start + step * 3;
        return {
          'q': 'أكمل النمط: $start، ${start+step}، ${start+step*2}، ؟',
          'a': '$answer',
          'e': 'نضيف $step في كل مرة',
          'o': ['$answer', '${answer+1}', '${answer-step}', '${answer+step}']
        };

      case 5:
        final a = random.nextInt(8) + 2;
        final b = a + random.nextInt(3) + 2;
        return {
          'q': 'ما الرقم المختلف؟',
          'a': '$b',
          'e': 'الرقم المختلف هو $b',
          'o': ['$a', '$a', '$b', '$a']
        };

      case 6:
        final patterns = [
          ['🔴 🔵 🔴 🔵 ؟', '🔴'],
          ['⭐ 🌙 ⭐ 🌙 ؟', '⭐'],
          ['🟢 🟡 🟢 🟡 ؟', '🟢'],
          ['🔺 🔵 🔺 🔵 ؟', '🔺']
        ];
        final p = patterns[random.nextInt(patterns.length)];
        return {
          'q': 'أكمل النمط: ${p[0]}',
          'a': p[1],
          'e': 'النمط يتكرر بالتناوب',
          'o': [p[1], '🔵', '🟡', '⭐']
        };

      case 7:
        final moves = random.nextInt(8) + 2;
        return {
          'q': 'تحرك $moves خطوات للأمام ثم خطوتين للخلف. كم خطوة بقيت؟',
          'a': '${moves-2}',
          'e': '$moves - 2 = ${moves-2}',
          'o': ['${moves-2}', '$moves', '${moves+2}', '${moves-1}']
        };

      default:
        final facts = [
          ['ما أكبر كوكب في المجموعة الشمسية؟', 'المشتري', 'المشتري أكبر كواكب المجموعة الشمسية'],
          ['كم عدد أيام الأسبوع؟', '7', 'الأسبوع يتكون من سبعة أيام'],
          ['ما عاصمة العراق؟', 'بغداد', 'بغداد عاصمة العراق'],
          ['كم عدد قارات العالم؟', '7', 'عدد القارات سبع'],
          ['ما الكوكب الأحمر؟', 'المريخ', 'المريخ يعرف بالكوكب الأحمر'],
          ['ما أسرع حيوان بري؟', 'الفهد', 'الفهد أسرع الحيوانات البرية'],
          ['كم ضلع للمثلث؟', '3', 'المثلث له ثلاثة أضلاع'],
          ['ما أقرب نجم إلى الأرض؟', 'الشمس', 'الشمس أقرب نجم إلى الأرض'],
        ];
        final f = facts[random.nextInt(facts.length)];
        return {
          'q': f[0],
          'a': f[1],
          'e': f[2],
          'o': [f[1], 'القمر', 'الأرض', 'زحل']
        };
    }
  }

  void chooseAnswer(int index) {
    if (answered || finished) return;
    setState(() {
      selected = index;
      answered = true;
      if (options[index] == correctAnswer) score++;
    });
  }

  void nextQuestion() {
    if (questionIndex == 9) {
      setState(() => finished = true);
    } else {
      setState(() {
        questionIndex++;
        loadQuestion();
      });
    }
  }

  String get worldName {
    const names = [
      'عالم الذاكرة', 'عالم الرياضيات', 'عالم الكلمات',
      'عالم المنطق', 'عالم التركيز', 'عالم الأشكال',
      'عالم الاستراتيجية', 'عالم المعلومات'
    ];
    return names[widget.world - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF10121C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10121C),
        foregroundColor: Colors.white,
        title: Text(worldName),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: finished ? resultScreen() : gameScreen(),
        ),
      ),
    );
  }

  Widget gameScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'المرحلة ${widget.stage} • ${questionIndex+1}/10',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 15),
        LinearProgressIndicator(
          value: (questionIndex+1)/10,
          color: const Color(0xFFFFC857),
          backgroundColor: Colors.white12,
        ),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1D2233),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            question,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 25),
        ...List.generate(options.length, (i) {
          final isRight = options[i] == correctAnswer;
          Color color = const Color(0xFF252B3D);
          if (answered && isRight) color = Colors.green.shade800;
          if (answered && selected == i && !isRight) color = Colors.red.shade800;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => chooseAnswer(i),
              child: Container(
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  options[i],
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 19),
                ),
              ),
            ),
          );
        }),
        const Spacer(),
        if (answered) ...[
          Text(
            selected >= 0 && options[selected] == correctAnswer
                ? 'إجابة صحيحة! 🎉'
                : 'إجابة غير صحيحة',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.orangeAccent, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(explanation,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: nextQuestion,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC857),
              foregroundColor: Colors.black,
            ),
            child: Text(questionIndex == 9 ? 'النتيجة' : 'السؤال التالي'),
          ),
        ],
      ],
    );
  }

  Widget resultScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emoji_events, color: Color(0xFFFFC857), size: 90),
          const SizedBox(height: 20),
          const Text('انتهى التحدي!',
              style: TextStyle(color: Colors.white, fontSize: 28)),
          Text('$score / 10',
              style: const TextStyle(color: Color(0xFFFFC857), fontSize: 42)),
          const SizedBox(height: 20),
          Text(
            score >= 8 ? 'ممتاز! 🔥' : score >= 5 ? 'أداء جيد!' : 'حاول مرة ثانية!',
            style: const TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, score),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC857),
              foregroundColor: Colors.black,
            ),
            child: const Text('العودة للمراحل'),
          ),
        ],
      ),
    );
  }
}
