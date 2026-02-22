import 'package:couple_wellness/constants/app_colors.dart';
import 'package:couple_wellness/screens/kegel/kegel_play_menu_screen.dart';
import 'package:couple_wellness/screens/kegel/kegel_play_screen.dart';
import 'package:couple_wellness/services/kegel_service.dart';
import 'package:couple_wellness/utils/responsive_sizer.dart';
import 'package:flutter/material.dart';

class KegelScreen extends StatefulWidget {
  const KegelScreen({super.key});

  @override
  State<KegelScreen> createState() => _KegelScreenState();
}

class _KegelScreenState extends State<KegelScreen> {
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _startRoutine(String title, int minutes, int sets) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KegelPlayScreen(
          routineType: title,
          durationMinutes: minutes,
          sets: sets,
        ),
      ),
    ).then((_) => _loadKegelData()); // Refresh data after returning
  }

  void _navigateToPlayMenu() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const KegelPlayMenuScreen()),
    ).then((_) => _loadKegelData()); // Refresh data after returning
  }

  int get _weekStreak => _kegelData?['weekStreak'] ?? 0;
  int get _totalCompleted => _kegelData?['totalCompleted'] ?? 0;
  double get _dailyGoalPercent =>
      (_kegelData?['dailyGoalPercent'] ?? 0.0).toDouble();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      body: Column(
        children: [
          // Fixed Header Section
          _buildHeader(context),

          // Scrollable Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadKegelData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProgressCard(),
                    SizedBox(height: 32.h),
                    Text(
                      "Exercise Routines",
                      style: TextStyle(
                        fontSize: 18.fSize,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _buildRoutineItem(
                      "Beginner Routine",
                      "5 minutes • 3 sets",
                      Colors.green,
                      Icons.emoji_events_outlined,
                      onTap: () => _navigateToPlayMenu(),
                    ),
                    _buildRoutineItem(
                      "Intermediate Routine",
                      "8 minutes • 4 sets",
                      Colors.purpleAccent,
                      Icons.emoji_events_outlined,
                      onTap: () => _navigateToPlayMenu(),
                    ),
                    _buildRoutineItem(
                      "Advanced Routine",
                      "12 minutes • 5 sets",
                      Colors.redAccent,
                      Icons.emoji_events_outlined,
                      onTap: () => _navigateToPlayMenu(),
                    ),

                    SizedBox(height: 32.h),

                    // Educational Sections (Scrolling down content)
                    _buildInfoSection(
                      icon: Icons.info_outline,
                      iconColor: Colors.blueAccent,
                      title: "About Kegel Exercises",
                      content:
                          "Kegel exercises strengthen the pelvic floor muscles, which support the bladder, uterus, and bowel. These exercises can improve intimate wellness, bladder control, and enhance physical connection with your partner.",
                    ),
                    _buildInfoSection(
                      icon: Icons.track_changes,
                      iconColor: Colors.pink,
                      title: "Target Muscle",
                      content:
                          "Pelvic floor muscles - the muscles you use to stop urination midstream.",
                    ),
                    _buildHowToPerformSection(),

                    _buildTipsSection(),

                    _buildMedicalDisclaimer(),

                    SizedBox(height: 100.h), // Space for bottom nav
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
      padding: EdgeInsets.fromLTRB(24.w, 60.h, 24.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 24.adaptSize,
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Icon(
                Icons.timeline_rounded,
                color: Colors.white,
                size: 30.adaptSize,
              ),
              SizedBox(width: 12.w),
              Text(
                "Kegel",
                style: TextStyle(
                  fontSize: 32.fSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          const Text(
            "Your intimate wellness journey",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    final progressValue = _dailyGoalPercent / 100;

    return Container(
      padding: EdgeInsets.all(24.adaptSize),
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
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Your Progress",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.fSize,
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    _buildProgressStat(
                      "Week Streak",
                      "$_weekStreak",
                      const Color(0xFFF5F3FF),
                      Colors.orange,
                    ),
                    SizedBox(width: 12.w),
                    _buildProgressStat(
                      "Completed",
                      "$_totalCompleted",
                      const Color(0xFFF0FFF4),
                      Colors.green,
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Daily Goal",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13.fSize,
                      ),
                    ),
                    Text(
                      "${_dailyGoalPercent.toInt()}%",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13.fSize,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progressValue.clamp(0.0, 1.0),
                    minHeight: 8.h,
                    backgroundColor: AppColors.brandPurpleLight.withOpacity(
                      0.2,
                    ),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.brandPurple,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildProgressStat(
    String label,
    String value,
    Color bg,
    Color iconColor,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.adaptSize),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16.adaptSize),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  label.contains("Streak")
                      ? Icons.local_fire_department
                      : Icons.check_circle_outline,
                  color: iconColor,
                  size: 18.adaptSize,
                ),
                SizedBox(width: 8.w),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.fSize,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              value,
              style: TextStyle(fontSize: 22.fSize, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutineItem(
    String title,
    String subtitle,
    Color color,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.adaptSize),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.adaptSize),
          border: Border.all(color: AppColors.inputBorder.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.adaptSize),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24.adaptSize),
            ),
            SizedBox(width: 16.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.fSize,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey, fontSize: 13.fSize),
                ),
              ],
            ),
            const Spacer(),
            CircleAvatar(
              backgroundColor: AppColors.brandPurple,
              radius: 18.adaptSize,
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.adaptSize),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.brandPurpleLight.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 24.adaptSize),
              SizedBox(width: 12.w),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.fSize,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            content,
            style: TextStyle(
              color: Colors.grey.shade700,
              height: 1.5,
              fontSize: 14.fSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowToPerformSection() {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.adaptSize),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.brandPurpleLight.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.menu_book_outlined,
                color: AppColors.brandPurple,
                size: 24,
              ),
              SizedBox(width: 12.w),
              Text(
                "How to Perform",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.fSize,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          _buildStep(
            1,
            "Identify the Right Muscles",
            "Imagine stopping urination or holding gas. Those are your pelvic floor muscles.",
            Colors.blueAccent,
          ),
          _buildStep(
            2,
            "Contract & Hold",
            "Tighten these muscles and hold for the specified time. Don't hold your breath.",
            Colors.pinkAccent,
          ),
          _buildStep(
            3,
            "Relax Completely",
            "Release the muscles fully and rest between repetitions.",
            Colors.purpleAccent,
          ),
          _buildStep(
            4,
            "Stay Consistent",
            "Practice daily for best results. You should notice improvements within weeks.",
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildStep(int num, String title, String desc, Color barColor) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 3.w,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$num. $title",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.fSize,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    desc,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13.fSize,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsSection() {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.adaptSize),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: Colors.orange,
                size: 24,
              ),
              SizedBox(width: 12.w),
              Text(
                "Important Tips",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.fSize,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...[
            "Don't tighten your stomach, thighs, or buttocks",
            "Breathe normally throughout the exercise",
            "Start with beginner level and progress gradually",
            "Practice on an empty bladder for comfort",
          ].map(
            (tip) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "• ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Text(
                      tip,
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 13.fSize,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalDisclaimer() {
    return Container(
      padding: EdgeInsets.all(16.adaptSize),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Colors.orange, size: 20),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Medical Disclaimer",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade900,
                    fontSize: 14.fSize,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "This app is for informational and educational purposes only. Please consult a healthcare professional for any medical advice or concerns.",
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontSize: 12.fSize,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
