import 'dart:io';
import 'package:couple_wellness/constants/app_colors.dart';
import 'package:couple_wellness/services/user_service.dart';
import 'package:couple_wellness/utils/responsive_sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final UserService _userService = UserService();
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  bool _isLoading = true;
  String _email = '';
  String _displayName = '';
  String _subscriptionStatus = 'free';
  String? _profilePictureUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userData = await _userService.getUserData();
      final status = await _userService.getSubscriptionStatus();
      final profileUrl = await _userService.getProfilePictureUrl();

      if (mounted) {
        setState(() {
          _email = user?.email ?? '';
          _displayName = userData?['displayName'] ?? '';
          _subscriptionStatus = status;
          _profilePictureUrl = profileUrl;
          _nameController.text = _displayName;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateDisplayName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      _showSnackBar('Name cannot be empty', isError: true);
      return;
    }

    try {
      await _userService.updateDisplayName(newName);
      setState(() => _displayName = newName);
      _showSnackBar('Name updated successfully');
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showSnackBar('Failed to update name: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showEditNameDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Name'),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Display Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateDisplayName();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandPurple,
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Show image source selection dialog
  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Choose Profile Picture'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.brandPurple),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.brandPurple),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_profilePictureUrl != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Picture'),
                onTap: () {
                  Navigator.pop(context);
                  _removeProfilePicture();
                },
              ),
          ],
        ),
      ),
    );
  }

  /// Pick image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      _showSnackBar('Uploading profile picture...');

      final imageFile = File(pickedFile.path);
      final downloadUrl = await _userService.uploadProfilePicture(imageFile);

      setState(() {
        _profilePictureUrl = downloadUrl;
      });

      _showSnackBar('Profile picture updated successfully');
    } catch (e) {
      _showSnackBar('Failed to upload picture: $e', isError: true);
    }
  }

  /// Remove profile picture
  Future<void> _removeProfilePicture() async {
    try {
      await _userService.deleteProfilePicture();
      setState(() {
        _profilePictureUrl = null;
      });
      _showSnackBar('Profile picture removed');
    } catch (e) {
      _showSnackBar('Failed to remove picture: $e', isError: true);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
                    children: [
                      _buildProfileSection(),
                      SizedBox(height: 24.h),
                      _buildInfoGroup([
                        _buildInfoItem('Email', _email, Icons.email_outlined),
                        _buildInfoItem(
                          'Subscription',
                          _subscriptionStatus == 'premium'
                              ? 'Premium'
                              : _subscriptionStatus == 'trial'
                                  ? 'Trial'
                                  : 'Free',
                          Icons.card_membership_outlined,
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
            "Account",
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

  Widget _buildProfileSection() {
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
          Stack(
            children: [
              CircleAvatar(
                radius: 50.adaptSize,
                backgroundColor: AppColors.brandPurple.withOpacity(0.1),
                backgroundImage: _profilePictureUrl != null
                    ? NetworkImage(_profilePictureUrl!)
                    : null,
                child: _profilePictureUrl == null
                    ? Icon(
                        Icons.person,
                        size: 50.adaptSize,
                        color: AppColors.brandPurple,
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: Container(
                    padding: EdgeInsets.all(8.adaptSize),
                    decoration: BoxDecoration(
                      color: AppColors.brandPurple,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 16.adaptSize,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            _displayName.isEmpty ? 'No Name Set' : _displayName,
            style: TextStyle(
              fontSize: 22.fSize,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _email,
            style: TextStyle(
              fontSize: 14.fSize,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showEditNameDialog,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit Name'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandPurple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.adaptSize),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGroup(List<Widget> items) {
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

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Padding(
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
                  label,
                  style: TextStyle(
                    fontSize: 12.fSize,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.fSize,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
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
