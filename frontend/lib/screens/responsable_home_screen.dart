import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import 'dashboard_responsable_screen.dart';
import 'residents_screen.dart';

class ResponsableHomeScreen extends StatefulWidget {
  const ResponsableHomeScreen({Key? key}) : super(key: key);

  @override
  State<ResponsableHomeScreen> createState() => _ResponsableHomeScreenState();
}

class _ResponsableHomeScreenState extends State<ResponsableHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardResponsableScreen(),
    ResidentsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: const Color(0xFF1a1a2e),
        selectedItemColor: const Color(0xFF00d4ff),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Résidents',
          ),
        ],
      ),
    );
  }
}
