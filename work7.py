content = open('lib/services/storage_service.dart', encoding='utf-8').read()

# 충전권 잔액 관련 함수 추가 (클래스 닫히기 전에)
old_end = '}'
# 마지막 } 찾아서 앞에 삽입
insert = """
  // 충전권 잔액
  static Future<void> saveVoucherBalance(int amount) async {
    final box = await Hive.openBox('settings');
    await box.put('voucherBalance', amount);
  }

  static Future<int> getVoucherBalance() async {
    final box = await Hive.openBox('settings');
    return box.get('voucherBalance', defaultValue: 0) as int;
  }

  static Future<void> addVoucherBalance(int amount) async {
    final current = await getVoucherBalance();
    await saveVoucherBalance(current + amount);
  }

  static Future<void> deductVoucherBalance(int amount) async {
    final current = await getVoucherBalance();
    final newBalance = current - amount;
    await saveVoucherBalance(newBalance < 0 ? 0 : newBalance);
  }
"""

# 마지막 } 바로 앞에 삽입
last_brace = content.rfind('}')
content = content[:last_brace] + insert + content[last_brace:]

open('lib/services/storage_service.dart', 'w', encoding='utf-8').write(content)
print('storage OK' if 'voucherBalance' in content else 'FAIL')
