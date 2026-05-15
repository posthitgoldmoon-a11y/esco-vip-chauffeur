content = open('lib/screens/booking_screen.dart', encoding='utf-8').read()

# _selectParkingLocation 함수 바로 앞에 삽입
old = '  Future<void> _selectParkingLocation'

new = '''  Future<void> _showVoucherPurchaseDialog() async {
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
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '충전권은 서비스 이용 요금은 물론\n주차, 주유 등의 요금이 결제됩니다.',
                  style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.5),
                ),
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setState2) => Column(
                  children: [
                    _buildVoucherOption(300000, selectedAmount, (val) => setDialogState(() => selectedAmount = val)),
                    const SizedBox(height: 8),
                    _buildVoucherOption(500000, selectedAmount, (val) => setDialogState(() => selectedAmount = val)),
                    const SizedBox(height: 8),
                    _buildVoucherOption(1000000, selectedAmount, (val) => setDialogState(() => selectedAmount = val)),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: selectedAmount == null ? null : () async {
                Navigator.pop(context);
                await _purchaseVoucher(selectedAmount!);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B2A4A),
                foregroundColor: Colors.white,
              ),
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
          border: Border.all(
            color: isSelected ? const Color(0xFF1B2A4A) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isSelected ? const Color(0xFF1B2A4A) : Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('충전권 $label 구매 완료! 잔액: ${newBalance ~/ 10000}만원'),
          backgroundColor: const Color(0xFF1B2A4A),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('충전권 구매 중 오류가 발생했습니다.'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _selectParkingLocation'''

content = content.replace(old, new, 1)
open('lib/screens/booking_screen.dart', 'w', encoding='utf-8').write(content)
print('OK' if '_showVoucherPurchaseDialog' in content else 'FAIL')
