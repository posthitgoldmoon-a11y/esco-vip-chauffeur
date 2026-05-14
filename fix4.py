content = open('lib/screens/booking_screen.dart', encoding='utf-8').read()

old = '''      final passengers = await StorageService.getPassengers();
      final vehicles = await StorageService.getVehicles();
      final locations = await StorageService.getLocations();
      final preferences = await StorageService.getPartnerPreferences();'''
new = '''      final passengers = await StorageService.getPassengers();
      final vehicles = await StorageService.getVehicles();
      final locations = await StorageService.getLocations();
      final preferences = await StorageService.getPartnerPreferences();
      final parkingBox = await Hive.openBox('parkingLocations');
      final parkingLocations = parkingBox.values.cast<String>().toList();'''
content = content.replace(old, new)

old2 = '''        _savedPassengers = passengers;
        _savedVehicles = vehicles;
        _savedLocations = locations;
        _savedPartnerPreferences = preferences;'''
new2 = '''        _savedPassengers = passengers;
        _savedVehicles = vehicles;
        _savedLocations = locations;
        _savedPartnerPreferences = preferences;
        _savedParkingLocations = parkingLocations;'''
content = content.replace(old2, new2)

open('lib/screens/booking_screen.dart', 'w', encoding='utf-8').write(content)
print('OK' if '_savedParkingLocations = parkingLocations' in content else 'FAIL')
