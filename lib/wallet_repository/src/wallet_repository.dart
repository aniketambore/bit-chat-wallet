import 'package:bit_chat_wallet/bdk_api/bdk_api.dart';
import 'package:bit_chat_wallet/bdk_exceptions/bdk_exceptions.dart';
import 'package:bit_chat_wallet/nostr_api/nostr_api.dart';
import 'package:bit_chat_wallet/contacts_storage/contacts_storage.dart';
import 'package:bit_chat_wallet/wallet_repository/src/wallet_secure_storage.dart';

class WalletRepository {
  WalletRepository({
    required this.bdkApi,
    required this.nostrApi,
    required ContactStorage contactStorage,
  })  : _secureStorage = const WalletSecureStorage(),
        _localStorage = contactStorage;

  final BDKApi bdkApi;
  final WalletSecureStorage _secureStorage;
  final NostrApi nostrApi;
  final ContactStorage _localStorage;

  Future<void> createWallet({String? recoveryMnemonic}) async {
    try {
      final bdk = await bdkApi.createWallet(recoveryMnemonic: recoveryMnemonic);

      await _secureStorage.upsertWalletMnemonic(mnemonic: bdk);
    } catch (error) {
      if (error is CreateWalletBdkException) {
        throw CreateWalletBdkException();
      } else if (error is BlockchainBdkException) {
        throw BlockchainBdkException();
      }
      rethrow;
    }
  }

  Future<void> recoverWallet(String mnemonic) async {
    try {
      await bdkApi.recoverWallet(
        mnemonic,
        Network.Testnet,
      );
    } catch (error) {
      if (error is RecoverWalletBdkException) {
        throw RecoverWalletBdkException();
      } else if (error is BlockchainBdkException) {
        throw BlockchainBdkException();
      }
      rethrow;
    }
  }

  Future<String?> getWalletMnemonic() {
    return _secureStorage.getWalletMnemonic();
  }

  Future<Balance> getBalance() async {
    try {
      final apiBalance = await bdkApi.getBalance();
      return apiBalance;
    } on SyncWalletBdkException catch (_) {
      throw SyncWalletBdkException();
    }
  }

  Future<String> getAddress() {
    try {
      final address = bdkApi.getAddress();
      return address;
    } on GetAddressBdkException catch (_) {
      throw GetAddressBdkException();
    }
  }

  Future<void> sendTx({
    required String addressStr,
    required int amount,
    required double fee,
  }) async {
    try {
      await bdkApi.sendTx(
        addressStr: addressStr,
        amount: amount,
        fee: fee,
      );
    } catch (e) {
      if (e is SendTxBdkException) {
        throw SendTxBdkException();
      }
      rethrow;
    }
  }

  String mnemonicToPrivKey(String mnemonic) =>
      nostrApi.mnemonicToPrivKey(mnemonic);

  String getPublicKey(String privKeyHex) => nostrApi.getPublicKey(privKeyHex);

  String privKeyHexToNsec(String privKeyHex) =>
      nostrApi.privKeyHexToNsec(privKeyHex);

  String privKeyNsecToHex(String privKeyNsec) =>
      nostrApi.privKeyNsecToHex(privKeyNsec);

  String pubKeyHexToNpub(String pubKeyHex) =>
      nostrApi.pubKeyHexToNpub(pubKeyHex);

  String pubKeyNpubToHex(String pubKeyNpub) =>
      nostrApi.pubKeyNpubToHex(pubKeyNpub);

  Future<void> addContact(String id, String name, String npub) async {
    await _localStorage.addContact(ContactCM(id: id, name: name, npub: npub));
  }

  Future<List<ContactCM>> allContacts() async {
    return await _localStorage.allContacts();
  }

  Future<void> clearCache() async {
    await _localStorage.clearCache();
  }
}
