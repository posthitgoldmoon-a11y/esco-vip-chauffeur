import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';
import '../models/passenger_info.dart';
import '../models/vehicle_info.dart';
import '../models/location_info.dart';
import 'login_screen.dart';
import 'admin_screen.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});
  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  final AuthService _authService = AuthService();
  List<PassengerInfo> _passengers = [];
  List<VehicleInfo> _vehicles = [];
  List<LocationInfo> _locations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final passengers = await StorageService.getPassengers();
      final vehicles = await StorageService.getVehicles();
      final locations = await StorageService.getLocations();
      setState(() {
        _passengers = passengers;
        _vehicles = vehicles;
        _locations = locations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _authService.signOut();
    if (!mounted) return;
    final appProvider =
        Provider.of<AppProvider>(context, listen: false);
    await appProvider.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  void _showAddPassengerDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('탑승자 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: '이름 *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              decoration:
                  const InputDecoration(labelText: '전화번호 *'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty || phoneCtrl.text.isEmpty) {
                return;
              }
              final passenger = PassengerInfo(
                id: DateTime.now()
                    .millisecondsSinceEpoch
                    .toString(),
                name: nameCtrl.text.trim(),
                phoneNumber: phoneCtrl.text.trim(),
              );
              Navigator.pop(ctx);
              await StorageService.savePassenger(passenger);
              _loadData();
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  void _showAddVehicleDialog() {
    final typeCtrl = TextEditingController();
    final plateCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('차량 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: typeCtrl,
              decoration: const InputDecoration(
                labelText: '차종 *',
                hintText: '예: 제네시스 G80',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: plateCtrl,
              decoration: const InputDecoration(
                labelText: '차량번호 *',
                hintText: '예: 12가 3456',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (typeCtrl.text.isEmpty || plateCtrl.text.isEmpty) {
                return;
              }
              final vehicle = VehicleInfo(
                id: DateTime.now()
                    .millisecondsSinceEpoch
                    .toString(),
                vehicleType: typeCtrl.text.trim(),
                licensePlate: plateCtrl.text.trim(),
              );
              Navigator.pop(ctx);
              await StorageService.saveVehicle(vehicle);
              _loadData();
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  void _showAddLocationDialog() {
    final addressCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('즐겨찾기 주소 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: addressCtrl,
              decoration: const InputDecoration(
                labelText: '주소 *',
                hintText: '예: 서울 강남구 테헤란로 123',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: '별칭 (선택)',
                hintText: '예: 집, 회사',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (addressCtrl.text.isEmpty) {
                return;
              }
              final location = LocationInfo(
                id: DateTime.now()
                    .millisecondsSinceEpoch
                    .toString(),
                address: addressCtrl.text.trim(),
                name: nameCtrl.text.trim().isEmpty
                    ? null
                    : nameCtrl.text.trim(),
              );
              Navigator.pop(ctx);
              await StorageService.saveLocation(location);
              _loadData();
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> items,
    required VoidCallback onAdd,
  }) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(icon, color: Colors.black87),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: onAdd,
            ),
          ),
          const Divider(height: 1),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '등록된 $title이 없습니다',
                style: TextStyle(color: Colors.grey.shade500),
              ),
            )
          else
            ...items,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지'),
        actions: [
          if (appProvider.isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AdminScreen()),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ─── 프로필 카드 ───────────────────────────────
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.black87,
                            child: Text(
                              (appProvider.userName ?? '?')[0]
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                appProvider.userName ?? '사용자',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (appProvider.isAdmin)
                                Container(
                                  margin: const EdgeInsets.only(
                                      top: 4),
                                  padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black87,
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    '관리자',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ─── 탑승자 ────────────────────────────────────
                  _buildSectionCard(
                    title: '탑승자',
                    icon: Icons.person,
                    onAdd: _showAddPassengerDialog,
                    items: _passengers
                        .map((p) => ListTile(
                              leading: const Icon(
                                  Icons.person_outline),
                              title: Text(p.name),
                              subtitle: Text(p.phoneNumber),
                              trailing: IconButton(
                                icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red),
                                onPressed: () async {
                                  await StorageService
                                      .deletePassenger(p.id);
                                  _loadData();
                                },
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 12),

                  // ─── 차량 ──────────────────────────────────────
                  _buildSectionCard(
                    title: '차량',
                    icon: Icons.directions_car,
                    onAdd: _showAddVehicleDialog,
                    items: _vehicles
                        .map((v) => ListTile(
                              leading: const Icon(
                                  Icons.directions_car_outlined),
                              title: Text(v.vehicleType),
                              subtitle: Text(v.licensePlate),
                              trailing: IconButton(
                                icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red),
                                onPressed: () async {
                                  await StorageService
                                      .deleteVehicle(v.id);
                                  _loadData();
                                },
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 12),

                  // ─── 즐겨찾기 주소 ─────────────────────────────
                  _buildSectionCard(
                    title: '즐겨찾기 주소',
                    icon: Icons.location_on,
                    onAdd: _showAddLocationDialog,
                    items: _locations
                        .map((l) => ListTile(
                              leading: const Icon(
                                  Icons.location_on_outlined),
                              title: Text(l.displayName),
                              subtitle: l.name != null
                                  ? Text(l.address)
                                  : null,
                              trailing: IconButton(
                                icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red),
                                onPressed: () async {
                                  await StorageService
                                      .deleteLocation(l.id);
                                  _loadData();
                                },
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 24),

                  // ─── 로그아웃 버튼 ─────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _handleLogout,
                      icon: const Icon(Icons.logout,
                          color: Colors.red),
                      label: const Text(
                        '로그아웃',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(
                            vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
