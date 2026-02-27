import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../services/storage_service.dart';
import '../models/booking.dart';
import '../models/location_info.dart';
import '../widgets/address_search_dialog.dart';

class RestaurantDeliveryScreen extends StatefulWidget {
  const RestaurantDeliveryScreen({super.key});
  @override
  State<RestaurantDeliveryScreen> createState() =>
      _RestaurantDeliveryScreenState();
}

class _RestaurantDeliveryScreenState
    extends State<RestaurantDeliveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _restaurantNameController = TextEditingController();
  final _requestController = TextEditingController();
  DateTime? _scheduledTime;
  LocationInfo? _restaurantLocation;
  LocationInfo? _deliveryLocation;
  bool _isLoading = false;

  @override
  void dispose() {
    _restaurantNameController.dispose();
    _requestController.dispose();
    super.dispose();
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
        context: context, initialTime: TimeOfDay.now());
    if (time == null) return;
    setState(() {
      _scheduledTime = DateTime(
          date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _selectAddress(bool isRestaurant) async {
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
      if (isRestaurant) {
        _restaurantLocation = location;
      } else {
        _deliveryLocation = location;
      }
    });
  }

  double _calculateDeliveryFee() => 30000;

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_scheduledTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('픽업 시간을 선택해주세요')));
      return;
    }
    if (_restaurantLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('맛집 주소를 입력해주세요')));
      return;
    }
    if (_deliveryLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('배달 주소를 입력해주세요')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final appProvider =
          Provider.of<AppProvider>(context, listen: false);
      final booking = Booking(
        id: const Uuid().v4(),
        userId: appProvider.userId!,
        type: 'restaurant',
        restaurantName: _restaurantNameController.text,
        restaurantAddress: _restaurantLocation?.fullAddress,
        deliveryAddress: _deliveryLocation?.fullAddress,
        scheduledTime: _scheduledTime,
        totalAmount: _calculateDeliveryFee(),
        requestMessage: _requestController.text,
        createdAt: DateTime.now(),
      );
      await StorageService.createBooking(booking);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('맛집배송 예약이 완료되었습니다!')));
      setState(() {
        _scheduledTime = null;
        _restaurantLocation = null;
        _deliveryLocation = null;
        _restaurantNameController.clear();
        _requestController.clear();
        _isLoading = false;
      });
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
      appBar: AppBar(title: const Text('맛집배송')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 안내 배너
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.restaurant, color: Colors.orange.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '원하시는 맛집에서 음식을 픽업하여 배달해드립니다',
                      style: TextStyle(color: Colors.orange.shade700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 맛집 이름
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextFormField(
                  controller: _restaurantNameController,
                  decoration: const InputDecoration(
                    labelText: '맛집 이름 *',
                    hintText: '예: 을지면옥',
                    prefixIcon: Icon(Icons.restaurant),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? '맛집 이름을 입력해주세요' : null,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 픽업 시간
            Card(
              child: ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('픽업 시간'),
                subtitle: Text(
                  _scheduledTime != null
                      ? DateFormat('yyyy-MM-dd HH:mm').format(_scheduledTime!)
                      : '시간을 선택해주세요',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _selectDateTime,
              ),
            ),
            const SizedBox(height: 12),

            // 주소 정보
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('주소 정보',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ListTile(
                      leading:
                          const Icon(Icons.store, color: Colors.orange),
                      title: const Text('맛집 주소'),
                      subtitle: Text(
                        _restaurantLocation != null
                            ? _restaurantLocation!.fullAddress
                            : '맛집 주소를 선택해주세요',
                      ),
                      trailing: const Icon(Icons.search),
                      onTap: () => _selectAddress(true),
                    ),
                    const Divider(),
                    ListTile(
                      leading:
                          const Icon(Icons.home, color: Colors.blue),
                      title: const Text('배달 주소'),
                      subtitle: Text(
                        _deliveryLocation != null
                            ? _deliveryLocation!.fullAddress
                            : '배달 받을 주소를 선택해주세요',
                      ),
                      trailing: const Icon(Icons.search),
                      onTap: () => _selectAddress(false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 요청사항
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextFormField(
                  controller: _requestController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: '요청사항 (선택)',
                    hintText: '음식 주문 내용이나 특별 요청사항을 입력해주세요',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 배달 요금
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('배달 요금',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(
                      '${NumberFormat('#,###').format(_calculateDeliveryFee())}원~',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 예약 버튼
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitBooking,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('맛집배송 예약하기',
                        style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
