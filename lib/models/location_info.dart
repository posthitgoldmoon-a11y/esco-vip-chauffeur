class LocationInfo {
  final String id;
  final String address; // 도로명 주소
  final String? detailAddress; // 상세 주소
  final String? name; // 별칭 (예: "집", "회사")

  LocationInfo({
    required this.id,
    required this.address,
    this.detailAddress,
    this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'address': address,
      'detailAddress': detailAddress,
      'name': name,
    };
  }

  factory LocationInfo.fromMap(Map<String, dynamic> map) {
    return LocationInfo(
      id: map['id'] as String,
      address: map['address'] as String,
      detailAddress: map['detailAddress'] as String?,
      name: map['name'] as String?,
    );
  }

  LocationInfo copyWith({
    String? id,
    String? address,
    String? detailAddress,
    String? name,
  }) {
    return LocationInfo(
      id: id ?? this.id,
      address: address ?? this.address,
      detailAddress: detailAddress ?? this.detailAddress,
      name: name ?? this.name,
    );
  }

  String get displayName => name ?? address;
  String get fullAddress => detailAddress != null && detailAddress!.isNotEmpty
      ? '$address, $detailAddress'
      : address;
}
