import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_strings.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/node_provider.dart';
import '../services/backup_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<String?> _ask(BuildContext context) {
    final s = S.of(context);
    final c = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(s.t('passphrase')),
        content: TextField(controller: c, obscureText: true, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(s.t('cancel'))),
          FilledButton(onPressed: () => Navigator.pop(context, c.text), child: Text(s.t('save'))),
        ],
      ),
    );
  }

  void _toast(BuildContext c, String m) => ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _export(BuildContext context, {required bool encrypted}) async {
    final s = S.of(context);
    final nodes = context.read<NodeProvider>().nodes;
    final email = context.read<AuthProvider>().user?.email;
    String? pass;
    if (encrypted) {
      pass = await _ask(context);
      if (pass == null || pass.isEmpty) return;
    }
    try {
      await BackupService.exportAndShare(nodes, passphrase: pass, ownerEmail: email);
    } catch (_) {
      if (context.mounted) _toast(context, s.t('export_failed'));
    }
  }

  Future<void> _import(BuildContext context) async {
    final s = S.of(context);
    final provider = context.read<NodeProvider>();
    try {
      final incoming = await BackupService.pickAndParse(() => _ask(context));
      if (incoming == null) return;
      final r = await provider.mergeImport(incoming);
      if (context.mounted) {
        _toast(context, s.f('import_summary', {'a': r.added, 'u': r.updated, 's': r.skipped}));
      }
    } on BackupException catch (e) {
      if (context.mounted) _toast(context, s.t(e.key));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final lp = context.watch<LocaleProvider>();
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      appBar: AppBar(title: Text(s.t('settings'))),
      body: ListView(children: [
        ListTile(
          leading: const Icon(Icons.account_circle),
          title: Text(s.t('signed_in_as')),
          subtitle: Text('${user?.email ?? ''}\n${s.t('data_private')}'),
          isThreeLine: true,
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.language),
          title: Text(s.t('language')),
          trailing: DropdownButton<String>(
            value: lp.locale.languageCode,
            underline: const SizedBox.shrink(),
            items: S.names.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
            onChanged: (v) => v == null ? null : lp.setLanguage(v),
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(s.t('backup'), style: Theme.of(context).textTheme.titleSmall),
        ),
        ListTile(
          leading: const Icon(Icons.upload_file),
          title: Text(s.t('export_plain')),
          onTap: () => _export(context, encrypted: false),
        ),
        ListTile(
          leading: const Icon(Icons.enhanced_encryption),
          title: Text(s.t('export_encrypted')),
          onTap: () => _export(context, encrypted: true),
        ),
        ListTile(
          leading: const Icon(Icons.download),
          title: Text(s.t('import_backup')),
          onTap: () => _import(context),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout),
          title: Text(s.t('logout')),
          onTap: () async {
            final nav = Navigator.of(context);
            await context.read<AuthProvider>().signOut();
            nav.popUntil((r) => r.isFirst);
          },
        ),
      ]),
    );
  }
}
