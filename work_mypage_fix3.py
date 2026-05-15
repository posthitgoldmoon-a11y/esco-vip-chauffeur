content = open('lib/screens/my_page_screen.dart', encoding='utf-8').read()

old = '  Widget _buildSection('

new = '''  Widget _buildMenuTile(IconData icon, String title, VoidCallback onTap) {
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

  Widget _buildSection('''

content = content.replace(old, new, 1)
open('lib/screens/my_page_screen.dart', 'w', encoding='utf-8').write(content)
print('OK' if 'Widget _buildMenuTile' in content else 'FAIL')
