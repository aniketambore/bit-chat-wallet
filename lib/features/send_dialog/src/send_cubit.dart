import 'package:bit_chat_wallet/bdk_exceptions/bdk_exceptions.dart';
import 'package:bit_chat_wallet/wallet_repository/wallet_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'send_state.dart';

class SendCubit extends Cubit<SendState> {
  SendCubit({
    required this.walletRepository,
  }) : super(
          const SendState(
            address: '',
            amount: 0,
          ),
        );

  final WalletRepository walletRepository;

  void onSubmit(String address, int amount, double fee) async {
    final isFormValid =
        (address.trim().isNotEmpty) && (amount > 0) && (fee > 0);

    final newState = state.copyWith(
      address: address,
      amount: amount,
      fee: fee,
      submissionStatus: isFormValid ? SubmissionStatus.inProgress : null,
    );

    emit(newState);

    if (isFormValid) {
      try {
        await walletRepository.sendTx(
          addressStr: address,
          amount: amount,
          fee: fee,
        );
        final newState = state.copyWith(
          submissionStatus: SubmissionStatus.success,
        );
        emit(newState);
      } catch (error) {
        final newState = state.copyWith(
          submissionStatus: error is SendTxBdkException
              ? SubmissionStatus.sendTxError
              : SubmissionStatus.genericError,
        );
        emit(newState);
      }
    }
  }
}
