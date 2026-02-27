

class Booking {
  final String id;
  final String userId;
  final String type;
  final String? departureLocation;
  final String? arrivalLocation;
  final DateTime? scheduledTime;
  final String? passengerName;
  final String? passengerPhone;
  final String? vehicleType;
  final String? licensePlate;
  final bool? parkingRequired;
  final String? usageType;
  final double? totalAmount;
  final String? partnerPreferenceId;
  final String? requestMessage;
  final String status;
  final DateTime createdAt;
  final String? restaurantName;
  final String? restaurantAddress;
  final String? deliveryAddress;
  final String? hospitalName;
  final String? hospitalAddress;
  final DateTime? overnightStartDate;
  final DateTime? overnightEndDate;

  Booking({
    required this.id,
    required this.userId,
    required this.type,
    this.departureLocation,
    this.arrivalLocation,
    this.scheduledTime,
    this.passengerName,
    this.passengerPhone,
    this.vehicleType,
    this.licensePlate,
    this.parkingRequired,
    this.usageType,
    this.totalAmount,
    this.partnerPreferenceId,
    this.requestMessage,
    this.status = 'pending',
    required this.createdAt,
    this.restaurantName,
    this.restaurantAddress,
    this.deliveryAddress,
    this.hospitalName,
    this.hospitalAddress,
    this.overnightStartDate,
    this.overnightEndDate,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'type': type,
        'departureLocation': departureLocation,
        'arrivalLocation': arrivalLocation,
        'scheduledTime': scheduledTime?.toIso8601String(),
        'passengerName': passengerName,
        'passengerPhone': passengerPhone,
        'vehicleType': vehicleType,
        'licensePlate': licensePlate,
        'parkingRequired': parkingRequired,
        'usageType': usageType,
        'totalAmount': totalAmount,
        'partnerPreferenceId': partnerPreferenceId,
        'requestMessage': requestMessage,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
        'restaurantName': restaurantName,
        'restaurantAddress': restaurantAddress,
        'deliveryAddress': deliveryAddress,
        'hospitalName': hospitalName,
        'hospitalAddress': hospitalAddress,
        'overnightStartDate': overnightStartDate?.toIso8601String(),
        'overnightEndDate': overnightEndDate?.toIso8601String(),
      };

  factory Booking.fromMap(Map<String, dynamic> map) => Booking(
        id: map['id'] as String,
        userId: map['userId'] as String,
        type: map['type'] as String,
        departureLocation: map['departureLocation'] as String?,
        arrivalLocation: map['arrivalLocation'] as String?,
        scheduledTime: map['scheduledTime'] != null ? DateTime.parse(map['scheduledTime'] as String) : null,
        passengerName: map['passengerName'] as String?,
        passengerPhone: map['passengerPhone'] as String?,
        vehicleType: map['vehicleType'] as String?,
        licensePlate: map['licensePlate'] as String?,
        parkingRequired: map['parkingRequired'] as bool?,
        usageType: map['usageType'] as String?,
        totalAmount: (map['totalAmount'] as num?)?.toDouble(),
        partnerPreferenceId: map['partnerPreferenceId'] as String?,
        requestMessage: map['requestMessage'] as String?,
        status: map['status'] as String? ?? 'pending',
        createdAt: DateTime.parse(map['createdAt'] as String),
        restaurantName: map['restaurantName'] as String?,
        restaurantAddress: map['restaurantAddress'] as String?,
        deliveryAddress: map['deliveryAddress'] as String?,
        hospitalName: map['hospitalName'] as String?,
        hospitalAddress: map['hospitalAddress'] as String?,
        overnightStartDate: map['overnightStartDate'] != null ? DateTime.parse(map['overnightStartDate'] as String) : null,
        overnightEndDate: map['overnightEndDate'] != null ? DateTime.parse(map['overnightEndDate'] as String) : null,
      );

  Booking copyWith({
    String? id, String? userId, String? type, String? departureLocation,
    String? arrivalLocation, DateTime? scheduledTime, String? passengerName,
    String? passengerPhone, String? vehicleType, String? licensePlate,
    bool? parkingRequired, String? usageType, double? totalAmount,
    String? partnerPreferenceId, String? requestMessage, String? status,
    DateTime? createdAt, String? restaurantName, String? restaurantAddress,
    String? deliveryAddress, String? hospitalName, String? hospitalAddress,
    DateTime? overnightStartDate, DateTime? overnightEndDate,
  }) => Booking(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        type: type ?? this.type,
        departureLocation: departureLocation ?? this.departureLocation,
        arrivalLocation: arrivalLocation ?? this.arrivalLocation,
        scheduledTime: scheduledTime ?? this.scheduledTime,
        passengerName: passengerName ?? this.passengerName,
        passengerPhone: passengerPhone ?? this.passengerPhone,
        vehicleType: vehicleType ?? this.vehicleType,
        licensePlate: licensePlate ?? this.licensePlate,
        parkingRequired: parkingRequired ?? this.parkingRequired,
        usageType: usageType ?? this.usageType,
        totalAmount: totalAmount ?? this.totalAmount,
        partnerPreferenceId: partnerPreferenceId ?? this.partnerPreferenceId,
        requestMessage: requestMessage ?? this.requestMessage,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        restaurantName: restaurantName ?? this.restaurantName,
        restaurantAddress: restaurantAddress ?? this.restaurantAddress,
        deliveryAddress: deliveryAddress ?? this.deliveryAddress,
        hospitalName: hospitalName ?? this.hospitalName,
        hospitalAddress: hospitalAddress ?? this.hospitalAddress,
        overnightStartDate: overnightStartDate ?? this.overnightStartDate,
        overnightEndDate: overnightEndDate ?? this.overnightEndDate,
      );
}
