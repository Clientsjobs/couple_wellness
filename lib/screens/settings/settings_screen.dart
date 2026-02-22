import 'package:couple_wellness/constants/app_colors.dart';
import 'package:couple_wellness/screens/auth/sign_in_screen.dart';
import 'package:couple_wellness/screens/settings/account_screen.dart';
import 'package:couple_wellness/screens/settings/help_support_screen.dart';
import 'package:couple_wellness/screens/settings/notifications_screen.dart';
import 'package:couple_wellness/screens/settings/privacy_security_screen.dart';
import 'package:couple_wellness/screens/settings/subscription_screen.dart';
import 'package:couple_wellness/screens/settings/sway_settings_screen.dart';
import 'package:couple_wellness/services/auth_service.dart';
import 'package:couple_wellness/services/user_service.dart';
import 'package:couple_wellness/utils/responsive_sizer.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final UserService _userService = UserService();

  // Track selected language
  String _selectedLanguage = "English";
  bool _isLoadingLanguage = true;

  @override
  void initState() {
    super.initState();
    _loadUserLanguage();
  }

  /// Load user's preferred language from Firebase
  Future<void> _loadUserLanguage() async {
    try {
      final userData = await _userService.getUserData();
      if (userData != null && mounted) {
        final languageCode = userData['preferredLanguage'] as String?;
        if (languageCode != null) {
          setState(() {
            _selectedLanguage = _getLanguageName(languageCode);
          });
        }
      }
    } catch (e) {
      // Use default if error
    } finally {
      if (mounted) {
        setState(() => _isLoadingLanguage = false);
      }
    }
  }

  /// Convert language code to display name
  String _getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'ar':
        return 'Arabic';
      case 'fr':
        return 'French';
      default:
        return 'English';
    }
  }

  /// Convert display name to language code
  String _getLanguageCode(String name) {
    switch (name) {
      case 'English':
        return 'en';
      case 'Arabic':
        return 'ar';
      case 'French':
        return 'fr';
      default:
        return 'en';
    }
  }

  /// Save language to Firebase
  Future<void> _saveLanguage(String languageName) async {
    try {
      final languageCode = _getLanguageCode(languageName);
      await _userService.updateLanguage(languageCode);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save language: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              children: [
                _buildSettingsGroup([
                  _buildSettingsItem(
                    icon: Icons.person_outline,
                    title: "Account",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AccountScreen(),
                        ),
                      );
                    },
                  ),
                  _buildSettingsItem(
                    icon: Icons.credit_card_outlined,
                    title: "Premium Access",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PremiumScreen(),
                        ),
                      );
                    },
                  ),
                ]),
                SizedBox(height: 20.h),
                _buildSettingsGroup([
                  _buildSettingsItem(
                    icon: Icons.language_outlined,
                    title: "Language",
                    onTap: () => _showLanguageDialog(context), // Trigger Popup
                  ),
                  _buildSettingsItem(
                    icon: Icons.vibration_outlined,
                    title: "Sway Settings",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SwaySettingsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildSettingsItem(
                    icon: Icons.notifications_none_outlined,
                    title: "Notifications",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildSettingsItem(
                    icon: Icons.shield_outlined,
                    title: "Privacy & Security",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacySecurityScreen(),
                        ),
                      );
                    },
                  ),
                ]),
                SizedBox(height: 20.h),
                _buildSettingsGroup([
                  _buildSettingsItem(
                    icon: Icons.help_outline_rounded,
                    title: "Help & Support",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HelpSupportScreen(),
                        ),
                      );
                    },
                  ),
                ]),
                SizedBox(height: 20.h),
                _buildSettingsGroup([
                  _buildSettingsItem(
                    icon: Icons.logout_rounded,
                    title: "Log Out",
                    isDestructive: true,
                    onTap: () => _handleLogout(context),
                  ),
                ]),
                SizedBox(height: 100.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Logout Logic ---
  Future<void> _handleLogout(BuildContext context) async {
    final authService = AuthService();

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Log Out', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await authService.logout();
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LogInScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  // --- Language Popup Logic ---
  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.adaptSize),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 24), // Spacer for balance
                    Text(
                      "Language",
                      style: TextStyle(
                        fontSize: 18.fSize,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2933),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                _buildLanguageOption("English", "English"),
                _buildLanguageOption("Arabic", "العربية"),
                _buildLanguageOption("French", "Français"),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(String title, String subTitle) {
    bool isSelected = _selectedLanguage == title;
    return GestureDetector(
      onTap: () async {
        setState(() {
          _selectedLanguage = title;
        });
        await _saveLanguage(title); // Save to Firebase
        Navigator.pop(context);
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.brandPurple.withOpacity(0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? AppColors.brandPurple : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.fSize,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
                Text(
                  subTitle,
                  style: TextStyle(fontSize: 12.fSize, color: Colors.grey),
                ),
              ],
            ),
            if (isSelected)
              const CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.brandPurple,
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- Rest of your original UI Methods ---
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 220.h,
      decoration: const BoxDecoration(
        color: AppColors.brandPurple,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      padding: EdgeInsets.fromLTRB(24.w, 80.h, 24.w, 0),
      child: Text(
        "Settings",
        style: TextStyle(
          fontSize: 32.fSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.adaptSize),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(children: items),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final Color themeColor = isDestructive ? Colors.red : AppColors.brandPurple;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.adaptSize),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.adaptSize),
              decoration: BoxDecoration(
                color: themeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.adaptSize),
              ),
              child: Icon(icon, color: themeColor, size: 22.adaptSize),
            ),
            SizedBox(width: 16.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.fSize,
                fontWeight: FontWeight.w500,
                color: isDestructive ? Colors.red : const Color(0xFF1F2933),
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade400,
              size: 24.adaptSize,
            ),
          ],
        ),
      ),
    );
  }
}
