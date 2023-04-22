import 'dart:collection';

import 'package:bit_chat_wallet/features/chat_screen/src/chat_screen_cubit.dart';
import 'package:bit_chat_wallet/features/chat_screen/src/message_bubble.dart';
import 'package:bit_chat_wallet/wallet_repository/wallet_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_tools/nostr_tools.dart';

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
        walletRepository: walletRepository,
      ),
    );
  }
}

class ChatScreenView extends StatefulWidget {
  const ChatScreenView({
    super.key,
    required this.receiverName,
    required this.receiverPubKey,
    required this.walletRepository,
  });
  final String receiverName;
  final String receiverPubKey;
  final WalletRepository walletRepository;

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
                  walletRepository: widget.walletRepository,
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
    required this.walletRepository,
  });
  final String receiverName;
  final String receiverPubKey;
  final String myPubKey;
  final String myPrivKey;
  final WalletRepository walletRepository;

  @override
  State<_ChatScreenContainer> createState() => __ChatScreenContainerState();
}

class __ChatScreenContainerState extends State<_ChatScreenContainer> {
  final mssgController = TextEditingController();
  final Queue<Message> messages = Queue();
  final ScrollController scrollController = ScrollController();
  final _relay = RelayApi(relayUrl: 'wss://nos.lol');
  late Stream<Event> _stream;
  final nip04 = Nip04();
  final eventApi = EventApi();

  get _scrollController => scrollController.animateTo(
        scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );

  @override
  void initState() {
    super.initState();
    _initStream();
  }

  @override
  void dispose() {
    _relay.close();
    super.dispose();
  }

  Future<Stream<Event>> _connectToRelay() async {
    final stream = await _relay.connect();

    _relay.sub([
      Filter(
        kinds: [4],
        authors: [widget.myPubKey],
        p: [widget.receiverPubKey],
        limit: 100,
      ),
      Filter(
        kinds: [4],
        authors: [widget.receiverPubKey],
        p: [widget.myPubKey],
        limit: 100,
      )
    ]);

    return stream
        .where((message) => message.type == 'EVENT')
        .map((message) => message.message);
  }

  void _initStream() async {
    _stream = await _connectToRelay();
    _stream.listen((message) {
      final event = message;
      if (event.kind == 4) {
        final decryptedMessage = nip04.decrypt(
          widget.myPrivKey,
          widget.receiverPubKey,
          event.content,
        );
        print(decryptedMessage);
        final message = Message(
          time: DateTime.now(),
          text: decryptedMessage,
          isMe: event.pubkey == widget.myPubKey,
          createdAt: event.created_at,
        );
        updateMessagesQueue(message);
      }
    });
  }

  void updateMessagesQueue(Message message) {
    setState(() {
      messages.addFirst(message);
    });
    _scrollController;
  }

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
              final message = messages.elementAt(index);
              return MessageBubble(
                message: message.text,
                isMe: message.isMe,
                createdAt: message.createdAt,
                walletRepository: widget.walletRepository,
              );
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
                        publishMessage(messageToSend);
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

  void publishMessage(String messageToSend) {
    final encryptedMessage = nip04.encrypt(
      widget.myPrivKey,
      widget.receiverPubKey,
      messageToSend,
    );
    final event = eventApi.finishEvent(
      Event(
          kind: 4,
          tags: [
            ['p', widget.receiverPubKey]
          ],
          content: encryptedMessage,
          created_at: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          pubkey: widget.myPubKey),
      widget.myPrivKey,
    );
    if (eventApi.verifySignature(event)) {
      try {
        _relay.publish(event);
      } catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Something went wrong!'),
        ));
      }
    }
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
