import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:couple_wellness/constants/app_colors.dart';
import 'package:couple_wellness/l10n/app_localizations.dart';
import 'package:couple_wellness/screens/chat/chat_screen.dart';
import 'package:couple_wellness/screens/game/gamescreen.dart';
import 'package:couple_wellness/screens/kegel/kegel_screen.dart';
import 'package:couple_wellness/services/auth_service.dart';
import 'package:couple_wellness/services/user_service.dart';
import 'package:couple_wellness/utils/responsive_sizer.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();

  String _displayName = '';
  String _subscriptionStatus = 'free';
  Duration? _trialTimeRemaining;
  String _preferredLanguage = 'EN';
  Map<String, bool> _featureAccess = {
    'games': false,
    'kegel': false,
    'chat': false,
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _userService.getUserData();
      if (userData != null && mounted) {
        setState(() {
          _displayName = userData['displayName'] ?? '';
          _subscriptionStatus = userData['subscriptionStatus'] ?? 'free';
          _preferredLanguage =
              (userData['preferredLanguage'] ?? 'en').toUpperCase();
          _featureAccess = {
            'games': userData['featuresAccess']?['games'] ?? false,
            'kegel': userData['featuresAccess']?['kegel'] ?? false,
            'chat': userData['featuresAccess']?['chat'] ?? false,
          };
        });

        // Check trial status
        if (_subscriptionStatus == 'trial') {
          final remaining = await _userService.getTrialTimeRemaining();
          if (mounted) {
            setState(() {
              _trialTimeRemaining = remaining;
            });
          }

          // Check if trial expired
          if (remaining == null || remaining.inSeconds <= 0) {
            await _userService.upgradeToPremium();
            if (mounted) {
              setState(() {
                _subscriptionStatus = 'free';
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _startTrial() async {
    try {
      await _userService.startTrial();
      await _loadUserData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).trialStarted),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).failedToStartTrial}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _changeLanguage(String lang) async {
    final langCode = lang.substring(0, 2).toLowerCase();
    try {
      await _userService.updateLanguage(langCode);
      if (mounted) {
        setState(() {
          _preferredLanguage = lang;
        });
      }
    } catch (e) {
      debugPrint('Error updating language: $e');
    }
  }

  void _navigateToFeature(String feature) {
    final hasAccess = _featureAccess[feature] ?? false;

    if (!hasAccess && _subscriptionStatus != 'trial') {
      _showPremiumDialog();
      return;
    }

    Widget screen;
    switch (feature) {
      case 'games':
        screen = const GamesScreen();
        break;
      case 'kegel':
        screen = const KegelScreen();
        break;
      case 'chat':
        screen = const ChatScreen();
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).premiumFeature),
        content: Text(AppLocalizations.of(context).premiumMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startTrial();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandPurple,
            ),
            child: Text(AppLocalizations.of(context).startFreeTrial),
          ),
        ],
      ),
    );
  }

  String _getWelcomeMessage() {
    if (_displayName.isEmpty) {
      return AppLocalizations.of(context).welcomeBack;
    }
    return '${AppLocalizations.of(context).welcome}\n$_displayName';
  }

  String _getTrialMessage() {
    if (_subscriptionStatus == 'trial' && _trialTimeRemaining != null) {
      final hours = _trialTimeRemaining!.inHours;
      final minutes = _trialTimeRemaining!.inMinutes % 60;
      return '$hours:${minutes.toString().padLeft(2, '0')} ${AppLocalizations.of(context).hoursRemaining}';
    }
    return AppLocalizations.of(context).fullAccess;
  }

  @override
  Widget build(BuildContext context) {
    // Theme Colors
    const Color primaryPurple = Color(0xFF8B42FF);
    const Color trialOrange = Color(0xFFFF8C00);
    const Color lightBackground = Color(0xFFF9F9FF);

    return Scaffold(
      backgroundColor: lightBackground,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: primaryPurple,
              ),
            )
          : StreamBuilder<DocumentSnapshot?>(
              stream: _userService.userStream,
              builder: (context, snapshot) {
                // Reload data when Firestore updates
                if (snapshot.hasData && snapshot.data != null) {
                  final data = snapshot.data!.data() as Map<String, dynamic>?;
                  if (data != null) {
                    _displayName = data['displayName'] ?? '';
                    _subscriptionStatus = data['subscriptionStatus'] ?? 'free';
                    _preferredLanguage =
                        (data['preferredLanguage'] ?? 'en').toUpperCase();
                  }
                }

                return Column(
                  children: [
                    // ── Header & Trial Card Stack ──────────────────────────────
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Purple Header
                        Container(
                          width: double.infinity,
                          height: 280.h,
                          decoration: const BoxDecoration(
                            color: primaryPurple,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(40),
                              bottomRight: Radius.circular(40),
                            ),
                          ),
                          padding: EdgeInsets.fromLTRB(24.w, 60.h, 24.w, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Icon(
                                    Icons.favorite,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                  // Language Switcher
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: Row(
                                      children: [
                                        _buildLangChip('GB EN',
                                            _preferredLanguage == 'EN', 'EN'),
                                        _buildLangChip('SA AR',
                                            _preferredLanguage == 'AR', 'AR'),
                                        _buildLangChip('FR FR',
                                            _preferredLanguage == 'FR', 'FR'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.h),
                              Text(
                                _getWelcomeMessage(),
                                style: TextStyle(
                                  fontSize: 34.fSize,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  height: 1.1,
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                AppLocalizations.of(context).exploreFeatures,
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 16.fSize),
                              ),
                            ],
                          ),
                        ),
                        // Floating Trial Card
                        Positioned(
                          bottom: -45.h,
                          left: 24.w,
                          right: 24.w,
                          child: GestureDetector(
                            onTap: () {
                              if (_subscriptionStatus == 'free') {
                                _startTrial();
                              }
                            },
                            child: Container(
                              height: 90.h,
                              decoration: BoxDecoration(
                                color: _subscriptionStatus == 'premium'
                                    ? Colors.green
                                    : trialOrange,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              child: Row(
                                children: [
                                  Icon(
                                    _subscriptionStatus == 'premium'
                                        ? Icons.workspace_premium
                                        : Icons.auto_awesome,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  SizedBox(width: 15.w),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _subscriptionStatus == 'premium'
                                              ? AppLocalizations.of(context).premiumActive
                                              : _subscriptionStatus == 'trial'
                                                  ? AppLocalizations.of(context).trialActive
                                                  : AppLocalizations.of(context).startTrial,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.fSize,
                                          ),
                                        ),
                                        Text(
                                          _getTrialMessage(),
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13.fSize,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    _subscriptionStatus == 'premium'
                                        ? Icons.verified
                                        : Icons.workspace_premium,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 60.h),

                    // ── Feature List ───────────────────────────────────────────
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        children: [
                          _buildFeatureCard(
                            title: AppLocalizations.of(context).couplesGames,
                            subtitle: AppLocalizations.of(context).couplesGamesSubtitle,
                            icon: Icons.sports_esports,
                            iconBg: const Color(0xFFFF4D8D),
                            hasAccess: _featureAccess['games'] ?? false,
                            onTap: () => _navigateToFeature('games'),
                          ),
                          _buildFeatureCard(
                            title: AppLocalizations.of(context).kegelExercises,
                            subtitle: AppLocalizations.of(context).kegelExercisesSubtitle,
                            icon: Icons.show_chart,
                            iconBg: const Color(0xFF9E64FF),
                            hasAccess: _featureAccess['kegel'] ?? false,
                            onTap: () => _navigateToFeature('kegel'),
                          ),
                          _buildFeatureCard(
                            title: AppLocalizations.of(context).aiChat,
                            subtitle: AppLocalizations.of(context).aiChatSubtitle,
                            icon: Icons.chat_bubble_outline,
                            iconBg: const Color(0xFF6B66FF),
                            hasAccess: _featureAccess['chat'] ?? false,
                            onTap: () => _navigateToFeature('chat'),
                          ),
                          SizedBox(height: 20.h),
                          // Show sign out button at bottom
                          ListTile(
                            leading: const Icon(Icons.logout, color: Colors.red),
                            title: Text(AppLocalizations.of(context).signOut),
                            onTap: () async {
                              try {
                                await _authService.logout();
                                // Navigation will be handled automatically by auth state listener in main.dart
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to sign out: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
    );
  }

  Widget _buildLangChip(String label, bool isSelected, String langCode) {
    return GestureDetector(
      onTap: () => _changeLanguage(langCode),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontSize: 10.fSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBg,
    required bool hasAccess,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.adaptSize),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: hasAccess
                  ? iconBg.withOpacity(0.1)
                  : Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.adaptSize),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.fSize,
                          ),
                        ),
                      ),
                      if (!hasAccess)
                        Icon(
                          Icons.lock_outline,
                          color: Colors.grey,
                          size: 16,
                        ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey, fontSize: 13.fSize),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
