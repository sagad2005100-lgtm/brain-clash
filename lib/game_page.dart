import 'package:flutter/material.dart';
import 'game_engine.dart';
import 'stage_progress.dart';
import 'stage_questions.dart';

class GamePage extends StatefulWidget {
  final int stageNumber;

  const GamePage({
    super.key,
    this.stageNumber = 1,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late GameEngine engine;
  late List questions;

  bool answered = false;
  bool? lastResult;
  int? selectedAnswer;
  bool progressSaved = false;

  @override
  void initState() {
    super.initState();

    questions = StageQuestions.getQuestions(widget.stageNumber);

    if (questions.isEmpty) {
      return;
    }

    engine = GameEngine(questions: questions);
    startTimer();
  }

  void startTimer() {
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

  void answer(int index) {
    if (answered) return;

    final result = engine.answer(index);

    setState(() {
      answered = true;
      selectedAnswer = index;
      lastResult = result;
    });
  }

  void nextQuestion() {
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

    startTimer();
  }

  Future<void> saveProgress() async {
    if (progressSaved) return;

    progressSaved = true;

    final stars = StageProgress.starsForCorrectAnswers(
      engine.correctAnswers,
      questions.length,
    );

    await StageProgress.saveStars(
      widget.stageNumber,
      stars,
    );
  }

  @override
  void dispose() {
    if (questions.isNotEmpty) {
      engine.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('المرحلة ${widget.stageNumber}'),
        ),
        body: const Center(
          child: Text(
            'أسئلة هذه المرحلة قيد الإعداد',
            style: TextStyle(fontSize: 20),
          ),
        ),
      );
    }

    if (engine.isFinished) {
      return FutureBuilder<void>(
        future: saveProgress(),
        builder: (context, snapshot) => resultPage(),
      );
    }

    final question = engine.currentQuestion!;

    return Scaffold(
      appBar: AppBar(
        title: Text('المرحلة ${widget.stageNumber}'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  info('النقاط', '${engine.score}'),
                  info(
                    'السؤال',
                    '${engine.currentIndex + 1}/${questions.length}',
                  ),
                  info('الوقت', '${engine.remainingSeconds}'),
                ],
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: engine.progress,
                  minHeight: 9,
                  color: const Color(0xFFFFC857),
                  backgroundColor: Colors.white12,
                ),
              ),
              const SizedBox(height: 25),
              Text(
                question.category,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFFFC857),
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(23),
                decoration: BoxDecoration(
                  color: const Color(0xFF121D33),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFFC857),
                  ),
                ),
                child: Text(
                  question.question,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              ...List.generate(question.answers.length, (index) {
                final correct = index == question.correctAnswer;
                final selected = index == selectedAnswer;

                Color color = const Color(0xFF172442);

                if (answered && correct) {
                  color = Colors.green.shade800;
                } else if (answered && selected) {
                  color = Colors.red.shade800;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 11),
                  child: SizedBox(
                    height: 57,
                    child: ElevatedButton(
                      onPressed: answered ? null : () => answer(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        question.answers[index],
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                );
              }),
              const Spacer(),
              if (answered) ...[
                Text(
                  lastResult == true
                      ? 'إجابة صحيحة! أحسنت'
                      : 'إجابة خاطئة!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 19,
                    color: lastResult == true
                        ? Colors.greenAccent
                        : Colors.orangeAccent,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: answered ? nextQuestion : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC857),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text(
                    'السؤال التالي',
                    style: TextStyle(
                      fontSize: 18,
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

  Widget info(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.white60)),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFFFC857),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget resultPage() {
    final stars = StageProgress.starsForCorrectAnswers(
      engine.correctAnswers,
      questions.length,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('النتيجة النهائية')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.emoji_events,
                color: Color(0xFFFFC857),
                size: 100,
              ),
              const SizedBox(height: 15),
              const Text(
                'انتهت المرحلة!',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                '⭐' * stars + '☆' * (3 - stars),
                style: const TextStyle(fontSize: 35),
              ),
              const SizedBox(height: 20),
              Text('النقاط: ${engine.score}'),
              Text('الإجابات الصحيحة: ${engine.correctAnswers}'),
              Text('الإجابات الخاطئة: ${engine.wrongAnswers}'),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('العودة للمراحل'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
