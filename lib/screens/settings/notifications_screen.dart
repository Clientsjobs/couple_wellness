import 'package:couple_wellness/constants/app_colors.dart';
import 'package:couple_wellness/utils/responsive_sizer.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _exerciseReminders = true;
  bool _partnerActivity = true;
  bool _weeklyReports = false;
  bool _promotions = false;

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
                _buildSectionTitle('General'),
                SizedBox(height: 12.h),
                _buildNotificationGroup([
                  _buildSwitchItem(
                    'Push Notifications',
                    'Receive notifications on your device',
                    Icons.notifications_active_outlined,
                    _pushNotifications,
                    (value) => setState(() => _pushNotifications = value),
                  ),
                  _buildSwitchItem(
                    'Email Notifications',
                    'Receive updates via email',
                    Icons.email_outlined,
                    _emailNotifications,
                    (value) => setState(() => _emailNotifications = value),
                  ),
                ]),
                SizedBox(height: 24.h),
                _buildSectionTitle('Activity'),
                SizedBox(height: 12.h),
                _buildNotificationGroup([
                  _buildSwitchItem(
                    'Exercise Reminders',
                    'Daily reminders for Kegel exercises',
                    Icons.fitness_center,
                    _exerciseReminders,
                    (value) => setState(() => _exerciseReminders = value),
                  ),
                  _buildSwitchItem(
                    'Partner Activity',
                    'Get notified when your partner completes activities',
                    Icons.favorite_outline,
                    _partnerActivity,
                    (value) => setState(() => _partnerActivity = value),
                  ),
                  _buildSwitchItem(
                    'Weekly Reports',
                    'Summary of your weekly progress',
                    Icons.bar_chart_outlined,
                    _weeklyReports,
                    (value) => setState(() => _weeklyReports = value),
                  ),
                ]),
                SizedBox(height: 24.h),
                _buildSectionTitle('Marketing'),
                SizedBox(height: 12.h),
                _buildNotificationGroup([
                  _buildSwitchItem(
                    'Promotions & Offers',
                    'Special deals and premium features',
                    Icons.local_offer_outlined,
                    _promotions,
                    (value) => setState(() => _promotions = value),
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

  Widget _buildHeader() {
    return Container(
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
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back, color: Colors.white, size: 24.adaptSize),
          ),
          SizedBox(height: 24.h),
          Text(
            "Notifications",
            style: TextStyle(
              fontSize: 32.fSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14.fSize,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildNotificationGroup(List<Widget> items) {
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

  Widget _buildSwitchItem(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.adaptSize),
            decoration: BoxDecoration(
              color: AppColors.brandPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.adaptSize),
            ),
            child: Icon(icon, color: AppColors.brandPurple, size: 22.adaptSize),
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
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.fSize,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.brandPurple,
          ),
        ],
      ),
    );
  }
}
