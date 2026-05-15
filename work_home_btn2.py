content = open('lib/screens/home_screen.dart', encoding='utf-8').read()

old = """                              onPressed: () {
                                final mainScreen = context.findAncestorStateOfType<dynamic>();
                                DefaultTabController.of(context).animateTo(1);
                              },"""

new = """                              onPressed: () {
                                Navigator.pushNamed(context, '/booking');
                              },"""

content = content.replace(old, new, 1)
open('lib/screens/home_screen.dart', 'w', encoding='utf-8').write(content)
print('OK' if "pushNamed" in content else 'FAIL')
