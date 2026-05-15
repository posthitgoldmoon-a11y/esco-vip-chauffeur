content = open('lib/screens/home_screen.dart', encoding='utf-8').read()

old = """                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),"""

new = """                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                final mainScreen = context.findAncestorStateOfType<dynamic>();
                                DefaultTabController.of(context).animateTo(1);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFC9A84C),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                '예약하기',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),"""

content = content.replace(old, new, 1)
open('lib/screens/home_screen.dart', 'w', encoding='utf-8').write(content)
print('버튼 OK' if 'Color(0xFFC9A84C)' in content else '버튼 FAIL')
