import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'api_service.dart';
import 'app_colors.dart';
import 'chat_bubble.dart';
import 'message_model.dart';
import '../widgets/owl_character.dart';


class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _api = const ApiService();
  final List<Message> _messages = [
    Message(
      text:
          "Hello there! I'm thrilled to meet you and help you navigate the world of stocks and investing.\nWhat would you like to talk about today?",
      sender: Sender.bot,
    )
  ];
  bool _isTyping = false;

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(Message(text: text, sender: Sender.user));
      _isTyping = true;
    });
    _controller.clear();

    try {
      final reply = await _api.sendMessage(text);
      setState(() => _messages.add(Message(text: reply, sender: Sender.bot)));
    } catch (e) {
      setState(() => _messages.add(Message(
            text: '❌ Connection error: $e',
            sender: Sender.bot,
          )));
    } finally {
      if (mounted) setState(() => _isTyping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const OwlCharacter(size: 28.0, isAnimated: true),
            const SizedBox(width: 8),
            const Text('StockWise AI'),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: ChatBubble(message: _messages[i]),
              ),
            ),
          ),
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: SpinKitThreeBounce(
                color: AppColors.primary,
                size: 20.0,
              ),
            ),
          _inputArea(),
        ],
      ),
    );
  }

  Widget _inputArea() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Ask about stocks...',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onSubmitted: (_) => _send(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send, color: AppColors.primary),
            onPressed: _send,
          ),
        ],
      ),
    );
  }
}
