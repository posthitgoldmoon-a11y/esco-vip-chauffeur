class PaymentCard {
  final String id;
  final String cardNumber; // 마지막 4자리만 저장 (보안)
  final String cardholderName;
  final String expiryMonth;
  final String expiryYear;
  final String cardType; // Visa, MasterCard, Amex 등
  final bool isDefault;
  final DateTime createdAt;

  PaymentCard({
    required this.id,
    required this.cardNumber,
    required this.cardholderName,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cardType,
    this.isDefault = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cardNumber': cardNumber,
      'cardholderName': cardholderName,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'cardType': cardType,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PaymentCard.fromMap(Map<String, dynamic> map) {
    return PaymentCard(
      id: map['id'] as String,
      cardNumber: map['cardNumber'] as String,
      cardholderName: map['cardholderName'] as String,
      expiryMonth: map['expiryMonth'] as String,
      expiryYear: map['expiryYear'] as String,
      cardType: map['cardType'] as String,
      isDefault: map['isDefault'] as bool? ?? false,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  PaymentCard copyWith({
    String? id,
    String? cardNumber,
    String? cardholderName,
    String? expiryMonth,
    String? expiryYear,
    String? cardType,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return PaymentCard(
      id: id ?? this.id,
      cardNumber: cardNumber ?? this.cardNumber,
      cardholderName: cardholderName ?? this.cardholderName,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      cardType: cardType ?? this.cardType,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get maskedNumber => '**** **** **** $cardNumber';
  String get expiryDate => '$expiryMonth/$expiryYear';
}
