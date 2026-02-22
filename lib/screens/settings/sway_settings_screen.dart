import 'package:couple_wellness/constants/app_colors.dart';
import 'package:couple_wellness/services/user_service.dart';
import 'package:couple_wellness/utils/responsive_sizer.dart';
import 'package:flutter/material.dart';

class SwaySettingsScreen extends StatefulWidget {
  const SwaySettingsScreen({super.key});

  @override
  State<SwaySettingsScreen> createState() => _SwaySettingsScreenState();
}

class _SwaySettingsScreenState extends State<SwaySettingsScreen> {
  final UserService _userService = UserService();

  // Sway settings state
  String _selectedIntensity = 'Medium';
  String _selectedMode = 'Manual';
  bool _notificationsEnabled = true;
  List<String> _selectedDays = ['Mon', 'Wed', 'Fri'];
  String _selectedTime = '09:00';

  bool _isLoading = true;
  bool _isSaving = false;

  // Options
  final List<String> _intensityOptions = ['Low', 'Medium', 'High'];
  final List<String> _modeOptions = ['Manual', 'Auto'];
  final List<String> _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _loadSwaySettings();
  }

  /// Load sway settings from Firebase
  Future<void> _loadSwaySettings() async {
    try {
      final settings = await _userService.getSwaySettings();
      if (settings != null && mounted) {
        setState(() {
          _selectedIntensity = settings['intensity'] ?? 'Medium';
          _selectedMode = settings['mode'] ?? 'Manual';
          _notificationsEnabled = settings['notificationsEnabled'] ?? true;
          _selectedDays = List<String>.from(settings['scheduleDays'] ?? ['Mon', 'Wed', 'Fri']);
          _selectedTime = settings['scheduleTime'] ?? '09:00';
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to load settings: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Save all sway settings to Firebase
  Future<void> _saveSwaySettings() async {
    setState(() => _isSaving = true);
    try {
      await _userService.updateSwaySettings(
        intensity: _selectedIntensity,
        mode: _selectedMode,
        notificationsEnabled: _notificationsEnabled,
        scheduleDays: _selectedDays,
        scheduleTime: _selectedTime,
      );
      if (mounted) {
        _showSnackBar('Sway settings saved successfully!');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to save settings: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : AppColors.brandPurple,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
                    children: [
                      // Intensity Setting
                      _buildSettingCard(
                        title: 'Intensity Level',
                        icon: Icons.speed_outlined,
                        child: _buildIntensitySelector(),
                      ),
                      SizedBox(height: 20.h),

                      // Mode Setting
                      _buildSettingCard(
                        title: 'Control Mode',
                        icon: Icons.touch_app_outlined,
                        child: _buildModeSelector(),
                      ),
                      SizedBox(height: 20.h),

                      // Notifications Setting
                      _buildSettingCard(
                        title: 'Notifications',
                        icon: Icons.notifications_outlined,
                        child: _buildNotificationToggle(),
                      ),
                      SizedBox(height: 20.h),

                      // Schedule Setting
                      _buildSettingCard(
                        title: 'Schedule',
                        icon: Icons.calendar_today_outlined,
                        child: _buildScheduleSelector(),
                      ),
                      SizedBox(height: 20.h),

                      // Time Setting
                      _buildSettingCard(
                        title: 'Reminder Time',
                        icon: Icons.access_time_outlined,
                        child: _buildTimeSelector(),
                      ),
                      SizedBox(height: 40.h),

                      // Save Button
                      _buildSaveButton(),
                      SizedBox(height: 100.h),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

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
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              "Sway Settings",
              style: TextStyle(
                fontSize: 28.fSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: 48.w), // Balance for back button
        ],
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
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
      padding: EdgeInsets.all(20.adaptSize),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.adaptSize),
                decoration: BoxDecoration(
                  color: AppColors.brandPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.adaptSize),
                ),
                child: Icon(icon, color: AppColors.brandPurple, size: 22.adaptSize),
              ),
              SizedBox(width: 12.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.fSize,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2933),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }

  Widget _buildIntensitySelector() {
    return Row(
      children: _intensityOptions.map((intensity) {
        final isSelected = _selectedIntensity == intensity;
        Color intensityColor;
        switch (intensity) {
          case 'Low':
            intensityColor = Colors.green;
            break;
          case 'High':
            intensityColor = Colors.red;
            break;
          default:
            intensityColor = Colors.orange;
        }

        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => _selectedIntensity = intensity);
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: isSelected ? intensityColor.withOpacity(0.1) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? intensityColor : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.circle,
                    size: 12,
                    color: intensityColor,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    intensity,
                    style: TextStyle(
                      fontSize: 12.fSize,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? intensityColor : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildModeSelector() {
    return Row(
      children: _modeOptions.map((mode) {
        final isSelected = _selectedMode == mode;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => _selectedMode = mode);
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              padding: EdgeInsets.symmetric(vertical: 16.h),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.brandPurple : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                mode,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.fSize,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNotificationToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Enable Sway Reminders',
          style: TextStyle(
            fontSize: 14.fSize,
            color: const Color(0xFF1F2933),
          ),
        ),
        Switch(
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() => _notificationsEnabled = value);
          },
          activeColor: AppColors.brandPurple,
        ),
      ],
    );
  }

  Widget _buildScheduleSelector() {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: _weekDays.map((day) {
        final isSelected = _selectedDays.contains(day);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedDays.remove(day);
              } else {
                _selectedDays.add(day);
              }
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.brandPurple : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              day,
              style: TextStyle(
                fontSize: 12.fSize,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimeSelector() {
    return GestureDetector(
      onTap: () => _showTimePicker(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedTime,
              style: TextStyle(
                fontSize: 16.fSize,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2933),
              ),
            ),
            const Icon(Icons.access_time, color: AppColors.brandPurple),
          ],
        ),
      ),
    );
  }

  Future<void> _showTimePicker() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(_selectedTime.split(':')[0]),
        minute: int.parse(_selectedTime.split(':')[1]),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.brandPurple,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _isSaving ? null : _saveSwaySettings,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 18.h),
        decoration: BoxDecoration(
          color: _isSaving ? Colors.grey : AppColors.brandPurple,
          borderRadius: BorderRadius.circular(16.adaptSize),
          boxShadow: [
            BoxShadow(
              color: AppColors.brandPurple.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: _isSaving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  'Save Settings',
                  style: TextStyle(
                    fontSize: 16.fSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
