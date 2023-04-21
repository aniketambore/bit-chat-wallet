import 'package:bit_chat_wallet/bdk_api/bdk_api.dart';
import 'package:bit_chat_wallet/bdk_exceptions/bdk_exceptions.dart';
import 'package:bit_chat_wallet/wallet_repository/src/wallet_secure_storage.dart';

class WalletRepository {
  WalletRepository({
    required this.bdkApi,
  }) : _secureStorage = const WalletSecureStorage();

  final BDKApi bdkApi;
  final WalletSecureStorage _secureStorage;

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
}
