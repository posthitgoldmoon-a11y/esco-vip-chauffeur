content = open('lib/screens/my_page_screen.dart', encoding='utf-8').read()

# actions 중복 제거 + AppBar 정리
old = """        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.white), onPressed: () {}),
          IconButton(icon: const Icon(Icons.settings_outlined, color: Colors.white), onPressed: () {}),
        ],
        actions: [
          IconButton(
            icon: Icon(
              appProvider.isAdmin ? Icons.admin_panel_settings : Icons.security,
              color: appProvider.isAdmin ? Colors.red : Colors.grey,
            ),
            onPressed: () => _toggleAdminMode(appProvider),
            tooltip: appProvider.isAdmin ? '관 리자 모드 해제' : '관리자 모드',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await appProvider.logout();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],"""

new = """        actions: [
          IconButton(
            icon: Icon(
              appProvider.isAdmin ? Icons.admin_panel_settings : Icons.security,
              color: appProvider.isAdmin ? Colors.amber : Colors.white54,
            ),
            onPressed: () => _toggleAdminMode(appProvider),
            tooltip: appProvider.isAdmin ? '관리자 모드 해제' : '관리자 모드',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await appProvider.logout();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],"""

content = content.replace(old, new)

# body 전체를 고급스러운 디자인으로 교체
old_body = """      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child:"""

new_body = """      backgroundColor: const Color(0xFFF8F8F8),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 프로필 헤더
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
            decoration: const BoxDecoration(
              color: Color(0xFF1B2A4A),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC9A84C),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Center(
                    child: Text(
                      appProvider.userName != null && appProvider.userName!.isNotEmpty
                          ? appProvider.userName![0]
                          : 'U',
                      style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appProvider.userName ?? '사용자',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    const Text('내 정보 수정하기', style: TextStyle(fontSize: 13, color: Colors.white60)),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 메뉴 그룹 1
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildMenuTile(Icons.card_membership_outlined, '구독형 상품', () {}),
                _buildMenuTile(Icons.location_on_outlined, '주소 관리', () {}),
                _buildMenuTile(Icons.people_outline, '탑승자 관리', () {}),
                _buildMenuTile(Icons.directions_car_outlined, '차량 관리', () {}),
                _buildMenuTile(Icons.receipt_long_outlined, '이용 내역', () {}),
                _buildMenuTile(Icons.swap_vert, '파트너 우선순위 변경', () {}),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 메뉴 그룹 2
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildMenuTile(Icons.credit_card_outlined, '카드 관리', () {}),
              ],
            ),
          ),

          const SizedBox(height: 16),
          // 기존 상세 컨텐츠
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child:"""

content = content.replace(old_body, new_body)

# _buildMenuTile 헬퍼 함수 추가 (클래스 닫히기 전에)
if '_buildMenuTile' not in content:
    old_end = '  Widget _buildSection('
    new_end = """  Widget _buildMenuTile(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF1B2A4A), size: 22),
        title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF1A1A1A))),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildSection("""
    content = content.replace(old_end, new_end)

open('lib/screens/my_page_screen.dart', 'w', encoding='utf-8').write(content)
print('마이페이지 디자인 OK' if '_buildMenuTile' in content else 'FAIL')
