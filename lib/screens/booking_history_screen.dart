import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../services/storage_service.dart';
import '../models/booking.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  List<Booking> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);

    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final bookings = await StorageService.getUserBookings(appProvider.userId!);

    setState(() {
      _bookings = bookings;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('예약 내역'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy, size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        '예약 내역이 없습니다',
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadBookings,
                  child: ListView.builder(
                    itemCount: _bookings.length,
                    itemBuilder: (context, index) {
                      return _buildBookingCard(_bookings[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    final isRestaurant = booking.type == 'restaurant';
    
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showBookingDetails(booking),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Type Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isRestaurant ? Colors.orange.shade50 : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isRestaurant ? Icons.restaurant : Icons.directions_car,
                      color: isRestaurant ? Colors.orange.shade700 : Colors.blue.shade700,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isRestaurant ? '맛집배송' : '운전 서비스',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isRestaurant ? Colors.orange.shade700 : Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('yyyy-MM-dd HH:mm').format(booking.scheduledTime),
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(booking.status),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              
              if (isRestaurant) ...[
                // Restaurant delivery details
                _buildRow(Icons.restaurant, '맛집', booking.restaurantName ?? ''),
                _buildRow(Icons.fastfood, '메뉴', booking.menu ?? ''),
                _buildRow(Icons.location_on, '배달 주소', booking.deliveryAddress ?? ''),
                if (booking.distanceKm != null)
                  _buildRow(Icons.social_distance, '거리', '${booking.distanceKm!.toStringAsFixed(1)} km'),
              ] else ...[
                // Driver service details
                _buildRow(Icons.trip_origin, '출발', booking.departureLocation),
                if (booking.waypointLocation != null && booking.waypointLocation!.isNotEmpty)
                  _buildRow(Icons.more_horiz, '경유', booking.waypointLocation!),
                _buildRow(Icons.location_on, '도착', booking.arrivalLocation),
              ],
              
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '총 요금',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    '₩${booking.totalAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          Text('$label: ', style: TextStyle(color: Colors.grey.shade600)),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
  
  String _getStatusText(String status) {
    final labels = {
      'pending': '대기중',
      'confirmed': '확정',
      'completed': '완료',
      'cancelled': '취소됨',
    };
    return labels[status] ?? status;
  }

  Widget _buildStatusChip(String status) {
    final colors = {
      'pending': Colors.orange,
      'confirmed': Colors.blue,
      'completed': Colors.green,
      'cancelled': Colors.red,
    };
    final labels = {
      'pending': '대기중',
      'confirmed': '확정',
      'completed': '완료',
      'cancelled': '취소됨',
    };
    
    final color = colors[status] ?? Colors.grey;
    final label = labels[status] ?? status;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _showBookingDetails(Booking booking) {
    final isRestaurant = booking.type == 'restaurant';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isRestaurant ? Icons.restaurant : Icons.directions_car,
              color: isRestaurant ? Colors.orange.shade700 : Colors.blue.shade700,
            ),
            const SizedBox(width: 8),
            Text(isRestaurant ? '맛집배송 상세' : '운전 서비스 상세'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('예약시간', DateFormat('yyyy-MM-dd HH:mm').format(booking.scheduledTime)),
              const Divider(),
              
              if (isRestaurant) ...[
                // Restaurant delivery details
                _buildDetailRow('맛집명', booking.restaurantName ?? '-'),
                _buildDetailRow('맛집 주소', booking.restaurantAddress ?? '-'),
                _buildDetailRow('메뉴', booking.menu ?? '-'),
                _buildDetailRow('배달 주소', booking.deliveryAddress ?? '-'),
                if (booking.distanceKm != null)
                  _buildDetailRow('거리', '${booking.distanceKm!.toStringAsFixed(1)} km'),
                _buildDetailRow('배송료', '₩${booking.totalAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}'),
              ] else ...[
                // Driver service details
                _buildDetailRow('출발지', booking.departureLocation),
                if (booking.waypointLocation != null && booking.waypointLocation!.isNotEmpty)
                  _buildDetailRow('경유지', booking.waypointLocation!),
                _buildDetailRow('도착지', booking.arrivalLocation),
                const Divider(),
                _buildDetailRow('탑승자', booking.passengerName),
                _buildDetailRow('연락처', booking.passengerPhone),
                _buildDetailRow('차량', '${booking.vehicleType} (${booking.licensePlate})'),
                if (booking.customerParkingLocation != null && booking.customerParkingLocation!.isNotEmpty)
                  _buildDetailRow('고객 차량 주차위치', booking.customerParkingLocation!),
                _buildDetailRow('드라이버 주차', booking.driverParkingAvailable ? '가능' : '불가'),
                if (booking.driverParkingLocation != null && booking.driverParkingLocation!.isNotEmpty)
                  _buildDetailRow('드라이버 주차장소', booking.driverParkingLocation!),
                const Divider(),
                _buildDetailRow('이용시간', '${booking.usageHours}시간'),
                if (booking.isHospitalCompanion) ...[
                  _buildDetailRow('병원동행', '${booking.hospitalCompanionHours}시간 (₩${(booking.hospitalCompanionHours * 20000).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')})', highlight: true),
                ],
                _buildDetailRow('총 요금', '₩${booking.totalAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}'),
              ],
              
              const Divider(),
              _buildDetailRow('상태', _getStatusText(booking.status)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text('$label:', style: TextStyle(
              color: highlight ? Colors.blue.shade700 : Colors.grey.shade600,
              fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
            )),
          ),
          Expanded(
            child: Text(value, style: TextStyle(
              fontWeight: FontWeight.w500,
              color: highlight ? Colors.blue.shade700 : Colors.black87,
            )),
          ),
        ],
      ),
    );
  }
}
