import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'room_manager.dart';
import 'questions.dart';

class MultiplayerPage extends StatefulWidget {
  const MultiplayerPage({super.key});

  @override
  State<MultiplayerPage> createState() => _MultiplayerPageState();
}

class _MultiplayerPageState extends State<MultiplayerPage> {
  final RoomManager room = RoomManager();

  final TextEditingController addressController =
      TextEditingController();

  final TextEditingController nameController =
      TextEditingController();

  StreamSubscription<String>? subscription;

  final Map<String, int> scores = {};
  final Map<String, int> correctAnswers = {};
  final Map<String, int> answers = {};

  String status = 'اختر طريقة اللعب';
  String roomAddress = '';
  String questionText = '';
  String category = '';
  String playerName = 'لاعب';

  int questionIndex = 0;
  int remainingSeconds = 15;
  int? selectedAnswer;

  bool loading = false;
  bool connected = false;
  bool gameStarted = false;
  bool answered = false;
  bool questionEnded = false;
  bool gameFinished = false;

  Timer? timer;

  @override
  void initState() {
    super.initState();

    subscription = room.messages.listen(_handleMessage);
  }

  void _handleMessage(String raw) {
    try {
      final data = jsonDecode(raw);
      if (data is! Map) return;

      final event = Map<String, dynamic>.from(data);

      if (!mounted) return;

      setState(() {
        switch (event['type']) {
          case 'players_update':
            final list = event['players'];
            if (list is Map) {
              for (final entry in list.entries) {
                scores.putIfAbsent(entry.key.toString(), () => 0);
                correctAnswers.putIfAbsent(entry.key.toString(), () => 0);
              }
            }
            break;

          case 'player_joined':
            status = 'انضم لاعب جديد: ${event['name']}';
            break;

          case 'player_left':
            status = 'غادر لاعب الغرفة';
            break;

          case 'chat':
            status = '${event['message']}';
            break;

          case 'game_start':
            gameStarted = true;
            gameFinished = false;
            questionIndex = 0;
            scores.clear();
            correctAnswers.clear();
            answers.clear();
            break;

          case 'new_question':
            questionIndex = event['index'] as int;
            questionText = event['question'] as String;
            category = event['category'] as String;
            remainingSeconds = 15;
            selectedAnswer = null;
            answered = false;
            questionEnded = false;
            gameStarted = true;
            break;

          case 'answer_result':
            final id = event['playerId'].toString();
            scores[id] = event['score'] as int;
            correctAnswers[id] = event['correct'] as int;
            break;

          case 'question_end':
            questionEnded = true;
            timer?.cancel();
            break;

          case 'game_end':
            gameFinished = true;
            gameStarted = false;
            timer?.cancel();
            status = 'انتهت اللعبة';
            break;
        }
      });

      if (event['type'] == 'new_question') {
        _startTimer();
      }
    } catch (_) {}
  }

