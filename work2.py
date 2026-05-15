# ==================== 2단계: 전체 디자인 리뉴얼 ====================

# ----- main_screen.dart (하단 네비게이션 바 디자인) -----
content = open('lib/screens/main_screen.dart', encoding='utf-8').read()

old = """      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: '예약',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            selectedIcon: Icon(Icons.history),
            label: '예약내역',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: '채팅',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_outlined),
            selectedIcon: Icon(Icons.restaurant),
            label: '맛집배송',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '마이페이지',
          ),
        ],
      ),"""

new = """      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFF1B2A4A).withOpacity(0.1),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: Color(0xFF1B2A4A), fontWeight: FontWeight.bold, fontSize: 11);
          }
          return const TextStyle(color: Colors.grey, fontSize: 11);
        }),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: Colors.grey),
            selectedIcon: Icon(Icons.home, color: Color(0xFF1B2A4A)),
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline, color: Colors.grey),
            selectedIcon: Icon(Icons.add_circle, color: Color(0xFF1B2A4A)),
            label: '예약',
          ),
          NavigationDestination(
            icon: Icon(Icons.history, color: Colors.grey),
            selectedIcon: Icon(Icons.history, color: Color(0xFF1B2A4A)),
            label: '예약내역',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline, color: Colors.grey),
            selectedIcon: Icon(Icons.chat_bubble, color: Color(0xFF1B2A4A)),
            label: '컨시어지',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_outlined, color: Colors.grey),
            selectedIcon: Icon(Icons.restaurant, color: Color(0xFF1B2A4A)),
            label: '맛집배송',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline, color: Colors.grey),
            selectedIcon: Icon(Icons.person, color: Color(0xFF1B2A4A)),
            label: '마이페이지',
          ),
        ],
      ),"""

content = content.replace(old, new)
open('lib/screens/main_screen.dart', 'w', encoding='utf-8').write(content)
print('main_screen OK' if 'Color(0xFF1B2A4A)' in content else 'main_screen FAIL')

# ----- home_screen.dart (AppBar + 웰컴섹션 색상) -----
content = open('lib/screens/home_screen.dart', encoding='utf-8').read()

# AppBar 배경색
content = content.replace(
    'centerTitle: true,\n        actions: [',
    'centerTitle: true,\n        backgroundColor: const Color(0xFF1B2A4A),\n        iconTheme: const IconThemeData(color: Colors.white),\n        actions: ['
)

# 웰컴섹션 그라디언트 색상 변경
content = content.replace(
    'colors: [\n                    Colors.blue.shade600,\n                    Colors.blue.shade400,\n                  ],',
    'colors: [\n                    Color(0xFF1B2A4A),\n                    Color(0xFF2E4A7A),\n                  ],'
)

# 예약하기 버튼 색상
content = content.replace(
    'backgroundColor: Colors.blue,',
    'backgroundColor: const Color(0xFFC9A84C),'
)
content = content.replace(
    'backgroundColor: Colors.blue.shade600,',
    'backgroundColor: const Color(0xFF1B2A4A),'
)

open('lib/screens/home_screen.dart', 'w', encoding='utf-8').write(content)
print('home_screen OK' if 'Color(0xFF1B2A4A)' in content else 'home_screen FAIL')

print('2단계 완료!')
