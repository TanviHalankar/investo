import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';

import 'app_colors.dart';
import 'message_model.dart';

class ChatBubble extends StatelessWidget {
  final Message message;
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == Sender.user;
    return BubbleSpecialThree(
      text: message.text,
      color: isUser ? AppColors.primary : AppColors.surfaceAlt,
      tail: true,
      textStyle: TextStyle(
        color: isUser ? AppColors.textPrimary : AppColors.textSecondary,
        fontSize: 16,
      ),
      isSender: isUser,
    );
  }
}
