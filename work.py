import re

# ==================== 1. my_page_screen.dart ====================
content = open('lib/screens/my_page_screen.dart', encoding='utf-8').read()

# 약관 텍스트 변경
content = content.replace(
    "title: const Text('약관'),",
    "title: const Text('이용약관/개인정보/환불취소'),"
)

# 마이페이지 전체 디자인 리뉴얼 - AppBar 색상
content = content.replace(
    "appBar: AppBar(\n        title: const Text('마이페이지'),",
    """appBar: AppBar(
        title: const Text('마이페이지', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1B2A4A),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.white), onPressed: () {}),
          IconButton(icon: const Icon(Icons.settings_outlined, color: Colors.white), onPressed: () {}),
        ],"""
)

# 배경색 변경
content = content.replace(
    'backgroundColor: Colors.grey.shade50,',
    'backgroundColor: const Color(0xFFF8F8F8),'
)

open('lib/screens/my_page_screen.dart', 'w', encoding='utf-8').write(content)
print('1. my_page OK')

# ==================== 2. booking_screen.dart ====================
content = open('lib/screens/booking_screen.dart', encoding='utf-8').read()

# AppBar 색상
content = content.replace(
    "appBar: AppBar(\n        title: const Text('예약하기'),\n      ),",
    """appBar: AppBar(
        title: const Text('예약하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1B2A4A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),"""
)

open('lib/screens/booking_screen.dart', 'w', encoding='utf-8').write(content)
print('2. booking OK')

print('모든 작업 완료!')
