import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';

import 'app_colors.dart';
import 'message_model.dart';
import '../widgets/owl_character.dart';

class ChatBubble extends StatelessWidget {
  final Message message;
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == Sender.user;
    
    if (isUser) {
      // User messages - show on right side
      return BubbleSpecialThree(
        text: message.text,
        color: AppColors.primary,
        tail: true,
        textStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
        isSender: true,
      );
    } else {
      // Bot messages - show owl character on left side
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Owl character avatar
          Padding(
            padding: const EdgeInsets.only(right: 8.0, top: 4.0),
            child: const OwlCharacter(size: 32.0, isAnimated: true),
          ),
          // Bot message bubble
          Flexible(
            child: BubbleSpecialThree(
              text: message.text,
              color: AppColors.surfaceAlt,
              tail: true,
              textStyle: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
              isSender: false,
            ),
          ),
        ],
      );
    }
  }
}
