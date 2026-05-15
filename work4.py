content = open('lib/screens/booking_screen.dart', encoding='utf-8').read()

# 카드 관련 import 및 변수 확인 후 추가
# _savedPaymentCards 변수 추가
old_var = '  List<String> _savedParkingLocations = [];'
new_var = """  List<String> _savedParkingLocations = [];
  List<dynamic> _savedPaymentCards = [];
  dynamic _selectedCard;"""
content = content.replace(old_var, new_var)

# _loadSavedData에 카드 로드 추가
old_load = '      final parkingBox = await Hive.openBox(\'parkingLocations\');'
new_load = """      final cards = await StorageService.getPaymentCards();
      final parkingBox = await Hive.openBox('parkingLocations');"""
content = content.replace(old_load, new_load)

# setState에 카드 추가
old_set = '        _savedParkingLocations = parkingBox.values.cast<String>().toList();'
new_set = """        _savedPaymentCards = cards;
        if (cards.isNotEmpty) _selectedCard = cards.first;
        _savedParkingLocations = parkingBox.values.cast<String>().toList();"""
content = content.replace(old_set, new_set)

# 전화예약 버튼 다음에 카드선택 UI 추가
old_btn = "            const SizedBox(height: 1"
new_btn = """            const SizedBox(height: 24),

            // 카드 간편결제 섹션
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1B2A4A), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.credit_card, color: Color(0xFF1B2A4A), size: 20),
                      SizedBox(width: 8),
                      Text('카드 간편결제', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1B2A4A))),
                      Text(' *', style: TextStyle(color: Colors.red, fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 12),
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
                          child: Text('+ 카드 등록하기', style: TextStyle(color: Color(0xFF1B2A4A), fontWeight: FontWeight.w600, fontSize: 14)),
                        ),
                      ),
                    )
                  else
                    DropdownButtonFormField(
                      value: _selectedCard,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                      ),
                      items: _savedPaymentCards.map((card) {
                        return DropdownMenuItem(
                          value: card,
                          child: Text(card.toString(), style: const TextStyle(fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedCard = val),
                    ),
                  const SizedBox(height: 10),
                  const Text(
                    '서비스 이용 중 추가 금액 발생 시 충전권 사용을 우선으로 하며,\n충전권 사용 외 금액에 대해서만 선택하신 카드로 결제됩니다.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 1"""
content = content.replace(old_btn, new_btn, 1)

# CardRegistrationScreen import 추가
if 'card_registration_screen' not in content:
    content = content.replace(
        "import 'package:flutter/material.dart';",
        "import 'package:flutter/material.dart';\nimport 'card_registration_screen.dart';"
    )

open('lib/screens/booking_screen.dart', 'w', encoding='utf-8').write(content)
print('카드등록 UI OK' if '카드 간편결제' in content else 'FAIL')
