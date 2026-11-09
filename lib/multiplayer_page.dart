
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
  Timer? timer;

  final Map<String, int> scores = {};
  final Map<String, int> correctAnswers = {};
  final Map<String, int> answers = {};
  final Map<String, String> playerNames = {};

  String status = 'اختر طريقة اللعب';
  String roomAddress = '';
  String questionText = '';
  String category = '';

  int questionIndex = 0;
  int remainingSeconds = 15;
  int? selectedAnswer;

  bool loading = false;
  bool connected = false;
  bool gameStarted = false;
  bool answered = false;
  bool questionEnded = false;
  bool gameFinished = false;

  @override
  void initState() {
    super.initState();
    subscription = room.messages.listen(_handleMessage);
  }

  String _name() {
    final value = nameController.text.trim();
    return value.isEmpty ? 'لاعب' : value;
  }

  void _handleMessage(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;

      final event = Map<String, dynamic>.from(decoded);
      final type = event['type'];

      if (type == 'player_answer') {
        _receiveAnswer(event);
        return;
      }

      if (!mounted) return;

      setState(() {
        switch (type) {
          case 'players_update':
            final list = event['players'];

            if (list is Map) {
              playerNames.clear();

              for (final entry in list.entries) {
                final id = entry.key.toString();
                playerNames[id] = entry.value.toString();
                scores.putIfAbsent(id, () => 0);
                correctAnswers.putIfAbsent(id, () => 0);
              }
            }
            break;

          case 'player_joined':
            status = 'انضم لاعب جديد: ${event['name']}';
            break;

          case 'player_left':
            playerNames.remove(event['playerId']?.toString());
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

            for (final id in playerNames.keys) {
              scores[id] = 0;
              correctAnswers[id] = 0;
            }
            break;

          case 'new_question':
            final index = event['index'];

            if (index is! int ||
                index < 0 ||
                index >= questions.length) {
              break;
            }

            questionIndex = index;
            questionText = event['question']?.toString() ?? '';
            category = event['category']?.toString() ?? '';
            remainingSeconds = 15;
            selectedAnswer = null;
            answered = false;
            questionEnded = false;
            answers.clear();
            gameStarted = true;
            break;

          case 'answer_result':
            final id = event['playerId']?.toString() ?? '';
            final score = event['score'];
            final correct = event['correct'];

            if (id.isNotEmpty &&
                score is int &&
                correct is int) {
              scores[id] = score;
              correctAnswers[id] = correct;
            }
            break;

          case 'question_end':
            questionEnded = true;
            remainingSeconds = 0;
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

      if (type == 'new_question') {
        _startTimer();
      }
    } catch (e) {
      debugPrint('Message error: $e');
    }
  }

  void _receiveAnswer(Map<String, dynamic> event) {
    if (!room.isHost ||
        !gameStarted ||
        questionEnded) {
      return;
    }

    final id = event['senderId']?.toString();
    final index = event['index'];
    final receivedQuestion = event['questionIndex'];

    if (id == null ||
        id.isEmpty ||
        !room.players.containsKey(id) ||
        index is! int ||
        receivedQuestion != questionIndex ||
        questionIndex < 0 ||
        questionIndex >= questions.length ||
        index < 0 ||
        index >= questions[questionIndex].answers.length) {
      return;
    }

    final question = questions[questionIndex];
    final correct = index == question.correctAnswer;

    _recordAnswer(id, correct, question.difficulty);
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
        roomAddress =
            '${room.hostIp ?? 'IP غير متاح'}:${room.port}';
        status = 'الغرفة جاهزة لاستقبال اللاعبين';

        playerNames[room.playerId] = room.playerName;
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
  void _startGame() {
    if (!room.isHost ||
        !connected ||
        questions.isEmpty) {
      return;
    }

    scores.clear();
    correctAnswers.clear();
    answers.clear();

    for (final entry in room.players.entries) {
      playerNames[entry.key] = entry.value;
      scores[entry.key] = 0;
      correctAnswers[entry.key] = 0;
    }

    room.sendEvent({'type': 'game_start'});
    _sendQuestion(0);
  }

  void _sendQuestion(int index) {
    if (!room.isHost) return;

    if (index >= questions.length) {
      _finishGame();
      return;
    }

    final question = questions[index];

    timer?.cancel();
    answers.clear();

    setState(() {
      questionIndex = index;
      questionText = question.question;
      category = question.category;
      selectedAnswer = null;
      answered = false;
      questionEnded = false;
      remainingSeconds = 15;
    });

    room.sendEvent({
      'type': 'new_question',
      'index': index,
      'question': question.question,
      'category': question.category,
      'answers': question.answers,
    });

    _startTimer();
  }

  void _startTimer() {
    timer?.cancel();

    if (!gameStarted || questionEnded) return;

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (t) {
        if (!mounted || questionEnded || !gameStarted) {
          t.cancel();
          return;
        }

        if (remainingSeconds > 0) {
          setState(() {
            remainingSeconds--;
          });
        } else {
          t.cancel();

          if (room.isHost) {
            _endQuestion();
          }
        }
      },
    );
  }

  void _answer(int index) {
    if (answered ||
        questionEnded ||
        !gameStarted ||
        questionIndex >= questions.length) {
      return;
    }

    setState(() {
      selectedAnswer = index;
      answered = true;
    });

    room.sendEvent({
      'type': 'player_answer',
      'playerId': room.playerId,
      'index': index,
      'questionIndex': questionIndex,
    });

    if (room.isHost) {
      final question = questions[questionIndex];

      _recordAnswer(
        room.playerId,
        index == question.correctAnswer,
        question.difficulty,
      );
    }
  }

  void _recordAnswer(
    String id,
    bool correct,
    String difficulty,
  ) {
    if (!room.isHost ||
        answers.containsKey(id) ||
        questionEnded) {
      return;
    }

    answers[id] = correct ? 1 : 0;

    scores.putIfAbsent(id, () => 0);
    correctAnswers.putIfAbsent(id, () => 0);

    if (correct) {
      scores[id] =
          (scores[id] ?? 0) + _points(difficulty);

      correctAnswers[id] =
          (correctAnswers[id] ?? 0) + 1;
    }

    room.sendEvent({
      'type': 'answer_result',
      'playerId': id,
      'score': scores[id] ?? 0,
      'correct': correctAnswers[id] ?? 0,
    });

    if (mounted) {
      setState(() {});
    }

    if (answers.length >= room.players.length) {
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

    if (!mounted) return;

    setState(() {
      questionEnded = true;
      remainingSeconds = 0;
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
      questionEnded = true;
    });
  }

  List<MapEntry<String, int>> _sortedResults() {
    final results = scores.entries.toList();

    results.sort((a, b) {
      final comparison = (correctAnswers[b.key] ?? 0)
          .compareTo(correctAnswers[a.key] ?? 0);

      if (comparison != 0) return comparison;

      return b.value.compareTo(a.value);
    });

    return results;
  }

  String _playerName(String id) {
    if (id == room.playerId) {
      return room.playerName;
    }

    return playerNames[id] ?? room.players[id] ?? 'لاعب';
  }

  String _winner() {
    final results = _sortedResults();

    if (results.isEmpty) return 'لا يوجد فائز';

    final first = results.first;

    final tied = results.where((entry) {
      return (correctAnswers[entry.key] ?? 0) ==
              (correctAnswers[first.key] ?? 0) &&
          entry.value == first.value;
    }).toList();

    if (tied.length > 1) {
      return 'تعادل: ${tied.map((e) => _playerName(e.key)).join(' و ')}';
    }

    return 'الفائز: ${_playerName(first.key)}';
  }

  @override
  void dispose() {
    timer?.cancel();
    subscription?.cancel();
    room.dispose();
    addressController.dispose();
    nameController.dispose();
    super.dispose();
  }  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101827),
      appBar: AppBar(
        title: const Text('صراع العقول'),
        centerTitle: true,
        backgroundColor: const Color(0xFF17243A),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: gameFinished
              ? _result()
              : gameStarted
                  ? _game()
                  : _lobby(),
        ),
      ),
    );
  }

  Widget _lobby() {
    return ListView(
      children: [
        const SizedBox(height: 20),
        const Icon(
          Icons.psychology,
          size: 85,
          color: Color(0xFFFFC857),
        ),
        const SizedBox(height: 15),
        const Text(
          'صراع العقول',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          status,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 25),
        TextField(
          controller: nameController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'اسم اللاعب',
            labelStyle: TextStyle(color: Colors.white70),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 15),
        if (!connected) ...[
          ElevatedButton(
            onPressed: loading ? null : createRoom,
            child: const Text('إنشاء غرفة'),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: addressController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'عنوان الغرفة IP:PORT',
              labelStyle: TextStyle(color: Colors.white70),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: loading ? null : joinRoom,
            child: const Text('الانضمام إلى غرفة'),
          ),
        ],
        if (loading)
          const Padding(
            padding: EdgeInsets.all(15),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (connected) ...[
          const SizedBox(height: 20),
          const Text(
            'عنوان الغرفة',
            style: TextStyle(color: Colors.white70),
          ),
          SelectableText(
            roomAddress,
            style: const TextStyle(
              color: Color(0xFFFFC857),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'اللاعبون المتصلون',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ...room.players.entries.map((entry) {
            return Card(
              color: const Color(0xFF1D2B43),
              child: ListTile(
                leading: const Icon(
                  Icons.person,
                  color: Color(0xFFFFC857),
                ),
                title: Text(
                  entry.value,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          }),
          if (room.isHost) ...[
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startGame,
              child: const Text('ابدأ اللعب'),
            ),
          ],
        ],
      ],
    );
  }

  Widget _game() {
    if (questionIndex < 0 || questionIndex >= questions.length) {
      return const Center(
        child: Text(
          'جاري تحميل السؤال...',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final question = questions[questionIndex];

    return ListView(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'السؤال ${questionIndex + 1} من ${questions.length}',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              '$remainingSeconds ثانية',
              style: const TextStyle(
                color: Color(0xFFFFC857),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        LinearProgressIndicator(
          value: remainingSeconds / 15,
          backgroundColor: Colors.white12,
          color: const Color(0xFFFFC857),
        ),
        const SizedBox(height: 20),
        Text(
          category,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFFFC857),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 15),
        Card(
          color: const Color(0xFF1D2B43),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Text(
              questionText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ...List.generate(question.answers.length, (index) {
          final isSelected = selectedAnswer == index;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected
                    ? const Color(0xFFFFC857)
                    : const Color(0xFF263957),
                foregroundColor:
                    isSelected ? Colors.black : Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              onPressed: answered || questionEnded
                  ? null
                  : () => _answer(index),
              child: Text(
                question.answers[index],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 17),
              ),
            ),
          );
        }),
        if (answered)
          const Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              'تم إرسال إجابتك',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.greenAccent,
                fontSize: 17,
              ),
            ),
          ),
        if (questionEnded && room.isHost)
          ElevatedButton(
            onPressed: _nextQuestion,
            child: const Text('السؤال التالي'),
          ),
        if (questionEnded && !room.isHost)
          const Text(
            'انتظر المضيف حتى يبدأ السؤال التالي',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
        const SizedBox(height: 25),
        const Text(
          'النتائج الحالية',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        ..._sortedResults().map((entry) {
          return ListTile(
            title: Text(
              _playerName(entry.key),
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              'الإجابات الصحيحة: ${entry.value}',
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: Text(
              '${scores[entry.key] ?? 0} نقطة',
              style: const TextStyle(
                color: Color(0xFFFFC857),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _result() {
    final results = _sortedResults();

    return ListView(
      children: [
        const SizedBox(height: 35),
        const Icon(
          Icons.emoji_events,
          size: 90,
          color: Color(0xFFFFC857),
        ),
        const SizedBox(height: 20),
        const Text(
          'انتهت اللعبة',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          _winner(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFFFC857),
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 30),
        const Text(
          'الترتيب النهائي',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
          ),
        ),
        const SizedBox(height: 15),
        ...List.generate(results.length, (index) {
          final entry = results[index];

          return Card(
            color: const Color(0xFF1D2B43),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFFFC857),
                child: Text('${index + 1}'),
              ),
              title: Text(
                _playerName(entry.key),
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                'الإجابات الصحيحة: ${entry.value}',
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: Text(
                '${scores[entry.key] ?? 0} نقطة',
                style: const TextStyle(
                  color: Color(0xFFFFC857),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
  
  
