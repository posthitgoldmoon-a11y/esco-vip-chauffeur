class VehicleInfo {
  final String id;
  final String vehicleType;
  final String licensePlate;

  VehicleInfo({
    required this.id,
    required this.vehicleType,
    required this.licensePlate,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'vehicleType': vehicleType,
        'licensePlate': licensePlate,
      };

  factory VehicleInfo.fromMap(Map<String, dynamic> map) => VehicleInfo(
        id: map['id'] as String,
        vehicleType: map['vehicleType'] as String,
        licensePlate: map['licensePlate'] as String,
      );

  VehicleInfo copyWith({String? id, String? vehicleType, String? licensePlate}) =>
      VehicleInfo(
        id: id ?? this.id,
        vehicleType: vehicleType ?? this.vehicleType,
        licensePlate: licensePlate ?? this.licensePlate,
      );
}