  Future<void> createRoom() async {
    setState(() {
      loading = true;
      status = 'جارٍ إنشاء الغرفة...';
    });

    try {
      await room.createRoom(name: _name());

      if (!mounted) return;

      setState(() {
        connected = true;
        roomAddress = '${room.hostIp ?? 'IP غير متاح'}:${room.port}';
        status = 'الغرفة جاهزة لاستقبال اللاعبين';
        scores[room.playerId] = 0;
        correctAnswers[room.playerId] = 0;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => status = 'فشل إنشاء الغرفة: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> joinRoom() async {
    setState(() {
      loading = true;
      status = 'جارٍ الاتصال...';
    });

    try {
      await room.joinRoom(
        addressController.text.trim(),
        name: _name(),
      );

      if (!mounted) return;

      setState(() {
        connected = true;
        status = 'تم الاتصال بالمضيف';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => status = 'فشل الاتصال: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  String _name() {
    final value = nameController.text.trim();
    return value.isEmpty ? 'لاعب' : value;
  }

  void _startGame() {
    if (!room.isHost || !connected || questions.isEmpty) return;

    scores.clear();
    correctAnswers.clear();
    answers.clear();

    scores[room.playerId] = 0;
    correctAnswers[room.playerId] = 0;

    room.sendEvent({'type': 'game_start'});

    _sendQuestion(0);
  }

  void _sendQuestion(int index) {
    if (index >= questions.length) {
      _finishGame();
      return;
    }

    final question = questions[index];

    room.sendEvent({
      'type': 'new_question',
      'index': index,
      'question': question.question,
      'category': question.category,
      'answers': question.answers,
    });

    setState(() {
      questionIndex = index;
      questionText = question.question;
      category = question.category;
      selectedAnswer = null;
      answered = false;
      questionEnded = false;
      remainingSeconds = 15;
    });

    _startTimer();
  }

  void _startTimer() {
    timer?.cancel();

    if (!room.isHost && !gameStarted) return;

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted || questionEnded || answered) {
        t.cancel();
        return;
      }

      if (remainingSeconds > 0) {
        setState(() => remainingSeconds--);
      } else {
        t.cancel();

        if (room.isHost) {
          _endQuestion();
        } else {
          setState(() {
            answered = true;
            questionEnded = true;
          });
        }
      }
    });
  }

  void _answer(int index) {
    if (answered || questionEnded || !gameStarted) return;

    final question = questions[questionIndex];
    final correct = index == question.correctAnswer;

    setState(() {
      selectedAnswer = index;
      answered = true;
    });

    room.sendEvent({
      'type': 'player_answer',
      'playerId': room.playerId,
      'index': index,
      'correct': correct,
      'questionIndex': questionIndex,
    });

    if (room.isHost) {
      _recordAnswer(room.playerId, correct, question.difficulty);
    }
  }

  void _recordAnswer(
    String id,
    bool correct,
    String difficulty,
  ) {
    if (answers.containsKey(id)) return;

    answers[id] = correct ? 1 : 0;

    if (correct) {
      scores[id] = (scores[id] ?? 0) + _points(difficulty);
      correctAnswers[id] = (correctAnswers[id] ?? 0) + 1;
    }

    room.sendEvent({
      'type': 'answer_result',
      'playerId': id,
      'score': scores[id] ?? 0,
      'correct': correctAnswers[id] ?? 0,
    });

    if (room.isHost && answers.length >= room.players.length) {
      _endQuestion();
    }
  }

  int _points(String difficulty) {
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

  void _endQuestion() {
    if (!room.isHost || questionEnded) return;

    timer?.cancel();

    room.sendEvent({'type': 'question_end'});

    setState(() {
      questionEnded = true;
    });
  }

  void _nextQuestion() {
    if (!room.isHost || !questionEnded) return;

    _sendQuestion(questionIndex + 1);
  }

  void _finishGame() {
    timer?.cancel();

    room.sendEvent({'type': 'game_end'});

    setState(() {
      gameFinished = true;
      gameStarted = false;
    });
  }

  String _winner() {
    if (correctAnswers.isEmpty) return 'لا يوجد فائز';

    final sorted = correctAnswers.entries.toList()
      ..sort((a, b) {
        final comparison = b.value.compareTo(a.value);
        if (comparison != 0) return comparison;

        return (scores[b.key] ?? 0).compareTo(scores[a.key] ?? 0);
      });

    final id = sorted.first.key;

    if (id == room.playerId) return '${room.playerName}';

    return 'الفائز: $id';
  }

  @override
  void dispose() {
    timer?.cancel();
    subscription?.cancel();
    room.dispose();
    addressController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('صراع العقول - اللعب الجماعي'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: gameFinished
            ? _result()
            : gameStarted
                ? _game()
                : _lobby(),
      ),
    );
  }

  Widget _lobby() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Icon(
          Icons.wifi,
          size: 85,
          color: Color(0xFFD6AE55),
        ),
        const SizedBox(height: 15),
        const Text(
          'العب مع أصدقائك',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'اسم اللاعب',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 15),
        ElevatedButton(
          onPressed: loading || connected ? null : createRoom,
          child: const Text('إنشاء غرفة'),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: addressController,
          decoration: const InputDecoration(
            labelText: 'عنوان IP',
            hintText: '192.168.1.5:4040',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: loading || connected ? null : joinRoom,
          child: const Text('انضمام إلى غرفة'),
        ),
        const SizedBox(height: 20),
        Text(status, textAlign: TextAlign.center),
        if (roomAddress.isNotEmpty) ...[
          const SizedBox(height: 10),
          const Text('عنوان الغرفة', textAlign: TextAlign.center),
          SelectableText(roomAddress, textAlign: TextAlign.center),
        ],
        if (connected) ...[
          const SizedBox(height: 20),
          const Text(
            'اللاعبون المتصلون',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          ...room.players.entries.map(
            (entry) => ListTile(
              leading: const Icon(Icons.person),
              title: Text(entry.value),
            ),
          ),
          if (room.isHost)
            ElevatedButton(
              onPressed: _startGame,
              child: const Text('ابدأ اللعبة'),
            ),
        ],
      ],
    );
  }

  Widget _game() {
    final question = questions[questionIndex];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'السؤال ${questionIndex + 1} من ${questions.length}',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'الوقت: $remainingSeconds ثانية',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFD6AE55),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            category,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFD6AE55)),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF172442),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFD6AE55)),
            ),
            child: Text(
              questionText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(question.answers.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ElevatedButton(
                onPressed: answered || questionEnded
                    ? null
                    : () => _answer(index),
                child: Text(question.answers[index]),
              ),
            );
          }),
          const Spacer(),
          if (answered)
            const Text(
              'تم إرسال إجابتك',
              textAlign: TextAlign.center,
            ),
          if (questionEnded && room.isHost)
            ElevatedButton(
              onPressed: _nextQuestion,
              child: const Text('السؤال التالي'),
            ),
          if (questionEnded && !room.isHost)
            const Text(
              'بانتظار المضيف...',
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Widget _result() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.emoji_events,
              size: 90,
              color: Color(0xFFD6AE55),
            ),
            const SizedBox(height: 20),
            const Text(
              'انتهت اللعبة!',
              style: TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 15),
            Text(_winner()),
            const SizedBox(height: 20),
            ...correctAnswers.entries.map(
              (entry) => Text(
                '${entry.key}: ${entry.value} إجابة صحيحة - ${scores[entry.key] ?? 0} نقطة',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
