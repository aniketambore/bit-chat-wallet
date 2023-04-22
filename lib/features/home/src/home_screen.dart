import 'package:bit_chat_wallet/contacts_storage/contacts_storage.dart';
import 'package:bit_chat_wallet/features/home/src/home_cubit.dart';
import 'package:bit_chat_wallet/features/receive_dialog/receive_dialog.dart';
import 'package:bit_chat_wallet/features/secrets/secrets.dart';
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
      child: HomeView(
        walletRepository: walletRepository,
      ),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({
    super.key,
    required this.walletRepository,
  });
  final WalletRepository walletRepository;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HomeCubit>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('BitChat Wallet'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.key_sharp),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SecretsScreen(
                  walletRepository: walletRepository,
                ),
                fullscreenDialog: true,
              ),
            );
          },
        ),
        actions: [
          IconButton(
              onPressed: () {
                walletRepository.clearCache();
              },
              icon: const Icon(Icons.delete)),
        ],
      ),
      body: BlocConsumer<HomeCubit, HomeState>(
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
              ? _HomeContainer(
                  walletRepository: walletRepository,
                  amount: state.balance.total,
                  syncStatus: state.syncStatus,
                  contactsList: state.contactsList,
                  myNostPrivKey: state.nostrPrivKey,
                )
              : const Center(
                  child: CircularProgressIndicator(),
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AddContactDialog(
                addContact: (id, name, npub) =>
                    cubit.addContactSubmit(id, name, npub),
              );
            },
          );
        },
        child: const Icon(
          Icons.contacts_outlined,
        ),
      ),
    );
  }
}

class _HomeContainer extends StatelessWidget {
  const _HomeContainer({
    required this.amount,
    required this.walletRepository,
    required this.syncStatus,
    required this.contactsList,
    required this.myNostPrivKey,
  });

  final int amount;
  final WalletRepository walletRepository;
  final SyncStatus syncStatus;
  final List<ContactCM> contactsList;
  final String myNostPrivKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _BtcWidgetContainer(
            amount: amount,
            walletRepository: walletRepository,
            syncStatus: syncStatus,
          ),
          const SizedBox(height: 26),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Chats',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: contactsList.isEmpty
                ? const Center(
                    child: Text(
                      'No contacts found',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: contactsList.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return ChatListTile(
                        username: contactsList[index].name,
                        receiverNpub: contactsList[index].npub,
                        walletRepository: walletRepository,
                        myNostPrivKey: myNostPrivKey,
                      );
                    },
                    separatorBuilder: (_, __) {
                      return const Divider(
                        thickness: 2,
                        color: Colors.black54,
                      );
                    },
                  ),
          ),
        ],
      ),
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

class ChatListTile extends StatelessWidget {
  final String username; // User username
  final String receiverNpub; // User subtitle
  final WalletRepository walletRepository;
  final String myNostPrivKey;

  const ChatListTile({
    super.key,
    required this.username,
    required this.receiverNpub,
    required this.walletRepository,
    required this.myNostPrivKey,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HomeCubit>();
    final receiverPubKey = cubit.npubToHex(receiverNpub);

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(
            'https://robohash.org/$receiverPubKey?set=set5'), // User avatar image
        radius: 24,
        backgroundColor: Colors.indigo,
      ),
      title: Text(
        username,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        receiverNpub,
        style: const TextStyle(fontSize: 14),
      ),
      onTap: () {
        // TODO: Navigating to ChatScreen
      },
    );
  }
}

class AddContactDialog extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController userNpubController = TextEditingController();
  final Future<void> Function(String id, String name, String npub) addContact;

  AddContactDialog({super.key, required this.addContact});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        constraints: const BoxConstraints(maxWidth: 600),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add Contact',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: userNpubController,
              decoration: const InputDecoration(
                labelText: 'User npub',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                  },
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    String username = usernameController.text;
                    String npub = userNpubController.text;
                    addContact(npub, username, npub);
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
