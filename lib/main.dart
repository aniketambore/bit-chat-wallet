import 'package:bit_chat_wallet/splashscreen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const BitChatWalletApp());
}

class BitChatWalletApp extends StatefulWidget {
  const BitChatWalletApp({super.key});

  @override
  State<BitChatWalletApp> createState() => _BitChatWalletAppState();
}

class _BitChatWalletAppState extends State<BitChatWalletApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.purple,
        ).copyWith(
          background: Colors.white,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
