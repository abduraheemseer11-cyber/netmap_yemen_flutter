import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Offline-first storage. Node boxes are AES-encrypted (key kept in Keystore/Keychain)
/// and namespaced per user id, so accounts on one phone never see each other's data.
class LocalStore {
  static const _secure = FlutterSecureStorage();
  static late HiveAesCipher _cipher;
  static late Box settings;

  static Future<void> init() async {
    await Hive.initFlutter();
    final stored = await _secure.read(key: 'hive_key');
    late List<int> key;
    if (stored == null) {
      key = Hive.generateSecureKey();
      await _secure.write(key: 'hive_key', value: base64UrlEncode(key));
    } else {
      key = base64Url.decode(stored);
    }
    _cipher = HiveAesCipher(key);
    settings = await Hive.openBox('settings');
  }

  static Future<Box<String>> openNodes(String uid) =>
      Hive.openBox<String>('nodes_$uid', encryptionCipher: _cipher);
}
