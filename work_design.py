# ===== 1. booking_screen.dart AppBar 디자인 =====
content = open('lib/screens/booking_screen.dart', encoding='utf-8').read()

old = """AppBar(
        title: const Text('예약하기'),
      ),"""

new = """AppBar(
        title: const Text('예약하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1B2A4A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),"""

content = content.replace(old, new, 1)
open('lib/screens/booking_screen.dart', 'w', encoding='utf-8').write(content)
print('booking AppBar OK' if 'backgroundColor: const Color(0xFF1B2A4A)' in content else 'booking AppBar FAIL')

# ===== 2. my_page_screen.dart AppBar 디자인 =====
content = open('lib/screens/my_page_screen.dart', encoding='utf-8').read()

old = """AppBar(
        title: const Text('마이페이지'),
        actions: ["""

new = """AppBar(
        title: const Text('마이페이지', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1B2A4A),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: ["""

content = content.replace(old, new, 1)
open('lib/screens/my_page_screen.dart', 'w', encoding='utf-8').write(content)
print('mypage AppBar OK' if 'backgroundColor: const Color(0xFF1B2A4A)' in content else 'mypage AppBar FAIL')

# ===== 3. home_screen.dart AppBar + 전체 디자인 =====
content = open('lib/screens/home_screen.dart', encoding='utf-8').read()

old = """AppBar(
        title: Image.asset(
          'assets/images/esco_logo.png',
          height: 40,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        actions: ["""

new = """AppBar(
        title: Image.asset(
          'assets/images/esco_logo.png',
          height: 40,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1B2A4A),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: ["""

content = content.replace(old, new, 1)

# 예약하기 버튼 색상
old_btn = "backgroundColor: Colors.black87,"
new_btn = "backgroundColor: const Color(0xFFC9A84C),"
content = content.replace(old_btn, new_btn, 1)

# 전화예약 버튼 색상
old_tel = "side: const BorderSide(color: Color(0xFF1a73e8)"
new_tel = "side: const BorderSide(color: Color(0xFF1B2A4A)"
content = content.replace(old_tel, new_tel)

old_tel2 = "color: Color(0xFF1a73e8),"
new_tel2 = "color: Color(0xFF1B2A4A),"
content = content.replace(old_tel2, new_tel2)

open('lib/screens/home_screen.dart', 'w', encoding='utf-8').write(content)
print('home AppBar OK' if 'backgroundColor: const Color(0xFF1B2A4A)' in content else 'home AppBar FAIL')
print('home 버튼 OK' if 'Color(0xFFC9A84C)' in content else 'home 버튼 FAIL')

# ===== 4. 전체 Scaffold backgroundColor 통일 =====
for fname in ['lib/screens/booking_screen.dart', 'lib/screens/my_page_screen.dart']:
    content = open(fname, encoding='utf-8').read()
    if 'backgroundColor: const Color(0xFFF8F8F8)' not in content:
        old_scaffold = 'body: SingleChildScrollView(' if 'booking' in fname else 'body: ListView('
        new_scaffold = 'backgroundColor: const Color(0xFFF8F8F8),\n      body: SingleChildScrollView(' if 'booking' in fname else 'backgroundColor: const Color(0xFFF8F8F8),\n      body: ListView('
        content = content.replace(old_scaffold, new_scaffold, 1)
        open(fname, 'w', encoding='utf-8').write(content)
        name = fname.split('/')[-1]
        print(name, 'backgroundColor OK' if 'Color(0xFFF8F8F8)' in content else 'backgroundColor FAIL')

print('===== 디자인 완료 =====')
