import 'package:flutter/material.dart';

class RequestBitcoinDialog extends StatefulWidget {
  const RequestBitcoinDialog({super.key});

  @override
  State<RequestBitcoinDialog> createState() => _RequestBitcoinDialogState();
}

class _RequestBitcoinDialogState extends State<RequestBitcoinDialog> {
  final TextEditingController _requestAmountController =
      TextEditingController();
  final TextEditingController _requestMessageController =
      TextEditingController();

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
                'Request Bitcoin',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _requestAmountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount (SATS)',
                  border: OutlineInputBorder(),
                  suffix: Text('SATS'),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _requestMessageController,
                decoration: const InputDecoration(
                  labelText: 'Message',
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
                      // Pass form field values back to parent widget
                      Navigator.of(context).pop({
                        'requestAmount': _requestAmountController.text,
                        'requestMessage': _requestMessageController.text,
                      });
                    },
                    child: const Text('Request'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
