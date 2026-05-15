content = open('lib/screens/booking_screen.dart', encoding='utf-8').read()

# 1. 변수 추가 (_savedParkingLocations 뒤에)
old_vars = '''  List<PassengerInfo> _savedPassengers = [];
  List<VehicleInfo> _savedVehicles = [];
  List<LocationInfo> _savedLocations = [];
  List<PartnerPreference> _savedPartnerPreferences = [];'''

new_vars = '''  List<PassengerInfo> _savedPassengers = [];
  List<VehicleInfo> _savedVehicles = [];
  List<LocationInfo> _savedLocations = [];
  List<PartnerPreference> _savedPartnerPreferences = [];
  List<dynamic> _savedPaymentCards = [];
  dynamic _selectedCard;
  List<String> _savedParkingLocations = [];
  int _voucherBalance = 0;'''

content = content.replace(old_vars, new_vars, 1)

# 2. _loadSavedData에 카드/충전권 로드 추가
old_load = '''      final passengers = await StorageService.getPassengers();
      final vehicles = await StorageService.getVehicles();
      final locations = await StorageService.getLocations();
      final preferences = await StorageService.getPartnerPreferences();'''

new_load = '''      final passengers = await StorageService.getPassengers();
      final vehicles = await StorageService.getVehicles();
      final locations = await StorageService.getLocations();
      final preferences = await StorageService.getPartnerPreferences();
      final cards = await StorageService.getPaymentCards();
      final voucherBal = await StorageService.getVoucherBalance();'''

content = content.replace(old_load, new_load, 1)

# 3. setState에 카드/충전권 추가
old_set = '''      setState(() {
        _savedPassengers = passengers;
        _savedVehicles = vehicles;
        _savedLocations = locations;
        _savedPartnerPreferences = preferences;
      });'''

new_set = '''      setState(() {
        _savedPassengers = passengers;
        _savedVehicles = vehicles;
        _savedLocations = locations;
        _savedPartnerPreferences = preferences;
        _savedPaymentCards = cards;
        if (cards.isNotEmpty) _selectedCard = cards.first;
        _voucherBalance = voucherBal;
      });'''

content = content.replace(old_set, new_set, 1)

# 4. Submit Button 바로 위에 충전권+카드 섹션 삽입
old_submit = '''            const SizedBox(height: 32),

            // Submit Button'''

new_submit = '''            const SizedBox(height: 16),

            // 충전권 섹션
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.account_balance_wallet, color: Color(0xFF1B2A4A), size: 20),
                          SizedBox(width: 8),
                          Text('충전권', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1B2A4A))),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () => _showVoucherPurchaseDialog(),
                        icon: const Icon(Icons.add, size: 16, color: Color(0xFFC9A84C)),
                        label: const Text('충전권 구매', style: TextStyle(color: Color(0xFFC9A84C), fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '잔액: ${_voucherBalance ~/ 10000}만원',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B2A4A)),
                  ),
                  if (_voucherBalance < _totalAmount && _voucherBalance > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '충전권 잔액이 부족합니다. 충전권을 충전해 주세요.',
                        style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
                      ),
                    ),
                  if (_voucherBalance == 0)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        '충전권을 구매하시면 서비스 이용 요금 및 주차/주유 요금이 자동 차감됩니다.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 카드 간편결제 섹션
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.credit_card, color: Color(0xFF1B2A4A), size: 20),
                      SizedBox(width: 8),
                      Text('카드 등록', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1B2A4A))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (_savedPaymentCards.isEmpty)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CardRegistrationScreen()),
                        ).then((_) => _loadSavedData());
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F8F8),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Center(
                          child: Text('+ 카드 등록하기', style: TextStyle(color: Color(0xFF1B2A4A), fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  if (_savedPaymentCards.isNotEmpty)
                    DropdownButtonFormField(
                      value: _selectedCard,
                      items: _savedPaymentCards.map((card) => DropdownMenuItem(value: card, child: Text(card.toString()))).toList(),
                      onChanged: (val) => setState(() => _selectedCard = val),
                      decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                    ),
                  const SizedBox(height: 8),
                  const Text(
                    '서비스 이용 중 추가 금액 발생 시 등록하신 카드로 결제됩니다.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Submit Button'''

content = content.replace(old_submit, new_submit, 1)

# 5. _showVoucherPurchaseDialog 함수 추가 (dispose 메서드 바로 앞에)
old_dispose = '''  @override
  void dispose() {'''

new_dispose = '''  Future<void> _showVoucherPurchaseDialog() async {
    int? selectedAmount;
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('충전권 구매', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B2A4A))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFF8F8F8), borderRadius: BorderRadius.circular(8)),
                child: const Text('충전권은 서비스 이용 요금은 물론\\n주차, 주유 등의 요금이 결제됩니다.', style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.5)),
              ),
              const SizedBox(height: 16),
              _buildVoucherOption(300000, selectedAmount, (val) => setDialogState(() => selectedAmount = val)),
              const SizedBox(height: 8),
              _buildVoucherOption(500000, selectedAmount, (val) => setDialogState(() => selectedAmount = val)),
              const SizedBox(height: 8),
              _buildVoucherOption(1000000, selectedAmount, (val) => setDialogState(() => selectedAmount = val)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: selectedAmount == null ? null : () async {
                Navigator.pop(context);
                await _purchaseVoucher(selectedAmount!);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B2A4A), foregroundColor: Colors.white),
              child: const Text('결제'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoucherOption(int amount, int? selected, Function(int) onSelect) {
    final isSelected = selected == amount;
    final label = amount == 300000 ? '30만원' : amount == 500000 ? '50만원' : '100만원';
    return GestureDetector(
      onTap: () => onSelect(amount),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? const Color(0xFF1B2A4A) : Colors.grey.shade300, width: isSelected ? 2 : 1),
        ),
        child: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFF1B2A4A) : Colors.black87), textAlign: TextAlign.center),
      ),
    );
  }

  Future<void> _purchaseVoucher(int amount) async {
    try {
      await StorageService.addVoucherBalance(amount);
      final newBalance = await StorageService.getVoucherBalance();
      setState(() => _voucherBalance = newBalance);
      if (!mounted) return;
      final label = amount == 300000 ? '30만원' : amount == 500000 ? '50만원' : '100만원';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('충전권 $label 구매 완료! 잔액: ${newBalance ~/ 10000}만원'), backgroundColor: const Color(0xFF1B2A4A)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('충전권 구매 중 오류가 발생했습니다.'), backgroundColor: Colors.red));
    }
  }

  @override
  void dispose() {'''

content = content.replace(old_dispose, new_dispose, 1)

open('lib/screens/booking_screen.dart', 'w', encoding='utf-8').write(content)

checks = [
    ('_voucherBalance', '_voucherBalance 변수'),
    ('_showVoucherPurchaseDialog', '충전권 다이얼로그'),
    ('_buildVoucherOption', '충전권 옵션'),
    ('카드 등록', '카드 섹션'),
    ('// Submit Button', '예약하기 버튼'),
]
for key, name in checks:
    print(f'{name}: {"OK" if key in content else "FAIL"}')
