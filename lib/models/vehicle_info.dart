class VehicleInfo {
  final String id;
  final String vehicleType;
  final String licensePlate;
  final DateTime createdAt;

  VehicleInfo({
    required this.id,
    required this.vehicleType,
    required this.licensePlate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleType': vehicleType,
      'licensePlate': licensePlate,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory VehicleInfo.fromMap(Map<String, dynamic> map) {
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
    return VehicleInfo(
      id: map['id']?.toString() ?? '',
      vehicleType: map['vehicleType']?.toString() ?? '',
      licensePlate: map['licensePlate']?.toString() ?? '',
      createdAt: parsedDate,
    );
  }

  VehicleInfo copyWith({
    String? id,
    String? vehicleType,
    String? licensePlate,
    DateTime? createdAt,
  }) {
    return VehicleInfo(
      id: id ?? this.id,
      vehicleType: vehicleType ?? this.vehicleType,
      licensePlate: licensePlate ?? this.licensePlate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
