
import 'package:shared_preferences/shared_preferences.dart';

class StageProgress {
  static const int totalStages = 20;

  static Future<List<int>> loadStars() async {
    final prefs = await SharedPreferences.getInstance();

    return List.generate(
      totalStages,
      (index) => prefs.getInt('stage_${index + 1}') ?? 0,
    );
  }

  static Future<void> saveStars(int stage, int stars) async {
    if (stage < 1 || stage > totalStages) return;

    final prefs = await SharedPreferences.getInstance();
    final key = 'stage_$stage';

    final oldStars = prefs.getInt(key) ?? 0;
    final newStars = stars.clamp(0, 3);

    if (newStars > oldStars) {
      await prefs.setInt(key, newStars);
    }
  }

  static Future<int> unlockedStage() async {
    final stars = await loadStars();

    int unlocked = 1;

    for (int i = 0; i < stars.length; i++) {
      if (stars[i] > 0) {
        unlocked = i + 2;
      } else {
        break;
      }
    }

    return unlocked.clamp(1, totalStages);
  }

  static int starsForCorrectAnswers(int correct, int total) {
    if (total <= 0) return 0;

    final ratio = correct / total;

    if (ratio >= 0.8) return 3;
    if (ratio >= 0.6) return 2;
    if (ratio >= 0.4) return 1;

    return 0;
  }
}
