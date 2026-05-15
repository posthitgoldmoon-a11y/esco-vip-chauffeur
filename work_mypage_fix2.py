lines = open('lib/screens/my_page_screen.dart', encoding='utf-8').readlines()

# 190~236번 줄 제거 (인덱스 189~235)
new_lines = lines[:189] + lines[236:]

open('lib/screens/my_page_screen.dart', 'w', encoding='utf-8').writelines(new_lines)
print('OK' if '기존 상세 컨텐츠' not in open('lib/screens/my_page_screen.dart', encoding='utf-8').read() else 'FAIL')
