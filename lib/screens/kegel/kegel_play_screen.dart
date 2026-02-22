import 'dart:async';
import 'package:couple_wellness/constants/app_colors.dart';
import 'package:couple_wellness/services/kegel_service.dart';
import 'package:couple_wellness/utils/responsive_sizer.dart';
import 'package:flutter/material.dart';

class KegelPlayScreen extends StatefulWidget {
  final String routineType;
  final int durationMinutes;
  final int sets;

  const KegelPlayScreen({
    super.key,
    required this.routineType,
    required this.durationMinutes,
    required this.sets,
  });

  @override
  State<KegelPlayScreen> createState() => _KegelPlayScreenState();
}

class _KegelPlayScreenState extends State<KegelPlayScreen>
    with TickerProviderStateMixin {
  final KegelService _kegelService = KegelService();

  late AnimationController _breathingController;
  late Animation<double> _scaleAnimation;

  Timer? _timer;
  int _elapsedSeconds = 0;
  int _currentSet = 1;
  bool _isContracting = true;
  bool _isPlaying = false;
  bool _isCompleted = false;

  final int _contractSeconds = 5;
  final int _relaxSeconds = 5;
  int _phaseSeconds = 0;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    _startExercise();
  }

  void _startExercise() {
    setState(() {
      _isPlaying = true;
      _phaseSeconds = _contractSeconds;
    });
    _breathingController.forward();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() {
        _elapsedSeconds++;
        _phaseSeconds--;

        if (_phaseSeconds <= 0) {
          _togglePhase();
        }

        final totalSeconds = widget.durationMinutes * 60;
        if (_elapsedSeconds >= totalSeconds) {
          _completeExercise();
        }
      });
    });
  }

  void _togglePhase() {
    if (_isContracting) {
      _isContracting = false;
      _phaseSeconds = _relaxSeconds;
      _breathingController.reverse();
    } else {
      _isContracting = true;
      _phaseSeconds = _contractSeconds;
      _breathingController.forward();
      if (_currentSet < widget.sets) {
        _currentSet++;
      }
    }
  }

  void _pauseExercise() {
    _timer?.cancel();
    _breathingController.stop();
    setState(() => _isPlaying = false);
  }

  void _resumeExercise() {
    setState(() => _isPlaying = true);
    _breathingController.forward();
    _startTimer();
  }

  void _completeExercise() {
    _timer?.cancel();
    _breathingController.stop();
    setState(() => _isCompleted = true);
    _saveProgress();
  }

  Future<void> _saveProgress() async {
    await _kegelService.saveSession(
      routineType: widget.routineType,
      durationMinutes: widget.durationMinutes,
      setsCompleted: _currentSet,
    );
  }

  String get _formattedTime {
    final minutes = _elapsedSeconds ~/ 60;
    final seconds = _elapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      body: _isCompleted ? _buildCompletionScreen() : _buildExerciseScreen(),
    );
  }

  Widget _buildExerciseScreen() {
    final progress = _elapsedSeconds / (widget.durationMinutes * 60);

    return Column(
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
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Spacer(),
                  Text(
                    widget.routineType,
                    style: TextStyle(fontSize: 20.fSize, fontWeight: FontWeight.w500, color: Colors.white),
                  ),
                  const Spacer(),
                  SizedBox(width: 48.w),
                ],
              ),
              SizedBox(height: 24.h),
              Padding(
                padding: EdgeInsets.only(left: 16.w),
                child: Text(
                  "Kegel Exercise",
                  style: TextStyle(fontSize: 28.fSize, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                SizedBox(height: 32.h),

                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 8.h,
                    backgroundColor: AppColors.brandPurpleLight.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.brandPurple),
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Progress", style: TextStyle(fontSize: 14.fSize, color: Colors.grey.shade600)),
                    Text("${(progress * 100).toInt()}%", style: TextStyle(fontSize: 14.fSize, fontWeight: FontWeight.w600, color: AppColors.brandPurple)),
                  ],
                ),

                SizedBox(height: 40.h),

                // Breathing Circle
                AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 220.adaptSize,
                      height: 220.adaptSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: _isContracting
                              ? [AppColors.brandPurple, const Color(0xFF8B5CF6)]
                              : [Colors.green, const Color(0xFF4ADE80)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_isContracting ? AppColors.brandPurple : Colors.green).withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: _scaleAnimation.value * 10,
                          ),
                        ],
                      ),
                      transform: Matrix4.identity()..scale(_scaleAnimation.value),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isContracting ? Icons.favorite : Icons.spa,
                            size: 60.adaptSize,
                            color: Colors.white,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            _isContracting ? "Contract" : "Relax",
                            style: TextStyle(
                              fontSize: 24.fSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "$_phaseSeconds s",
                            style: TextStyle(fontSize: 18.fSize, color: Colors.white.withOpacity(0.9)),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                SizedBox(height: 40.h),

                // Timer Display
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.adaptSize),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    _formattedTime,
                    style: TextStyle(
                      fontSize: 48.fSize,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandPurple,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),

                SizedBox(height: 32.h),

                // Set Counter
                Text(
                  "Set $_currentSet of ${widget.sets}",
                  style: TextStyle(
                    fontSize: 18.fSize,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),

                SizedBox(height: 40.h),

                // Control Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _isPlaying ? _pauseExercise : _resumeExercise,
                      child: Container(
                        width: 80.adaptSize,
                        height: 80.adaptSize,
                        decoration: BoxDecoration(
                          color: AppColors.brandPurple,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.brandPurple.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 40.adaptSize,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 24.w),
                    GestureDetector(
                      onTap: () {
                        _timer?.cancel();
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 60.adaptSize,
                        height: 60.adaptSize,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.red, width: 2),
                        ),
                        child: Icon(Icons.stop, size: 28.adaptSize, color: Colors.red),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        Container(
          width: 120.adaptSize,
          height: 120.adaptSize,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_circle, size: 80.adaptSize, color: Colors.green),
        ),
        SizedBox(height: 32.h),
        Text(
          "Great Job!",
          style: TextStyle(fontSize: 32.fSize, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        SizedBox(height: 16.h),
        Text(
          "You completed ${widget.routineType}",
          style: TextStyle(fontSize: 16.fSize, color: Colors.grey.shade600),
        ),
        SizedBox(height: 8.h),
        Text(
          "Duration: $_formattedTime",
          style: TextStyle(fontSize: 14.fSize, color: Colors.grey.shade500),
        ),
        const Spacer(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Row(
            children: [
              _buildStatCard("Sets Completed", "$_currentSet/${widget.sets}", Icons.fitness_center, AppColors.brandPurple),
              SizedBox(width: 16.w),
              _buildStatCard("Time", _formattedTime, Icons.timer, Colors.orange),
            ],
          ),
        ),
        const Spacer(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.adaptSize)),
              ),
              child: Text(
                "Done",
                style: TextStyle(fontSize: 18.fSize, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ),
        ),
        SizedBox(height: 40.h),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(20.adaptSize),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.adaptSize),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32.adaptSize),
            SizedBox(height: 12.h),
            Text(
              value,
              style: TextStyle(fontSize: 20.fSize, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(fontSize: 12.fSize, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
