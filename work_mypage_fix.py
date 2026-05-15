content = open('lib/screens/my_page_screen.dart', encoding='utf-8').read()

# 기존 상세 컨텐츠 블록 제거 (불필요한 중복 프로필 카드)
old = '''          const SizedBox(height: 16),
          // 기존 상세 컨텐츠
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    child: Text(
                      appProvider.userName![0],
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    appProvider.userName!,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => _editUserInfo(appProvider),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('정보 수정'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                    ),
                  ),
                  if (appProvider.isAdmin) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '관리자',
                        style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          ),
          const SizedBox(height: 16),'''

new = '''          const SizedBox(height: 16),'''

content = content.replace(old, new)
open('lib/screens/my_page_screen.dart', 'w', encoding='utf-8').write(content)
print('OK' if '기존 상세 컨텐츠' not in content else 'FAIL - 아직 남아있음')
