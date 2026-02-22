import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class KegelService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  /// Get user kegel data from Firebase
  Future<Map<String, dynamic>?> getKegelData() async {
    try {
      if (_userId.isEmpty) return null;

      final doc = await _firestore.collection('users').doc(_userId).get();
      if (!doc.exists) return null;

      final data = doc.data();
      return data?['kegel'] as Map<String, dynamic>?;
    } catch (e) {
      print('Error getting kegel data: $e');
      return null;
    }
  }

  /// Save kegel session completion
  Future<void> saveSession({
    required String routineType,
    required int durationMinutes,
    required int setsCompleted,
  }) async {
    try {
      if (_userId.isEmpty) return;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Get current kegel data
      final currentData = await getKegelData();

      int weekStreak = currentData?['weekStreak'] ?? 0;
      int totalCompleted = currentData?['totalCompleted'] ?? 0;
      List<dynamic> completedDates = currentData?['completedDates'] ?? [];
      DateTime? lastCompletedDate = currentData?['lastCompletedDate'] != null
          ? (currentData!['lastCompletedDate'] as Timestamp).toDate()
          : null;

      // Check if already completed today
      bool alreadyCompletedToday = completedDates.any((date) {
        final d = (date as Timestamp).toDate();
        return d.year == today.year &&
            d.month == today.month &&
            d.day == today.day;
      });

      if (!alreadyCompletedToday) {
        totalCompleted++;
        completedDates.add(Timestamp.fromDate(today));

        // Calculate streak
        if (lastCompletedDate != null) {
          final difference = today.difference(lastCompletedDate).inDays;
          if (difference == 1) {
            weekStreak++;
          } else if (difference > 1) {
            weekStreak = 1;
          }
        } else {
          weekStreak = 1;
        }
      }

      // Calculate daily goal percentage
      final dailyGoalPercent = _calculateDailyGoal(completedDates);

      await _firestore.collection('users').doc(_userId).update({
        'kegel': {
          'weekStreak': weekStreak,
          'totalCompleted': totalCompleted,
          'completedDates': completedDates,
          'lastCompletedDate': Timestamp.fromDate(today),
          'dailyGoalPercent': dailyGoalPercent,
          'lastRoutineType': routineType,
          'lastSessionDuration': durationMinutes,
          'lastSessionDate': Timestamp.fromDate(now),
        }
      });
    } catch (e) {
      print('Error saving kegel session: $e');
    }
  }

  /// Calculate daily goal percentage based on weekly completion
  double _calculateDailyGoal(List<dynamic> completedDates) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final today = DateTime(now.year, now.month, now.day);

    int thisWeekCompletions = 0;
    for (var date in completedDates) {
      final d = (date as Timestamp).toDate();
      if (d.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          d.isBefore(now.add(const Duration(days: 1)))) {
        thisWeekCompletions++;
      }
    }

    // Goal: 3 sessions per week = ~43% per session
    return (thisWeekCompletions / 7 * 100).clamp(0, 100);
  }

  /// Initialize kegel data for new users
  Future<void> initializeKegelData() async {
    try {
      if (_userId.isEmpty) return;

      final doc = await _firestore.collection('users').doc(_userId).get();
      if (!doc.exists || doc.data()?['kegel'] == null) {
        await _firestore.collection('users').doc(_userId).set({
          'kegel': {
            'weekStreak': 0,
            'totalCompleted': 0,
            'completedDates': [],
            'dailyGoalPercent': 0.0,
            'lastCompletedDate': null,
            'lastRoutineType': '',
            'lastSessionDuration': 0,
            'lastSessionDate': null,
          }
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error initializing kegel data: $e');
    }
  }
}
