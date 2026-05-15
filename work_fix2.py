content = open('lib/screens/booking_screen.dart', encoding='utf-8').read()

# 변수 선언 위치 찾기
idx = content.find('List<String> _savedParkingLocations = [];')
print('현재 위치:', repr(content[idx-100:idx+150]))
