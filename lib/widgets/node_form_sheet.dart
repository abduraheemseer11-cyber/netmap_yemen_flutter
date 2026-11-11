import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

import '../l10n/app_strings.dart';
import '../models/network_node.dart';

/// Bottom sheet for creating/editing a node. Pops with the resulting [NetworkNode] (or null).
class NodeFormSheet extends StatefulWidget {
  final NetworkNode? existing;
  final LatLng? position;
  const NodeFormSheet({super.key, this.existing, this.position}) : assert(existing != null || position != null);

  @override
  State<NodeFormSheet> createState() => _NodeFormSheetState();
}

class _NodeFormSheetState extends State<NodeFormSheet> {
  final _form = GlobalKey<FormState>();
  late NodeType _type;
  String? _model;
  late final TextEditingController _netNo, _ip, _user, _pass, _title, _custName, _custPhone;

  @override
  void initState() {
    super.initState();
    final n = widget.existing;
    _type = n?.type ?? NodeType.street;
    _model = (n != null && kRouterModels.contains(n.routerModel)) ? n.routerModel : null;
    _netNo = TextEditingController(text: n?.networkNumber ?? '');
    _ip = TextEditingController(text: n?.ip ?? '');
    _user = TextEditingController(text: n?.username ?? 'root');
    _pass = TextEditingController(text: n?.password ?? '');
    _title = TextEditingController(text: n?.title ?? '');
    _custName = TextEditingController(text: n?.customerName ?? '');
    _custPhone = TextEditingController(text: n?.customerPhone ?? '');
  }

  @override
  void dispose() {
    for (final c in [_netNo, _ip, _user, _pass, _title, _custName, _custPhone]) {
      c.dispose();
    }
    super.dispose();
  }

  bool _validIp(String v) {
    final p = v.trim().split('.');
    return p.length == 4 && p.every((o) => int.tryParse(o) != null && int.parse(o) >= 0 && int.parse(o) <= 255);
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    final now = DateTime.now().toUtc();
    final e = widget.existing;
    final isStreet = _type == NodeType.street;
    Navigator.pop(
      context,
      NetworkNode(
        id: e?.id ?? const Uuid().v4(),
        ownerUid: e?.ownerUid ?? '', // overwritten by NodeProvider with the authenticated uid
        type: _type,
        lat: e?.lat ?? widget.position!.latitude,
        lng: e?.lng ?? widget.position!.longitude,
        networkNumber: isStreet ? _netNo.text.trim() : '',
        routerModel: isStreet ? (_model ?? '') : '',
        ip: _ip.text.trim(),
        username: isStreet ? _user.text.trim() : '',
        password: isStreet ? _pass.text : '',
        title: isStreet ? _title.text.trim() : '',
        customerName: isStreet ? '' : _custName.text.trim(),
        customerPhone: isStreet ? '' : _custPhone.text.trim(),
        createdAt: e?.createdAt ?? now,
        updatedAt: now,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    String? req(String? v) => (v == null || v.trim().isEmpty) ? s.t('required') : null;
    final lat = widget.existing?.lat ?? widget.position!.latitude;
    final lng = widget.existing?.lng ?? widget.position!.longitude;
    final isStreet = _type == NodeType.street;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SegmentedButton<NodeType>(
              segments: [
                ButtonSegment(value: NodeType.street, icon: const Icon(Icons.router), label: Text(s.t('type_street'))),
                ButtonSegment(value: NodeType.home, icon: const Icon(Icons.home), label: Text(s.t('type_home'))),
              ],
              selected: {_type},
              onSelectionChanged: (v) => setState(() => _type = v.first),
            ),
            const SizedBox(height: 6),
            Text(s.t(isStreet ? 'street_router' : 'home_router'),
                textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 12),
            if (isStreet) ...[
              TextFormField(
                  controller: _netNo,
                  decoration: InputDecoration(labelText: s.t('network_number')),
                  validator: req),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _model,
                isExpanded: true,
                decoration: InputDecoration(labelText: s.t('router_type')),
                items: kRouterModels.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (v) => setState(() => _model = v),
                validator: (v) => v == null ? s.t('required') : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ip,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: s.t('router_ip')),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? s.t('required')
                    : (_validIp(v) ? null : s.t('invalid_ip')),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: TextFormField(
                        controller: _user, decoration: InputDecoration(labelText: s.t('username')), validator: req)),
                const SizedBox(width: 12),
                Expanded(
                    child: TextFormField(
                        controller: _pass, decoration: InputDecoration(labelText: s.t('router_password')))),
              ]),
              const SizedBox(height: 12),
              TextFormField(
                  controller: _title, decoration: InputDecoration(labelText: s.t('device_title')), validator: req),
            ] else ...[
              TextFormField(
                  controller: _custName, decoration: InputDecoration(labelText: s.t('customer_name')), validator: req),
              const SizedBox(height: 12),
              TextFormField(
                  controller: _custPhone,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: s.t('customer_phone')),
                  validator: req),
              const SizedBox(height: 12),
              TextFormField(controller: _ip, decoration: InputDecoration(labelText: s.t('ip_details'))),
            ],
            const SizedBox(height: 12),
            // Coordinates are auto-filled from the map position (read-only).
            Row(children: [
              Expanded(
                  child: TextFormField(
                      initialValue: lat.toStringAsFixed(6),
                      readOnly: true,
                      decoration: InputDecoration(labelText: s.t('latitude')))),
              const SizedBox(width: 12),
              Expanded(
                  child: TextFormField(
                      initialValue: lng.toStringAsFixed(6),
                      readOnly: true,
                      decoration: InputDecoration(labelText: s.t('longitude')))),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: Text(s.t('cancel')))),
              const SizedBox(width: 12),
              Expanded(child: FilledButton(onPressed: _save, child: Text(s.t('save')))),
            ]),
          ]),
        ),
      ),
    );
  }
}
