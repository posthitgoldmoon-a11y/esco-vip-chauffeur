content = open('lib/screens/booking_screen.dart', encoding='utf-8').read()

# _loadSavedData 확인
idx = content.find('Future<void> _loadSavedData')
print(repr(content[idx:idx+600]))
