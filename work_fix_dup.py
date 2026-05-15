content = open('lib/screens/booking_screen.dart', encoding='utf-8').read()

# 중복된 두 번째 선언 제거
old = '''  int _voucherBalance = 0;
  List<String> _savedParkingLocations = [];
  
  // 요금 계산'''

new = '''  int _voucherBalance = 0;
  
  // 요금 계산'''

content = content.replace(old, new, 1)

import re
count = len(re.findall('List<String> _savedParkingLocations', content))
print(f'_savedParkingLocations 선언 수: {count} (1이어야 정상)')
open('lib/screens/booking_screen.dart', 'w', encoding='utf-8').write(content)
print('OK' if count == 1 else 'FAIL')
