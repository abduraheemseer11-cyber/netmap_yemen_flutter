import 'dart:convert';

enum NodeType { street, home }

/// Router models allowed for street (waterproof box) devices.
const List<String> kRouterModels = [
  'Kt 708', 'kt 704', 'Kt 412', 'Phicomm K2P', 'Xiaomi CR6608', 'Nanostion m2',
  'Nanostion m5', 'Power beam M5 400', 'Power beam AC M5 420', 'VJJT', 'tp-link', 'D-link',
];

class NetworkNode {
  final String id;
  final String ownerUid;
  final NodeType type;
  final double lat;
  final double lng;

  // Street router fields
  final String networkNumber;
  final String routerModel;
  final String ip; // also used as "IP / details" for home routers
  final String username;
  final String password;
  final String title;

  // Home router fields
  final String customerName;
  final String customerPhone;

  final DateTime createdAt;
  final DateTime updatedAt;

  const NetworkNode({
    required this.id,
    required this.ownerUid,
    required this.type,
    required this.lat,
    required this.lng,
    this.networkNumber = '',
    this.routerModel = '',
    this.ip = '',
    this.username = 'root',
    this.password = '',
    this.title = '',
    this.customerName = '',
    this.customerPhone = '',
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isStreet => type == NodeType.street;

  String get displayName => isStreet
      ? (networkNumber.isNotEmpty ? '#$networkNumber' : title)
      : customerName;

  String get subtitle => isStreet ? '$routerModel • $title' : customerPhone;

  NetworkNode copyWith({
    String? ownerUid, NodeType? type, double? lat, double? lng, String? networkNumber,
    String? routerModel, String? ip, String? username, String? password, String? title,
    String? customerName, String? customerPhone, DateTime? updatedAt,
  }) =>
      NetworkNode(
        id: id,
        ownerUid: ownerUid ?? this.ownerUid,
        type: type ?? this.type,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        networkNumber: networkNumber ?? this.networkNumber,
        routerModel: routerModel ?? this.routerModel,
        ip: ip ?? this.ip,
        username: username ?? this.username,
        password: password ?? this.password,
        title: title ?? this.title,
        customerName: customerName ?? this.customerName,
        customerPhone: customerPhone ?? this.customerPhone,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  /// Case-insensitive match on network number, customer name/phone, title or IP.
  bool matches(String q) {
    final s = q.trim().toLowerCase();
    if (s.isEmpty) return false;
    return [networkNumber, customerName, customerPhone, title, ip]
        .any((f) => f.toLowerCase().contains(s));
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'ownerUid': ownerUid,
        'type': type.name,
        'lat': lat,
        'lng': lng,
        'networkNumber': networkNumber,
        'routerModel': routerModel,
        'ip': ip,
        'username': username,
        'password': password,
        'title': title,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'updatedAt': updatedAt.toUtc().toIso8601String(),
      };

  factory NetworkNode.fromMap(Map<String, dynamic> m) => NetworkNode(
        id: m['id'] as String,
        ownerUid: (m['ownerUid'] ?? '') as String,
        type: NodeType.values.firstWhere((t) => t.name == m['type'], orElse: () => NodeType.street),
        lat: (m['lat'] as num).toDouble(),
        lng: (m['lng'] as num).toDouble(),
        networkNumber: (m['networkNumber'] ?? '') as String,
        routerModel: (m['routerModel'] ?? '') as String,
        ip: (m['ip'] ?? '') as String,
        username: (m['username'] ?? 'root') as String,
        password: (m['password'] ?? '') as String,
        title: (m['title'] ?? '') as String,
        customerName: (m['customerName'] ?? '') as String,
        customerPhone: (m['customerPhone'] ?? '') as String,
        createdAt: DateTime.tryParse('${m['createdAt']}') ?? DateTime.now().toUtc(),
        updatedAt: DateTime.tryParse('${m['updatedAt']}') ?? DateTime.now().toUtc(),
      );

  String toJson() => jsonEncode(toMap());
  factory NetworkNode.fromJson(String s) => NetworkNode.fromMap(jsonDecode(s) as Map<String, dynamic>);
}
