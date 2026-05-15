content = open('lib/screens/booking_screen.dart', encoding='utf-8').read()

old = '''      final passengers = await StorageService.getPassengers();
      final vehicles = await StorageService.getVehicles();
      final locations = await StorageService.getLocations();
      final preferences = await StorageService.getPartnerPreferences();'''

new = '''      final passengers = await StorageService.getPassengers();
      final vehicles = await StorageService.getVehicles();
      final locations = await StorageService.getLocations();
      final preferences = await StorageService.getPartnerPreferences();
      final cards = await StorageService.getPaymentCards();
      final voucherBalance = await StorageService.getVoucherBalance();
      final parkingBox = await Hive.openBox('parkingLocations');
      final parkingLocations = parkingBox.values.cast<String>().toList();'''

content = content.replace(old, new)

# setState 부분도 확인
idx = content.find('setState(() {')
print(repr(content[idx:idx+400]))

open('lib/screens/booking_screen.dart', 'w', encoding='utf-8').write(content)
print('OK' if 'getVoucherBalance' in content else 'FAIL')
