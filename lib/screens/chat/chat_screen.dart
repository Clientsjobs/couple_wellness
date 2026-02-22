import 'package:couple_wellness/constants/app_colors.dart';
import 'package:couple_wellness/utils/responsive_sizer.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1. Purple Header Section
          _buildHeader(context),

          // 2. Chat Messages Area
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              children: [
                _buildAIMessage(
                  "Hello! I'm here to support your relationship journey. How can I help you today?",
                ),
              ],
            ),
          ),

          // 3. Footer Section (Disclaimer + Input)
          _buildChatFooter(),
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
                Icons.chat_bubble_outline,
                color: Colors.white,
                size: 30.adaptSize,
              ),
              SizedBox(width: 12.w),
              Text(
                "Chat",
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
            "Your AI relationship companion",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildAIMessage(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AI Icon Avatar
        Container(
          padding: EdgeInsets.all(8.adaptSize),
          decoration: const BoxDecoration(
            color: AppColors.brandPurpleLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.smart_toy_outlined,
            color: Colors.white,
            size: 20.adaptSize,
          ),
        ),
        SizedBox(width: 12.w),
        // Message Bubble
        Flexible(
          child: Container(
            padding: EdgeInsets.all(16.adaptSize),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F4F9),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20.adaptSize),
                bottomLeft: Radius.circular(20.adaptSize),
                bottomRight: Radius.circular(20.adaptSize),
              ),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 15.fSize,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChatFooter() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Medical Disclaimer Box
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.adaptSize),
            margin: EdgeInsets.only(bottom: 16.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9E6), // Pale Yellow
              borderRadius: BorderRadius.circular(12.adaptSize),
              border: Border.all(color: Colors.orange.shade100),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.orange,
                  size: 18.adaptSize,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    "For informational purposes only. Consult a doctor for medical advice.",
                    style: TextStyle(
                      color: Colors.orange.shade900,
                      fontSize: 12.fSize,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Text Input Field
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 54.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F4F9),
                    borderRadius: BorderRadius.circular(15.adaptSize),
                  ),
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type your message...",
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 14.fSize,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              // Send Button
              GestureDetector(
                onTap: () {
                  // Handle send logic
                },
                child: Container(
                  height: 54.h,
                  width: 54.h,
                  decoration: const BoxDecoration(
                    color: AppColors.brandPurple,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 24.adaptSize,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
