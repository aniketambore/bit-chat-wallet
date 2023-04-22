import 'package:bit_chat_wallet/wallet_repository/wallet_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'send_cubit.dart';

class SendBTCDialog extends StatelessWidget {
  const SendBTCDialog({
    super.key,
    required this.walletRepository,
    this.amountToSend,
    this.addressToSend,
  });
  final WalletRepository walletRepository;
  final String? amountToSend;
  final String? addressToSend;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SendCubit>(
      create: (_) => SendCubit(
        walletRepository: walletRepository,
      ),
      child: SendView(
        amountToSend: amountToSend,
        addressToSend: addressToSend,
      ),
    );
  }
}

class SendView extends StatelessWidget {
  const SendView({
    super.key,
    this.amountToSend,
    this.addressToSend,
  });
  final String? amountToSend;
  final String? addressToSend;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Send Bitcoin',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _SendBTCForm(
                amountToSend: amountToSend,
                addressToSend: addressToSend,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SendBTCForm extends StatefulWidget {
  const _SendBTCForm({
    this.amountToSend,
    this.addressToSend,
  });
  final String? amountToSend;
  final String? addressToSend;

  @override
  State<_SendBTCForm> createState() => __SendBTCFormState();
}

class __SendBTCFormState extends State<_SendBTCForm> {
  final TextEditingController recipientController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController feeRateController = TextEditingController();

  bool _isBTCPaidSuccess = false;

  @override
  void initState() {
    if (widget.amountToSend != null && widget.addressToSend != null) {
      setState(() {
        recipientController.text = widget.addressToSend!;
        amountController.text = widget.amountToSend!;
        feeRateController.text = '3';
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SendCubit, SendState>(
      listenWhen: (oldState, newState) =>
          oldState.submissionStatus != newState.submissionStatus,
      listener: (context, state) {
        if (state.submissionStatus == SubmissionStatus.success) {
          setState(() {
            _isBTCPaidSuccess = true;
          });
          return;
        }

        final hasSubmissionError =
            state.submissionStatus == SubmissionStatus.genericError ||
                state.submissionStatus == SubmissionStatus.sendTxError;

        if (hasSubmissionError) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              state.submissionStatus == SubmissionStatus.sendTxError
                  ? const SnackBar(
                      content: Text(
                        'There has been an error while sending transaction.',
                      ),
                    )
                  : const SnackBar(
                      content: Text('Something went wrong!'),
                    ),
            );
        }
      },
      builder: (context, state) {
        final cubit = context.read<SendCubit>();
        final isSubmissionInProgress =
            state.submissionStatus == SubmissionStatus.inProgress;
        return _isBTCPaidSuccess
            ? const _SuccessIndicatorContent()
            : Column(
                children: [
                  TextField(
                    controller: recipientController,
                    decoration: const InputDecoration(
                      labelText: 'Recipient',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Amount (SATS)',
                      border: OutlineInputBorder(),
                      suffix: Text('SATS'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: feeRateController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Fee rate',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  isSubmissionInProgress
                      ? const Center(child: CircularProgressIndicator())
                      : Row(
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
                                // Perform save operation
                                String recipient = recipientController.text;
                                String amount = amountController.text;
                                String fee = feeRateController.text;
                                cubit.onSubmit(
                                  recipient,
                                  int.tryParse(amount) ?? 0,
                                  double.tryParse(fee) ?? 1,
                                );
                              },
                              child: const Text('Send'),
                            ),
                          ],
                        ),
                ],
              );
      },
    );
  }
}

class _SuccessIndicatorContent extends StatelessWidget {
  const _SuccessIndicatorContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 48,
        ),
        const SizedBox(height: 16),
        const Text(
          'Congratulations!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Your request has been successfully processed!',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close dialog
          },
          child: const Text('Okay'),
        ),
      ],
    );
  }
}
