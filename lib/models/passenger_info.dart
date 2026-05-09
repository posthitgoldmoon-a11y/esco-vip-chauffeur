class PassengerInfo {
  final String id;
  final String name;
  final String phoneNumber;
  final DateTime createdAt;

  PassengerInfo({
    required this.id,
    required this.name,
    required this.phoneNumber,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PassengerInfo.fromMap(Map<String, dynamic> map) {
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
    return PassengerInfo(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      phoneNumber: map['phoneNumber']?.toString() ?? '',
      createdAt: parsedDate,
    );
  }

  PassengerInfo copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    DateTime? createdAt,
  }) {
    return PassengerInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
