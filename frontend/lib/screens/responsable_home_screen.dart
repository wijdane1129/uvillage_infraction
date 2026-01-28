import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../gen_l10n/app_localizations.dart';
import 'dashboard_responsable_screen.dart';
import 'residents_screen.dart';
import 'configuration_motifs_screen.dart';

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
    ConfigurationMotifsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
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
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: locale.dashboard,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people),
            label: locale.residents,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: locale.configurationMotifs,
          ),
        ],
      ),
    );
  }
}
