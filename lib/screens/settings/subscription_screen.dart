import 'package:couple_wellness/constants/app_colors.dart';
import 'package:couple_wellness/utils/responsive_sizer.dart';
import 'package:flutter/material.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  // Initializing with the 'Yearly' plan selected by default as seen in screenshots
  String _selectedPlan = 'yearly';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBFF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              // Back Button
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.arrow_back, size: 24.adaptSize),
                ),
              ),

              // Trial Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFB800), Color(0xFFFF6B00)],
                  ),
                  borderRadius: BorderRadius.circular(25.adaptSize),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 16.adaptSize,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      "Start your 48-hour free trial",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14.fSize,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // Crown Icon
              Icon(
                Icons.workspace_premium_rounded,
                size: 76.adaptSize,
                color: AppColors.brandPurple,
              ),

              SizedBox(height: 16.h),

              // Title & Subtitle
              Text(
                "Premium Access",
                style: TextStyle(
                  fontSize: 32.fSize,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2D1160),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "Choose your plan",
                style: TextStyle(
                  fontSize: 16.fSize,
                  color: AppColors.brandPurple,
                ),
              ),

              SizedBox(height: 40.h),

              // Plan Options
              _buildPlanCard(
                id: 'monthly',
                title: "Monthly Plan",
                price: "\$4.99",
                subPrice: "/month",
                totalPrice: "\$4.99",
                icon: Icons.electric_bolt_rounded,
                iconBg: const Color(0xFFA267FF),
              ),
              SizedBox(height: 16.h),
              _buildPlanCard(
                id: '3month',
                title: "3-Month Plan",
                price: "\$3.33",
                subPrice: "/month",
                totalPrice: "\$9.99",
                badge: "SAVE 33%",
                badgeColor: const Color(0xFFFF8A00),
                icon: Icons.trending_up_rounded,
                iconBg: const Color(0xFFFF4B8D),
                savingsText: "Save 33% compared to monthly",
              ),
              SizedBox(height: 16.h),
              _buildPlanCard(
                id: 'yearly',
                title: "Yearly Plan",
                price: "\$2.50",
                subPrice: "/month",
                totalPrice: "\$29.99",
                badge: "BEST VALUE",
                badgeColor: const Color(0xFFFF8A00),
                icon: Icons.workspace_premium, // Or Icons.stars_rounded
                iconBg: const Color(0xFFFF9F0A),
                savingsText: "Save 50% compared to monthly",
              ),

              SizedBox(height: 32.h),

              // Action Button
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.adaptSize),
                    ),
                  ),
                  child: Text(
                    "Start Free Trial",
                    style: TextStyle(
                      fontSize: 18.fSize,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Footer Info
              Text(
                "Free for 48 hours, then \$4.99/month. Cancel anytime.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 13.fSize,
                ),
              ),
              SizedBox(height: 24.h),
              _buildFooterIconLabel(
                Icons.lock_outline,
                "Secure payment via Apple & Google",
              ),
              SizedBox(height: 8.h),
              _buildFooterIconLabel(
                Icons.auto_awesome,
                "Cancel anytime, no commitment",
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String id,
    required String title,
    required String price,
    required String subPrice,
    required String totalPrice,
    required IconData icon,
    required Color iconBg,
    String? badge,
    Color? badgeColor,
    String? savingsText,
  }) {
    bool isSelected = _selectedPlan == id;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(16.adaptSize),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.adaptSize),
          border: Border.all(
            color: isSelected ? AppColors.brandPurple : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Icon
                Container(
                  padding: EdgeInsets.all(10.adaptSize),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12.adaptSize),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24.adaptSize),
                ),
                SizedBox(width: 16.w),
                // Title & Badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 15.fSize,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF1F2933),
                            ),
                          ),
                          if (badge != null) ...[
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: badgeColor,
                                borderRadius: BorderRadius.circular(
                                  6.adaptSize,
                                ),
                              ),
                              child: Text(
                                badge,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9.fSize,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            price,
                            style: TextStyle(
                              fontSize: 22.fSize,
                              fontWeight: FontWeight.w400,
                              color: AppColors.brandPurple,
                            ),
                          ),
                          Text(
                            subPrice,
                            style: TextStyle(
                              fontSize: 12.fSize,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Radio/Check Icon
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 24.adaptSize,
                      height: 24.adaptSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? AppColors.brandPurple
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.brandPurple
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16.adaptSize,
                            )
                          : null,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      totalPrice,
                      style: TextStyle(
                        fontSize: 11.fSize,
                        color: Colors.grey.shade400,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (savingsText != null) ...[
              SizedBox(height: 8.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  savingsText,
                  style: TextStyle(
                    color: Colors.green.shade600,
                    fontSize: 11.fSize,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFooterIconLabel(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.black87, size: 16.adaptSize),
        SizedBox(width: 8.w),
        Text(
          text,
          style: TextStyle(color: Colors.grey.shade700, fontSize: 12.fSize),
        ),
      ],
    );
  }
}
