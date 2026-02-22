class PartnerPreference {
  final String id;
  final bool nonSmoking; // 비흡연
  final String? agePreference; // 20대, 30대, 40대, 50대
  final String? genderPreference; // 남성, 여성
  final List<String> hobbies; // 취미 (골프, 음악, 주식, 기타)
  final String? otherHobby; // 기타 취미 (직접 입력)
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nonSmoking': nonSmoking,
      'agePreference': agePreference,
      'genderPreference': genderPreference,
      'hobbies': hobbies,
      'otherHobby': otherHobby,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PartnerPreference.fromMap(Map<String, dynamic> map) {
    return PartnerPreference(
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
  }

  String get displayText {
    List<String> items = [];
    if (nonSmoking) items.add('비흡연');
    if (agePreference != null) items.add(agePreference!);
    if (genderPreference != null) items.add(genderPreference!);
    if (hobbies.isNotEmpty) {
      final hobbyText = hobbies.join(', ');
      items.add('취미: $hobbyText');
      if (otherHobby != null && otherHobby!.isNotEmpty) {
        items.add('($otherHobby)');
      }
    }
    return items.isEmpty ? '선택 안 함' : items.join(' · ');
  }
}
