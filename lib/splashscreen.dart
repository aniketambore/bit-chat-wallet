import 'dart:async';

import 'package:bit_chat_wallet/features/create_wallet/create_wallet.dart';
import 'package:bit_chat_wallet/features/home/home.dart';
import 'package:bit_chat_wallet/wallet_repository/wallet_repository.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.walletRepository,
  });

  final WalletRepository walletRepository;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Timer(const Duration(milliseconds: 2000), () {
      _walletCheck();
    });
  }

  Future<void> _walletCheck() async {
    final walletMnemonic = await widget.walletRepository.getWalletMnemonic();
    if (walletMnemonic != null) {
      try {
        await widget.walletRepository.recoverWallet(walletMnemonic);
        pushToHome();
      } catch (e) {
        print('Error: [splash_screen.dart | _walletCheck]: $e');
        pushToCreateWallet();
      }
    } else {
      pushToCreateWallet();
    }
  }

  void pushToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          walletRepository: widget.walletRepository,
        ),
      ),
    );
  }

  void pushToCreateWallet() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CreateWalletScreen(
          walletRepository: widget.walletRepository,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Image(
              height: 180,
              image: AssetImage('assets/bitcoin-symbol.png'),
            ),
            Text('Initializing...')
          ],
        ),
      ),
    );
  }
}
