content = open('lib/screens/booking_screen.dart', encoding='utf-8').read()

# 깨진 문자열 수정
old = """                    '서비스 이용 중 추가 금액 발생 시 충전권 사용을 우선으로 하며,
충전권 사용 외 금액에 대해서만 선택하신 카드로 결제됩니다.',"""

new = "                    '서비스 이용 중 추가 금액 발생 시 등록하신 카드로 결제됩니다.',"

content = content.replace(old, new)

open('lib/screens/booking_screen.dart', 'w', encoding='utf-8').write(content)

# 확인
lines = open('lib/screens/booking_screen.dart', encoding='utf-8').readlines()
for i, line in enumerate(lines[670:680], start=671):
    print(f'{i}: {repr(line)}')
print('OK')
