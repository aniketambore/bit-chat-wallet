part of 'secrets_cubit.dart';

abstract class SecretsState extends Equatable {
  const SecretsState();
}

class SecretsInProgress extends SecretsState {
  const SecretsInProgress();

  @override
  List<Object?> get props => [];
}

class SecretsSuccess extends SecretsState {
  const SecretsSuccess({
    required this.mnemonic,
    required this.privKeyHex,
    required this.pubKeyHex,
    required this.privKeyNsec,
    required this.pubKeyNpub,
    this.recoverPhraseError,
  });

  final String mnemonic;
  final String privKeyHex;
  final String pubKeyHex;
  final String privKeyNsec;
  final String pubKeyNpub;
  final dynamic recoverPhraseError;

  @override
  List<Object?> get props => [
        mnemonic,
        privKeyHex,
        pubKeyHex,
        privKeyNsec,
        pubKeyNpub,
        recoverPhraseError,
      ];
}

class SecretsFailure extends SecretsState {
  const SecretsFailure();

  @override
  List<Object?> get props => [];
}
