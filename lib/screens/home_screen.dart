import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_provider.dart';
import '../services/storage_service.dart';
import '../models/announcement.dart';
import '../models/booking.dart';
import 'announcement_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Announcement> _announcements = [];
  List<Booking> _recentBookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final announcements = await StorageService.getAnnouncements();
      final bookings = await StorageService.getUserBookings();
      setState(() {
        _announcements = announcements;
        _recentBookings = bookings.take(3).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _launchPhone(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending': return '대기중';
      case 'confirmed': return '확정';
      case 'completed': return '완료';
      case 'cancelled': return '취소';
      default: return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'confirmed': return Colors.blue;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('ESCO VIP Chauffeur'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 환영 배너
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.directions_car,
                            color: Colors.white, size: 40),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '안녕하세요, ${appProvider.userName ?? '고객'}님!',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '프리미엄 운전대행 서비스',
                              style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 공지사항
                  if (_announcements.isNotEmpty) ...[
                    const Text('공지사항',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ..._announcements.take(3).map((a) => Card(
                          child: ListTile(
                            leading: Icon(
                              a.isPinned ? Icons.push_pin : Icons.announcement,
                              color: a.isPinned ? Colors.red : Colors.grey,
                            ),
                            title: Text(a.title),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AnnouncementDetailScreen(announcement: a),
                              ),
                            ),
                          ),
                        )),
                    const SizedBox(height: 24),
                  ],

                  // 최근 예약
                  const Text('최근 예약',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (_recentBookings.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 8),
                              Text('최근 예약이 없습니다',
                                  style: TextStyle(
                                      color: Colors.grey.shade600)),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    ..._recentBookings.map((b) => Card(
                          child: ListTile(
                            leading: Icon(
                              b.type == 'restaurant'
                                  ? Icons.restaurant
                                  : Icons.directions_car,
                              color: Colors.black87,
                            ),
                            title: Text(b.type == 'restaurant'
                                ? b.restaurantName ?? '맛집배송'
                                : b.departureLocation ?? '운전대행'),
                            subtitle: Text(
                                b.createdAt.toString().substring(0, 16)),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(b.status)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getStatusText(b.status),
                                style: TextStyle(
                                    color: _getStatusColor(b.status),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        )),
                  const SizedBox(height: 24),

                  // 연락처 카드
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('고객센터',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          ListTile(
                            leading: const Icon(Icons.phone,
                                color: Colors.black87),
                            title: const Text('전화 문의'),
                            subtitle: const Text('010-0000-0000'),
                            trailing:
                                const Icon(Icons.chevron_right),
                            onTap: () =>
                                _launchPhone('01000000000'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
