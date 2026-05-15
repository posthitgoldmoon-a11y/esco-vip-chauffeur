content = open('lib/screens/booking_screen.dart', encoding='utf-8').read()

old = 'MaterialPageRoute(builder: (_) => const CardRegistrationScreen())'
new = 'MaterialPageRoute(builder: (_) => CardRegistrationScreen())'

content = content.replace(old, new, 1)
open('lib/screens/booking_screen.dart', 'w', encoding='utf-8').write(content)
print('OK' if 'const CardRegistrationScreen()' not in content else 'FAIL')
