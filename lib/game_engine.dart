
import 'dart:async';
import 'questions.dart';

class GameEngine {
  final List<Question> questions;
  final int secondsPerQuestion;

  int currentIndex = 0;
  int score = 0;
  int round = 1;
  int correctAnswers = 0;
  int wrongAnswers = 0;
  int remainingSeconds = 15;

  Timer? _timer;
  bool isFinished = false;
  bool hasAnswered = false;

  GameEngine({
    required this.questions,
    this.secondsPerQuestion = 15,
  }) {
    remainingSeconds = secondsPerQuestion > 0
        ? secondsPerQuestion
        : 15;
  }

  Question? get currentQuestion {
    if (questions.isEmpty ||
        currentIndex < 0 ||
        currentIndex >= questions.length) {
      return null;
    }

    return questions[currentIndex];
  }

  double get progress {
    if (questions.isEmpty) return 0;
    return (currentIndex + 1) / questions.length;
  }

  void startTimer({
    required void Function() onTimeUp,
    required void Function(int seconds) onTick,
  }) {
    _timer?.cancel();

    if (isFinished || currentQuestion == null) return;

    remainingSeconds = secondsPerQuestion;
    hasAnswered = false;

    onTick(remainingSeconds);

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (isFinished || hasAnswered) {
          timer.cancel();
          return;
        }

        if (remainingSeconds > 1) {
          remainingSeconds--;
          onTick(remainingSeconds);
        } else {
          remainingSeconds = 0;
          hasAnswered = true;
          wrongAnswers++;

          timer.cancel();
          onTick(0);
          onTimeUp();
        }
      },
    );
  }

  bool answer(int selectedIndex) {
    if (isFinished || hasAnswered) return false;

    final question = currentQuestion;
    if (question == null) return false;

    if (selectedIndex < 0 ||
        selectedIndex >= question.answers.length) {
      return false;
    }

    hasAnswered = true;
    _timer?.cancel();

    final isCorrect =
        selectedIndex == question.correctAnswer;

    if (isCorrect) {
      score += _pointsForDifficulty(
        question.difficulty,
      );
      correctAnswers++;
    } else {
      wrongAnswers++;
    }

    return isCorrect;
  }

  int _pointsForDifficulty(String difficulty) {
    switch (difficulty) {
      case 'سهل':
        return 10;
      case 'متوسط':
        return 20;
      case 'صعب':
        return 30;
      default:
        return 10;
    }
  }

  bool nextQuestion() {
    if (isFinished || !hasAnswered) return false;

    _timer?.cancel();

    if (currentIndex + 1 >= questions.length) {
      finish();
      return false;
    }

    currentIndex++;
    round++;
    remainingSeconds = secondsPerQuestion;
    hasAnswered = false;

    return true;
  }

  void finish() {
    _timer?.cancel();
    isFinished = true;
    hasAnswered = true;
  }

  void reset() {
    _timer?.cancel();

    currentIndex = 0;
    score = 0;
    round = 1;
    correctAnswers = 0;
    wrongAnswers = 0;
    remainingSeconds = secondsPerQuestion;
    isFinished = false;
    hasAnswered = false;
  }

  void dispose() {
    _timer?.cancel();
  }
}
