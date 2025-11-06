import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_provider.dart';
import '../config/app_theme.dart';
import '../widgets/gradient_button.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _localUser = UserProvider();
  bool profileIsLoading = false;
  String? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = _localUser.language;
  }

  void _handleEditProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.darkBgAlt,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          // Ensure the sheet scrolls above the keyboard and on small screens
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Edit Profile",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Username",
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: AppTheme.darkBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: AppTheme.darkBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedLanguage,
                    decoration: InputDecoration(
                      labelText: 'Language',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: AppTheme.darkBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    dropdownColor: AppTheme.darkBgAlt,
                    items: const [
                      DropdownMenuItem(value: 'ar', child: Text('ar')),
                      DropdownMenuItem(value: 'fr', child: Text('fr')),
                      DropdownMenuItem(value: 'en', child: Text('en')),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _selectedLanguage = val;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: AppTheme.darkBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GradientButton(
                    text: 'Save Changes',
                    isLoading: profileIsLoading,
                    onPressed: () {
                      setState(() {
                        if (_selectedLanguage != null) {
                          _localUser.setLanguage(_selectedLanguage!);
                        }
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use local user as a fallback to avoid unresolved provider errors in editor.
    final user = {
      'username': _localUser.fullName,
      'email': _localUser.email,
      'language': _localUser.language,
    };

    return Scaffold(
      backgroundColor: AppTheme.darkBg, // Deep dark background
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.darkBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          // ensure Column takes at least the available height so Spacer pushes button to the bottom
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - kToolbarHeight - 48,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: AppTheme.glowingCircle(AppTheme.pinkAccent),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppTheme.purpleAccent, AppTheme.pinkAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.darkBgAlt,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoItem("USERNAME", user['username']!),
                    _buildInfoItem("EMAIL", user['email']!),
                    _buildInfoItem("LANGUAGE", user['language']!),
                    _buildInfoItem("PASSWORD", "••••••••"),
                  ],
                ),
              ),

              // small fixed spacer instead of Spacer() to avoid Expanded inside
              // a scrollable (which causes unbounded height errors)
              const SizedBox(height: 24),

              // Edit Profile button
              GradientButton(
                text: 'Edit Profile',
                isLoading: profileIsLoading,
                onPressed: _handleEditProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF9B90A8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Divider(color: Color(0xFF2E2730), thickness: 1),
        ],
      ),
    );
  }
}
