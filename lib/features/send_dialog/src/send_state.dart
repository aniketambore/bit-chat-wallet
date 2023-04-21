part of 'send_cubit.dart';

class SendState extends Equatable {
  const SendState({
    required this.address,
    required this.amount,
    this.fee = 3.0,
    this.submissionStatus = SubmissionStatus.idle,
  });

  final String address;
  final int amount;
  final double fee;
  final SubmissionStatus submissionStatus;

  SendState copyWith({
    String? address,
    int? amount,
    double? fee,
    SubmissionStatus? submissionStatus,
  }) {
    return SendState(
      address: address ?? this.address,
      amount: amount ?? this.amount,
      fee: fee ?? this.fee,
      submissionStatus: submissionStatus ?? this.submissionStatus,
    );
  }

  @override
  List<Object?> get props => [
        address,
        amount,
        fee,
        submissionStatus,
      ];
}

enum SubmissionStatus {
  idle,
  inProgress,
  success,
  genericError,
  sendTxError,
}
