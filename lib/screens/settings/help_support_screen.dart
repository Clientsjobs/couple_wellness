import 'package:couple_wellness/constants/app_colors.dart';
import 'package:couple_wellness/utils/responsive_sizer.dart';
import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              children: [
                _buildSectionTitle('Get Help'),
                SizedBox(height: 12.h),
                _buildHelpGroup(context, [
                  _buildHelpItem(
                    context,
                    'FAQs',
                    'Find answers to common questions',
                    Icons.help_outline,
                    () => _showFAQs(context),
                  ),
                  _buildHelpItem(
                    context,
                    'Contact Support',
                    'Get in touch with our team',
                    Icons.email_outlined,
                    () => _showContactSupport(context),
                  ),
                  _buildHelpItem(
                    context,
                    'Report a Bug',
                    'Help us improve the app',
                    Icons.bug_report_outlined,
                    () => _showReportBug(context),
                  ),
                ]),
                SizedBox(height: 24.h),
                _buildSectionTitle('Resources'),
                SizedBox(height: 12.h),
                _buildHelpGroup(context, [
                  _buildHelpItem(
                    context,
                    'User Guide',
                    'Learn how to use the app',
                    Icons.menu_book_outlined,
                    () => _showUserGuide(context),
                  ),
                  _buildHelpItem(
                    context,
                    'Terms of Service',
                    'Read our terms and conditions',
                    Icons.description_outlined,
                    () => _showTerms(context),
                  ),
                  _buildHelpItem(
                    context,
                    'Privacy Policy',
                    'How we handle your data',
                    Icons.privacy_tip_outlined,
                    () => _showPrivacyPolicy(context),
                  ),
                ]),
                SizedBox(height: 24.h),
                _buildSectionTitle('About'),
                SizedBox(height: 12.h),
                _buildAboutCard(),
                SizedBox(height: 100.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
            "Help & Support",
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

  Widget _buildHelpGroup(BuildContext context, List<Widget> items) {
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

  Widget _buildHelpItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
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

  Widget _buildAboutCard() {
    return Container(
      padding: EdgeInsets.all(24.adaptSize),
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
      child: Column(
        children: [
          Icon(
            Icons.favorite,
            size: 48.adaptSize,
            color: AppColors.brandPurple,
          ),
          SizedBox(height: 16.h),
          Text(
            'Couple Wellness',
            style: TextStyle(
              fontSize: 20.fSize,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Version 1.0.0',
            style: TextStyle(
              fontSize: 14.fSize,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Strengthening relationships through wellness',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.fSize,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showFAQs(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('FAQs'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFAQItem(
                'How do I start a Kegel exercise?',
                'Navigate to the Kegel tab and tap on any routine to begin.',
              ),
              SizedBox(height: 16.h),
              _buildFAQItem(
                'Can I connect with my partner?',
                'Yes, use the Chat feature to stay connected with your partner.',
              ),
              SizedBox(height: 16.h),
              _buildFAQItem(
                'How do I upgrade to Premium?',
                'Go to Settings > Premium Access to view subscription options.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: TextStyle(
            fontSize: 14.fSize,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          answer,
          style: TextStyle(
            fontSize: 13.fSize,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  void _showContactSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Contact Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Get in touch with us:'),
            SizedBox(height: 16.h),
            Row(
              children: [
                const Icon(Icons.email, color: AppColors.brandPurple),
                SizedBox(width: 12.w),
                const Text('support@couplewellness.com'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showReportBug(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Report a Bug'),
        content: const Text(
          'Please email us at bugs@couplewellness.com with details about the issue you encountered.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showUserGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('User Guide'),
        content: const Text('User guide will be available soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showTerms(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Terms of Service'),
        content: const Text('Terms of Service will be displayed here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Privacy Policy'),
        content: const Text('Privacy Policy will be displayed here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
