import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_provider.dart';
import '../services/storage_service.dart';
import '../models/booking.dart';
import '../models/announcement.dart';
import 'announcement_detail_screen.dart';
import 'admin_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Booking> _recentBookings = [];
  List<Announcement> _announcements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final userId = appProvider.userId ?? '';

    final bookings = await StorageService.getUserBookings(userId);
    final announcements = await StorageService.getAnnouncements();

    setState(() {
      _recentBookings = bookings.take(3).toList();
      _announcements = announcements;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/esco_logo.png',
          height: 40,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        actions: [
          if (appProvider.isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminScreen()),
                );
              },
              tooltip: '관리자 모드',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade600,
                            Colors.blue.shade400,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '안녕하세요, ${appProvider.userName}님',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'VIP 운전대행 서비스를 이용해주셔서 감사합니다',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Recent Bookings
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '최근 예약',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Navigate to booking history
                              DefaultTabController.of(context).animateTo(2);
                            },
                            child: const Text('전체보기'),
                          ),
                        ],
                      ),
                    ),

                    if (_recentBookings.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.event_busy,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '예약 내역이 없습니다',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._recentBookings.map((booking) => _buildBookingCard(booking)),

                    const SizedBox(height: 16),

                    // Announcements
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '공지사항',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (appProvider.isAdmin)
                            TextButton(
                              onPressed: () => _showAddAnnouncementDialog(),
                              child: const Text('추가'),
                            ),
                        ],
                      ),
                    ),

                    if (_announcements.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.announcement,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '공지사항이 없습니다',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._announcements.map((announcement) =>
                          _buildAnnouncementCard(announcement)),

                    const SizedBox(height: 32),
                    
                    // Contact Information
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.business, color: Colors.grey.shade700, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                '오시는 길',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.grey.shade600, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '서울 강남구 영동대로 510\n삼성빌딩 3층 304호',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.phone, color: Colors.grey.shade600, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '0503-7153-8223',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.call, color: Colors.green.shade600),
                                onPressed: () async {
                                  final uri = Uri.parse('tel:0503-7153-8223');
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri);
                                  }
                                },
                                tooltip: '전화 걸기',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    _buildFooter(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Show booking details
          _showBookingDetails(booking);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      DateFormat('yyyy-MM-dd HH:mm').format(booking.scheduledTime),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  _buildStatusChip(booking.status),
                ],
              ),
              const SizedBox(height: 12),
              _buildLocationRow(
                icon: Icons.trip_origin,
                label: '출발',
                location: booking.departureLocation,
              ),
              if (booking.waypointLocation != null) ...[
                const SizedBox(height: 8),
                _buildLocationRow(
                  icon: Icons.more_horiz,
                  label: '경유',
                  location: booking.waypointLocation!,
                ),
              ],
              const SizedBox(height: 8),
              _buildLocationRow(
                icon: Icons.location_on,
                label: '도착',
                location: booking.arrivalLocation,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationRow({
    required IconData icon,
    required String label,
    required String location,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue.shade600),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            location,
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        label = '대기중';
        break;
      case 'confirmed':
        color = Colors.blue;
        label = '확정';
        break;
      case 'completed':
        color = Colors.green;
        label = '완료';
        break;
      case 'cancelled':
        color = Colors.red;
        label = '취소됨';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAnnouncementCard(Announcement announcement) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AnnouncementDetailScreen(announcement: announcement),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (announcement.isPinned)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '공지',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (announcement.isPinned) const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      announcement.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                announcement.content,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('yyyy-MM-dd').format(announcement.createdAt),
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBookingDetails(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('예약 상세'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('예약시간', DateFormat('yyyy-MM-dd HH:mm').format(booking.scheduledTime)),
              _buildDetailRow('출발지', booking.departureLocation),
              if (booking.waypointLocation != null)
                _buildDetailRow('경유지', booking.waypointLocation!),
              _buildDetailRow('도착지', booking.arrivalLocation),
              _buildDetailRow('탑승자', booking.passengerName),
              _buildDetailRow('연락처', booking.passengerPhone),
              _buildDetailRow('차량', '${booking.vehicleType} (${booking.licensePlate})'),
              _buildDetailRow('드라이버 주차', booking.driverParkingAvailable ? '가능' : '불가'),
              if (booking.driverParkingLocation != null)
                _buildDetailRow('주차장소', booking.driverParkingLocation!),
              _buildDetailRow('상태', _getStatusLabel(booking.status)),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return '대기중';
      case 'confirmed':
        return '확정';
      case 'completed':
        return '완료';
      case 'cancelled':
        return '취소됨';
      default:
        return status;
    }
  }

  Future<void> _showAddAnnouncementDialog() async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    bool isPinned = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('공지사항 추가'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: '제목',
                    hintText: '공지사항 제목을 입력하세요',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: '내용',
                    hintText: '공지사항 내용을 입력하세요',
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  value: isPinned,
                  onChanged: (value) {
                    setState(() => isPinned = value ?? false);
                  },
                  title: const Text('상단 고정'),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty ||
                    contentController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('제목과 내용을 입력해주세요')),
                  );
                  return;
                }

                final announcement = Announcement(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text.trim(),
                  content: contentController.text.trim(),
                  createdAt: DateTime.now(),
                  isPinned: isPinned,
                );

                await StorageService.saveAnnouncement(announcement);
                
                if (!mounted) return;
                Navigator.of(context).pop();
                _loadData();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('공지사항이 추가되었습니다')),
                );
              },
              child: const Text('추가'),
            ),
          ],
        ),
      ),
    );

    titleController.dispose();
    contentController.dispose();
  }


  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: const Color(0xFF1a1a2e),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(color: Colors.white24),
          const SizedBox(height: 10),
          const Text('ESCO VIP Chauffeur', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('상호: 팬토리 | 대표자: 정상일', style: TextStyle(color: Colors.white60, fontSize: 12)),
          const Text('사업자등록번호: 897-22-02307', style: TextStyle(color: Colors.white60, fontSize: 12)),
          const Text('통신판매업: 2025-서울강남-06498', style: TextStyle(color: Colors.white60, fontSize: 12)),
          const Text('주소: 서울 강남구 영동대로 510 삼성빌딩 3층 304-4호', style: TextStyle(color: Colors.white60, fontSize: 12), textAlign: TextAlign.center),
          const Text('고객센터: 0507-1476-2344 | posthit@naver.com', style: TextStyle(color: Colors.white60, fontSize: 12)),
          const Text('CS운영시간: 평일 09:00~18:00', style: TextStyle(color: Colors.white60, fontSize: 12)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(onPressed: () => _launchUrl('https://esco-vip-chauffeur.web.app/terms.html'), child: const Text('이용약관', style: TextStyle(color: Colors.white54, fontSize: 12))),
              const Text('|', style: TextStyle(color: Colors.white30)),
              TextButton(onPressed: () => _launchUrl('https://esco-vip-chauffeur.web.app/privacy.html'), child: const Text('개인정보처리방침', style: TextStyle(color: Colors.white54, fontSize: 12))),
              const Text('|', style: TextStyle(color: Colors.white30)),
              TextButton(onPressed: () => _launchUrl('https://esco-vip-chauffeur.web.app/refund.html'), child: const Text('환불정책', style: TextStyle(color: Colors.white54, fontSize: 12))),
            ],
          ),
          const SizedBox(height: 8),
          const Text('ⓒ 2025 팬토리. All rights reserved.', style: TextStyle(color: Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }
}







