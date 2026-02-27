class PassengerInfo {
  final String id;
  final String name;
  final String phoneNumber;

  PassengerInfo({
    required this.id,
    required this.name,
    required this.phoneNumber,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phoneNumber': phoneNumber,
      };

  factory PassengerInfo.fromMap(Map<String, dynamic> map) => PassengerInfo(
        id: map['id'] as String,
        name: map['name'] as String,
        phoneNumber: map['phoneNumber'] as String,
      );

  PassengerInfo copyWith({String? id, String? name, String? phoneNumber}) =>
      PassengerInfo(
        id: id ?? this.id,
        name: name ?? this.name,
        phoneNumber: phoneNumber ?? this.phoneNumber,
      );
}
