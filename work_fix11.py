content = open('lib/screens/booking_screen.dart', encoding='utf-8').read()

old = '''      final cards = await StorageService.getPaymentCards();
      final voucherBalance = await StorageService.getVoucherBalance();
      final parkingBox = await Hive.openBox('parkingLocations');
      final parkingLocations = parkingBox.values.cast<String>().toList();
      final cards = await StorageService.getPaymentCards();
      final voucherBalance = await StorageService.getVoucherBalance();
      final parkingBox = await Hive.openBox('parkingLocations');
      final parkingLocations = parkingBox.values.cast<String>().toList();'''

new = '''      final cards = await StorageService.getPaymentCards();
      final voucherBalance = await StorageService.getVoucherBalance();
      final parkingBox = await Hive.openBox('parkingLocations');
      final parkingLocations = parkingBox.values.cast<String>().toList();'''

content = content.replace(old, new)
open('lib/screens/booking_screen.dart', 'w', encoding='utf-8').write(content)
print('OK' if content.count('final cards = await StorageService.getPaymentCards()') == 1 else 'FAIL')
