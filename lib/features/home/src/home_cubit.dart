import 'package:bit_chat_wallet/wallet_repository/wallet_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bit_chat_wallet/bdk_api/bdk_api.dart';
part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required WalletRepository walletRepository,
  })  : _walletRepository = walletRepository,
        super(
          const HomeInProgress(),
        ) {
    _fetchWalletBalance();
  }

  final WalletRepository _walletRepository;

  Future<void> _fetchWalletBalance() async {
    try {
      final balance = await _walletRepository.getBalance();
      emit(
        HomeSuccess(
          balance: balance,
          syncStatus: SyncStatus.success,
        ),
      );
    } catch (error) {
      final lastState = state;
      if (lastState is HomeSuccess) {
        emit(
          HomeSuccess(
            balance: lastState.balance,
            syncStatus: SyncStatus.error,
          ),
        );
      } else {
        emit(const HomeFailure());
      }
    }
  }

  Future<void> refresh() async {
    final lastState = state;
    if (lastState is HomeSuccess) {
      emit(
        HomeSuccess(
          balance: lastState.balance,
          syncStatus: SyncStatus.inProgress,
        ),
      );

      _fetchWalletBalance();
    }
  }
}
