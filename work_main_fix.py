# main_screen.dart - 탭 전환 메서드 추가
content = open('lib/screens/main_screen.dart', encoding='utf-8').read()

old = '  int _currentIndex = 0;'
new = '''  int _currentIndex = 0;

  void switchTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }'''

content = content.replace(old, new, 1)
open('lib/screens/main_screen.dart', 'w', encoding='utf-8').write(content)
print('main OK' if 'switchTab' in content else 'main FAIL')

# home_screen.dart - 예약하기 버튼을 NavigationBar index 1로 이동
content = open('lib/screens/home_screen.dart', encoding='utf-8').read()

old = """                              onPressed: () {
                                Navigator.pushNamed(context, '/booking');
                              },"""

new = """                              onPressed: () {
                                final scaffold = context.findAncestorStateOfType<State>();
                                if (scaffold != null && scaffold.toString().contains('MainScreen')) {
                                  (scaffold as dynamic).switchTab(1);
                                } else {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingScreen()));
                                }
                              },"""

content = content.replace(old, new, 1)

# BookingScreen import 확인 후 추가
if "import 'booking_screen.dart'" not in content:
    content = content.replace(
        "import 'package:flutter/material.dart';",
        "import 'package:flutter/material.dart';\nimport 'booking_screen.dart';"
    )

open('lib/screens/home_screen.dart', 'w', encoding='utf-8').write(content)
print('home OK' if 'BookingScreen' in content else 'home FAIL')
