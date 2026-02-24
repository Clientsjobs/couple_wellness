import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:couple_wellness/constants/app_colors.dart';
import 'package:couple_wellness/l10n/app_localizations.dart';
import 'package:couple_wellness/services/chat_service.dart';
import 'package:couple_wellness/utils/responsive_sizer.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      await _chatService.sendMessage(message);
      _messageController.clear();

      // Scroll to bottom after sending
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

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
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatService.getChatMessages(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading messages: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.adaptSize),
                      child: Text(
                        AppLocalizations.of(context).aiGreeting,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16.fSize,
                        ),
                      ),
                    ),
                  );
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData = messages[index].data() as Map<String, dynamic>;
                    final isUser = messageData['isUser'] ?? false;
                    final message = messageData['message'] ?? '';

                    return Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: isUser
                          ? _buildUserMessage(message)
                          : _buildAIMessage(message),
                    );
                  },
                );
              },
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
                AppLocalizations.of(context).chat,
                style: TextStyle(
                  fontSize: 32.fSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            AppLocalizations.of(context).aiCompanion,
            style: const TextStyle(color: Colors.white70),
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

  Widget _buildUserMessage(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Message Bubble
        Flexible(
          child: Container(
            padding: EdgeInsets.all(16.adaptSize),
            decoration: BoxDecoration(
              color: AppColors.brandPurple,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.adaptSize),
                bottomLeft: Radius.circular(20.adaptSize),
                bottomRight: Radius.circular(20.adaptSize),
              ),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.fSize,
                height: 1.4,
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        // User Icon Avatar
        Container(
          padding: EdgeInsets.all(8.adaptSize),
          decoration: const BoxDecoration(
            color: AppColors.brandPurple,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person,
            color: Colors.white,
            size: 20.adaptSize,
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
                    AppLocalizations.of(context).chatDisclaimer,
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
                      hintText: AppLocalizations.of(context).typeMessage,
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 14.fSize,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              // Send Button
              GestureDetector(
                onTap: _isSending ? null : _sendMessage,
                child: Container(
                  height: 54.h,
                  width: 54.h,
                  decoration: BoxDecoration(
                    color: _isSending
                        ? AppColors.brandPurple.withOpacity(0.5)
                        : AppColors.brandPurple,
                    shape: BoxShape.circle,
                  ),
                  child: _isSending
                      ? Padding(
                          padding: EdgeInsets.all(15.adaptSize),
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
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
