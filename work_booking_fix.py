content = open('lib/screens/booking_screen.dart', encoding='utf-8').read()

# 충전권 섹션 + 카드 섹션 블록 찾아서 추출
start_marker = '            // 충전권 섹션'
end_marker = '            const SizedBox(height: 16),\n\n            // DateTime Section'

start_idx = content.find(start_marker)
end_idx = content.find(end_marker)

# 충전권+카드 블록 추출
voucher_card_block = content[start_idx:end_idx]
print('추출된 블록 길이:', len(voucher_card_block))
print(repr(voucher_card_block[:100]))

# 원래 위치에서 제거
content = content[:start_idx] + content[end_idx:]

# Submit Button 바로 위에 삽입
old_submit = '            const SizedBox(height: 32),\n\n            // Submit Button'
new_submit = '            ' + voucher_card_block.strip() + '\n\n            const SizedBox(height: 16),\n\n            const SizedBox(height: 32),\n\n            // Submit Button'

content = content.replace(old_submit, new_submit, 1)

open('lib/screens/booking_screen.dart', 'w', encoding='utf-8').write(content)
print('OK' if '// Submit Button' in content else 'FAIL')
