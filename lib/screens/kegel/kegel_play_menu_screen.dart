import 'package:couple_wellness/constants/app_colors.dart';
import 'package:couple_wellness/screens/kegel/kegel_play_screen.dart';
import 'package:couple_wellness/services/kegel_service.dart';
import 'package:couple_wellness/utils/responsive_sizer.dart';
import 'package:flutter/material.dart';

class KegelPlayMenuScreen extends StatefulWidget {
  const KegelPlayMenuScreen({super.key});

  @override
  State<KegelPlayMenuScreen> createState() => _KegelPlayMenuScreenState();
}

class _KegelPlayMenuScreenState extends State<KegelPlayMenuScreen> {
  final KegelService _kegelService = KegelService();
  Map<String, dynamic>? _kegelData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadKegelData();
  }

  Future<void> _loadKegelData() async {
    try {
      final data = await _kegelService.getKegelData();
      if (mounted) {
        setState(() {
          _kegelData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startExercise(String routine, int minutes, int sets) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KegelPlayScreen(
          routineType: routine,
          durationMinutes: minutes,
          sets: sets,
        ),
      ),
    ).then((_) => _loadKegelData());
  }

  @override
  Widget build(BuildContext context) {
    final weekStreak = _kegelData?['weekStreak'] ?? 0;
    final totalCompleted = _kegelData?['totalCompleted'] ?? 0;
    final lastSessionDuration = _kegelData?['lastSessionDuration'] ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      body: Column(
        children: [
          // Purple Header
          Container(
            width: double.infinity,
            height: 200.h,
            decoration: const BoxDecoration(
              color: AppColors.brandPurple,
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
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.arrow_back, color: Colors.white, size: 24.adaptSize),
                    ),
                    const Spacer(),
                    Text(
                      "Kegel Exercise",
                      style: TextStyle(
                        fontSize: 20.fSize,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(width: 48.w),
                  ],
                ),
                SizedBox(height: 24.h),
                Padding(
                  padding: EdgeInsets.only(left: 16.w),
                  child: Text(
                    "Ready to Play?",
                    style: TextStyle(
                      fontSize: 28.fSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadKegelData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
                      child: Column(
                        children: [
                          // Stats Row
                          Container(
                            padding: EdgeInsets.all(20.adaptSize),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24.adaptSize),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem(Icons.local_fire_department, "$weekStreak", "Day Streak", Colors.orange),
                                Container(width: 1.w, height: 40.h, color: Colors.grey.shade200),
                                _buildStatItem(Icons.fitness_center, "$totalCompleted", "Sessions", AppColors.brandPurple),
                                Container(width: 1.w, height: 40.h, color: Colors.grey.shade200),
                                _buildStatItem(Icons.timer, "$lastSessionDuration", "Min Today", Colors.green),
                              ],
                            ),
                          ),

                          SizedBox(height: 32.h),

                          // Big Play Button
                          GestureDetector(
                            onTap: () => _startExercise("Daily Routine", 5, 3),
                            child: Container(
                              width: double.infinity,
                              height: 200.h,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.brandPurple, Color(0xFF9B59B6)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(32.adaptSize),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.brandPurple.withOpacity(0.3),
                                    blurRadius: 30,
                                    offset: const Offset(0, 15),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 80.adaptSize,
                                    height: 80.adaptSize,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.play_arrow, color: Colors.white, size: 50.adaptSize),
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    "Start Exercise",
                                    style: TextStyle(
                                      fontSize: 24.fSize,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    "Tap to begin your session",
                                    style: TextStyle(
                                      fontSize: 14.fSize,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 32.h),

                          // Routine Options
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Choose Routine",
                              style: TextStyle(
                                fontSize: 18.fSize,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),

                          _buildRoutineCard("Quick Start", "3 min • 2 sets", Colors.green, Icons.play_circle_fill, () => _startExercise("Quick Start", 3, 2)),
                          _buildRoutineCard("Daily Routine", "5 min • 3 sets", AppColors.brandPurple, Icons.favorite, () => _startExercise("Daily Routine", 5, 3)),
                          _buildRoutineCard("Intensive", "10 min • 5 sets", Colors.orange, Icons.local_fire_department, () => _startExercise("Intensive", 10, 5)),

                          SizedBox(height: 24.h),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28.adaptSize),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 20.fSize,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(fontSize: 12.fSize, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildRoutineCard(String title, String subtitle, Color color, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.adaptSize),
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
        child: Row(
          children: [
            Container(
              width: 56.adaptSize,
              height: 56.adaptSize,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.adaptSize),
              ),
              child: Icon(icon, color: color, size: 28.adaptSize),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.fSize,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14.fSize, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Container(
              width: 48.adaptSize,
              height: 48.adaptSize,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_forward, color: Colors.white, size: 24.adaptSize),
            ),
          ],
        ),
      ),
    );
  }
}
