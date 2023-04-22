import 'package:bit_chat_wallet/converter/converter.dart';
import 'package:bit_chat_wallet/wallet_repository/wallet_repository.dart';
import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final int createdAt;
  final WalletRepository walletRepository;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
    required this.createdAt,
    required this.walletRepository,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = isMe ? Colors.blue : Colors.grey[300];
    final textColor = isMe ? Colors.white : Colors.black;
    return _buildPlaintextBubble(align, bubbleColor!, textColor);
  }

  Widget _buildPlaintextBubble(
      CrossAxisAlignment align, Color bubbleColor, Color textColor) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            createdAt.timeago(),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            message,
            style: TextStyle(fontSize: 16, color: textColor),
          ),
        ),
      ],
    );
  }
}
