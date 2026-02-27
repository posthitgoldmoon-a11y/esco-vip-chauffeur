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

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Booking> _bookings = [];
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
    try {
      final announcements = await StorageService.getAnnouncements();
      setState(() {
        _announcements = announcements;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateBookingStatus(String id, String status) async {
    try {
      await StorageService.updateBookingStatus(id, status);
      await _loadData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('상태가 업데이트되었습니다')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('업데이트 실패: $e')));
    }
  }

  void _showAddAnnouncementDialog() {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    bool isPinned = false;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('공지사항 추가'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: '제목 *'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentCtrl,
                  decoration: const InputDecoration(labelText: '내용 *'),
                  maxLines: 5,
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('상단 고정'),
                  value: isPinned,
                  onChanged: (v) => setDialogState(() => isPinned = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleCtrl.text.isEmpty || contentCtrl.text.isEmpty) {
                  return;
                }
                final announcement = Announcement(
                  id: const Uuid().v4(),
                  title: titleCtrl.text,
                  content: contentCtrl.text,
                  createdAt: DateTime.now(),
                  isPinned: isPinned,
                );
                await StorageService.saveAnnouncement(announcement);
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                await _loadData();
              },
              child: const Text('추가'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteAnnouncement(String id) async {
    try {
      await StorageService.deleteAnnouncement(id);
      await _loadData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('공지사항이 삭제되었습니다')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('삭제 실패: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('관리자'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: '예약 관리'), Tab(text: '공지사항')],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAnnouncementDialog,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // 예약 관리 탭
                _bookings.isEmpty
                    ? const Center(
                        child: Text('예약이 없습니다',
                            style: TextStyle(color: Colors.grey)))
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          itemCount: _bookings.length,
                          itemBuilder: (context, index) {
                            final b = _bookings[index];
                            return Card(
                              child: ListTile(
                                title: Text(b.type == 'restaurant'
                                    ? b.restaurantName ?? '맛집배송'
                                    : b.departureLocation ?? '운전대행'),
                                subtitle: Text(b.scheduledTime != null
                                    ? DateFormat('yyyy-MM-dd HH:mm')
                                        .format(b.scheduledTime!)
                                    : ''),
                                trailing: DropdownButton<String>(
                                  value: b.status,
                                  items: const [
                                    DropdownMenuItem(
                                        value: 'pending', child: Text('대기')),
                                    DropdownMenuItem(
                                        value: 'confirmed', child: Text('확정')),
                                    DropdownMenuItem(
                                        value: 'completed', child: Text('완료')),
                                    DropdownMenuItem(
                                        value: 'cancelled', child: Text('취소')),
                                  ],
                                  onChanged: (v) {
                                    if (v != null) {
                                      _updateBookingStatus(b.id, v);
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                // 공지사항 탭
                _announcements.isEmpty
                    ? const Center(
                        child: Text('공지사항이 없습니다',
                            style: TextStyle(color: Colors.grey)))
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          itemCount: _announcements.length,
                          itemBuilder: (context, index) {
                            final a = _announcements[index];
                            return Card(
                              child: ListTile(
                                leading: Icon(
                                  a.isPinned
                                      ? Icons.push_pin
                                      : Icons.announcement,
                                  color:
                                      a.isPinned ? Colors.red : Colors.grey,
                                ),
                                title: Text(a.title),
                                subtitle: Text(
                                    DateFormat('yyyy-MM-dd')
                                        .format(a.createdAt)),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () =>
                                      _deleteAnnouncement(a.id),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ],
            ),
    );
  }
}