import 'package:shared_preferences/shared_preferences.dart';

class StageProgress {
  static const int totalStages = 20;
  static const int questionsPerStage = 100;

  final SharedPreferences prefs;

  StageProgress(this.prefs);

  int starsFor(int stage) {
    return prefs.getInt('stage_${stage}_stars') ?? 0;
  }

  bool isUnlocked(int stage) {
    if (stage <= 1) return true;
    return starsFor(stage - 1) > 0;
  }

  int get totalStars {
    int total = 0;
    for (int i = 1; i <= totalStages; i++) {
      total += starsFor(i);
    }
    return total;
  }

  Future<void> saveResult(int stage, int correctAnswers) async {
    int stars = 0;

    if (correctAnswers >= 80) {
      stars = 3;
    } else if (correctAnswers >= 60) {
      stars = 2;
    } else if (correctAnswers >= 40) {
      stars = 1;
    }

    if (stars > starsFor(stage)) {
      await prefs.setInt('stage_${stage}_stars', stars);
    }
  }

  int get unlockedStages {
    int count = 1;
    for (int i = 2; i <= totalStages; i++) {
      if (isUnlocked(i)) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }
}
