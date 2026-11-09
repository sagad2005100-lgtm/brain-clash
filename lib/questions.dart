class Question {
  final String question;
  final List<String> answers;
  final int correctAnswer;
  final String category;
  final String difficulty;

  const Question({
    required this.question,
    required this.answers,
    required this.correctAnswer,
    required this.category,
    required this.difficulty,
  });
}

const List<Question> questions = [
  Question(
    question: 'ما هي عاصمة العراق؟',
    answers: ['بغداد', 'البصرة', 'الموصل', 'أربيل'],
    correctAnswer: 0,
    category: 'جغرافيا',
    difficulty: 'سهل',
  ),
  Question(
    question: 'كم عدد كواكب المجموعة الشمسية؟',
    answers: ['7', '8', '9', '10'],
    correctAnswer: 1,
    category: 'علوم',
    difficulty: 'سهل',
  ),
  Question(
    question: 'ما هو أكبر محيط في العالم؟',
    answers: ['الأطلسي', 'الهندي', 'الهادئ', 'المتجمد'],
    correctAnswer: 2,
    category: 'جغرافيا',
    difficulty: 'سهل',
  ),
  Question(
    question: 'ما هو الكوكب الأحمر؟',
    answers: ['الزهرة', 'المريخ', 'المشتري', 'زحل'],
    correctAnswer: 1,
    category: 'علوم',
    difficulty: 'سهل',
  ),
  Question(
    question: 'كم عدد أضلاع المثلث؟',
    answers: ['2', '3', '4', '5'],
    correctAnswer: 1,
    category: 'رياضيات',
    difficulty: 'سهل',
  ),
  Question(
    question: 'ما هو أسرع حيوان بري؟',
    answers: ['الأسد', 'الفهد', 'الحصان', 'النمر'],
    correctAnswer: 1,
    category: 'علوم',
    difficulty: 'سهل',
  ),
  Question(
    question: 'ما هي عاصمة اليابان؟',
    answers: ['بكين', 'سيول', 'طوكيو', 'بانكوك'],
    correctAnswer: 2,
    category: 'جغرافيا',
    difficulty: 'متوسط',
  ),
  Question(
    question: 'من رسم لوحة الموناليزا؟',
    answers: ['بيكاسو', 'فان غوخ', 'ليوناردو دافنشي', 'مونيه'],
    correctAnswer: 2,
    category: 'فن',
    difficulty: 'متوسط',
  ),
  Question(
    question: 'ما هو العنصر الكيميائي الذي رمزه O؟',
    answers: ['الذهب', 'الأكسجين', 'الحديد', 'الفضة'],
    correctAnswer: 1,
    category: 'علوم',
    difficulty: 'سهل',
  ),
  Question(
    question: 'كم عدد قارات العالم؟',
    answers: ['5', '6', '7', '8'],
    correctAnswer: 2,
    category: 'جغرافيا',
    difficulty: 'سهل',
  ),
  Question(
    question: 'ما هو أكبر كوكب في المجموعة الشمسية؟',
    answers: ['الأرض', 'زحل', 'المشتري', 'نبتون'],
    correctAnswer: 2,
    category: 'علوم',
    difficulty: 'متوسط',
  ),
  Question(
    question: 'ما هو الحيوان الذي يُلقب بسفينة الصحراء؟',
    answers: ['الحصان', 'الجمل', 'الفيل', 'الغزال'],
    correctAnswer: 1,
    category: 'معلومات عامة',
    difficulty: 'سهل',
  ),
  Question(
    question: 'ما هي اللغة الرسمية في البرازيل؟',
    answers: ['الإسبانية', 'الإنجليزية', 'البرتغالية', 'الفرنسية'],
    correctAnswer: 2,
    category: 'جغرافيا',
    difficulty: 'متوسط',
  ),
  Question(
    question: 'كم يساوي 12 × 12؟',
    answers: ['124', '144', '132', '154'],
    correctAnswer: 1,
    category: 'رياضيات',
    difficulty: 'متوسط',
  ),
  Question(
    question: 'ما هو العضو المسؤول عن ضخ الدم؟',
    answers: ['الرئة', 'الكبد', 'القلب', 'الكلى'],
    correctAnswer: 2,
    category: 'علوم',
    difficulty: 'سهل',
  ),
];
