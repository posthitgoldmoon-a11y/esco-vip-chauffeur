import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/app_provider.dart';
import '../services/storage_service.dart';
import '../models/passenger_info.dart';
import '../models/vehicle_info.dart';
import '../models/location_info.dart';
import '../models/payment_card.dart';
import '../models/partner_preference.dart';
import '../widgets/address_search_dialog.dart';
import '../screens/terms_screen.dart';
import '../screens/card_registration_screen.dart';
import 'login_screen.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  List<PassengerInfo> _passengers = [];
  List<VehicleInfo> _vehicles = [];
  List<LocationInfo> _locations = [];
  List<PaymentCard> _paymentCards = [];
  List<PartnerPreference> _partnerPreferences = [];
  List<String> _parkingLocations = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final passengers = await StorageService.getPassengers();
      final vehicles = await StorageService.getVehicles();
      final locations = await StorageService.getLocations();
      final cards = await StorageService.getPaymentCards();
      final preferences = await StorageService.getPartnerPreferences();

      if (kDebugMode) {
        print('✅ 데이터 로드 성공:');
        print('  - 탑승자: ${passengers.length}개');
        print('  - 차량: ${vehicles.length}개');
        print('  - 장소: ${locations.length}개');
        print('  - 카드: ${cards.length}개');
        print('  - 파트너 선호: ${preferences.length}개');
      }

      setState(() {
        _passengers = passengers;
        _vehicles = vehicles;
        _locations = locations;
        _paymentCards = cards;
        _partnerPreferences = preferences;
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ 데이터 로드 실패: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('데이터 로드 실패: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지'),
        actions: [
          IconButton(
            icon: Icon(
              appProvider.isAdmin ? Icons.admin_panel_settings : Icons.security,
              color: appProvider.isAdmin ? Colors.red : Colors.grey,
            ),
            onPressed: () => _toggleAdminMode(appProvider),
            tooltip: appProvider.isAdmin ? '관리자 모드 해제' : '관리자 모드',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await appProvider.logout();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    child: Text(
                      appProvider.userName![0],
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    appProvider.userName!,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => _editUserInfo(appProvider),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('정보 수정'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                    ),
                  ),
                  if (appProvider.isAdmin) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '관리자',
                        style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSection('탑승자 정보', _passengers.length, Icons.person, () => _addPassenger()),
          ..._passengers.map((p) => _buildPassengerTile(p)),
          const SizedBox(height: 16),
          _buildSection('차량 정보', _vehicles.length, Icons.directions_car, () => _addVehicle()),
          ..._vehicles.map((v) => _buildVehicleTile(v)),
          const SizedBox(height: 16),
          _buildSection('장소 정보', _locations.length, Icons.location_on, () => _addLocation()),
          ..._locations.map((l) => _buildLocationTile(l)),
          const SizedBox(height: 16),
          _buildSection('결제 카드', _paymentCards.length, Icons.credit_card, () => _addPaymentCard()),
          ..._paymentCards.map((c) => _buildPaymentCardTile(c)),
          const SizedBox(height: 16),
          _buildSection('주차 위치', _parkingLocations.length, Icons.local_parking, () => _addParkingLocation()),
          ..._parkingLocations.asMap().entries.map((entry) => _buildParkingLocationTile(entry.key, entry.value)),
          const SizedBox(height: 16),
          _buildSection('파트너 선택사항', _partnerPreferences.length, Icons.person_search, () => _addPartnerPreference()),
          ..._partnerPreferences.map((p) => _buildPartnerPreferenceTile(p)),
          const SizedBox(height: 32),
          Card(
            child: ListTile(
              leading: Icon(Icons.description, color: Colors.grey.shade700),
              title: const Text('약관'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TermsScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, int count, IconData icon, VoidCallback onAdd) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.grey.shade700),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$count개', style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(width: 8),
            IconButton(icon: const Icon(Icons.add), onPressed: onAdd),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengerTile(PassengerInfo p) {
    return Card(
      child: ListTile(
        title: Text(p.name),
        subtitle: Text(p.phoneNumber),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () async {
            await StorageService.deletePassenger(p.id);
            _loadData();
          },
        ),
      ),
    );
  }

  Widget _buildVehicleTile(VehicleInfo v) {
    return Card(
      child: ListTile(
        title: Text(v.vehicleType),
        subtitle: Text(v.licensePlate),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () async {
            await StorageService.deleteVehicle(v.id);
            _loadData();
          },
        ),
      ),
    );
  }

  Widget _buildLocationTile(LocationInfo l) {
    return Card(
      child: ListTile(
        title: Text(l.displayName),
        subtitle: Text(l.fullAddress),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () async {
            await StorageService.deleteLocation(l.id);
            _loadData();
          },
        ),
      ),
    );
  }

  Future<void> _addPassenger() async {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('탑승자 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: '이름')),
            const SizedBox(height: 8),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: '전화번호')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty) return;
              try {
                final p = PassengerInfo(id: const Uuid().v4(), name: nameCtrl.text.trim(), phoneNumber: phoneCtrl.text.trim());
                await StorageService.savePassenger(p);
                if (kDebugMode) {
                  print('✅ 탑승자 저장 성공: ${p.name} (${p.id})');
                }
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('탑승자 정보가 저장되었습니다')),
                );
                _loadData();
              } catch (e) {
                if (kDebugMode) {
                  print('❌ 탑승자 저장 실패: $e');
                }
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('저장 실패: $e')),
                );
              }
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  Future<void> _addVehicle() async {
    final typeCtrl = TextEditingController();
    final plateCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('차량 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: typeCtrl, decoration: const InputDecoration(labelText: '차종')),
            const SizedBox(height: 8),
            TextField(controller: plateCtrl, decoration: const InputDecoration(labelText: '차량번호')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          ElevatedButton(
            onPressed: () async {
              if (typeCtrl.text.trim().isEmpty || plateCtrl.text.trim().isEmpty) return;
              try {
                final v = VehicleInfo(id: const Uuid().v4(), vehicleType: typeCtrl.text.trim(), licensePlate: plateCtrl.text.trim());
                await StorageService.saveVehicle(v);
                if (kDebugMode) {
                  print('✅ 차량 저장 성공: ${v.vehicleType} ${v.licensePlate} (${v.id})');
                }
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('차량 정보가 저장되었습니다')),
                );
                _loadData();
              } catch (e) {
                if (kDebugMode) {
                  print('❌ 차량 저장 실패: $e');
                }
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('저장 실패: $e')),
                );
              }
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  Future<void> _addLocation() async {
    // 주소 검색 다이얼로그 표시
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const AddressSearchDialog(),
    );

    if (result != null) {
      try {
        final location = LocationInfo(
          id: const Uuid().v4(),
          address: result['address']!,
          detailAddress: result['detailAddress']!.isEmpty ? null : result['detailAddress'],
          name: result['name']!.isEmpty ? null : result['name'],
        );
        
        await StorageService.saveLocation(location);
        if (kDebugMode) {
          print('✅ 장소 저장 성공: ${location.address} (${location.id})');
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('장소 정보가 저장되었습니다')),
          );
        }
        _loadData();
      } catch (e) {
        if (kDebugMode) {
          print('❌ 장소 저장 실패: $e');
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('저장 실패: $e')),
          );
        }
      }
    }
  }

  Future<void> _toggleAdminMode(AppProvider appProvider) async {
    if (appProvider.isAdmin) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('관리자 모드 해제'),
          content: const Text('관리자 모드를 해제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('해제'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        appProvider.setAdmin(false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('관리자 모드가 해제되었습니다')),
        );
      }
      return;
    }

    final passwordController = TextEditingController();
    bool obscureText = true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.admin_panel_settings, color: Colors.red.shade700),
              const SizedBox(width: 8),
              const Text('관리자 인증'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '관리자 비밀번호를 입력하세요',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: obscureText,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureText = !obscureText;
                      });
                    },
                  ),
                ),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('확인'),
            ),
          ],
        ),
      ),
    );

    if (result != true || !mounted) {
      passwordController.dispose();
      return;
    }

    const correctPassword = 'admin1234';
    
    if (passwordController.text == correctPassword) {
      appProvider.setAdmin(true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ 관리자 모드가 활성화되었습니다'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ 비밀번호가 올바르지 않습니다'),
          backgroundColor: Colors.red,
        ),
      );
    }

    passwordController.dispose();
  }

  Future<void> _editUserInfo(AppProvider appProvider) async {
    final nameCtrl = TextEditingController(text: appProvider.userName);
    final phoneCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('정보 수정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: '이름',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(
                labelText: '휴대폰번호',
                prefixIcon: Icon(Icons.phone),
                hintText: '010-1234-5678',
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('이름을 입력해주세요')),
                );
                return;
              }
              
              await StorageService.setUserName(nameCtrl.text.trim());
              await appProvider.loadUserData();
              
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ 정보가 수정되었습니다'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade800,
            ),
            child: const Text('수정'),
          ),
        ],
      ),
    );

    nameCtrl.dispose();
    phoneCtrl.dispose();
  }

  Widget _buildPaymentCardTile(PaymentCard c) {
    return Card(
      child: ListTile(
        leading: Icon(
          _getCardIcon(c.cardType),
          color: Colors.grey.shade700,
          size: 32,
        ),
        title: Row(
          children: [
            Text(c.maskedNumber),
            if (c.isDefault) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '기본',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text('${c.cardholderName} • ${c.expiryDate}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!c.isDefault)
              IconButton(
                icon: const Icon(Icons.star_outline),
                onPressed: () async {
                  await StorageService.setDefaultPaymentCard(c.id);
                  _loadData();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('기본 카드로 설정되었습니다')),
                  );
                },
                tooltip: '기본 카드로 설정',
              ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('카드 삭제'),
                    content: const Text('이 카드를 삭제하시겠습니까?'),
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
                        child: const Text('삭제'),
                      ),
                    ],
                  ),
                );
                
                if (confirm == true) {
                  await StorageService.deletePaymentCard(c.id);
                  _loadData();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCardIcon(String cardType) {
    switch (cardType.toLowerCase()) {
      case 'visa':
        return Icons.credit_card;
      case 'mastercard':
        return Icons.credit_card;
      case 'amex':
        return Icons.credit_card;
      default:
        return Icons.credit_card;
    }
  }

  Future<void> _addPaymentCard() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CardRegistrationScreen()),
    );
    if (result == true) {
      _loadData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ 카드가 등록되었습니다'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _addPaymentCard_OLD() async {
    final cardNumberCtrl = TextEditingController();
    final cardholderNameCtrl = TextEditingController();
    final expiryMonthCtrl = TextEditingController();
    final expiryYearCtrl = TextEditingController();
    String selectedCardType = 'Visa';

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('결제 카드 추가'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedCardType,
                  decoration: const InputDecoration(labelText: '카드 종류'),
                  items: ['Visa', 'MasterCard', 'Amex', '기타']
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedCardType = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: cardNumberCtrl,
                  decoration: const InputDecoration(
                    labelText: '카드 번호 (마지막 4자리)',
                    hintText: '1234',
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: cardholderNameCtrl,
                  decoration: const InputDecoration(labelText: '카드 소유자'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: expiryMonthCtrl,
                        decoration: const InputDecoration(
                          labelText: '월 (MM)',
                          hintText: '01',
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: expiryYearCtrl,
                        decoration: const InputDecoration(
                          labelText: '년 (YY)',
                          hintText: '25',
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 20, color: Colors.grey.shade700),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          '보안을 위해 마지막 4자리만 저장됩니다.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (cardNumberCtrl.text.trim().length != 4 ||
                    cardholderNameCtrl.text.trim().isEmpty ||
                    expiryMonthCtrl.text.trim().length != 2 ||
                    expiryYearCtrl.text.trim().length != 2) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('모든 필드를 올바르게 입력해주세요')),
                  );
                  return;
                }

                final cards = await StorageService.getPaymentCards();
                final isFirstCard = cards.isEmpty;

                final card = PaymentCard(
                  id: const Uuid().v4(),
                  cardNumber: cardNumberCtrl.text.trim(),
                  cardholderName: cardholderNameCtrl.text.trim(),
                  expiryMonth: expiryMonthCtrl.text.trim(),
                  expiryYear: expiryYearCtrl.text.trim(),
                  cardType: selectedCardType,
                  isDefault: isFirstCard,
                  createdAt: DateTime.now(),
                );
                
                await StorageService.savePaymentCard(card);
                if (!context.mounted) return;
                Navigator.pop(context);
                _loadData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade800,
              ),
              child: const Text('추가'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnerPreferenceTile(PartnerPreference p) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.person_search, color: Colors.grey.shade700),
        title: Text(p.displayText),
        subtitle: Text('등록일: ${p.createdAt.month}/${p.createdAt.day}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () async {
            await StorageService.deletePartnerPreference(p.id);
            _loadData();
          },
        ),
      ),
    );
  }


  Widget _buildParkingLocationTile(int index, String location) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.local_parking, color: Colors.grey.shade700),
        title: Text(location),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () async {
            final box = await Hive.openBox('parkingLocations');
            await box.deleteAt(index);
            _loadData();
          },
        ),
      ),
    );
  }

  Future<void> _addParkingLocation() async {
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('주차 위치 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '차량이 주차된 위치를 자세히 적어주세요.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            const Text(
              '예시) 3층 주차장 B37\n예시) 지하 2층 엘리베이터 앞 A-15\n예시) 건물 옆 노상주차장 3번',
              style: TextStyle(fontSize: 12, color: Colors.blueGrey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: '주차 위치',
                hintText: '예) 3층 주차장 B37',
                helperText: '층수, 구역, 번호를 포함해서 적어주세요',
                helperMaxLines: 2,
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          ElevatedButton(
            onPressed: () async {
              if (ctrl.text.trim().isEmpty) return;
              final box = await Hive.openBox('parkingLocations');
              await box.add(ctrl.text.trim());
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('주차 위치가 저장되었습니다')),
              );
              _loadData();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade800),
            child: const Text('추가'),
          ),
        ],
      ),
    );
    ctrl.dispose();
  }

  Future<void> _addPartnerPreference() async {
    bool nonSmoking = false;
    String? selectedAge;
    String? selectedGender;
    List<String> selectedHobbies = [];
    final otherHobbyCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('파트너 선택사항'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 비흡연 체크박스
                CheckboxListTile(
                  value: nonSmoking,
                  onChanged: (value) {
                    setState(() => nonSmoking = value ?? false);
                  },
                  title: const Text('비흡연'),
                  contentPadding: EdgeInsets.zero,
                ),
                
                const SizedBox(height: 16),
                const Text(
                  '연령',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['20대', '30대', '40대', '50대'].map((age) {
                    return ChoiceChip(
                      label: Text(age),
                      selected: selectedAge == age,
                      onSelected: (selected) {
                        setState(() => selectedAge = selected ? age : null);
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),
                const Text(
                  '성별',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['남성', '여성'].map((gender) {
                    return ChoiceChip(
                      label: Text(gender),
                      selected: selectedGender == gender,
                      onSelected: (selected) {
                        setState(() => selectedGender = selected ? gender : null);
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),
                const Text(
                  '취미',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['골프', '음악', '주식'].map((hobby) {
                    return FilterChip(
                      label: Text(hobby),
                      selected: selectedHobbies.contains(hobby),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedHobbies.add(hobby);
                          } else {
                            selectedHobbies.remove(hobby);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 12),
                TextField(
                  controller: otherHobbyCtrl,
                  decoration: const InputDecoration(
                    labelText: '기타 취미 (직접 입력)',
                    hintText: '예: 등산, 독서, 여행',
                    border: OutlineInputBorder(),
                  ),
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
              child: const Text('등록'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      final otherHobbyText = otherHobbyCtrl.text.trim();
      if (otherHobbyText.isNotEmpty) {
        selectedHobbies.add('기타');
      }

      final preference = PartnerPreference(
        id: const Uuid().v4(),
        nonSmoking: nonSmoking,
        agePreference: selectedAge,
        genderPreference: selectedGender,
        hobbies: selectedHobbies,
        otherHobby: otherHobbyText.isEmpty ? null : otherHobbyText,
        createdAt: DateTime.now(),
      );
      
      await StorageService.savePartnerPreference(preference);
      _loadData();
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ 파트너 선택사항이 등록되었습니다'),
          backgroundColor: Colors.green,
        ),
      );
    }

    otherHobbyCtrl.dispose();
  }
}









