import 'dart:convert';
import 'dart:io';
import 'dart:async';

class RoomManager {
  ServerSocket? _server;
  Socket? _connection;
  final List<Socket> _players = [];

  bool get isHost => _server != null;
  bool get isConnected => _connection != null;

  final StreamController<Map<String, dynamic>> _messages =
      StreamController.broadcast();

  Stream<Map<String, dynamic>> get messages => _messages.stream;

  Future<int> createRoom() async {
    _server = await ServerSocket.bind(
      InternetAddress.anyIPv4,
      4040,
    );

    _server!.listen((socket) {
      _players.add(socket);
      _listenToSocket(socket);
    });

    return _server!.port;
  }

  Future<void> joinRoom(String address) async {
    _connection = await Socket.connect(
      address,
      4040,
      timeout: const Duration(seconds: 10),
    );

    _listenToSocket(_connection!);
  }

  void _listenToSocket(Socket socket) {
    socket
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((data) {
      try {
        final message = jsonDecode(data);
        if (message is Map<String, dynamic>) {
          _messages.add(message);
        }
      } catch (_) {}
    }, onDone: () {
      if (socket == _connection) {
        _connection = null;
      }
      _players.remove(socket);
    });
  }

  void sendToHost(Map<String, dynamic> data) {
    if (_connection != null) {
      _connection!.write('${jsonEncode(data)}\n');
    }
  }

  void broadcast(Map<String, dynamic> data) {
    final message = '${jsonEncode(data)}\n';

    for (final player in List<Socket>.from(_players)) {
      player.write(message);
    }
  }

  Future<void> closeRoom() async {
    for (final player in _players) {
      await player.close();
    }

    _players.clear();

    await _connection?.close();
    _connection = null;

    await _server?.close();
    _server = null;
  }

  Future<void> dispose() async {
    await closeRoom();
    await _messages.close();
  }
}
