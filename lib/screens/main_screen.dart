import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'booking_screen.dart';
import 'booking_history_screen.dart';
import 'chat_screen.dart';
import 'restaurant_delivery_screen.dart';
import 'my_page_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    BookingScreen(),
    BookingHistoryScreen(),
    ChatScreen(),
    RestaurantDeliveryScreen(),
    MyPageScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
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
      ),
    );
  }
}
