content = open('lib/screens/booking_screen.dart', encoding='utf-8').read()

old = "import 'package:hive_flutter/hive_flutter.dart';"
new = """import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'card_registration_screen.dart';"""

content = content.replace(old, new, 1)
open('lib/screens/booking_screen.dart', 'w', encoding='utf-8').write(content)

lines = content.split('\n')
imports = [l for l in lines if l.startswith('import')]
print('\n'.join(imports))
