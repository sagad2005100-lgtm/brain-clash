import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const BrainClash());
}

class BrainClash extends StatelessWidget {
  const BrainClash({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Brain Clash',
      theme: ThemeData.dark(),
      home: const GamePage(),
    );
  }
}

class Question {
  final String text;
  final List<String> answers;
  final int correct;
  final String level;

  const Question(
    this.text,
    this.answers,
    this.correct,
    this.level,
  );
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final List<Question> questions = const [
    Question('ما عاصمة العراق؟',
        ['بغداد', 'البصرة', 'كربلاء', 'الموصل'], 0, 'سهل'),
    Question('كم عدد كواكب المجموعة الشمسية؟',
        ['7', '8', '9', '10'], 1, 'سهل'),
    Question('ما أكبر محيط في العالم؟',
        ['الأطلسي', 'الهندي', 'الهادئ', 'المتجمد'], 2, 'متوسط'),
    Question('ما العنصر الذي رمزه O؟',
        ['الذهب', 'الأوكسجين', 'الحديد', 'الفضة'], 1, 'متوسط'),
    Question('كم ضلعاً للمسدس؟',
        ['5', '6', '7', '8'], 1, 'سهل'),
    Question('ما أسرع حيوان بري؟',
        ['الأسد', 'الفهد', 'الحصان', 'النمر'], 1, 'متوسط'),
    Question('ما ناتج 12 × 12؟',
        ['124', '144', '132', '154'], 1, 'صعب'),
    Question('ما الكوكب الأحمر؟',
        ['الزهرة', 'المريخ', 'زحل', 'عطارد'], 1, 'سهل'),
    Question('كم ضلعاً للمثلث؟',
        ['2', '3', '4', '5'], 1, 'سهل'),
    Question('ما أكبر قارة في العالم؟',
        ['أفريقيا', 'أوروبا', 'آسيا', 'أستراليا'], 2, 'متوسط'),
  ];

  int screen = 0;
  int index = 0;
  int score = 0;
  int seconds = 15;
  int? selected;
  bool answered = false;
  Timer? timer;
    void startTimer() {
    timer?.cancel();
    seconds = 15;
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (seconds > 0) {
        setState(() => seconds--);
      } else {
        t.cancel();
        nextQuestion();
      }
    });
  }

  void startGame() {
    setState(() {
      screen = 1;
      index = 0;
      score = 0;
      selected = null;
      answered = false;
    });
    startTimer();
  }

  void answerQuestion(int choice) {
    if (answered) return;

    timer?.cancel();

    setState(() {
      selected = choice;
      answered = true;

      if (choice == questions[index].correct) {
        score++;
      }
    });
  }

  void nextQuestion() {
    timer?.cancel();

    if (index < questions.length - 1) {
      setState(() {
        index++;
        selected = null;
        answered = false;
      });
      startTimer();
    } else {
      setState(() => screen = 2);
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (screen == 0) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.psychology, size: 100, color: Colors.amber),
              const SizedBox(height: 20),
              const Text('صراع العقول',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: startGame,
                child: const Text('ابدأ اللعب'),
              ),
            ],
          ),
        ),
      );
    }

    if (screen == 2) {
      return Scaffold(
        appBar: AppBar(title: const Text('النتيجة')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events, size: 100, color: Colors.amber),
              const Text('انتهت اللعبة', style: TextStyle(fontSize: 28)),
              Text('نتيجتك: $score من ${questions.length}',
                  style: const TextStyle(fontSize: 24)),
              ElevatedButton(
                onPressed: startGame,
                child: const Text('العب مرة أخرى'),
              ),
            ],
          ),
        ),
      );
    }

    final q = questions[index];

    return Scaffold(
      appBar: AppBar(
        title: Text('السؤال ${index + 1} / ${questions.length}'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('المستوى: ${q.level}',
                style: const TextStyle(color: Colors.amber, fontSize: 18)),
            const SizedBox(height: 15),
            Text('الوقت: $seconds ثانية',
                style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 30),
            Text(q.text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 25, fontWeight: FontWeight.bold)),
            const SizedBox(height: 25),
            ...List.generate(q.answers.length, (i) {
              Color color = Colors.blueGrey;

              if (answered && i == q.correct) {
                color = Colors.green;
              } else if (answered && i == selected) {
                color = Colors.red;
              }

              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    padding: const EdgeInsets.all(16),
                  ),
                  onPressed: answered ? null : () => answerQuestion(i),
                  child: Text(q.answers[i],
                      style: const TextStyle(fontSize: 19)),
                ),
              );
            }),
            const SizedBox(height: 15),
            if (answered)
              ElevatedButton(
                onPressed: nextQuestion,
                child: Text(index == questions.length - 1
                    ? 'عرض النتيجة'
                    : 'السؤال التالي'),
              ),
          ],
        ),
      ),
    );
  }
}
