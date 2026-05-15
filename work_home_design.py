content = open('lib/screens/home_screen.dart', encoding='utf-8').read()

# Welcome Section 그라데이션 색상 변경
old_gradient = """                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade600,
                            Colors.blue.shade400,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),"""

new_gradient = """                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF1B2A4A),
                            Color(0xFF2E4A7A),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),"""

content = content.replace(old_gradient, new_gradient, 1)
open('lib/screens/home_screen.dart', 'w', encoding='utf-8').write(content)
print('gradient OK' if 'Color(0xFF1B2A4A)' in content else 'gradient FAIL')
