
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
  
