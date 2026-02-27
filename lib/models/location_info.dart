class LocationInfo {
  final String id;
  final String address;
  final String? detailAddress;
  final String? name;

  LocationInfo({
    required this.id,
    required this.address,
    this.detailAddress,
    this.name,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'address': address,
        'detailAddress': detailAddress,
        'name': name,
      };

  factory LocationInfo.fromMap(Map<String, dynamic> map) => LocationInfo(
        id: map['id'] as String,
        address: map['address'] as String,
        detailAddress: map['detailAddress'] as String?,
        name: map['name'] as String?,
      );

  LocationInfo copyWith({
    String? id,
    String? address,
    String? detailAddress,
    String? name,
  }) => LocationInfo(
        id: id ?? this.id,
        address: address ?? this.address,
        detailAddress: detailAddress ?? this.detailAddress,
        name: name ?? this.name,
      );

  String get displayName => name ?? address;
  String get fullAddress => detailAddress != null ? '$address $detailAddress' : address;
}
