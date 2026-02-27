import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../services/storage_service.dart';
import '../models/booking.dart';
import '../models/passenger_info.dart';
import '../models/vehicle_info.dart';
import '../models/location_info.dart';
import '../widgets/address_search_dialog.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _requestController = TextEditingController();
  final String _bookingType = 'chauffeur';
  DateTime? _scheduledTime;
  PassengerInfo? _selectedPassenger;
  VehicleInfo? _selectedVehicle;
  LocationInfo? _departureLocation;
  LocationInfo? _arrivalLocation;
  bool _parkingRequired = false;
  String _usageType = '일반';
  List<PassengerInfo> _passengers = [];
  List<VehicleInfo> _vehicles = [];
  bool _isLoading = false;
  bool _isDataLoading = true;

  final List<String> _usageTypes = [
    '일반',
    '병원동행',
    '공항픽업',
    '골프',
    '기타',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _requestController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isDataLoading = true);
    try {
      final passengers = await StorageService.getPassengers();
      final vehicles = await StorageService.getVehicles();
      setState(() {
        _passengers = passengers;
        _vehicles = vehicles;
        _isDataLoading = false;
      });
    } catch (e) {
      setState(() => _isDataLoading = false);
    }
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;
    setState(() {
      _scheduledTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _selectAddress(bool isDeparture) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const AddressSearchDialog(),
    );
    if (result == null) return;
    final location = LocationInfo(
      id: const Uuid().v4(),
      address: result['address'] ?? '',
      detailAddress: result['detailAddress'],
      name: result['name'],
    );
    setState(() {
      if (isDeparture) {
        _departureLocation = location;
      } else {
        _arrivalLocation = location;
      }
    });
  }

  double _calculateAmount() {
    double base = 50000;
    if (_usageType == '병원동행') base += 20000;
    if (_usageType == '공항픽업') base += 30000;
    if (_usageType == '골프') base += 50000;
    if (_parkingRequired) base += 10000;
    return base;
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate() ||
        _scheduledTime == null ||
        _departureLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('필수 정보를 입력해주세요')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final appProvider =
          Provider.of<AppProvider>(context, listen: false);
      final booking = Booking(
        id: const Uuid().v4(),
        userId: appProvider.userId!,
        type: _bookingType,
        departureLocation: _departureLocation?.fullAddress,
        arrivalLocation: _arrivalLocation?.fullAddress,
        scheduledTime: _scheduledTime,
        passengerName: _selectedPassenger?.name,
        passengerPhone: _selectedPassenger?.phoneNumber,
        vehicleType: _selectedVehicle?.vehicleType,
        licensePlate: _selectedVehicle?.licensePlate,
        parkingRequired: _parkingRequired,
        usageType: _usageType,
        totalAmount: _calculateAmount(),
        requestMessage: _requestController.text,
        createdAt: DateTime.now(),
      );
      await StorageService.createBooking(booking);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('예약이 완료되었습니다!')));
      setState(() {
        _scheduledTime = null;
        _selectedPassenger = null;
        _selectedVehicle = null;
        _departureLocation = null;
        _arrivalLocation = null;
        _parkingRequired = false;
        _usageType = '일반';
        _isLoading = false;
      });
      _requestController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('예약 실패: $e')));
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('운전대행 예약')),
      body: _isDataLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ─── 이용 유형 ─────────────────────────────────
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '이용 유형',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: _usageType,
                            items: _usageTypes
                                .map((t) => DropdownMenuItem(
                                    value: t, child: Text(t)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _usageType = v!),
                            decoration: const InputDecoration(
                                labelText: '이용 유형'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ─── 예약 시간 ─────────────────────────────────
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.access_time),
                      title: const Text('예약 시간'),
                      subtitle: Text(
                        _scheduledTime != null
                            ? DateFormat('yyyy-MM-dd HH:mm')
                                .format(_scheduledTime!)
                            : '시간을 선택해주세요',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _selectDateTime,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ─── 출발지 / 도착지 ───────────────────────────
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '출발지 / 도착지',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ListTile(
                            leading: const Icon(
                                Icons.location_on,
                                color: Colors.green),
                            title: const Text('출발지'),
                            subtitle: Text(
                              _departureLocation?.fullAddress ??
                                  '출발지를 선택해주세요',
                            ),
                            trailing: const Icon(Icons.search),
                            onTap: () => _selectAddress(true),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(
                                Icons.location_on,
                                color: Colors.red),
                            title: const Text('도착지'),
                            subtitle: Text(
                              _arrivalLocation?.fullAddress ??
                                  '도착지를 선택해주세요 (선택)',
                            ),
                            trailing: const Icon(Icons.search),
                            onTap: () => _selectAddress(false),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ─── 탑승자 선택 ───────────────────────────────
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '탑승자',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<PassengerInfo?>(
                            initialValue: _selectedPassenger,
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('직접 탑승'),
                              ),
                              ..._passengers.map(
                                (p) => DropdownMenuItem(
                                  value: p,
                                  child: Text(p.name),
                                ),
                              ),
                            ],
                            onChanged: (v) => setState(
                                () => _selectedPassenger = v),
                            decoration: const InputDecoration(
                                labelText: '탑승자 선택'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ─── 차량 선택 ─────────────────────────────────
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '차량',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<VehicleInfo?>(
                            initialValue: _selectedVehicle,
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('차량 선택 안함'),
                              ),
                              ..._vehicles.map(
                                (v) => DropdownMenuItem(
                                  value: v,
                                  child: Text(
                                      '${v.vehicleType} (${v.licensePlate})'),
                                ),
                              ),
                            ],
                            onChanged: (v) => setState(
                                () => _selectedVehicle = v),
                            decoration: const InputDecoration(
                                labelText: '차량 선택'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ─── 주차 대행 ─────────────────────────────────
                  Card(
                    child: SwitchListTile(
                      title: const Text('주차 대행'),
                      subtitle: const Text('주차 대행 서비스 (+10,000원)'),
                      value: _parkingRequired,
                      onChanged: (v) =>
                          setState(() => _parkingRequired = v),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ─── 요청사항 ──────────────────────────────────
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextFormField(
                        controller: _requestController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: '요청사항 (선택)',
                          hintText: '특별한 요청사항이 있으시면 입력해주세요',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ─── 예상 금액 ─────────────────────────────────
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '예상 금액',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${NumberFormat('#,###').format(_calculateAmount())}원',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ─── 예약 버튼 ─────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitBooking,
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white)
                          : const Text(
                              '예약하기',
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
