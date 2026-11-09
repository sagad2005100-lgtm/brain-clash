
import 'dart:async';
import 'dart:convert';
import 'dart:io';

class RoomManager {
  static const int defaultPort = 4040;

  ServerSocket? _server;
  Socket? _clientSocket;

  final Set<Socket> _clients = {};

  final StreamController<String> _messages =
      StreamController<String>.broadcast();

  String? hostIp;
  int port = defaultPort;

  bool isHost = false;
  bool isConnected = false;

  Stream<String> get messages => _messages.stream;

  // إنشاء غرفة واستقبال اللاعبين
  Future<void> createRoom() async {
    await _closeConnections();

    isHost = true;
    port = defaultPort;

    _server = await ServerSocket.bind(
      InternetAddress.anyIPv4,
      port,
    );

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

    _server!.listen((socket) {
      _clients.add(socket);
      isConnected = true;

      _listenToSocket(socket, (message) {
        _messages.add(message);

        for (final client in _clients) {
          if (client != socket) {
            client.write('${jsonEncode(message)}\n');
          }
        }
      }, () {
        _clients.remove(socket);
        isConnected = _clients.isNotEmpty;
      });
    });
  }

  // الانضمام إلى غرفة باستخدام IP
  Future<void> joinRoom(String address) async {
    await _closeConnections();

    final cleanedAddress = address.trim();
    final parts = cleanedAddress.split(':');

    final host = parts[0];
    final targetPort = parts.length > 1
        ? int.tryParse(parts[1]) ?? defaultPort
        : defaultPort;

    if (targetPort < 1 || targetPort > 65535) {
      throw Exception('عنوان المنفذ غير صحيح');
    }

    _clientSocket = await Socket.connect(
      host,
      targetPort,
      timeout: const Duration(seconds: 10),
    );

    isHost = false;
    isConnected = true;

    _listenToSocket(
      _clientSocket!,
      (message) {
        _messages.add(message);
      },
      () {
        isConnected = false;
        _clientSocket = null;
      },
    );
  }

  // إرسال رسالة إلى اللاعبين
  void sendMessage(String message) {
    if (!isConnected || message.trim().isEmpty) return;

    if (isHost) {
      _messages.add(message);

      for (final client in _clients) {
        client.write('${jsonEncode(message)}\n');
      }
    } else {
      _clientSocket?.write('${jsonEncode(message)}\n');
      _messages.add(message);
    }
  }

  // استقبال الرسائل
  void _listenToSocket(
    Socket socket,
    void Function(String) onMessage,
    void Function() onDisconnect,
  ) {
    socket
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
      (line) {
        try {
          final decoded = jsonDecode(line);
          if (decoded is String) {
            onMessage(decoded);
          }
        } catch (_) {
          onMessage(line);
        }
      },
      onDone: onDisconnect,
      onError: (_) => onDisconnect(),
      cancelOnError: true,
    );
  }

  // إغلاق الاتصالات
  Future<void> _closeConnections() async {
    await _server?.close();
    _server = null;

    for (final client in _clients.toList()) {
      await client.close();
    }

    _clients.clear();

    await _clientSocket?.close();
    _clientSocket = null;

    isConnected = false;
  }

  // إنهاء الغرفة
  void dispose() {
    _closeConnections();
    isHost = false;
    hostIp = null;
  }
}
