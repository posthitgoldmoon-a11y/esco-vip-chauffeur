lines = open('lib/screens/my_page_screen.dart', encoding='utf-8').readlines()

# 160~188번 줄 제거 (인덱스 159~187) - 메뉴 그룹 1, 2 전체
new_lines = lines[:159] + lines[188:]

open('lib/screens/my_page_screen.dart', 'w', encoding='utf-8').writelines(new_lines)
content = open('lib/screens/my_page_screen.dart', encoding='utf-8').read()
print('OK' if '구독형 상품' not in content else 'FAIL')
