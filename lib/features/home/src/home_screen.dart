import 'package:bit_chat_wallet/wallet_repository/wallet_repository.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.walletRepository,
  });
  final WalletRepository walletRepository;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Wallet Home Screen'),
      ),
    );
  }
}
