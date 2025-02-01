import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class DiskusiRoomScreen extends StatefulWidget {
  final String selectedDay;

  const DiskusiRoomScreen({super.key, required this.selectedDay});

  @override
  _DiskusiRoomScreenState createState() => _DiskusiRoomScreenState();
}

class _DiskusiRoomScreenState extends State<DiskusiRoomScreen> {
  final List<Map<String, dynamic>> messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isEmojiVisible = false;
  late WebSocketChannel _channel;

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  void _connectWebSocket() {
    try {
      // Ganti IP sesuai dengan server WebSocket Anda
      _channel = WebSocketChannel.connect(Uri.parse('ws://10.128.79.146:8080'));

      _channel.stream.listen(
            (message) {
          // Terima pesan dari server dan tambahkan ke daftar pesan
          setState(() {
            messages.add({
              'type': 'text',
              'content': message,
              'sender': 'other', // pesan dari pengguna lain
              'time': DateFormat('HH:mm').format(DateTime.now()),
            });
          });
        },
        onError: (error) {
          print('Error WebSocket: $error');
        },
        onDone: () {
          print('WebSocket terputus');
          // Opsional: Implementasi reconnect di sini
        },
      );
    } catch (e) {
      print('Gagal terhubung ke WebSocket: $e');
    }
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      final messageText = _controller.text;

      // Kirim pesan melalui WebSocket
      _channel.sink.add(messageText);

      setState(() {
        messages.add({
          'type': 'text',
          'content': messageText,
          'sender': 'user',
          'time': DateFormat('HH:mm').format(DateTime.now()),
        });
        _controller.clear();
      });
    }
  }

  @override
  void dispose() {
    _channel.sink.close();
    _controller.dispose();
    super.dispose();
  }

  // Sisanya tetap sama seperti kode asli
  void _toggleEmojiKeyboard() {
    setState(() {
      _isEmojiVisible = !_isEmojiVisible;
    });
  }

  Widget _buildEmojiPicker() {
    return Offstage(
      offstage: !_isEmojiVisible,
      child: SizedBox(
        height: 250,
        child: EmojiPicker(
          onEmojiSelected: (category, emoji) {
            _controller.text += emoji.emoji;
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build method tetap sama seperti kode asli
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Ruang Diskusi',
          style: TextStyle(color: Colors.black, fontSize: 19, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isUser = message['sender'] == 'user';

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment:
                    isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Text(
                        message['time']!,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      if (message['type'] == 'text') ...[
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 8.0,
                          ),
                          decoration: BoxDecoration(
                            color: isUser ? const Color(0xFF85C1E9) : Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black,
                                blurRadius: 2.0,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Text(
                            message['content']!,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ] else if (message['type'] == 'file') ...[
                        // File message container tetap sama
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: isUser ? const Color(0xFF85C1E9) : Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black,
                                blurRadius: 2.0,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.insert_drive_file, color: Colors.black54),
                              const SizedBox(width: 8),
                              Text(
                                message['fileName'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          _buildEmojiPicker(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isEmojiVisible ? Icons.keyboard : Icons.emoji_emotions_outlined,
                    color: Colors.grey,
                  ),
                  onPressed: _toggleEmojiKeyboard,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Ketik pesan...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
