import 'dart:async';
import 'package:flutter/material.dart';
import 'room_manager.dart';

class MultiplayerPage extends StatefulWidget {
  const MultiplayerPage({super.key});

  @override
  State<MultiplayerPage> createState() => _MultiplayerPageState();
}

class _MultiplayerPageState extends State<MultiplayerPage> {
  final RoomManager room = RoomManager();
  final TextEditingController addressController =
      TextEditingController();
  final TextEditingController messageController =
      TextEditingController();

  final List<String> chatMessages = [];
  StreamSubscription<String>? messageSubscription;

  String status = 'اختر طريقة اللعب';
  String roomAddress = '';
  bool loading = false;
  bool connected = false;

  @override
  void initState() {
    super.initState();

    messageSubscription = room.messages.listen((message) {
      if (!mounted) return;
      setState(() {
        chatMessages.add(message);
      });
    });
  }

  Future<void> createRoom() async {
    setState(() {
      loading = true;
      status = 'جارٍ إنشاء الغرفة...';
    });

    try {
      await room.createRoom();

      if (!mounted) return;

      setState(() {
        roomAddress = '${room.hostIp ?? 'IP غير متاح'}:${room.port}';
        status = 'تم إنشاء الغرفة بنجاح';
        connected = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        status = 'تعذر إنشاء الغرفة: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> joinRoom() async {
    final address = addressController.text.trim();

    if (address.isEmpty) {
      setState(() {
        status = 'أدخل عنوان الجهاز المضيف';
      });
      return;
    }

    setState(() {
      loading = true;
      status = 'جارٍ الاتصال...';
    });

    try {
      await room.joinRoom(address);

      if (!mounted) return;

      setState(() {
        connected = true;
        status = 'تم الاتصال بالغرفة';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        status = 'فشل الاتصال، تحقق من العنوان والشبكة';
      });
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  void sendChatMessage() {
    final message = messageController.text.trim();

    if (message.isEmpty || !connected) return;

    room.sendMessage(message);
    messageController.clear();
  }

  @override
  void dispose() {
    messageSubscription?.cancel();
    room.dispose();
    addressController.dispose();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اللعب الجماعي'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            const Icon(
              Icons.wifi,
              size: 90,
              color: Color(0xFFD6AE55),
            ),
            const SizedBox(height: 20),
            const Text(
              'العب مع أصدقائك',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF172442),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'إنشاء غرفة جديدة',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: loading ? null : createRoom,
                      child: const Text('إنشاء غرفة'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF172442),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'الانضمام إلى غرفة',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      hintText: 'مثال: 192.168.1.5:4040',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: loading ? null : joinRoom,
                      child: const Text('انضمام'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFD6AE55),
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Text(
                    status,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                  ),
                  if (roomAddress.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text('عنوان الغرفة:'),
                    SelectableText(roomAddress),
                  ],
                  if (loading) ...[
                    const SizedBox(height: 15),
                    const CircularProgressIndicator(),
                  ],
                  if (connected) ...[
                    const SizedBox(height: 12),
                    const Text('تم الاتصال بالغرفة'),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (connected) ...[
              const Text(
                'محادثة اللاعبين',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 180,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF172442),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.builder(
                  itemCount: chatMessages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(chatMessages[index]),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration: const InputDecoration(
                        hintText: 'اكتب رسالة...',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => sendChatMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: sendChatMessage,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
