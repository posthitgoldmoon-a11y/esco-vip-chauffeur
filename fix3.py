content = open('lib/screens/booking_screen.dart', encoding='utf-8').read()
old = "import 'package:flutter/material.dart';"
new = "import 'package:flutter/material.dart';\nimport 'package:hive_flutter/hive_flutter.dart';"
content = content.replace(old, new)
open('lib/screens/booking_screen.dart', 'w', encoding='utf-8').write(content)
print('hive import OK' if 'hive_flutter' in content else 'FAIL')
