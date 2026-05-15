content = open('lib/screens/booking_screen.dart', encoding='utf-8').read()

old = """                  '충전권은 서비스 이용 요금은 물론
주차, 주유 등의 요금이 결제됩니다.',"""

new = "                  '충전권은 서비스 이용 요금은 물론\\n주차, 주유 등의 요금이 결제됩니다.',"

content = content.replace(old, new)
open('lib/screens/booking_screen.dart', 'w', encoding='utf-8').write(content)
print('OK' if '물론\\n주차' in content else 'FAIL')
