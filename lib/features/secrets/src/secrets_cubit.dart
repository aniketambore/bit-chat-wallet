import 'package:bit_chat_wallet/wallet_repository/wallet_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'secrets_state.dart';

class SecretsCubit extends Cubit<SecretsState> {
  SecretsCubit({
    required this.walletRepository,
  }) : super(
          const SecretsInProgress(),
        ) {
    _fetchWalletSecrets();
  }

  final WalletRepository walletRepository;

  Future<void> _fetchWalletSecrets() async {
    try {
      final mnemonic = await walletRepository.getWalletMnemonic();
      final privKeyHex = walletRepository.mnemonicToPrivKey(mnemonic!);
      final pubKeyHex = walletRepository.getPublicKey(privKeyHex);
      final nsec = walletRepository.privKeyHexToNsec(privKeyHex);
      final npub = walletRepository.pubKeyHexToNpub(pubKeyHex);

      emit(
        SecretsSuccess(
          mnemonic: mnemonic,
          privKeyHex: privKeyHex,
          pubKeyHex: pubKeyHex,
          privKeyNsec: nsec,
          pubKeyNpub: npub,
        ),
      );
    } catch (error) {
      emit(
        const SecretsFailure(),
      );
    }
  }

  Future<void> refetch() async {
    emit(
      const SecretsInProgress(),
    );

    _fetchWalletSecrets();
  }
}
