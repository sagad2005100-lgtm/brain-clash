import 'questions.dart';

/// بنك أسئلة المراحل في Brain Clash
///
/// المرحلة الأولى تحتوي على 100 سؤال من questions.dart.
/// نضيف بنوك المراحل التالية تباعاً.

class StageQuestions {
  static const int totalStages = 20;
  static const int questionsPerStage = 100;

  static List<Question> getQuestions(int stage) {
    if (stage < 1 || stage > totalStages) {
      return [];
    }

    switch (stage) {
      case 1:
        return questions;
      default:
        return [];
    }
  }

  static bool isReady(int stage) {
    return getQuestions(stage).length >= questionsPerStage;
  }
}
