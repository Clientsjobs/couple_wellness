import 'package:couple_wellness/constants/app_colors.dart';
import 'package:couple_wellness/screens/auth/sign_up_screen.dart';
import 'package:couple_wellness/screens/home/main_dashboard.dart';
import 'package:couple_wellness/services/auth_service.dart';
import 'package:couple_wellness/utils/responsive_sizer.dart';
import 'package:flutter/material.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showErrorSnackbar('Please enter both email and password');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.loginWithEmailPassword(
        email: email,
        password: password,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainDashboard()),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.bgGradientStart, AppColors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                SizedBox(height: 60.h),
                const TogetherLogo(),
                SizedBox(height: 14.h),
                Text(
                  'Together',
                  style: TextStyle(
                    fontSize: 32.fSize,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brandPurpleDark,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Wellness for couples',
                  style: TextStyle(
                    fontSize: 14.fSize,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 30.h),

                // --- LOGIN CARD ---
                Container(
                  padding: EdgeInsets.all(24.adaptSize),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.cardShadow,
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Log In',
                        style: TextStyle(
                          fontSize: 24.fSize,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 20.fSize),

                      _buildTextField(
                        hint: 'Enter your email',
                        icon: Icons.email_outlined,
                        controller: _emailController,
                      ),
                      SizedBox(height: 16.h),

                      _buildTextField(
                        hint: 'Enter your password',
                        icon: Icons.lock_outline,
                        isPassword: true,
                        controller: _passwordController,
                      ),

                      SizedBox(height: 20.h),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandPurple,
                            foregroundColor: AppColors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Text(
                                  'Log In',
                                  style: TextStyle(
                                    fontSize: 16.fSize,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: 20.h),

                      Row(
                        children: [
                          const Expanded(
                            child: Divider(color: AppColors.inputBorder),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'or',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                          const Expanded(
                            child: Divider(color: AppColors.inputBorder),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),

                      _buildSocialButton(
                        label: 'Continue with Google',
                        iconPath: Icons.g_mobiledata,
                      ),
                      SizedBox(height: 12.h),
                      _buildSocialButton(
                        label: 'Continue with Apple',
                        iconPath: Icons.apple,
                      ),
                      SizedBox(height: 20.h),

                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Don't have an account?",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.fSize,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.hintText, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.brandPurpleLight, size: 22),
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.brandPurple,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String label,
    required IconData iconPath,
  }) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.inputBorder),
        borderRadius: BorderRadius.circular(16),
        color: AppColors.inputFill,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(iconPath, size: 24),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class TogetherLogo extends StatelessWidget {
  const TogetherLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60.w,
      height: 40.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            child: Icon(
              Icons.favorite,
              color: Color.fromARGB(255, 175, 144, 231),
              size: 30.fSize,
            ),
          ),
          Positioned(
            right: 0,
            child: Icon(
              Icons.favorite,
              color: Color.fromARGB(255, 99, 59, 100),
              size: 30.fSize,
            ),
          ),
        ],
      ),
    );
  }
}
