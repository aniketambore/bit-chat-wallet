import 'package:nostr_tools/nostr_tools.dart';

class NostrApi {
  final nip06 = Nip06();
  final nip19 = Nip19();
  final keyGenerator = KeyApi();

  String getPublicKey(String privKeyHex) =>
      keyGenerator.getPublicKey(privKeyHex);

  String mnemonicToPrivKey(String mnemonic) =>
      nip06.privateKeyFromSeedWords(mnemonic);

  String privKeyHexToNsec(String privKeyHex) => nip19.nsecEncode(privKeyHex);

  String privKeyNsecToHex(String privKeyNsec) {
    final privKeyHex = nip19.decode(privKeyNsec);
    return privKeyHex['data'];
  }

  String pubKeyHexToNpub(String pubKeyHex) => nip19.npubEncode(pubKeyHex);

  String pubKeyNpubToHex(String pubKeyNpub) {
    final pubKeyHex = nip19.decode(pubKeyNpub);
    return pubKeyHex['data'];
  }
}
