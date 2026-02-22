import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../services/storage_service.dart';
import '../models/booking.dart';
import '../models/announcement.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Booking> _bookings = [];
  List<Announcement> _announcements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final bookings = await StorageService.getBookings();
    final announcements = await StorageService.getAnnouncements();
    setState(() {
      _bookings = bookings;
      _announcements = announcements;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('관리자 모드'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '예약 관리'),
            Tab(text: '공지사항 관리'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingsTab(),
          _buildAnnouncementsTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton.extended(
              onPressed: _addAnnouncement,
              backgroundColor: Colors.grey.shade800,
              icon: const Icon(Icons.add),
              label: const Text('공지사항 작성'),
            )
          : null,
    );
  }

  Widget _buildBookingsTab() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _bookings.isEmpty
            ? const Center(child: Text('예약이 없습니다'))
            : RefreshIndicator(
                onRefresh: _loadData,
                child: ListView.builder(
                  itemCount: _bookings.length,
                  itemBuilder: (context, index) => _buildBookingCard(_bookings[index]),
                ),
              );
  }

  Widget _buildAnnouncementsTab() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _announcements.isEmpty
            ? const Center(child: Text('공지사항이 없습니다'))
            : RefreshIndicator(
                onRefresh: _loadData,
                child: ListView.builder(
                  itemCount: _announcements.length,
                  itemBuilder: (context, index) => _buildAnnouncementCard(_announcements[index]),
                ),
              );
  }

  Widget _buildBookingCard(Booking b) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat('yyyy-MM-dd HH:mm').format(b.scheduledTime), style: const TextStyle(fontWeight: FontWeight.bold)),
                _buildStatusChip(b.status),
              ],
            ),
            const Divider(height: 16),
            _buildRow('출발', b.departureLocation),
            if (b.waypointLocation != null) _buildRow('경유', b.waypointLocation!),
            _buildRow('도착', b.arrivalLocation),
            const Divider(height: 16),
            _buildRow('탑승자', '${b.passengerName} (${b.passengerPhone})'),
            _buildRow('차량', '${b.vehicleType} (${b.licensePlate})'),
            if (b.customerParkingLocation != null)
              _buildRow('차량주차', b.customerParkingLocation!),
            if (b.driverParkingAvailable)
              _buildRow('드라이버주차', b.driverParkingLocation ?? '가능'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildStatusButton('확정', 'confirmed', b)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatusButton('완료', 'completed', b)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatusButton('취소', 'cancelled', b)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 60, child: Text('$label:', style: TextStyle(color: Colors.grey.shade600))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final colors = {'pending': Colors.orange, 'confirmed': Colors.blue, 'completed': Colors.green, 'cancelled': Colors.red};
    final labels = {'pending': '대기중', 'confirmed': '확정', 'completed': '완료', 'cancelled': '취소됨'};
    final color = colors[status] ?? Colors.grey;
    final label = labels[status] ?? status;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildStatusButton(String label, String status, Booking b) {
    return ElevatedButton(
      onPressed: b.status == status ? null : () async {
        await StorageService.updateBookingStatus(b.id, status);
        _loadData();
      },
      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildAnnouncementCard(Announcement announcement) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(
          announcement.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              announcement.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('yyyy-MM-dd HH:mm').format(announcement.createdAt),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteAnnouncement(announcement),
        ),
      ),
    );
  }

  Future<void> _addAnnouncement() async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('공지사항 작성'),
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
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade800,
            ),
            child: const Text('작성'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      if (titleController.text.trim().isEmpty ||
          contentController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('제목과 내용을 모두 입력해주세요')),
        );
        return;
      }

      final announcement = Announcement(
        id: const Uuid().v4(),
        title: titleController.text.trim(),
        content: contentController.text.trim(),
        createdAt: DateTime.now(),
      );

      await StorageService.saveAnnouncement(announcement);
      _loadData();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('공지사항이 등록되었습니다')),
      );
    }

    titleController.dispose();
    contentController.dispose();
  }

  Future<void> _deleteAnnouncement(Announcement announcement) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('공지사항 삭제'),
        content: Text('${announcement.title}\n\n이 공지사항을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await StorageService.deleteAnnouncement(announcement.id);
      _loadData();
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('공지사항이 삭제되었습니다')),
      );
    }
  }
}
