import 'package:bit_chat_wallet/wallet_repository/wallet_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'chat_screen_state.dart';

class ChatScreenCubit extends Cubit<ChatScreenState> {
  ChatScreenCubit({
    required WalletRepository walletRepository,
    required String myPrivKey,
  })  : _walletRepository = walletRepository,
        _myPrivKey = myPrivKey,
        super(
          const ChatScreenInProgress(),
        ) {
    _fetchNostPrivKey();
  }

  final WalletRepository _walletRepository;
  final String _myPrivKey;

  Future<void> _fetchNostPrivKey() async {
    final myPubKey = _walletRepository.getPublicKey(_myPrivKey);
    try {
      emit(
        ChatScreenSuccess(
          myPrivKey: _myPrivKey,
          myPubKey: myPubKey,
          syncStatus: SyncStatus.success,
        ),
      );
    } catch (error) {
      final lastState = state;
      if (lastState is ChatScreenSuccess) {
        emit(
          ChatScreenSuccess(
            myPrivKey: lastState.myPrivKey,
            myPubKey: lastState.myPubKey,
            syncStatus: SyncStatus.error,
          ),
        );
      } else {
        emit(const ChatScreenFailure());
      }
    }
  }

  Future<String> getAddress() async {
    try {
      final address = await _walletRepository.getAddress();
      return address;
    } catch (error) {
      rethrow;
    }
  }
}
