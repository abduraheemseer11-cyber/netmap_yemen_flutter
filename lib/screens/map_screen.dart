import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../l10n/app_strings.dart';
import '../models/network_node.dart';
import '../providers/node_provider.dart';
import '../widgets/node_details_sheet.dart';
import '../widgets/node_form_sheet.dart';
import 'settings_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _sanaa = LatLng(15.3694, 44.1910); // default start: Sana'a, Yemen
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  GoogleMapController? _map;
  LatLng _center = _sanaa;
  bool _locationGranted = false;
  List<NetworkNode> _results = [];

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) return;
    if (mounted) setState(() => _locationGranted = true);
    try {
      final p = await Geolocator.getCurrentPosition();
      _map?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(p.latitude, p.longitude), 17));
    } catch (_) {/* GPS unavailable: stay on default */}
  }

  /// Colour coding: blue = street infrastructure, green = connected homes.
  Set<Marker> _markers(List<NetworkNode> nodes) => nodes
      .map((n) => Marker(
            markerId: MarkerId(n.id),
            position: n.latLng,
            icon: BitmapDescriptor.defaultMarkerWithHue(
                n.isStreet ? BitmapDescriptor.hueBlue : BitmapDescriptor.hueGreen),
            infoWindow: InfoWindow(
              title: n.displayName,
              snippet: n.subtitle,
              onTap: () => showNodeDetails(context, n),
            ),
            onTap: () => setState(() => _results = []),
          ))
      .toSet();

  Future<void> _addAt(LatLng p) async {
    final provider = context.read<NodeProvider>();
    final node = await showModalBottomSheet<NetworkNode>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => NodeFormSheet(position: p),
    );
    if (node != null) await provider.upsert(node);
  }

  /// Search result tap: fly to the marker and open its info window.
  Future<void> _focus(NetworkNode n) async {
    _searchFocus.unfocus();
    setState(() => _results = []);
    await _map?.animateCamera(CameraUpdate.newLatLngZoom(n.latLng, 19));
    await Future.delayed(const Duration(milliseconds: 450));
    await _map?.showMarkerInfoWindow(MarkerId(n.id));
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final nodes = context.watch<NodeProvider>().nodes;
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Stack(children: [
        GoogleMap(
          mapType: MapType.satellite, // satellite by default
          initialCameraPosition: const CameraPosition(target: _sanaa, zoom: 12),
          onMapCreated: (c) => _map = c,
          onCameraMove: (pos) => _center = pos.target,
          onLongPress: _addAt,
          markers: _markers(nodes),
          myLocationEnabled: _locationGranted,
          myLocationButtonEnabled: _locationGranted,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          padding: EdgeInsets.only(top: top + 72, bottom: 80),
        ),
        // Persistent floating search bar
        Positioned(
          top: top + 8,
          left: 12,
          right: 12,
          child: Column(children: [
            Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(28),
              child: TextField(
                controller: _searchCtrl,
                focusNode: _searchFocus,
                onChanged: (q) => setState(() => _results = context.read<NodeProvider>().search(q)),
                decoration: InputDecoration(
                  hintText: s.t('search_hint'),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (_searchCtrl.text.isNotEmpty)
                      IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(() {
                                _searchCtrl.clear();
                                _results = [];
                              })),
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                    ),
                  ]),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
                ),
              ),
            ),
            if (_searchCtrl.text.isNotEmpty)
              Card(
                margin: const EdgeInsets.only(top: 6),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 280),
                  child: _results.isEmpty
                      ? Padding(padding: const EdgeInsets.all(16), child: Text(s.t('no_results')))
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: _results.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final n = _results[i];
                            return ListTile(
                              leading: Icon(n.isStreet ? Icons.router : Icons.home,
                                  color: n.isStreet ? Colors.blue : Colors.green),
                              title: Text(n.displayName),
                              subtitle: Text(n.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                              onTap: () => _focus(n),
                            );
                          },
                        ),
                ),
              ),
          ]),
        ),
        // Legend
        Positioned(
          left: 12,
          bottom: 24,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [const Icon(Icons.circle, size: 12, color: Colors.blue), const SizedBox(width: 6), Text(s.t('type_street'))]),
                Row(children: [const Icon(Icons.circle, size: 12, color: Colors.green), const SizedBox(width: 6), Text(s.t('type_home'))]),
              ]),
            ),
          ),
        ),
      ]),
      // Adds a node at the current map centre (alternative to long-press).
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addAt(_center),
        icon: const Icon(Icons.add_location_alt),
        label: Text(s.t('add_node')),
      ),
    );
  }
}
