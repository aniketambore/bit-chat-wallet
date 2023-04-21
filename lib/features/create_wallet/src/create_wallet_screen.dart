import 'package:bit_chat_wallet/features/create_wallet/src/create_wallet_cubit.dart';
import 'package:bit_chat_wallet/features/home/home.dart';
import 'package:bit_chat_wallet/wallet_repository/wallet_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateWalletScreen extends StatelessWidget {
  const CreateWalletScreen({
    super.key,
    required this.walletRepository,
  });

  final WalletRepository walletRepository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateWalletCubit>(
      create: (_) => CreateWalletCubit(
        walletRepository: walletRepository,
      ),
      child: CreateWalletView(
        walletRepository: walletRepository,
      ),
    );
  }
}

class CreateWalletView extends StatelessWidget {
  const CreateWalletView({
    super.key,
    required this.walletRepository,
  });
  final WalletRepository walletRepository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/chat.png', width: 150),
            const SizedBox(height: 16),
            const Text(
              'Bit Chat Wallet',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            _CreateWalletForm(
              walletRepository: walletRepository,
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateWalletForm extends StatefulWidget {
  const _CreateWalletForm({required this.walletRepository});
  final WalletRepository walletRepository;

  @override
  State<_CreateWalletForm> createState() => __CreateWalletFormState();
}

class __CreateWalletFormState extends State<_CreateWalletForm> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateWalletCubit, CreateWalletState>(
      listenWhen: (oldState, newState) =>
          oldState.submissionStatus != newState.submissionStatus,
      listener: (context, state) {
        if (state.submissionStatus == SubmissionStatus.success) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                walletRepository: widget.walletRepository,
              ),
            ),
          );
          return;
        }

        if (state.submissionStatus == SubmissionStatus.error) {
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
        final cubit = context.read<CreateWalletCubit>();
        final isSubmissionInProgress =
            state.submissionStatus == SubmissionStatus.inProgress;
        return Column(
          children: [
            isSubmissionInProgress
                ? const Text('Creating Wallet...')
                : ElevatedButton(
                    onPressed: cubit.onCreateWalletSubmit,
                    child: const Text('Create a new wallet'),
                  ),
            const SizedBox(height: 16),
            isSubmissionInProgress
                ? Container()
                : OutlinedButton(
                    onPressed: () {},
                    child: const Text('Recover an existing wallet'),
                  ),
          ],
        );
      },
    );
  }
}
