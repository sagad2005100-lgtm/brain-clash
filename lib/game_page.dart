
import 'package:flutter/material.dart';
import 'game_engine.dart';
import 'stage_progress.dart';
import 'stage_questions.dart';

const Color gold = Color(0xFFD6AE55);
const Color navy = Color(0xFF080D1B);
const Color panel = Color(0xFF172442);

class GamePage extends StatefulWidget {
  final int stageNumber;

  const GamePage({super.key, this.stageNumber = 1});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late final List<Question> stageQuestions;
  late GameEngine engine;

  bool answered = false;
  bool? lastResult;
  int? selectedAnswer;
  bool progressSaved = false;

  @override
  void initState() {
    super.initState();

    stageQuestions = StageQuestions.getQuestions(widget.stageNumber);

    engine = GameEngine(questions: stageQuestions);

    if (stageQuestions.isNotEmpty) {
      _startTimer();
    }
  }

  void _startTimer() {
    engine.startTimer(
      onTimeUp: () {
        if (!mounted) return;
        setState(() {
          answered = true;
          lastResult = false;
        });
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
    if (!answered) return;

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

  Future<void> _saveProgress() async {
    if (progressSaved) return;
    progressSaved = true;

    final stars = StageProgress.starsForCorrectAnswers(
      engine.correctAnswers,
      stageQuestions.length,
    );

    await StageProgress.saveStars(widget.stageNumber, stars);
  }

  @override
  void dispose() {
    engine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (stageQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('المرحلة ${widget.stageNumber}')),
        body: const Center(
          child: Text(
            'أسئلة هذه المرحلة لم تُضف بعد',
            style: TextStyle(fontSize: 19),
          ),
        ),
      );
    }

    if (engine.isFinished) {
      return FutureBuilder<void>(
        future: _saveProgress(),
        builder: (context, snapshot) {
          return _resultPage();
        },
      );
    }

    final question = engine.currentQuestion;

    if (question == null) {
      return const Scaffold(
        body: Center(child: Text('لا توجد أسئلة')),
      );
    }

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
                  _info('النقاط', '${engine.score}'),
                  _info(
                    'السؤال',
                    '${engine.currentIndex + 1}/${stageQuestions.length}',
                  ),
                  _info('الوقت', '${engine.remainingSeconds}'),
                ],
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: engine.progress,
                  minHeight: 9,
                  color: gold,
                  backgroundColor: Colors.white12,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                question.category,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: gold,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: panel,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: gold),
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

                Color color = panel;

                if (answered && correct) {
                  color = Colors.green.shade800;
                } else if (answered && selected) {
                  color = Colors.red.shade800;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 11),
                  child: SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed: answered ? null : () => _answer(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: color,
                        disabledForegroundColor: Colors.white,
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
              if (answered)
                Text(
                  lastResult == true
                      ? 'إجابة صحيحة!'
                      : 'إجابة خاطئة أو انتهى الوقت',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: lastResult == true
                        ? Colors.greenAccent
                        : Colors.orangeAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 10),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: answered ? _next : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    foregroundColor: navy,
                  ),
                  child: Text(
                    engine.currentIndex + 1 == stageQuestions.length
                        ? 'إنهاء المرحلة'
                        : 'السؤال التالي',
                    style: const TextStyle(
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

  Widget _info(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: gold,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _resultPage() {
    final stars = StageProgress.starsForCorrectAnswers(
      engine.correctAnswers,
      stageQuestions.length,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('النتيجة النهائية')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.emoji_events,
                color: gold,
                size: 95,
              ),
              const SizedBox(height: 18),
              const Text(
                'انتهت المرحلة!',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                '⭐' * stars,
                style: const TextStyle(fontSize: 38),
              ),
              const SizedBox(height: 15),
              Text(
                'النقاط: ${engine.score}',
                style: const TextStyle(color: gold, fontSize: 24),
              ),
              Text('الإجابات الصحيحة: ${engine.correctAnswers}'),
              Text('الإجابات الخاطئة: ${engine.wrongAnswers}'),
              Text('عدد الأسئلة: ${stageQuestions.length}'),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    foregroundColor: navy,
                  ),
                  child: const Text('العودة إلى المراحل'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
