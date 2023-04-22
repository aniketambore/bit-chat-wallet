import 'package:bit_chat_wallet/features/chat_screen/src/chat_screen_cubit.dart';
import 'package:bit_chat_wallet/wallet_repository/wallet_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({
    super.key,
    required this.walletRepository,
    required this.myPrivKey,
    required this.receiverName,
    required this.receiverPubKey,
  });
  final WalletRepository walletRepository;
  final String myPrivKey;
  final String receiverName;
  final String receiverPubKey;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChatScreenCubit>(
      create: (_) => ChatScreenCubit(
        walletRepository: walletRepository,
        myPrivKey: myPrivKey,
      ),
      child: ChatScreenView(
        receiverName: receiverName,
        receiverPubKey: receiverPubKey,
      ),
    );
  }
}

class ChatScreenView extends StatefulWidget {
  const ChatScreenView({
    super.key,
    required this.receiverName,
    required this.receiverPubKey,
  });
  final String receiverName;
  final String receiverPubKey;

  @override
  State<ChatScreenView> createState() => _ChatScreenViewState();
}

class _ChatScreenViewState extends State<ChatScreenView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                  'https://robohash.org/${widget.receiverPubKey}?set=set5'),
            ),
            const SizedBox(width: 8),
            Text(widget.receiverName),
          ],
        ),
      ),
      body: BlocConsumer<ChatScreenCubit, ChatScreenState>(
        listenWhen: (oldState, newState) =>
            oldState is ChatScreenSuccess && newState is ChatScreenSuccess
                ? oldState.syncStatus != newState.syncStatus
                : false,
        listener: (context, state) {
          if (state is ChatScreenSuccess) {
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
          return state is ChatScreenSuccess
              ? const Center(
                  child: Text('Chat Screen'),
                )
              : const Center(
                  child: CircularProgressIndicator(),
                );
        },
      ),
    );
  }
}
