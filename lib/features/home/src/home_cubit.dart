import 'package:bit_chat_wallet/contacts_storage/contacts_storage.dart';
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
      final contactsList = await _walletRepository.allContacts();
      emit(
        HomeSuccess(
          balance: balance,
          contactsList: contactsList,
          syncStatus: SyncStatus.success,
        ),
      );
    } catch (error) {
      final lastState = state;
      if (lastState is HomeSuccess) {
        emit(
          HomeSuccess(
            balance: lastState.balance,
            contactsList: lastState.contactsList,
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
          contactsList: lastState.contactsList,
          syncStatus: SyncStatus.inProgress,
        ),
      );

      _fetchWalletBalance();
    }
  }

  Future<void> addContactSubmit(String id, String name, String npub) async {
    final lastState = state;
    if (lastState is HomeSuccess) {
      try {
        await _walletRepository.addContact(id, name, npub);
        final contactsList = await _walletRepository.allContacts();
        emit(
          HomeSuccess(
            balance: lastState.balance,
            contactsList: contactsList,
            syncStatus: SyncStatus.success,
          ),
        );
      } catch (error) {
        emit(
          HomeSuccess(
            balance: lastState.balance,
            contactsList: lastState.contactsList,
            syncStatus: SyncStatus.error,
          ),
        );
      }
    }
  }
}
