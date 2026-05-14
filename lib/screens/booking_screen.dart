import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/app_provider.dart';
import '../services/storage_service.dart';
import '../models/booking.dart';
import '../models/passenger_info.dart';
import '../models/vehicle_info.dart';
import '../models/location_info.dart';
import '../models/partner_preference.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _departureController = TextEditingController();
  final _waypointController = TextEditingController();
  final _arrivalController = TextEditingController();
  final _passengerNameController = TextEditingController();
  final _passengerPhoneController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _customerParkingLocationController = TextEditingController(); // 고객 차량 주차 위치
  final _requestMessageController = TextEditingController(); // 요청사항

  DateTime _selectedDateTime = DateTime.now().add(const Duration(hours: 1));
  int _usageHours = 4; // 이용시간 (기본 4시간)
  bool _driverParkingAvailable = false;
  bool _arrivalSameAsDeparture = false; // 도착지 = 출발지
  String? _selectedPartnerPreferenceId; // 선택된 파트너 선택사항 ID
  bool _isOvernight = false; // 숙박 여부
  int _overnightDays = 1; // 숙박 일수 (기본 1박)
  bool _isHospitalCompanion = false; // 병원동행 여부
  int _hospitalCompanionHours = 1; // 병원동행 시간 (기본 1시간)

  List<PassengerInfo> _savedPassengers = [];
  List<VehicleInfo> _savedVehicles = [];
  List<LocationInfo> _savedLocations = [];
  List<PartnerPreference> _savedPartnerPreferences = [];
  List<String> _savedParkingLocations = [];
  
  // 요금 계산
  int get _totalAmount {
    int baseAmount = 0;
    if (_isOvernight) {
      baseAmount = _overnightDays * 510000; // 1박당 51만원
    } else {
      baseAmount = _usageHours * 30000; // 시간당 3만원
    }
    
    // 병원동행 요금 추가
    if (_isHospitalCompanion) {
      baseAmount += _hospitalCompanionHours * 20000; // 시간당 2만원
    }
    
    return baseAmount;
  }
  
  DateTime get _endDateTime => _selectedDateTime.add(Duration(hours: _usageHours));

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    try {
      final passengers = await StorageService.getPassengers();
      final vehicles = await StorageService.getVehicles();
      final locations = await StorageService.getLocations();
      final preferences = await StorageService.getPartnerPreferences();
      final parkingBox = await Hive.openBox('parkingLocations');
      final parkingLocations = parkingBox.values.cast<String>().toList();

      if (kDebugMode) {
        print('✅ 예약 화면 - 저장된 데이터 로드:');
        print('  - 탑승자: ${passengers.length}개');
        print('  - 차량: ${vehicles.length}개');
        print('  - 장소: ${locations.length}개');
        print('  - 파트너 선호: ${preferences.length}개');
      }

      setState(() {
        _savedPassengers = passengers;
        _savedVehicles = vehicles;
        _savedLocations = locations;
        _savedPartnerPreferences = preferences;
        _savedParkingLocations = parkingLocations;
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ 예약 화면 - 데이터 로드 실패: $e');
      }
    }
  }

  @override
  void dispose() {
    _departureController.dispose();
    _waypointController.dispose();
    _arrivalController.dispose();
    _passengerNameController.dispose();
    _passengerPhoneController.dispose();
    _vehicleTypeController.dispose();
    _licensePlateController.dispose();
    _customerParkingLocationController.dispose();
    _requestMessageController.dispose();
    super.dispose();
  }

  Future<void> _submitBooking() async {
    if (_departureController.text.trim().isEmpty ||
        _arrivalController.text.trim().isEmpty ||
        _passengerNameController.text.trim().isEmpty ||
        _passengerPhoneController.text.trim().isEmpty ||
        _vehicleTypeController.text.trim().isEmpty ||
        _licensePlateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('필수 항목을 모두 입력해주세요')),
      );
      return;
    }

    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final booking = Booking(
      id: const Uuid().v4(),
      userId: appProvider.userId!,
      departureLocation: _departureController.text.trim(),
      waypointLocation: _waypointController.text.trim().isEmpty
          ? null
          : _waypointController.text.trim(),
      arrivalLocation: _arrivalController.text.trim(),
      scheduledTime: _selectedDateTime,
      passengerName: _passengerNameController.text.trim(),
      passengerPhone: _passengerPhoneController.text.trim(),
      vehicleType: _vehicleTypeController.text.trim(),
      licensePlate: _licensePlateController.text.trim(),
      customerParkingLocation: _customerParkingLocationController.text.trim().isEmpty
          ? null
          : _customerParkingLocationController.text.trim(),
      driverParkingAvailable: _driverParkingAvailable,
      driverParkingLocation: null,
      usageHours: _usageHours,
      totalAmount: _totalAmount,
      requestMessage: _requestMessageController.text.trim().isEmpty
          ? null
          : _requestMessageController.text.trim(),
      partnerPreferenceId: _selectedPartnerPreferenceId,
      status: 'pending',
      createdAt: DateTime.now(),
      isHospitalCompanion: _isHospitalCompanion,
      hospitalCompanionHours: _hospitalCompanionHours,
    );

    await StorageService.saveBooking(booking);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('예약이 완료되었습니다')),
    );

    // Clear form
    _departureController.clear();
    _waypointController.clear();
    _arrivalController.clear();
    _passengerNameController.clear();
    _passengerPhoneController.clear();
    _vehicleTypeController.clear();
    _licensePlateController.clear();
    _customerParkingLocationController.clear();
    _requestMessageController.clear();
    setState(() {
      _driverParkingAvailable = false;
      _arrivalSameAsDeparture = false;
      _usageHours = 4;
      _selectedPartnerPreferenceId = null;
      _isOvernight = false;
      _overnightDays = 1;
      _isHospitalCompanion = false;
      _hospitalCompanionHours = 1;
      _isHospitalCompanion = false;
      _hospitalCompanionHours = 1;
      _selectedDateTime = DateTime.now().add(const Duration(hours: 1));
    });
  }

  // 저장된 탑승자 선택
  Future<void> _selectPassenger() async {
    if (_savedPassengers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장된 탑승자가 없습니다. 마이페이지에서 탑승자를 추가해주세요.')),
      );
      return;
    }

    final selected = await showDialog<PassengerInfo>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('저장된 탑승자 선택'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _savedPassengers.length,
            itemBuilder: (context, index) {
              final passenger = _savedPassengers[index];
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(passenger.name),
                subtitle: Text(passenger.phoneNumber),
                onTap: () => Navigator.pop(context, passenger),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
        ],
      ),
    );

    if (selected != null) {
      setState(() {
        _passengerNameController.text = selected.name;
        _passengerPhoneController.text = selected.phoneNumber;
      });
    }
  }

  // 저장된 차량 선택
  Future<void> _selectVehicle() async {
    if (_savedVehicles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장된 차량이 없습니다. 마이페이지에서 차량을 추가해주세요.')),
      );
      return;
    }

    final selected = await showDialog<VehicleInfo>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('저장된 차량 선택'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _savedVehicles.length,
            itemBuilder: (context, index) {
              final vehicle = _savedVehicles[index];
              return ListTile(
                leading: const Icon(Icons.directions_car),
                title: Text(vehicle.vehicleType),
                subtitle: Text(vehicle.licensePlate),
                onTap: () => Navigator.pop(context, vehicle),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
        ],
      ),
    );

    if (selected != null) {
      setState(() {
        _vehicleTypeController.text = selected.vehicleType;
        _licensePlateController.text = selected.licensePlate;
      });
    }
  }

  // 저장된 파트너 선호사항 선택
  Future<void> _selectPartnerPreference() async {
    if (_savedPartnerPreferences.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장된 파트너 선호사항이 없습니다. 마이페이지에서 추가해주세요.')),
      );
      return;
    }

    final selected = await showDialog<PartnerPreference>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('파트너 선택사항 선택'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _savedPartnerPreferences.length,
            itemBuilder: (context, index) {
              final pref = _savedPartnerPreferences[index];
              return ListTile(
                leading: const Icon(Icons.person_search),
                title: Text(pref.displayText),
                onTap: () => Navigator.pop(context, pref),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
        ],
      ),
    );

    if (selected != null) {
      setState(() {
        _selectedPartnerPreferenceId = selected.id;
      });
    }
  }

  // 저장된 장소 선택
  Future<void> _selectParkingLocation(TextEditingController controller) async {
    if (_savedParkingLocations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장된 주차위치가 없습니다. 마이페이지에서 주차위치를 추가해주세요.')),
      );
      return;
    }
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('저장된 주차위치 선택'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _savedParkingLocations.length,
            itemBuilder: (context, index) {
              final location = _savedParkingLocations[index];
              return ListTile(
                leading: const Icon(Icons.local_parking),
                title: Text(location),
                onTap: () => Navigator.pop(context, location),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
        ],
      ),
    );
    if (selected != null) {
      controller.text = selected;
    }
  }

  Future<void> _selectLocation(TextEditingController controller) async {
    if (_savedLocations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장된 장소가 없습니다. 마이페이지에서 장소를 추가해주세요.')),
      );
      return;
    }

    final selected = await showDialog<LocationInfo>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('저장된 장소 선택'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _savedLocations.length,
            itemBuilder: (context, index) {
              final location = _savedLocations[index];
              return ListTile(
                leading: const Icon(Icons.location_on),
                title: Text(location.name ?? location.address),
                subtitle: Text(location.address),
                onTap: () => Navigator.pop(context, location),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
        ],
      ),
    );

    if (selected != null) {
      setState(() {
        controller.text = selected.address;
      });
    }
  }

  // 날짜 선택
  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _selectedDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          _selectedDateTime.hour,
          _selectedDateTime.minute,
        );
      });
    }
  }

  // 시간 선택
  Future<void> _selectHour() async {
    final hour = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('시작 시간 선택'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: 24,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('${index.toString().padLeft(2, '0')}:00'),
                onTap: () => Navigator.pop(context, index),
              );
            },
          ),
        ),
      ),
    );

    if (hour != null) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          hour,
          0,
        );
      });
    }
  }

  // 이용시간 선택
  Future<void> _selectUsageHours() async {
    final hours = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이용시간 선택'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: 12,
            itemBuilder: (context, index) {
              final hour = index + 1;
              return ListTile(
                title: Text('$hour시간'),
                subtitle: Text('₩${(hour * 30000).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}'),
                onTap: () => Navigator.pop(context, hour),
              );
            },
          ),
        ),
      ),
    );

    if (hours != null) {
      setState(() {
        _usageHours = hours;
      });
    }
  }

  // 숙박 일수 선택
  Future<void> _selectOvernightDays() async {
    final days = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('숙박 일수 선택'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: 7,
            itemBuilder: (context, index) {
              final day = index + 1;
              return ListTile(
                title: Text('$day박'),
                subtitle: Text('₩${(day * 510000).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}'),
                onTap: () => Navigator.pop(context, day),
              );
            },
          ),
        ),
      ),
    );

    if (days != null) {
      setState(() {
        _overnightDays = days;
      });
    }
  }

  // 병원동행 시간 선택
  Future<void> _selectHospitalCompanionHours() async {
    final hours = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('병원동행 이용시간 선택'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              final hour = index + 1;
              return ListTile(
                title: Text('$hour시간'),
                subtitle: Text('₩${(hour * 20000).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}'),
                onTap: () => Navigator.pop(context, hour),
              );
            },
          ),
        ),
      ),
    );

    if (hours != null) {
      setState(() {
        _hospitalCompanionHours = hours;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('예약하기'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Location Section
            _buildSectionTitle('출발지 / 경유지 / 도착지', true),
            const SizedBox(height: 8),
            _buildLocationField(
              controller: _departureController,
              label: '출발지',
              icon: Icons.trip_origin,
              onSelectSaved: () => _selectLocation(_departureController),
            ),
            const SizedBox(height: 12),
            _buildLocationField(
              controller: _waypointController,
              label: '경유지 (선택)',
              icon: Icons.more_horiz,
              onSelectSaved: () => _selectLocation(_waypointController),
            ),
            const SizedBox(height: 12),
            _buildLocationField(
              controller: _arrivalController,
              label: '도착지',
              icon: Icons.location_on,
              onSelectSaved: () => _selectLocation(_arrivalController),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(
                  value: _arrivalSameAsDeparture,
                  onChanged: (value) {
                    setState(() {
                      _arrivalSameAsDeparture = value ?? false;
                      if (_arrivalSameAsDeparture) {
                        _arrivalController.text = _departureController.text;
                      }
                    });
                  },
                ),
                const Text('출발지와 동일합니다'),
              ],
            ),

            const SizedBox(height: 24),

            // DateTime Section
            Row(
              children: [
                Expanded(child: _buildSectionTitle('일정', true)),
                Row(
                  children: [
                    Checkbox(
                      value: _isOvernight,
                      onChanged: (value) {
                        setState(() {
                          _isOvernight = value ?? false;
                        });
                      },
                    ),
                    const Text('숙박'),
                    const SizedBox(width: 8),
                    Checkbox(
                      value: _isHospitalCompanion,
                      onChanged: (value) {
                        setState(() {
                          _isHospitalCompanion = value ?? false;
                        });
                      },
                    ),
                    const Text('병원동행'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Date Selection
            InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.grey.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${_selectedDateTime.year}년 ${_selectedDateTime.month}월 ${_selectedDateTime.day}일',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade600),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            if (_isOvernight) ...[
              // Overnight Days Selection
              InkWell(
                onTap: _selectOvernightDays,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.hotel, color: Colors.grey.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '숙박 일수: $_overnightDays박',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade600),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Overnight Notice
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '숙박 안내',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• 숙박의 경우 매일 기본 이용시간이 12시간으로 적용됩니다',
                      style: TextStyle(
                        color: Colors.blue.shade900,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• 출장비는 1박 당 15만원이 별도 부과되며, 파트너의 숙박비, 식사비가 포함됩니다',
                      style: TextStyle(
                        color: Colors.blue.shade900,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Hospital Companion Hours Selection
            if (_isHospitalCompanion) ...[
              const SizedBox(height: 12),
              InkWell(
                onTap: _selectHospitalCompanionHours,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.local_hospital, color: Colors.grey.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '병원동행 이용시간: $_hospitalCompanionHours시간 (₩${_hospitalCompanionHours * 20000})',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade600),
                    ],
                  ),
                ),
              ),
            ],
            
            if (!_isOvernight) ...[
              const SizedBox(height: 12),
              // Time Selection (Hour) - only show when not overnight
              InkWell(
                onTap: _selectHour,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.grey.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '시작시간: ${_selectedDateTime.hour.toString().padLeft(2, '0')}:00',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade600),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),
              
              // Usage Hours Selection
              InkWell(
                onTap: _selectUsageHours,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.schedule, color: Colors.grey.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '이용시간: $_usageHours시간',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade600),
                  ],
                ),
              ),
            ),

              const SizedBox(height: 8),

              // End Time Display - only for hourly bookings
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey.shade600, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '종료시간: ${_endDateTime.hour.toString().padLeft(2, '0')}:${_endDateTime.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 8),

            // Hospital Companion Section
            if (_isHospitalCompanion) ...[
              InkWell(
                onTap: _selectHospitalCompanionHours,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.local_hospital, color: Colors.grey.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '병원동행 이용시간: $_hospitalCompanionHours시간',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade600),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.green.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '병원동행 요금: ${_hospitalCompanionHours * 20000}원 (시간당 20,000원)',
                        style: TextStyle(
                          color: Colors.green.shade900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Total Amount Display
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.payment, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _isOvernight
                              ? '운전 이용요금: ${(_overnightDays * 510000).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원 ($_overnightDays박 × 510,000원)'
                              : '운전 이용요금: ${(_usageHours * 30000).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원 (시간당 30,000원)',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_isHospitalCompanion) ...[
                    const SizedBox(height: 4),
                    Text(
                      '+ 병원동행: ${(_hospitalCompanionHours * 20000).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원 (시간당 20,000원)',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const Divider(color: Colors.white30, height: 16),
                  ],
                  Text(
                    '예상 이용요금: ${_totalAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Passenger Section
            _buildSectionTitle('탑승자 정보', true),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _passengerNameController,
              label: '이름',
              icon: Icons.person_outline,
              onSelectSaved: () => _selectPassenger(),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _passengerPhoneController,
              label: '전화번호',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 24),

            // Vehicle Section
            _buildSectionTitle('이용 차량', true),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _vehicleTypeController,
              label: '차종',
              icon: Icons.directions_car_outlined,
              onSelectSaved: () => _selectVehicle(),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _licensePlateController,
              label: '차량번호',
              icon: Icons.confirmation_number_outlined,
            ),

            const SizedBox(height: 24),

            // Partner Preference Section
            _buildSectionTitle('파트너 선택 (선택사항)'),
            const SizedBox(height: 8),
            InkWell(
              onTap: _savedPartnerPreferences.isEmpty
                  ? null
                  : () => _selectPartnerPreference(),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _selectedPartnerPreferenceId != null
                      ? Colors.blue.shade50
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedPartnerPreferenceId != null
                        ? Colors.blue.shade300
                        : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_search,
                      color: _selectedPartnerPreferenceId != null
                          ? Colors.blue.shade700
                          : Colors.grey.shade700,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedPartnerPreferenceId != null
                            ? _savedPartnerPreferences
                                .firstWhere((p) => p.id == _selectedPartnerPreferenceId)
                                .displayText
                            : '파트너 조건 선택 (선택사항)',
                        style: TextStyle(
                          fontSize: 16,
                          color: _selectedPartnerPreferenceId != null
                              ? Colors.blue.shade900
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                    if (_selectedPartnerPreferenceId != null)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          setState(() => _selectedPartnerPreferenceId = null);
                        },
                      )
                    else
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey.shade600, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '상황에 따라 비선택 파트너로 매칭이 될 수 있습니다',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_savedPartnerPreferences.isEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '파트너 선택사항은 마이페이지에서 등록할 수 있습니다',
                        style: TextStyle(
                          color: Colors.amber.shade900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Customer Parking Location Section
            _buildSectionTitle('고객 차량 주차 위치'),
            const SizedBox(height: 8),
            _buildLocationField(
              controller: _customerParkingLocationController,
              label: '차량이 주차된 위치 (선택)',
              icon: Icons.local_parking,
              onSelectSaved: () => _selectParkingLocation(_customerParkingLocationController),
            ),

            const SizedBox(height: 24),

            // Driver Parking Section
            _buildSectionTitle('파트너 주차지원'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '주차지원이 가능한 경우 빠른 매칭 확률이 높아집니다',
                      style: TextStyle(
                        color: Colors.blue.shade900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              value: _driverParkingAvailable,
              onChanged: (value) {
                setState(() => _driverParkingAvailable = value);
              },
              title: const Text('파트너 주차지원 가능'),
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 24),

            // Request Message Section
            _buildSectionTitle('예약 요청사항 (선택사항)'),
            const SizedBox(height: 8),
            TextField(
              controller: _requestMessageController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: '요청하실 내용을 입력해주세요',
                prefixIcon: const Icon(Icons.message_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Submit Button
            ElevatedButton(
              onPressed: _submitBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade800,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                '예약하기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 16),

            OutlinedButton.icon(
              onPressed: () async {
                final uri = Uri.parse('tel:0503-7153-8223');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
              icon: const Icon(Icons.phone, color: Color(0xFF1a73e8)),
              label: const Text(
                '전화로 예약하기  0503-7153-8223',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF1a73e8),
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                side: const BorderSide(color: Color(0xFF1a73e8), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, [bool isRequired = false]) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        if (isRequired) ...[
          const SizedBox(width: 4),
          const Text("*필수", style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold)),
        ],
      ],
    );
  }

  Widget _buildLocationField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    VoidCallback? onSelectSaved,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: onSelectSaved != null
            ? IconButton(
                icon: const Icon(Icons.bookmark_border),
                onPressed: onSelectSaved,
                tooltip: '불러오기',
              )
            : null,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    VoidCallback? onSelectSaved,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: onSelectSaved != null
            ? IconButton(
                icon: const Icon(Icons.bookmark_border),
                onPressed: onSelectSaved,
                tooltip: '불러오기',
              )
            : null,
      ),
    );
  }
}




