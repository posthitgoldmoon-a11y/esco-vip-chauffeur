class LocationInfo {
  final String id;
  final String address;
  final String? detailAddress;
  final String? name;
  final DateTime createdAt;

  LocationInfo({
    required this.id,
    required this.address,
    this.detailAddress,
    this.name,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'address': address,
      'detailAddress': detailAddress,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory LocationInfo.fromMap(Map<String, dynamic> map) {
    DateTime parsedDate;
    try {
      final raw = map['createdAt'];
      if (raw == null) {
        parsedDate = DateTime.now();
      } else if (raw is String) {
        parsedDate = DateTime.parse(raw);
      } else {
        parsedDate = (raw as dynamic).toDate();
      }
    } catch (_) {
      parsedDate = DateTime.now();
    }
    return LocationInfo(
      id: map['id']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      detailAddress: map['detailAddress']?.toString(),
      name: map['name']?.toString(),
      createdAt: parsedDate,
    );
  }

  LocationInfo copyWith({
    String? id,
    String? address,
    String? detailAddress,
    String? name,
    DateTime? createdAt,
  }) {
    return LocationInfo(
      id: id ?? this.id,
      address: address ?? this.address,
      detailAddress: detailAddress ?? this.detailAddress,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get displayName => name ?? address;
  String get fullAddress => detailAddress != null && detailAddress!.isNotEmpty
      ? '$address, $detailAddress'
      : address;
}
