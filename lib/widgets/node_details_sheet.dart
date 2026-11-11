import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_strings.dart';
import '../models/network_node.dart';
import '../providers/node_provider.dart';
import 'node_form_sheet.dart';

extension NodeLatLng on NetworkNode {
  LatLng get latLng => LatLng(lat, lng);
}

/// Opens Google Maps turn-by-turn navigation from the current GPS position to the node.
Future<void> openNavigation(NetworkNode n) async {
  final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${n.lat},${n.lng}&travelmode=driving');
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

Future<void> showNodeDetails(BuildContext context, NetworkNode node) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _NodeDetails(node: node),
  );
}

class _NodeDetails extends StatefulWidget {
  final NetworkNode node;
  const _NodeDetails({required this.node});
  @override
  State<_NodeDetails> createState() => _NodeDetailsState();
}

class _NodeDetailsState extends State<_NodeDetails> {
  bool _showPass = false;

  Widget _row(String label, String value, {bool copy = true, Widget? trailing}) {
    if (value.isEmpty) return const SizedBox.shrink();
    return ListTile(
      dense: true,
      title: Text(label, style: Theme.of(context).textTheme.labelMedium),
      subtitle: Text(value, style: Theme.of(context).textTheme.bodyLarge),
      trailing: trailing ??
          (copy
              ? IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(S.of(context).t('copied')), duration: const Duration(seconds: 1)));
                  })
              : null),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final n = widget.node;
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: n.isStreet ? Colors.blue : Colors.green,
              child: Icon(n.isStreet ? Icons.router : Icons.home, color: Colors.white),
            ),
            title: Text(n.displayName, style: Theme.of(context).textTheme.titleLarge),
            subtitle: Text(s.t(n.isStreet ? 'street_router' : 'home_router')),
          ),
          if (n.isStreet) ...[
            _row(s.t('network_number'), n.networkNumber),
            _row(s.t('router_type'), n.routerModel, copy: false),
            _row(s.t('router_ip'), n.ip),
            _row(s.t('username'), n.username),
            _row(s.t('router_password'), n.password.isEmpty ? '' : (_showPass ? n.password : '••••••••'),
                copy: false,
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(
                      icon: Icon(_showPass ? Icons.visibility_off : Icons.visibility, size: 18),
                      onPressed: () => setState(() => _showPass = !_showPass)),
                  IconButton(
                      icon: const Icon(Icons.copy, size: 18),
                      onPressed: () => Clipboard.setData(ClipboardData(text: n.password))),
                ])),
            _row(s.t('device_title'), n.title, copy: false),
          ] else ...[
            _row(s.t('customer_name'), n.customerName),
            _row(s.t('customer_phone'), n.customerPhone),
            _row(s.t('ip_details'), n.ip),
          ],
          _row('${s.t('latitude')} / ${s.t('longitude')}', '${n.lat.toStringAsFixed(6)}, ${n.lng.toStringAsFixed(6)}'),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  icon: const Icon(Icons.navigation),
                  label: Text(s.t('navigate')),
                  onPressed: () => openNavigation(n),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: s.t('edit'),
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final nav = Navigator.of(context);
                  final provider = context.read<NodeProvider>();
                  final updated = await showModalBottomSheet<NetworkNode>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => NodeFormSheet(existing: n),
                  );
                  if (updated != null) await provider.upsert(updated);
                  nav.pop();
                },
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: s.t('delete'),
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  final nav = Navigator.of(context);
                  final provider = context.read<NodeProvider>();
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      content: Text(s.t('delete_confirm')),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(s.t('cancel'))),
                        FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(s.t('delete'))),
                      ],
                    ),
                  );
                  if (ok == true) {
                    await provider.remove(n.id);
                    nav.pop();
                  }
                },
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
