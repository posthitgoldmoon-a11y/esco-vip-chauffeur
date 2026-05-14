content = open('lib/screens/booking_screen.dart', encoding='utf-8').read()

# 1. _savedParkingLocations 변수 추가
old = '  List<PartnerPreference> _savedPartnerPreferences = [];'
new = '  List<PartnerPreference> _savedPartnerPreferences = [];\n  List<String> _savedParkingLocations = [];'
content = content.replace(old, new)

# 2. _loadData에 주차위치 로드 추가
old2 = '    _savedLocations = await StorageService.getLocations();'
new2 = '    _savedLocations = await StorageService.getLocations();\n    final parkingBox = await Hive.openBox(' + chr(39) + 'parkingLocations' + chr(39) + ');\n    _savedParkingLocations = parkingBox.values.cast<String>().toList();'
content = content.replace(old2, new2)

# 3. onSelectSaved를 _selectParkingLocation으로 변경
old3 = 'onSelectSaved: () => _selectLocation(_customerParkingLocationController),'
new3 = 'onSelectSaved: () => _selectParkingLocation(_customerParkingLocationController),'
content = content.replace(old3, new3)

open('lib/screens/booking_screen.dart', 'w', encoding='utf-8').write(content)
print('1단계 OK')
