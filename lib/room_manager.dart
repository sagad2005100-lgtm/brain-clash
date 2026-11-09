
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

class RoomManager {
  static const int defaultPort = 4040;

  ServerSocket? _server;
  Socket? _clientSocket;

  final Map<String, Socket> _clients = {};
  final Map<Socket, String> _socketPlayers = {};
  final Map<Socket, StreamSubscription<String>> _subscriptions = {};

  final StreamController<String> _messages =
      StreamController<String>.broadcast();

  String? hostIp;
  String playerId = '';
  String playerName = 'لاعب';
  int port = defaultPort;

  bool isHost = false;
  bool isConnected = false;

  Stream<String> get messages => _messages.stream;

  final Map<String, String> players = {};

  String _generateId() {
    return '${DateTime.now().microsecondsSinceEpoch}'
        '${Random().nextInt(99999)}';
  }

  Future<void> createRoom({
    String name = 'المضيف',
  }) async {
    await _closeConnections();

    playerId = _generateId();
    playerName = name;
    players.clear();
    players[playerId] = playerName;

    port = defaultPort;
    isHost = true;

    _server = await ServerSocket.bind(
      InternetAddress.anyIPv4,
      port,
    );

    isConnected = true;

    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
    );

    hostIp = null;

    for (final interface in interfaces) {
      for (final address in interface.addresses) {
        if (!address.isLoopback && !address.isLinkLocal) {
          hostIp = address.address;
          break;
        }
      }
      if (hostIp != null) break;
    }

    _server!.listen(
      _handleNewClient,
      onError: (_) {
        isConnected = false;
      },
    );
  }

  void _handleNewClient(Socket socket) {
    final subscription = utf8.decoder
        .bind(socket)
        .transform(const LineSplitter())
        .listen(
      (line) => _handleClientMessage(socket, line),
      onDone: () => _removeClient(socket),
      onError: (_) => _removeClient(socket),
      cancelOnError: true,
    );

    _subscriptions[socket] = subscription;
  }

  void _handleClientMessage(Socket socket, String line) {
    try {
      final decoded = jsonDecode(line);

      if (decoded is! Map) return;

      final data = Map<String, dynamic>.from(decoded);
      final type = data['type'];

      if (type == 'hello') {
        final id = data['playerId']?.toString() ?? '';
        final name = data['name']?.toString() ?? 'لاعب';

        if (id.isEmpty) return;

        _clients[id] = socket;
        _socketPlayers[socket] = id;
        players[id] = name;

        _emit({
          'type': 'player_joined',
          'playerId': id,
          'name': name,
        });

        _emit({
          'type': 'players_update',
          'players': players,
        });

        return;
      }

      if (!_socketPlayers.containsKey(socket)) return;

      data['senderId'] = _socketPlayers[socket];
      _emit(data);
    } catch (_) {}
  }

  void _removeClient(Socket socket) {
    final id = _socketPlayers.remove(socket);

    if (id != null) {
      _clients.remove(id);
      players.remove(id);

      if (isHost && isConnected) {
        _emit({
          'type': 'player_left',
          'playerId': id,
        });

        _emit({
          'type': 'players_update',
          'players': players,
        });
      }
    }

    _subscriptions.remove(socket);
    socket.destroy();
  }

  Future<void> joinRoom(
    String address, {
    String name = 'لاعب',
  }) async {
    await _closeConnections();

    final cleanedAddress = address.trim();
    final parts = cleanedAddress.split(':');

    if (parts.length > 2 || parts[0].isEmpty) {
      throw Exception('عنوان IP غير صحيح');
    }

    final targetPort = parts.length == 2
        ? int.tryParse(parts[1])
        : defaultPort;

    if (targetPort == null ||
        targetPort < 1 ||
        targetPort > 65535) {
      throw Exception('رقم المنفذ غير صحيح');
    }

    playerId = _generateId();
    playerName = name;
    port = targetPort;

    _clientSocket = await Socket.connect(
      parts[0],
      targetPort,
      timeout: const Duration(seconds: 10),
    );

    isHost = false;
    isConnected = true;

    utf8.decoder
        .bind(_clientSocket!)
        .transform(const LineSplitter())
        .listen(
      (line) => _messages.add(line),
      onDone: () {
        isConnected = false;
        _clientSocket = null;
      },
      onError: (_) {
        isConnected = false;
        _clientSocket = null;
      },
      cancelOnError: true,
    );

    _clientSocket!.write(
      '${jsonEncode({
        'type': 'hello',
        'playerId': playerId,
        'name': playerName,
      })}\n',
    );
  }

  void sendEvent(Map<String, dynamic> event) {
    if (!isConnected) return;

    final data = Map<String, dynamic>.from(event);
    data['senderId'] = playerId;

    final encoded = '${jsonEncode(data)}\n';

    if (isHost) {
      _messages.add(jsonEncode(data));

      for (final client in _clients.values.toList()) {
        try {
          client.write(encoded);
        } catch (_) {}
      }
    } else {
      _clientSocket?.write(encoded);
    }
  }

  void sendMessage(String message) {
    if (message.trim().isEmpty) return;

    sendEvent({
      'type': 'chat',
      'message': message.trim(),
    });
  }

  void _emit(Map<String, dynamic> event) {
    final encoded = '${jsonEncode(event)}\n';

    _messages.add(jsonEncode(event));

    for (final client in _clients.values.toList()) {
      try {
        client.write(encoded);
      } catch (_) {}
    }
  }

  Future<void> _closeConnections() async {
    isConnected = false;
    isHost = false;

    for (final subscription in _subscriptions.values.toList()) {
      await subscription.cancel();
    }

    _subscriptions.clear();

    for (final client in _clients.values.toList()) {
      client.destroy();
    }

    _clients.clear();
    _socketPlayers.clear();
    players.clear();

    await _clientSocket?.close();
    _clientSocket = null;

    await _server?.close();
    _server = null;

    hostIp = null;
  }

  void dispose() {
    unawaited(_disposeAsync());
  }

  Future<void> _disposeAsync() async {
    await _closeConnections();

    if (!_messages.isClosed) {
      await _messages.close();
    }
  }
                    }
                    
