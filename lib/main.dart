import 'package:bit_chat_wallet/bdk_api/bdk_api.dart';
import 'package:bit_chat_wallet/contacts_storage/contacts_storage.dart';
import 'package:bit_chat_wallet/nostr_api/nostr_api.dart';
import 'package:bit_chat_wallet/splashscreen.dart';
import 'package:bit_chat_wallet/wallet_repository/wallet_repository.dart';
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
  final WalletRepository _walletRepository = WalletRepository(
    bdkApi: BDKApi(),
    nostrApi: NostrApi(),
    contactStorage: ContactStorage(),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.indigo,
        ).copyWith(
          background: Colors.white,
        ),
      ),
      home: SplashScreen(
        walletRepository: _walletRepository,
      ),
    );
  }
}
