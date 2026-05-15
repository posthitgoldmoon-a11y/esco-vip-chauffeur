content = open('lib/screens/booking_screen.dart', encoding='utf-8').read()

old_var = '  List<dynamic> _savedPaymentCards = [];\n  dynamic _selectedCard;'
new_var = '  List<dynamic> _savedPaymentCards = [];\n  dynamic _selectedCard;\n  int _voucherBalance = 0;'
content = content.replace(old_var, new_var)

old_load = '      final cards = await StorageService.getPaymentCards();'
new_load = '      final cards = await StorageService.getPaymentCards();\n      final voucherBalance = await StorageService.getVoucherBalance();'
content = content.replace(old_load, new_load)

old_set = '        _savedPaymentCards = cards;\n        if (cards.isNotEmpty) _selectedCard = cards.first;'
new_set = '        _savedPaymentCards = cards;\n        if (cards.isNotEmpty) _selectedCard = cards.first;\n        _voucherBalance = voucherBalance;'
content = content.replace(old_set, new_set)

old_card = '            // 카드 간편결제 섹션'
new_card = '''            // 충전권 섹션
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
                          Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF1B2A4A), size: 20),
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
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('사용 가능 잔액', style: TextStyle(fontSize: 14, color: Colors.grey)),
                        Text(
                          '${_voucherBalance ~/ 10000}만원',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B2A4A)),
                        ),
                      ],
                    ),
                  ),
                  if (_voucherBalance < _totalAmount && _voucherBalance > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '⚠️ 잔액이 부족합니다. 충전권을 충전해주세요.',
                        style: const TextStyle(fontSize: 12, color: Colors.red),
                      ),
                    ),
                  if (_voucherBalance == 0)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        '⚠️ 충전권 잔액이 없습니다. 충전권을 구매해주세요.',
                        style: TextStyle(fontSize: 12, color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 카드 간편결제 섹션'''
content = content.replace(old_card, new_card, 1)

open('lib/screens/booking_screen.dart', 'w', encoding='utf-8').write(content)
print('충전권섹션 OK' if '충전권 구매' in content else 'FAIL')
