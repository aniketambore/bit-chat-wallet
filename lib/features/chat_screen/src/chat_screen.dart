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
              ? _ChatScreenContainer(
                  receiverName: widget.receiverName,
                  receiverPubKey: widget.receiverPubKey,
                  myPrivKey: state.myPrivKey,
                  myPubKey: state.myPubKey,
                )
              : const Center(
                  child: CircularProgressIndicator(),
                );
        },
      ),
    );
  }
}

class _ChatScreenContainer extends StatefulWidget {
  const _ChatScreenContainer({
    required this.receiverName,
    required this.receiverPubKey,
    required this.myPrivKey,
    required this.myPubKey,
  });
  final String receiverName;
  final String receiverPubKey;
  final String myPubKey;
  final String myPrivKey;

  @override
  State<_ChatScreenContainer> createState() => __ChatScreenContainerState();
}

class __ChatScreenContainerState extends State<_ChatScreenContainer> {
  final mssgController = TextEditingController();
  final List<Message> messages = [];
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: ListView.builder(
            reverse: true,
            controller: scrollController,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              return Container();
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: mssgController,
                  decoration: const InputDecoration(
                    hintText: 'Type your message',
                    border: InputBorder.none,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      // TODO: Request BTC Dialog
                    },
                    icon: const Icon(Icons.currency_bitcoin_outlined),
                  ),
                  IconButton(
                    onPressed: () {
                      final messageToSend = mssgController.text.trim();
                      if (messageToSend.isNotEmpty) {
                        // TODO: Publish Message to Relays
                        mssgController.clear();
                      }
                    },
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class Message {
  final DateTime time;
  final String text;
  final bool isMe;
  final int createdAt;

  Message({
    required this.time,
    required this.text,
    required this.isMe,
    required this.createdAt,
  });
}
