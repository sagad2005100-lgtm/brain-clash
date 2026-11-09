import 'package:flutter/material.dart';
import 'questions.dart';
import 'game_engine.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late GameEngine engine;
  bool answered = false;
  bool? lastResult;
  int? selectedAnswer;

  @override
  void initState() {
    super.initState();
    engine = GameEngine(questions: questions);
    _startTimer();
  }

  void _startTimer() {
    engine.startTimer(
      onTimeUp: () {
        if (mounted) {
          setState(() {
            answered = true;
            lastResult = false;
          });
        }
      },
      onTick: (_) {
        if (mounted) setState(() {});
      },
    );
  }

  void _answer(int index) {
    if (answered) return;

    final result = engine.answer(index);

    setState(() {
      answered = true;
      selectedAnswer = index;
      lastResult = result;
    });
  }

  void _next() {
    if (engine.isFinished) return;

    final moved = engine.nextQuestion();

    if (!moved) {
      setState(() {});
      return;
    }

    setState(() {
      answered = false;
      lastResult = null;
      selectedAnswer = null;
    });

    _startTimer();
  }

  @override
  void dispose() {
    engine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (engine.isFinished) {
      return _resultPage();
    }

    final question = engine.currentQuestion;

    if (question == null) {
      return const Scaffold(
        body: Center(child: Text('لا توجد أسئلة')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Brain Clash'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _info('النقاط', '${engine.score}'),
                  _info('السؤال', '${engine.currentIndex + 1}/${questions.length}'),
                  _info('الوقت', '${engine.remainingSeconds}'),
                ],
              ),
              const SizedBox(height: 22),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: engine.progress,
                  minHeight: 8,
                  color: const Color(0xFFD6AE55),
                  backgroundColor: Colors.white12,
                ),
              ),
              const SizedBox(height: 25),
              Text(
                question.category,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFD6AE55),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF172442),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFD6AE55),
                  ),
                ),
                child: Text(
                  question.question,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              ...List.generate(question.answers.length, (index) {
                final isCorrect = index == question.correctAnswer;
                final isSelected = index == selectedAnswer;

                Color buttonColor = const Color(0xFF172442);

                if (answered && isCorrect) {
                  buttonColor = Colors.green.shade800;
                } else if (answered && isSelected && !isCorrect) {
                  buttonColor = Colors.red.shade800;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SizedBox(
                    height: 57,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: answered ? null : () => _answer(index),
                      child: Text(
                        question.answers[index],
                        style: const TextStyle(fontSize: 19),
                      ),
                    ),
                  ),
                );
              }),
              const Spacer(),
              if (answered)
                Text(
                  lastResult == true ? 'إجابة صحيحة!' : 'انتهى الوقت أو إجابة خاطئة',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: lastResult == true ? Colors.green : Colors.orange,
                  ),
                ),
              const SizedBox(height: 12),
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: answered ? _next : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD6AE55),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text(
                    'السؤال التالي',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _info(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD6AE55),
          ),
        ),
      ],
    );
  }

  Widget _resultPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('النتيجة النهائية'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.emoji_events,
              color: Color(0xFFD6AE55),
              size: 100,
            ),
            const SizedBox(height: 20),
            const Text(
              'انتهت اللعبة!',
              style: TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 15),
            Text(
              'نقاطك: ${engine.score}',
              style: const TextStyle(
                fontSize: 25,
                color: Color(0xFFD6AE55),
              ),
            ),
            Text('الإجابات الصحيحة: ${engine.correctAnswers}'),
            Text('الإجابات الخاطئة: ${engine.wrongAnswers}'),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                engine.reset();
                setState(() {
                  answered = false;
                  lastResult = null;
                  selectedAnswer = null;
                });
                _startTimer();
              },
              child: const Text('إعادة اللعب'),
            ),
          ],
        ),
      ),
    );
  }
}
