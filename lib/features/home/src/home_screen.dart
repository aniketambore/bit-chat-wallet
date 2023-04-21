import 'package:bit_chat_wallet/features/home/src/home_cubit.dart';
import 'package:bit_chat_wallet/features/receive_dialog/receive_dialog.dart';
import 'package:bit_chat_wallet/features/send_dialog/send_dialog.dart';
import 'package:bit_chat_wallet/wallet_repository/wallet_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.walletRepository,
  });

  final WalletRepository walletRepository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeCubit>(
      create: (_) => HomeCubit(
        walletRepository: walletRepository,
      ),
      child: _HomeView(
        walletRepository: walletRepository,
      ),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView({
    required this.walletRepository,
  });
  final WalletRepository walletRepository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BitChat Wallet'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.key_sharp),
          onPressed: () {
            // TODO: Navigating to Wallet Secrets screen
          },
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              BtcWidget(
                amount: 0.5,
                walletRepository: walletRepository,
              ),
              // TODO: Some Chat kind of UI
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Showing contacts Dialog
        },
        child: const Icon(
          Icons.contacts_outlined,
        ),
      ),
    );
  }
}

class BtcWidget extends StatefulWidget {
  final double amount;
  final WalletRepository walletRepository;

  const BtcWidget({
    super.key,
    required this.amount,
    required this.walletRepository,
  });

  @override
  State<BtcWidget> createState() => _BtcWidgetState();
}

class _BtcWidgetState extends State<BtcWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listenWhen: (oldState, newState) =>
          oldState is HomeSuccess && newState is HomeSuccess
              ? oldState.syncStatus != newState.syncStatus
              : false,
      listener: (context, state) {
        if (state is HomeSuccess) {
          final hasSubmissionError = state.syncStatus == SyncStatus.error;

          if (hasSubmissionError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('Something went wrong!'),
                ),
              );
          }
        }
      },
      builder: (context, state) {
        return state is HomeSuccess
            ? _BtcWidgetContainer(
                amount: state.balance.total,
                walletRepository: widget.walletRepository,
                syncStatus: state.syncStatus,
              )
            : const Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }
}

class _BtcWidgetContainer extends StatefulWidget {
  const _BtcWidgetContainer({
    required this.amount,
    required this.walletRepository,
    required this.syncStatus,
  });

  final int amount;
  final WalletRepository walletRepository;
  final SyncStatus syncStatus;

  @override
  State<_BtcWidgetContainer> createState() => _BtcWidgetContainerState();
}

class _BtcWidgetContainerState extends State<_BtcWidgetContainer> {
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HomeCubit>();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/bitcoin-symbol.png',
                width: 38,
                height: 38,
              ),
              const SizedBox(width: 8),
              Text(
                '${widget.amount} BTC',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) => SendBTCDialog(
                            walletRepository: widget.walletRepository,
                          ));
                },
                icon: const Icon(Icons.call_made),
                color: Colors.grey[600],
                iconSize: 28,
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => ReceiveAddressDialog(
                      walletRepository: widget.walletRepository,
                    ),
                  );
                },
                icon: const Icon(Icons.call_received),
                color: Colors.grey[600],
                iconSize: 28,
              ),
              const SizedBox(width: 8),
              widget.syncStatus == SyncStatus.inProgress
                  ? const Center(child: CircularProgressIndicator())
                  : IconButton(
                      onPressed: () {
                        cubit.refresh();
                      },
                      icon: const Icon(Icons.refresh),
                      color: Colors.grey[600],
                      iconSize: 28,
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
