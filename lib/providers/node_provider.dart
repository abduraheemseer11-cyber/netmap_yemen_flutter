import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/network_node.dart';
import '../services/local_store.dart';

class MergeResult {
  final int added, updated, skipped;
  const MergeResult(this.added, this.updated, this.skipped);
}

/// Single source of truth for the signed-in user's nodes.
/// Reads always come from the local encrypted Hive box (works offline);
/// writes go to Hive first, then to Firestore users/{uid}/nodes (queued offline by the SDK).
class NodeProvider extends ChangeNotifier {
  String? _uid;
  Box<String>? _box;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;
  List<NetworkNode> nodes = [];

  String? get uid => _uid;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      FirebaseFirestore.instance.collection('users').doc(uid).collection('nodes');

  Future<void> bind(String? uid) async {
    if (uid == _uid) return;
    _uid = uid;
    await _sub?.cancel();
    _sub = null;
    await _box?.close();
    _box = null;
    nodes = [];
    notifyListeners();
    if (uid == null) return;

    final box = await LocalStore.openNodes(uid);
    if (_uid != uid) return; // user changed while opening
    _box = box;
    _reload();

    // Push any local-only nodes (e.g. created offline before first sync), then mirror remote.
    for (final n in nodes) {
      _col(uid).doc(n.id).set(n.toMap(), SetOptions(merge: true)).catchError((_) {});
    }
    _sub = _col(uid).snapshots().listen((snap) async {
      final b = _box;
      if (b == null || _uid != uid) return;
      for (final ch in snap.docChanges) {
        if (ch.type == DocumentChangeType.removed) {
          await b.delete(ch.doc.id);
        } else {
          final remote = NetworkNode.fromMap(ch.doc.data()!);
          final local = b.get(remote.id);
          if (local == null || NetworkNode.fromJson(local).updatedAt.isBefore(remote.updatedAt)) {
            await b.put(remote.id, remote.toJson());
          }
        }
      }
      _reload();
    }, onError: (_) {});
  }

  void _reload() {
    nodes = (_box?.values ?? const <String>[]).map(NetworkNode.fromJson).toList()
      ..sort((a, b) => a.displayName.compareTo(b.displayName));
    notifyListeners();
  }

  Future<void> upsert(NetworkNode n) async {
    final box = _box, uid = _uid;
    if (box == null || uid == null) return;
    final node = n.copyWith(ownerUid: uid, updatedAt: DateTime.now().toUtc());
    await box.put(node.id, node.toJson());
    _reload();
    _col(uid).doc(node.id).set(node.toMap()).catchError((_) {});
  }

  Future<void> remove(String id) async {
    await _box?.delete(id);
    _reload();
    final uid = _uid;
    if (uid != null) _col(uid).doc(id).delete().catchError((_) {});
  }

  List<NetworkNode> search(String q) =>
      q.trim().isEmpty ? const [] : nodes.where((n) => n.matches(q)).take(15).toList();

  /// Merge imported nodes: new ids are appended; existing ids are replaced only if the import is newer.
  Future<MergeResult> mergeImport(List<NetworkNode> incoming) async {
    final box = _box, uid = _uid;
    if (box == null || uid == null) return const MergeResult(0, 0, 0);
    int added = 0, updated = 0, skipped = 0;
    for (final raw in incoming) {
      final n = raw.copyWith(ownerUid: uid); // re-own under the importing account
      final existing = box.get(n.id);
      if (existing == null) {
        added++;
      } else if (NetworkNode.fromJson(existing).updatedAt.isBefore(n.updatedAt)) {
        updated++;
      } else {
        skipped++;
        continue;
      }
      await box.put(n.id, n.toJson());
      _col(uid).doc(n.id).set(n.toMap()).catchError((_) {});
    }
    _reload();
    return MergeResult(added, updated, skipped);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
