import 'dart:convert';

import 'package:bit_chat_wallet/converter/converter.dart';
import 'package:bit_chat_wallet/features/send_dialog/send_dialog.dart';
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

    if (message.startsWith('{')) {
      try {
        final jsonMessage = json.decode(message);
        final amount = jsonMessage['amount'] as int?;
        final transactionMessage = jsonMessage['message'] as String?;
        final address = jsonMessage['address'] as String?;
        if (amount != null && transactionMessage != null && address != null) {
          return TransactionBubble(
            amount: amount,
            transactionMessage: transactionMessage,
            address: address,
            isMe: isMe,
            createdAt: createdAt,
            walletRepository: walletRepository,
          );
        }
      } catch (e) {
        return _buildPlaintextBubble(align, bubbleColor!, textColor);
      }
    }
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

class TransactionBubble extends StatelessWidget {
  final int amount;
  final String transactionMessage;
  final String address;
  final bool isMe;
  final int createdAt;
  final WalletRepository walletRepository;

  const TransactionBubble({
    Key? key,
    required this.amount,
    required this.transactionMessage,
    required this.address,
    required this.isMe,
    required this.createdAt,
    required this.walletRepository,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = isMe ? Colors.green : Colors.grey[300];
    final textColor = isMe ? Colors.white : Colors.black;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Requested $amount SATS',
                style: TextStyle(fontSize: 16, color: textColor),
              ),
              const SizedBox(height: 8),
              Text(
                'Message: $transactionMessage',
                style: TextStyle(fontSize: 16, color: textColor),
              ),
              const SizedBox(height: 8),
              Text(
                'Address: $address',
                style: TextStyle(fontSize: 16, color: textColor),
              ),
              const SizedBox(height: 8),
              isMe
                  ? Container()
                  : ElevatedButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) => SendBTCDialog(
                                  walletRepository: walletRepository,
                                  amountToSend: amount.toString(),
                                  addressToSend: address,
                                ));
                      },
                      child: const Text('Send Requested Coins'),
                    ),
            ],
          ),
        ),
      ],
    );
  }
}
