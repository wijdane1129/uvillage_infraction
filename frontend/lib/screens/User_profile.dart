import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../providers/user_provider.dart';
import '../providers/agent_auth_provider.dart';
import '../config/app_theme.dart';
import '../widgets/gradient_button.dart';
import '../services/auth_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _localUser = UserProvider();
  bool profileIsLoading = false;
  String? _selectedLanguage;
  File? _profileImageFile;
  final ImagePicker _picker = ImagePicker();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _currentPasswordController;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = _localUser.language;
    // initialize controllers with current provider values
    final currentName = ref.read(agentNameProvider);
    final currentEmail = ref.read(agentEmailProvider);
    _usernameController = TextEditingController(
      text: currentName.isNotEmpty ? currentName : _localUser.fullName,
    );
    _emailController = TextEditingController(
      text: currentEmail.isNotEmpty ? currentEmail : _localUser.email,
    );
    _passwordController = TextEditingController(text: _localUser.password);
    _currentPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _currentPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _profileImageFile = File(picked.path);
        });
      }
    } catch (e) {
      // ignore errors for now, could show a Snackbar
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkBgAlt,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white),
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.white),
                title: const Text(
                  'Take a Photo',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
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
                    controller: _usernameController,
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
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
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
                  TextField(
                    controller: _currentPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Current Password",
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
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "New Password",
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
                    onPressed: () async {
                      setState(() {
                        profileIsLoading = true;
                      });

                      final newName = _usernameController.text.trim();
                      final newEmail = _emailController.text.trim();
                      final newPassword = _passwordController.text.trim();

                      // update name/email locally first so UI reflects them
                      if (newName.isNotEmpty) {
                        ref
                            .read(agentNameProvider.notifier)
                            .setAgentName(newName);
                      }
                      if (newEmail.isNotEmpty) {
                        ref
                            .read(agentEmailProvider.notifier)
                            .setAgentEmail(newEmail);
                      }

                      // Attempt to change password on backend if provided
                      if (newPassword.isNotEmpty) {
                        final currentPassword =
                            _currentPasswordController.text.trim();
                        final auth = AuthService();
                        final emailForChange =
                            newEmail.isNotEmpty
                                ? newEmail
                                : (ref.read(agentEmailProvider).isNotEmpty
                                    ? ref.read(agentEmailProvider)
                                    : _localUser.email);
                        // Send currentPassword only when provided; backend must allow
                        // authenticated password change without current password.
                        final result = await auth.changePassword(
                          emailForChange,
                          currentPassword.isNotEmpty ? currentPassword : null,
                          newPassword,
                        );
                        final bool ok = result['success'] == true;
                        final String msg =
                            result['message']?.toString() ??
                            (ok
                                ? 'Password changed'
                                : 'Failed to change password');
                        if (ok) {
                          _localUser.setPassword(newPassword);
                        }
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(msg)));
                      }

                      setState(() {
                        if (_selectedLanguage != null) {
                          _localUser.setLanguage(_selectedLanguage!);
                        }
                        profileIsLoading = false;
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
    // Read agent name and email from the shared auth provider; fallback to local user
    final agentName = ref.watch(agentNameProvider);
    final agentEmail = ref.watch(agentEmailProvider);
    final user = {
      'username': agentName.isNotEmpty ? agentName : _localUser.fullName,
      'email': agentEmail.isNotEmpty ? agentEmail : _localUser.email,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              // Clear auth token
              await AuthService.logout();

              if (mounted) {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/welcome', (route) => false);
              }
            },
            tooltip: 'Logout',
          ),
        ],
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
              GestureDetector(
                onTap: _showImageSourceSheet,
                child: Container(
                  decoration: AppTheme.glowingCircle(AppTheme.pinkAccent),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: _buildAvatar(user['username']!),
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

  Widget _buildAvatar(String username) {
    if (_profileImageFile != null) {
      return CircleAvatar(
        radius: 50,
        backgroundImage: FileImage(_profileImageFile!),
        backgroundColor: Colors.transparent,
      );
    }

    final String initial =
        (username.isNotEmpty) ? username.trim()[0].toUpperCase() : 'A';
    return CircleAvatar(
      radius: 50,
      backgroundColor: AppTheme.purpleAccent,
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 36,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
