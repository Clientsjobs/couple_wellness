import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// UserService handles all user-related Firestore operations
class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Get user document reference
  DocumentReference get _userDoc =>
      _firestore.collection('users').doc(currentUserId);

  /// Get user stream for real-time updates
  Stream<DocumentSnapshot?> get userStream =>
      _userDoc.snapshots();

  /// Get user data once
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final doc = await _userDoc.get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      throw 'Failed to fetch user data: $e';
    }
  }

  /// Update user display name
  Future<void> updateDisplayName(String name) async {
    try {
      await _userDoc.update({
        'displayName': name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to update name: $e';
    }
  }

  /// Update preferred language
  Future<void> updateLanguage(String languageCode) async {
    try {
      await _userDoc.update({
        'preferredLanguage': languageCode,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to update language: $e';
    }
  }

  // ==================== SWAY SETTINGS ====================

  /// Get sway settings
  Future<Map<String, dynamic>?> getSwaySettings() async {
    try {
      final userData = await getUserData();
      return userData?['swaySettings'] as Map<String, dynamic>?;
    } catch (e) {
      throw 'Failed to fetch sway settings: $e';
    }
  }

  /// Update sway intensity/preference
  Future<void> updateSwayIntensity(String intensity) async {
    try {
      await _userDoc.update({
        'swaySettings.intensity': intensity,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to update sway intensity: $e';
    }
  }

  /// Update sway mode (manual/auto)
  Future<void> updateSwayMode(String mode) async {
    try {
      await _userDoc.update({
        'swaySettings.mode': mode,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to update sway mode: $e';
    }
  }

  /// Update sway notifications
  Future<void> updateSwayNotifications(bool enabled) async {
    try {
      await _userDoc.update({
        'swaySettings.notificationsEnabled': enabled,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to update sway notifications: $e';
    }
  }

  /// Update sway schedule/reminders
  Future<void> updateSwaySchedule(List<String> days, String time) async {
    try {
      await _userDoc.update({
        'swaySettings.scheduleDays': days,
        'swaySettings.scheduleTime': time,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to update sway schedule: $e';
    }
  }

  /// Update complete sway settings
  Future<void> updateSwaySettings({
    required String intensity,
    required String mode,
    required bool notificationsEnabled,
    List<String>? scheduleDays,
    String? scheduleTime,
  }) async {
    try {
      await _userDoc.update({
        'swaySettings': {
          'intensity': intensity,
          'mode': mode,
          'notificationsEnabled': notificationsEnabled,
          if (scheduleDays != null) 'scheduleDays': scheduleDays,
          if (scheduleTime != null) 'scheduleTime': scheduleTime,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to update sway settings: $e';
    }
  }

  /// Stream for real-time sway settings updates
  Stream<Map<String, dynamic>?> get swaySettingsStream {
    return _userDoc.snapshots().map((snapshot) {
      final data = snapshot.data() as Map<String, dynamic>?;
      return data?['swaySettings'] as Map<String, dynamic>?;
    });
  }

  // ==================== END SWAY SETTINGS ====================

  /// Start free trial
  Future<void> startTrial() async {
    try {
      final now = DateTime.now();
      final trialEnd = now.add(const Duration(hours: 48));

      await _userDoc.update({
        'subscriptionStatus': 'trial',
        'trialStartTime': Timestamp.fromDate(now),
        'trialEndTime': Timestamp.fromDate(trialEnd),
        'featuresAccess': {
          'games': true,
          'kegel': true,
          'chat': true,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to start trial: $e';
    }
  }

  /// Check if user is in trial period
  Future<bool> isTrialActive() async {
    try {
      final userData = await getUserData();
      if (userData == null) return false;

      final status = userData['subscriptionStatus'];
      if (status != 'trial') return false;

      final trialEnd = userData['trialEndTime'] as Timestamp?;
      if (trialEnd == null) return false;

      return DateTime.now().isBefore(trialEnd.toDate());
    } catch (e) {
      return false;
    }
  }

  /// Get trial time remaining
  Future<Duration?> getTrialTimeRemaining() async {
    try {
      final userData = await getUserData();
      if (userData == null) return null;

      final trialEnd = userData['trialEndTime'] as Timestamp?;
      if (trialEnd == null) return null;

      final remaining = trialEnd.toDate().difference(DateTime.now());
      return remaining.isNegative ? Duration.zero : remaining;
    } catch (e) {
      return null;
    }
  }

  /// Get subscription status
  Future<String> getSubscriptionStatus() async {
    try {
      final userData = await getUserData();
      return userData?['subscriptionStatus'] ?? 'free';
    } catch (e) {
      return 'free';
    }
  }

  /// Check feature access
  Future<Map<String, bool>> getFeatureAccess() async {
    try {
      final userData = await getUserData();
      final access = userData?['featuresAccess'] as Map<String, dynamic>?;

      // Default access for free users
      if (access == null) {
        return {
          'games': false,
          'kegel': false,
          'chat': false,
        };
      }

      return {
        'games': access['games'] ?? false,
        'kegel': access['kegel'] ?? false,
        'chat': access['chat'] ?? false,
      };
    } catch (e) {
      return {
        'games': false,
        'kegel': false,
        'chat': false,
      };
    }
  }

  /// Update subscription to premium
  Future<void> upgradeToPremium() async {
    try {
      await _userDoc.update({
        'subscriptionStatus': 'premium',
        'featuresAccess': {
          'games': true,
          'kegel': true,
          'chat': true,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to upgrade: $e';
    }
  }

  /// Get welcome message with user name
  Future<String> getWelcomeMessage() async {
    try {
      final userData = await getUserData();
      final name = userData?['displayName'] ?? '';

      if (name.isEmpty) {
        return 'Welcome\nBack';
      }

      return 'Welcome\n$name';
    } catch (e) {
      return 'Welcome\nBack';
    }
  }
}
