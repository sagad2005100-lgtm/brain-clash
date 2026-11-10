
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
  final TextEditingController answerController = TextEditingController();

  int questionIndex = 0;
  int score = 0;
  int selected = -1;
  bool answered = false;
  bool finished = false;

  late List<String> options;
  late String question;
  late String correctAnswer;
  late String explanation;

  final List<Map<String, dynamic>> challenges = [
    {
      'question': 'احفظ الترتيب ثم اختر الأرقام بالترتيب الصحيح',
      'answer': '3,1,4',
      'explanation': 'الترتيب الصحيح هو 3 ثم 1 ثم 4',
      'options': ['3,1,4', '1,3,4', '4,1,3', '3,4,1'],
    },
    {
      'question': 'كم يساوي 17 × 6 ؟',
      'answer': '102',
      'explanation': '17 × 6 = 102',
      'options': ['92', '102', '112', '108'],
    },
    {
      'question': 'رتّب الحروف لتكوين كلمة: ب ا ت ك',
      'answer': 'كتاب',
      'explanation': 'الكلمة هي كتاب',
      'options': ['كتاب', 'باب', 'كباب', 'تاب'],
    },
    {
      'question': 'أي رقم لا ينتمي إلى المجموعة؟',
      'answer': '9',
      'explanation': 'الأرقام الأخرى أعداد أولية',
      'options': ['3', '5', '7', '9'],
    },
    {
      'question': 'ابحث عن الرقم المختلف',
      'answer': '8',
      'explanation': 'الأرقام الأخرى متساوية',
      'options': ['6', '6', '8', '6'],
    },
    {
      'question': 'أي شكل يأتي بعد ذلك؟ 🔴 🔵 🔴 🔵 ؟',
      'answer': '🔴',
      'explanation': 'النمط يتناوب بين الأحمر والأزرق',
      'options': ['🔴', '🔵', '🟢', '🟡'],
    },
    {
      'question': 'للوصول إلى الهدف تحرّك: أعلى، أعلى، يمين. ما آخر اتجاه؟',
      'answer': 'يمين',
      'explanation': 'آخر حركة هي اليمين',
      'options': ['أعلى', 'أسفل', 'يمين', 'يسار'],
    },
    {
      'question': 'ما أكبر كوكب في المجموعة الشمسية؟',
      'answer': 'المشتري',
      'explanation': 'المشتري هو أكبر كواكب المجموعة الشمسية',
      'options': ['الأرض', 'المريخ', 'المشتري', 'زحل'],
    },
  ];

  @override
  void initState() {
    super.initState();
    loadChallenge();
  }

  void loadChallenge() {
    final item = challenges[widget.world - 1];
    question = item['question'];
    correctAnswer = item['answer'];
    explanation = item['explanation'];
    options = List<String>.from(item['options']);

    // تغيير ترتيب الخيارات حتى لا يكون الجواب دائماً في نفس المكان
    options.shuffle(random);

    selected = -1;
    answered = false;
    answerController.clear();
  }

  void chooseAnswer(int index) {
    if (answered || finished) return;

    setState(() {
      selected = index;
      answered = true;

      if (options[index] == correctAnswer) {
        score++;
      }
    });
  }

  void checkTextAnswer() {
    if (answered || finished) return;

    final value = answerController.text.trim();

    setState(() {
      answered = true;
      if (value == correctAnswer) {
        score++;
      }
    });
  }

  void nextChallenge() {
    if (questionIndex >= 9) {
      setState(() => finished = true);
    } else {
      setState(() {
        questionIndex++;
        loadChallenge();
      });
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
    return names[widget.world - 1];
  }

  @override
  void dispose() {
    answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCorrect = selected >= 0
        ? options[selected] == correctAnswer
        : answerController.text.trim() == correctAnswer;

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
          child: finished ? resultScreen() : gameScreen(isCorrect),
        ),
      ),
    );
  }

  Widget gameScreen(bool isCorrect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'المرحلة ${widget.stage}  •  التحدي ${questionIndex + 1}/10',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: (questionIndex + 1) / 10,
            minHeight: 8,
            backgroundColor: Colors.white12,
            color: const Color(0xFFFFC857),
          ),
        ),
        const SizedBox(height: 35),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1D2233),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: [
              const Icon(Icons.psychology_alt,
                  color: Color(0xFFFFC857), size: 42),
              const SizedBox(height: 18),
              Text(
                question,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),
        ...List.generate(options.length, (index) {
          final correct = options[index] == correctAnswer;
          Color color = const Color(0xFF252B3D);

          if (answered && correct) {
            color = Colors.green.shade800;
          } else if (answered && selected == index && !correct) {
            color = Colors.red.shade800;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => chooseAnswer(index),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 17),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text(
                  options[index],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }),
        const Spacer(),
        if (answered) ...[
          Text(
            isCorrect ? 'إجابة صحيحة! أحسنت 🎉' : 'مو صحيح، حاول بالتحدي القادم',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isCorrect ? Colors.greenAccent : Colors.orangeAccent,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            explanation,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: nextChallenge,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC857),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.all(16),
            ),
            child: Text(
              questionIndex == 9 ? 'عرض النتيجة' : 'التحدي التالي',
            ),
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
          const Icon(Icons.emoji_events,
              color: Color(0xFFFFC857), size: 90),
          const SizedBox(height: 20),
          const Text(
            'انتهى التحدي!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            '$score / 10',
            style: const TextStyle(
              color: Color(0xFFFFC857),
              fontSize: 42,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            score >= 8
                ? 'ممتاز! عقل خارق 🔥'
                : score >= 5
                    ? 'أداء جيد، استمر!'
                    : 'لا تستسلم، حاول مرة ثانية!',
            style: const TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, score),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC857),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(
                  horizontal: 35, vertical: 15),
            ),
            child: const Text('العودة للمراحل'),
          ),
        ],
      ),
    );
  }
}
