import 'package:bit_chat_wallet/features/receive_dialog/src/receive_address_cubit.dart';
import 'package:bit_chat_wallet/wallet_repository/wallet_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ReceiveAddressDialog extends StatelessWidget {
  const ReceiveAddressDialog({
    super.key,
    required this.walletRepository,
  });
  final WalletRepository walletRepository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReceiveAddressCubit>(
      create: (_) => ReceiveAddressCubit(
        walletRepository: walletRepository,
      ),
      child: const ReceiveAddressView(),
    );
  }
}

class ReceiveAddressView extends StatelessWidget {
  const ReceiveAddressView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReceiveAddressCubit, ReceiveAddressState>(
      listener: (context, state) {
        final receiveAddressError =
            state is ReceiveAddressSuccess ? state.receiveAddressError : null;

        if (receiveAddressError != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('Something went wrong'),
              ),
            );
        }
      },
      builder: (context, state) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Receive Address',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                state is ReceiveAddressSuccess
                    ? _ReceiveAddressDialogContent(
                        receiveAddress: state.receiveAddress)
                    : const Center(child: CircularProgressIndicator())
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ReceiveAddressDialogContent extends StatelessWidget {
  const _ReceiveAddressDialogContent({
    required this.receiveAddress,
  });
  final String receiveAddress;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ReceiveAddressCubit>();
    return Column(
      children: [
        QrImage(
          data: receiveAddress,
          version: QrVersions.auto,
          size: 200.0,
        ),
        const SizedBox(height: 16),
        SelectableText(
          receiveAddress,
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                cubit.refetch();
              },
              child: const Text('Generate New Address'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      ],
    );
  }
}
