import 'package:flutter/material.dart';
import 'dart:math' show cos, sqrt, asin;
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/storage_service.dart';
import '../models/location_info.dart';
import '../models/booking.dart';
import '../widgets/address_search_dialog.dart';

class RestaurantDeliveryScreen extends StatefulWidget {
  const RestaurantDeliveryScreen({super.key});

  @override
  State<RestaurantDeliveryScreen> createState() => _RestaurantDeliveryScreenState();
}

class _RestaurantDeliveryScreenState extends State<RestaurantDeliveryScreen> {
  final _restaurantNameController = TextEditingController();
  final _restaurantAddressController = TextEditingController();
  final _menuController = TextEditingController();
  final _deliveryAddressController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(hours: 1));
  TimeOfDay _selectedTime = TimeOfDay.now();
  List<LocationInfo> _savedLocations = [];
  
  // 좌표 저장
  double? _restaurantLat;
  double? _restaurantLng;
  double? _deliveryLat;
  double? _deliveryLng;
  
  // 거리 및 배송료
  double? _distanceKm;
  int? _deliveryFee;

  @override
  void initState() {
    super.initState();
    _loadSavedLocations();
  }

  Future<void> _loadSavedLocations() async {
    final locations = await StorageService.getLocations();
    setState(() {
      _savedLocations = locations;
    });
  }

  @override
  void dispose() {
    _restaurantNameController.dispose();
    _restaurantAddressController.dispose();
    _menuController.dispose();
    _deliveryAddressController.dispose();
    super.dispose();
  }
  
  // 거리 계산 함수 (Haversine formula)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 - cos((lat2 - lat1) * p) / 2 + 
              cos(lat1 * p) * cos(lat2 * p) * 
              (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }
  
  // 배송료 계산 함수
  int _calculateDeliveryFee(double distanceKm) {
    if (distanceKm <= 30) return 55000;
    if (distanceKm <= 50) return 80000;
    if (distanceKm <= 100) return 100000;
    if (distanceKm <= 150) return 150000;
    if (distanceKm <= 250) return 200000;
    if (distanceKm <= 350) return 250000;
    if (distanceKm <= 450) return 350000;
    return 350000; // 450km 초과시에도 최대 요금
  }
  
  // 거리 및 배송료 업데이트
  void _updateDistanceAndFee() {
    if (_restaurantLat != null && _restaurantLng != null &&
        _deliveryLat != null && _deliveryLng != null) {
      final distance = _calculateDistance(
        _restaurantLat!, 
        _restaurantLng!, 
        _deliveryLat!, 
        _deliveryLng!
      );
      
      setState(() {
        _distanceKm = distance;
        _deliveryFee = _calculateDeliveryFee(distance);
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDate.hour,
          _selectedDate.minute,
        );
      });
    }
  }

  Future<void> _selectTime() async {
    final hours = List.generate(24, (index) => index);
    
    final selectedHour = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('시간 선택'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: hours.length,
            itemBuilder: (context, index) {
              final hour = hours[index];
              final isSelected = hour == _selectedTime.hour;
              return ListTile(
                selected: isSelected,
                selectedTileColor: Colors.grey.shade100,
                leading: Icon(
                  Icons.access_time,
                  color: isSelected ? Colors.grey.shade800 : Colors.grey,
                ),
                title: Text(
                  '${hour.toString().padLeft(2, '0')}:00',
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.grey.shade800 : Colors.black87,
                    fontSize: 16,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_circle, color: Colors.grey.shade800)
                    : null,
                onTap: () => Navigator.of(context).pop(hour),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
        ],
      ),
    );

    if (selectedHour != null) {
      setState(() {
        _selectedTime = TimeOfDay(hour: selectedHour, minute: 0);
      });
    }
  }

  Future<void> _searchRestaurantAddress() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const AddressSearchDialog(),
    );

    if (result != null) {
      setState(() {
        _restaurantAddressController.text = result['address'] ?? '';
        // 임시 좌표 설정 (실제로는 주소 검색 결과에서 받아와야 함)
        // 서울 중심부 좌표를 기본값으로 사용
        _restaurantLat = 37.5665 + (DateTime.now().millisecond % 100) * 0.001;
        _restaurantLng = 126.9780 + (DateTime.now().millisecond % 100) * 0.001;
      });
      _updateDistanceAndFee();
    }
  }
  
  Future<void> _searchDeliveryAddress() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const AddressSearchDialog(),
    );

    if (result != null) {
      setState(() {
        _deliveryAddressController.text = result['address'] ?? '';
        // 임시 좌표 설정 (실제로는 주소 검색 결과에서 받아와야 함)
        // 서울 중심부 좌표를 기본값으로 사용
        _deliveryLat = 37.5665 + (DateTime.now().millisecond % 100) * 0.001;
        _deliveryLng = 126.9780 + (DateTime.now().millisecond % 100) * 0.001;
      });
      _updateDistanceAndFee();
    }
  }
  
  Future<void> _selectDeliveryAddress() async {
    final selected = await showDialog<LocationInfo>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('저장된 배달 주소 선택'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: _savedLocations.length,
            itemBuilder: (context, index) {
              final location = _savedLocations[index];
              return ListTile(
                leading: const Icon(Icons.location_on),
                title: Text(location.name ?? '저장된 주소'),
                subtitle: Text(location.address),
                onTap: () => Navigator.of(context).pop(location),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
        ],
      ),
    );

    if (selected != null) {
      setState(() {
        _deliveryAddressController.text = selected.address;
        // 임시 좌표 설정
        _deliveryLat = 37.5665 + (DateTime.now().millisecond % 100) * 0.001;
        _deliveryLng = 126.9780 + (DateTime.now().millisecond % 100) * 0.001;
      });
      _updateDistanceAndFee();
    }
  }

  Future<void> _submitOrder() async {
    if (_restaurantNameController.text.trim().isEmpty ||
        _restaurantAddressController.text.trim().isEmpty ||
        _menuController.text.trim().isEmpty ||
        _deliveryAddressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('모든 필수 항목을 입력해주세요'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final userId = appProvider.userId ?? '';
    
    // Combine date and time
    final scheduledDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      0,
    );

    // Create restaurant delivery booking
    final booking = Booking(
      id: const Uuid().v4(),
      userId: userId,
      type: 'restaurant',
      departureLocation: _restaurantAddressController.text.trim(),
      arrivalLocation: _deliveryAddressController.text.trim(),
      scheduledTime: scheduledDateTime,
      passengerName: '', // Not applicable for restaurant delivery
      passengerPhone: '', // Not applicable for restaurant delivery
      vehicleType: '', // Not applicable for restaurant delivery
      licensePlate: '', // Not applicable for restaurant delivery
      driverParkingAvailable: false,
      usageHours: 0, // Not applicable for restaurant delivery
      totalAmount: _deliveryFee ?? 55000,
      requestMessage: null,
      status: 'pending',
      createdAt: DateTime.now(),
      restaurantName: _restaurantNameController.text.trim(),
      restaurantAddress: _restaurantAddressController.text.trim(),
      menu: _menuController.text.trim(),
      deliveryAddress: _deliveryAddressController.text.trim(),
      distanceKm: _distanceKm,
    );

    await StorageService.saveBooking(booking);
    
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('맛집배송 주문이 접수되었습니다'),
        backgroundColor: Colors.green,
      ),
    );

    // Clear form
    _restaurantNameController.clear();
    _restaurantAddressController.clear();
    _menuController.clear();
    _deliveryAddressController.clear();
    setState(() {
      _selectedDate = DateTime.now().add(const Duration(hours: 1));
      _selectedTime = TimeOfDay.now();
      _restaurantLat = null;
      _restaurantLng = null;
      _deliveryLat = null;
      _deliveryLng = null;
      _distanceKm = null;
      _deliveryFee = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('맛집배송'),
        backgroundColor: Colors.grey.shade800,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date and Time Section
            _buildSectionTitle('일정'),
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
                        '${_selectedDate.year}년 ${_selectedDate.month}월 ${_selectedDate.day}일',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade600),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Time Selection
            InkWell(
              onTap: _selectTime,
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
                        '시간: ${_selectedTime.hour.toString().padLeft(2, '0')}:00',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade600),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Restaurant Information
            _buildSectionTitle('맛집 정보'),
            const SizedBox(height: 8),
            
            TextField(
              controller: _restaurantNameController,
              decoration: InputDecoration(
                labelText: '맛집 상호명',
                prefixIcon: const Icon(Icons.restaurant),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            
            const SizedBox(height: 12),
            
            TextField(
              controller: _restaurantAddressController,
              readOnly: true,
              onTap: _searchRestaurantAddress,
              decoration: InputDecoration(
                labelText: '맛집 주소',
                prefixIcon: const Icon(Icons.location_on),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchRestaurantAddress,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            
            const SizedBox(height: 12),
            
            TextField(
              controller: _menuController,
              decoration: InputDecoration(
                labelText: '메뉴',
                prefixIcon: const Icon(Icons.fastfood),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),

            const SizedBox(height: 24),

            // Delivery Address
            _buildSectionTitle('배달 주소'),
            const SizedBox(height: 8),
            
            TextField(
              controller: _deliveryAddressController,
              readOnly: true,
              onTap: _searchDeliveryAddress,
              decoration: InputDecoration(
                labelText: '배달 주소',
                prefixIcon: const Icon(Icons.home),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_savedLocations.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.bookmark),
                        onPressed: _selectDeliveryAddress,
                        tooltip: '저장된 주소 불러오기',
                      ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _searchDeliveryAddress,
                      tooltip: '주소 검색',
                    ),
                  ],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),

            const SizedBox(height: 24),

            // Delivery Fee Display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.payment, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          '배송 정보',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Distance Display
                  if (_distanceKm != null) ...[
                    Row(
                      children: [
                        Icon(Icons.social_distance, color: Colors.white70, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          '거리: ${_distanceKm!.toStringAsFixed(1)} km',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  
                  // Delivery Fee
                  if (_deliveryFee != null) ...[
                    Text(
                      '₩${_deliveryFee!.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getDeliveryFeeDescription(_distanceKm!),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ] else ...[
                    const Text(
                      '주소를 선택하면\n배송료가 계산됩니다',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white30),
                  const SizedBox(height: 8),
                  const Text(
                    '음식요금은 배송료와 합산하여 후불결제',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: _submitOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade800,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '주문하기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getDeliveryFeeDescription(double distanceKm) {
    if (distanceKm <= 30) return '30km 이내: 55,000원';
    if (distanceKm <= 50) return '50km 이내: 80,000원';
    if (distanceKm <= 100) return '100km 이내: 100,000원';
    if (distanceKm <= 150) return '150km 이내: 150,000원';
    if (distanceKm <= 250) return '250km 이내: 200,000원';
    if (distanceKm <= 350) return '350km 이내: 250,000원';
    if (distanceKm <= 450) return '450km 이내: 350,000원';
    return '450km 초과: 350,000원';
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
