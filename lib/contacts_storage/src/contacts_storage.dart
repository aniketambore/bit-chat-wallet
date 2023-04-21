import 'package:bit_chat_wallet/contacts_storage/src/models/models.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class ContactStorage {
  static const _nostrContactListBoxKey = 'nostr-contacts';

  ContactStorage({
    @visibleForTesting HiveInterface? hive,
  }) : _hive = hive ?? Hive {
    try {
      _hive.registerAdapter(ContactCMAdapter());
    } catch (_) {
      throw Exception(
          'You shouldn\'t have more than one [KeyValueStorage] instance in your '
          'project');
    }
  }

  final HiveInterface _hive;

  Future<Box<ContactCM>> get nostrContactBox => _openHiveBox<ContactCM>(
        _nostrContactListBoxKey,
        isTemporary: true,
      );

  Future<Box<T>> _openHiveBox<T>(
    String boxKey, {
    required bool isTemporary,
  }) async {
    if (_hive.isBoxOpen(boxKey)) {
      return _hive.box(boxKey);
    } else {
      final directory = await (isTemporary
          ? getTemporaryDirectory()
          : getApplicationDocumentsDirectory());
      return _hive.openBox<T>(
        boxKey,
        path: directory.path,
      );
    }
  }

  Future<void> addContact(ContactCM contact) async {
    final box = await nostrContactBox;
    await box.add(contact);
  }

  Future<void> updateContact(int index, ContactCM contact) async {
    final box = await nostrContactBox;
    await box.putAt(index, contact);
  }

  Future<void> deleteContact(int index) async {
    final box = await nostrContactBox;
    await box.deleteAt(index);
  }

  Future<List<ContactCM>> allContacts() async {
    final box = await nostrContactBox;
    return box.values.toList();
  }

  Future<ContactCM> getContactById(int id) async {
    final box = await nostrContactBox;
    return box.get(id)!;
  }

  Future<void> clearCache() async {
    await nostrContactBox.then((box) => box.clear());
  }
}
