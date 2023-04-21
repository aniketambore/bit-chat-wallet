import 'package:bit_chat_wallet/features/secrets/src/secrets_cubit.dart';
import 'package:bit_chat_wallet/wallet_repository/wallet_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SecretsScreen extends StatelessWidget {
  const SecretsScreen({
    super.key,
    required this.walletRepository,
  });
  final WalletRepository walletRepository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SecretsCubit>(
      create: (_) => SecretsCubit(
        walletRepository: walletRepository,
      ),
      child: _SecretsView(),
    );
  }
}

class _SecretsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secrets'),
      ),
      body: const _SecretsContent(),
    );
  }
}

class _SecretsContent extends StatefulWidget {
  const _SecretsContent();

  @override
  State<_SecretsContent> createState() => _SecretsContentState();
}

class _SecretsContentState extends State<_SecretsContent> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SecretsCubit, SecretsState>(
      listener: (context, state) {
        final recoverPhraseError =
            state is SecretsSuccess ? state.recoverPhraseError : null;
        if (recoverPhraseError != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('Something went wrong!'),
              ),
            );
        }
      },
      builder: (context, state) {
        return state is SecretsSuccess
            ? secretsSuccessContainer(
                state.mnemonic,
                state.privKeyHex,
                state.pubKeyHex,
                state.privKeyNsec,
                state.pubKeyNpub,
              )
            : const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget secretsSuccessContainer(String recoveryPhrase, String privKeyHex,
      String pubKeyHex, String nsec, String npub) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recovery Phrase:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              recoveryPhrase,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            const Text(
              'Private Key:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              privKeyHex,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            const Text(
              'Public Key:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              pubKeyHex,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            const Text(
              'Private Key (Nsec):',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SelectableText(
              nsec,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            const Text(
              'Public Key (Npub):',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SelectableText(
              npub,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
