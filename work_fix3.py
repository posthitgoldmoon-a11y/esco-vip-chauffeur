content = open('lib/screens/booking_screen.dart', encoding='utf-8').read()

old = '  List<PassengerInfo> _savedPassengers = [];\n  List<VehicleInfo> _savedVehicles = [];\n  List<LocationInfo> _savedLocations = [];\n  List<PartnerPreference> _savedPartnerPreferences = [];\n  \n  // 요금 계산'

new = '''  List<PassengerInfo> _savedPassengers = [];
  List<VehicleInfo> _savedVehicles = [];
  List<LocationInfo> _savedLocations = [];
  List<PartnerPreference> _savedPartnerPreferences = [];
  List<dynamic> _savedPaymentCards = [];
  dynamic _selectedCard;
  List<String> _savedParkingLocations = [];
  int _voucherBalance = 0;

  // 요금 계산'''

content = content.replace(old, new)

open('lib/screens/booking_screen.dart', 'w', encoding='utf-8').write(content)
print('OK' if '_voucherBalance' in content else 'FAIL')
