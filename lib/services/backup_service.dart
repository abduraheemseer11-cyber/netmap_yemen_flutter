import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/network_node.dart';

class BackupException implements Exception {
  final String key; // localization key
  BackupException(this.key);
}

/// JSON export/import with optional AES-256-GCM encryption (PBKDF2-HMAC-SHA256 key derivation).
class BackupService {
  static const _format = 'netmap-backup';
  static const _version = 1;
  static final _aes = AesGcm.with256bits();
  static final _kdf = Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: 150000, bits: 256);

  static List<int> _randomBytes(int n) {
    final r = Random.secure();
    return List<int>.generate(n, (_) => r.nextInt(256));
  }

  /// Builds the backup file and opens the system share sheet (WhatsApp, Telegram, Bluetooth...).
  static Future<void> exportAndShare(List<NetworkNode> nodes, {String? passphrase, String? ownerEmail}) async {
    final payload = jsonEncode({
      'format': _format,
      'version': _version,
      'exportedBy': ownerEmail ?? '',
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'nodes': nodes.map((n) => n.toMap()).toList(),
    });

    final encrypted = passphrase != null && passphrase.isNotEmpty;
    final content = encrypted ? await _encrypt(payload, passphrase) : payload;

    final dir = await getTemporaryDirectory();
    final stamp = DateTime.now().toIso8601String().substring(0, 16).replaceAll(RegExp(r'[:T-]'), '');
    final file = File('${dir.path}/netmap_backup_$stamp.${encrypted ? 'nmbak' : 'json'}');
    await file.writeAsString(content, flush: true);
    await Share.shareXFiles([XFile(file.path)], subject: 'NetMap backup');
  }

  /// Lets the user pick a file; returns null if cancelled. [askPassphrase] is called only for encrypted files.
  static Future<List<NetworkNode>?> pickAndParse(Future<String?> Function() askPassphrase) async {
    final res = await FilePicker.platform.pickFiles(type: FileType.any, withData: true);
    if (res == null || res.files.isEmpty) return null;
    final bytes = res.files.single.bytes ?? await File(res.files.single.path!).readAsBytes();

    Map<String, dynamic> outer;
    try {
      outer = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    } catch (_) {
      throw BackupException('invalid_file');
    }

    Map<String, dynamic> doc = outer;
    if (outer['enc'] == 1) {
      final pass = await askPassphrase();
      if (pass == null) return null;
      try {
        doc = jsonDecode(await _decrypt(outer, pass)) as Map<String, dynamic>;
      } catch (_) {
        throw BackupException('wrong_passphrase');
      }
    }
    if (doc['format'] != _format || doc['nodes'] is! List) throw BackupException('invalid_file');
    try {
      return (doc['nodes'] as List).map((e) => NetworkNode.fromMap(Map<String, dynamic>.from(e as Map))).toList();
    } catch (_) {
      throw BackupException('invalid_file');
    }
  }

  static Future<String> _encrypt(String plain, String pass) async {
    final salt = _randomBytes(16);
    final key = await _kdf.deriveKeyFromPassword(password: pass, nonce: salt);
    final box = await _aes.encrypt(utf8.encode(plain), secretKey: key);
    return jsonEncode({
      'enc': 1,
      'salt': base64Encode(salt),
      'nonce': base64Encode(box.nonce),
      'data': base64Encode(box.cipherText),
      'mac': base64Encode(box.mac.bytes),
    });
  }

  static Future<String> _decrypt(Map<String, dynamic> m, String pass) async {
    final key = await _kdf.deriveKeyFromPassword(password: pass, nonce: base64Decode(m['salt']));
    final box = SecretBox(base64Decode(m['data']), nonce: base64Decode(m['nonce']), mac: Mac(base64Decode(m['mac'])));
    return utf8.decode(await _aes.decrypt(box, secretKey: key));
  }
}
