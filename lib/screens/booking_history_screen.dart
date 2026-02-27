import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    try {
      final bookings = await StorageService.getUserBookings();
      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return '대기중';
      case 'confirmed':
        return '확정';
      case 'completed':
        return '완료';
      case 'cancelled':
        return '취소';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _getStatusText(status),
        style: TextStyle(
          color: _getStatusColor(status),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showBookingDetail(Booking booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '예약 상세',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                _buildStatusChip(booking.status),
              ],
            ),
            const Divider(height: 32),
            _buildDetailRow(
              '예약 유형',
              booking.type == 'restaurant' ? '맛집배송' : '운전대행',
            ),
            if (booking.usageType != null)
              _buildDetailRow('이용 유형', booking.usageType!),
            if (booking.scheduledTime != null)
              _buildDetailRow(
                '예약 시간',
                DateFormat('yyyy-MM-dd HH:mm').format(booking.scheduledTime!),
              ),
            if (booking.departureLocation != null)
              _buildDetailRow('출발지', booking.departureLocation!),
            if (booking.arrivalLocation != null)
              _buildDetailRow('도착지', booking.arrivalLocation!),
            if (booking.passengerName != null)
              _buildDetailRow('탑승자', booking.passengerName!),
            if (booking.vehicleType != null)
              _buildDetailRow(
                '차량',
                '${booking.vehicleType} (${booking.licensePlate})',
              ),
            if (booking.parkingRequired == true)
              _buildDetailRow('주차 대행', '신청'),
            if (booking.totalAmount != null)
              _buildDetailRow(
                '예상 금액',
                '${NumberFormat('#,###').format(booking.totalAmount)}원',
              ),
            if (booking.requestMessage != null &&
                booking.requestMessage!.isNotEmpty)
              _buildDetailRow('요청사항', booking.requestMessage!),
            _buildDetailRow(
              '예약일',
              DateFormat('yyyy-MM-dd HH:mm').format(booking.createdAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('예약 내역')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      const Text('예약 내역이 없습니다'),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadBookings,
                  child: ListView.builder(
                    itemCount: _bookings.length,
                    itemBuilder: (context, i) {
                      final b = _bookings[i];
                      return Card(
                        child: ListTile(
                          leading: Icon(
                            b.type == 'restaurant'
                                ? Icons.restaurant
                                : Icons.directions_car,
                            color: Colors.black87,
                          ),
                          title: Text(
                            b.type == 'restaurant'
                                ? b.restaurantName ?? '맛집배송'
                                : b.departureLocation ?? '운전대행',
                          ),
                          subtitle: Text(
                            b.scheduledTime != null
                                ? DateFormat('yyyy-MM-dd HH:mm')
                                    .format(b.scheduledTime!)
                                : DateFormat('yyyy-MM-dd HH:mm')
                                    .format(b.createdAt),
                          ),
                          trailing: _buildStatusChip(b.status),
                          onTap: () => _showBookingDetail(b),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
