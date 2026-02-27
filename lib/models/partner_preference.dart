class PartnerPreference {
  final String id;
  final bool nonSmoking;
  final String? agePreference;
  final String? genderPreference;
  final List<String> hobbies;
  final String? otherHobby;
  final DateTime createdAt;

  PartnerPreference({
    required this.id,
    required this.nonSmoking,
    this.agePreference,
    this.genderPreference,
    this.hobbies = const [],
    this.otherHobby,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'nonSmoking': nonSmoking,
        'agePreference': agePreference,
        'genderPreference': genderPreference,
        'hobbies': hobbies,
        'otherHobby': otherHobby,
        'createdAt': createdAt.toIso8601String(),
      };

  factory PartnerPreference.fromMap(Map<String, dynamic> map) =>
      PartnerPreference(
        id: map['id'] as String,
        nonSmoking: map['nonSmoking'] as bool,
        agePreference: map['agePreference'] as String?,
        genderPreference: map['genderPreference'] as String?,
        hobbies: map['hobbies'] != null
            ? List<String>.from(map['hobbies'] as List)
            : [],
        otherHobby: map['otherHobby'] as String?,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );

  String get displayText {
    final List<String> items = [];
    if (nonSmoking) items.add('비흡연');
    if (agePreference != null) items.add(agePreference!);
    if (genderPreference != null) items.add(genderPreference!);
    if (hobbies.isNotEmpty) {
      items.add('취미: ${hobbies.join(', ')}');
      if (otherHobby != null && otherHobby!.isNotEmpty) {
        items.add('($otherHobby)');
      }
    }
    return items.isEmpty ? '선택 안 함' : items.join(' · ');
  }
}
