content = open('lib/screens/booking_screen.dart', encoding='utf-8').read()

old = '''      setState(() {
        _savedPassengers = passengers;
        _savedVehicles = vehicles;
        _savedLocations = locations;
        _savedPartnerPreferences = preferences;
      });'''

new = '''      setState(() {
        _savedPassengers = passengers;
        _savedVehicles = vehicles;
        _savedLocations = locations;
        _savedPartnerPreferences = preferences;
        _savedPaymentCards = cards;
        if (cards.isNotEmpty) _selectedCard = cards.first;
        _savedParkingLocations = parkingLocations;
        _voucherBalance = voucherBalance;
      });'''

content = content.replace(old, new)
open('lib/screens/booking_screen.dart', 'w', encoding='utf-8').write(content)
print('OK' if '_voucherBalance = voucherBalance' in content else 'FAIL')
