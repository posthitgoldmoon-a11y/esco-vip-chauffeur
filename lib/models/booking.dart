class Booking {
  final String id;
  final String userId;
  final String type; // 'driver' or 'restaurant'
  final String departureLocation;
  final String? waypointLocation;
  final String arrivalLocation;
  final DateTime scheduledTime;
  final String passengerName;
  final String passengerPhone;
  final String vehicleType;
  final String licensePlate;
  final String? customerParkingLocation;
  final bool driverParkingAvailable;
  final String? driverParkingLocation;
  final int usageHours;
  final int totalAmount;
  final String? partnerPreferenceId;
  final String? requestMessage;
  final String status;
  final DateTime createdAt;
  
  // Restaurant delivery specific fields
  final String? restaurantName;
  final String? restaurantAddress;
  final String? menu;
  final String? deliveryAddress;
  final double? distanceKm;
  
  // Hospital companion specific fields
  final bool isHospitalCompanion;
  final int hospitalCompanionHours;

  Booking({
    required this.id,
    required this.userId,
    this.type = 'driver', // default to driver for backward compatibility
    required this.departureLocation,
    this.waypointLocation,
    required this.arrivalLocation,
    required this.scheduledTime,
    required this.passengerName,
    required this.passengerPhone,
    required this.vehicleType,
    required this.licensePlate,
    this.customerParkingLocation,
    required this.driverParkingAvailable,
    this.driverParkingLocation,
    required this.usageHours,
    required this.totalAmount,
    this.partnerPreferenceId,
    this.requestMessage,
    required this.status,
    required this.createdAt,
    this.restaurantName,
    this.restaurantAddress,
    this.menu,
    this.deliveryAddress,
    this.distanceKm,
    this.isHospitalCompanion = false,
    this.hospitalCompanionHours = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'departureLocation': departureLocation,
      'waypointLocation': waypointLocation,
      'arrivalLocation': arrivalLocation,
      'scheduledTime': scheduledTime.toIso8601String(),
      'passengerName': passengerName,
      'passengerPhone': passengerPhone,
      'vehicleType': vehicleType,
      'licensePlate': licensePlate,
      'customerParkingLocation': customerParkingLocation,
      'driverParkingAvailable': driverParkingAvailable,
      'driverParkingLocation': driverParkingLocation,
      'usageHours': usageHours,
      'totalAmount': totalAmount,
      'partnerPreferenceId': partnerPreferenceId,
      'requestMessage': requestMessage,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'restaurantName': restaurantName,
      'restaurantAddress': restaurantAddress,
      'menu': menu,
      'deliveryAddress': deliveryAddress,
      'distanceKm': distanceKm,
      'isHospitalCompanion': isHospitalCompanion,
      'hospitalCompanionHours': hospitalCompanionHours,
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'] as String,
      userId: map['userId'] as String,
      type: map['type'] as String? ?? 'driver',
      departureLocation: map['departureLocation'] as String? ?? '',
      waypointLocation: map['waypointLocation'] as String?,
      arrivalLocation: map['arrivalLocation'] as String? ?? '',
      scheduledTime: DateTime.parse(map['scheduledTime'] as String),
      passengerName: map['passengerName'] as String? ?? '',
      passengerPhone: map['passengerPhone'] as String? ?? '',
      vehicleType: map['vehicleType'] as String? ?? '',
      licensePlate: map['licensePlate'] as String? ?? '',
      customerParkingLocation: map['customerParkingLocation'] as String?,
      driverParkingAvailable: map['driverParkingAvailable'] as bool? ?? false,
      driverParkingLocation: map['driverParkingLocation'] as String?,
      usageHours: map['usageHours'] as int? ?? 4,
      totalAmount: map['totalAmount'] as int? ?? 120000,
      partnerPreferenceId: map['partnerPreferenceId'] as String?,
      requestMessage: map['requestMessage'] as String?,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      restaurantName: map['restaurantName'] as String?,
      restaurantAddress: map['restaurantAddress'] as String?,
      menu: map['menu'] as String?,
      deliveryAddress: map['deliveryAddress'] as String?,
      distanceKm: map['distanceKm'] as double?,
      isHospitalCompanion: map['isHospitalCompanion'] as bool? ?? false,
      hospitalCompanionHours: map['hospitalCompanionHours'] as int? ?? 0,
    );
  }

  Booking copyWith({
    String? id,
    String? userId,
    String? type,
    String? departureLocation,
    String? waypointLocation,
    String? arrivalLocation,
    DateTime? scheduledTime,
    String? passengerName,
    String? passengerPhone,
    String? vehicleType,
    String? licensePlate,
    String? customerParkingLocation,
    bool? driverParkingAvailable,
    String? driverParkingLocation,
    int? usageHours,
    int? totalAmount,
    String? partnerPreferenceId,
    String? requestMessage,
    String? status,
    DateTime? createdAt,
    String? restaurantName,
    String? restaurantAddress,
    String? menu,
    String? deliveryAddress,
    double? distanceKm,
    bool? isHospitalCompanion,
    int? hospitalCompanionHours,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      departureLocation: departureLocation ?? this.departureLocation,
      waypointLocation: waypointLocation ?? this.waypointLocation,
      arrivalLocation: arrivalLocation ?? this.arrivalLocation,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      passengerName: passengerName ?? this.passengerName,
      passengerPhone: passengerPhone ?? this.passengerPhone,
      vehicleType: vehicleType ?? this.vehicleType,
      licensePlate: licensePlate ?? this.licensePlate,
      customerParkingLocation: customerParkingLocation ?? this.customerParkingLocation,
      driverParkingAvailable: driverParkingAvailable ?? this.driverParkingAvailable,
      driverParkingLocation: driverParkingLocation ?? this.driverParkingLocation,
      usageHours: usageHours ?? this.usageHours,
      totalAmount: totalAmount ?? this.totalAmount,
      partnerPreferenceId: partnerPreferenceId ?? this.partnerPreferenceId,
      requestMessage: requestMessage ?? this.requestMessage,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      restaurantName: restaurantName ?? this.restaurantName,
      restaurantAddress: restaurantAddress ?? this.restaurantAddress,
      menu: menu ?? this.menu,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      distanceKm: distanceKm ?? this.distanceKm,
      isHospitalCompanion: isHospitalCompanion ?? this.isHospitalCompanion,
      hospitalCompanionHours: hospitalCompanionHours ?? this.hospitalCompanionHours,
    );
  }
}
