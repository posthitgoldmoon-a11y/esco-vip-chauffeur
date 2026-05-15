content = open('lib/screens/booking_screen.dart', encoding='utf-8').read()

# 1. hive import 추가
content = content.replace(
    "import 'package:hive_flutter/hive_flutter.dart';",
    "import 'package:hive_flutter/hive_flutter.dart';"
)
if 'hive_flutter' not in content:
    content = content.replace(
        "import 'package:flutter/material.dart';",
        "import 'package:flutter/material.dart';\nimport 'package:hive_flutter/hive_flutter.dart';"
    )

# 2. ... 스프레드 문제 수정 - if (_isOvernight) ...[ 를 if (_isOvernight) ...[  형태로 유지되어야 함
# 문제없는 패턴이므로 패스, 다른 ... 확인
import re
dots = [(m.start(), content[m.start()-50:m.start()+50]) for m in re.finditer(r'\.\.\.', content)]
for pos, ctx in dots:
    print(f'위치 {pos}:', repr(ctx))
    print('---')

print('hive:', 'hive_flutter' in content)
open('lib/screens/booking_screen.dart', 'w', encoding='utf-8').write(content)
