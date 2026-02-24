import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  /// Get chat messages stream
  Stream<QuerySnapshot> getChatMessages() {
    if (currentUserId == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('chatMessages')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots();
  }

  /// Send a message
  Future<void> sendMessage(String message) async {
    if (currentUserId == null || message.trim().isEmpty) return;

    try {
      // Add user message
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('chatMessages')
          .add({
        'message': message.trim(),
        'isUser': true,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Generate AI response
      await _generateAIResponse(message.trim());
    } catch (e) {
      throw 'Failed to send message: $e';
    }
  }

  /// Generate AI response (simple rule-based for now)
  Future<void> _generateAIResponse(String userMessage) async {
    if (currentUserId == null) return;

    // Wait a bit to simulate thinking
    await Future.delayed(const Duration(milliseconds: 500));

    String aiResponse = _getAIResponse(userMessage.toLowerCase());

    // Add AI response
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('chatMessages')
        .add({
      'message': aiResponse,
      'isUser': false,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Simple rule-based AI responses
  String _getAIResponse(String message) {
    // Greetings
    if (message.contains('hello') || message.contains('hi') || message.contains('hey')) {
      return 'Hello! How can I help you with your relationship today?';
    }

    // Love related
    if (message.contains('love') && !message.contains('language')) {
      return 'Love is a beautiful journey! What would you like to know about strengthening your relationship?';
    }

    // Love languages
    if (message.contains('love language')) {
      return 'The 5 love languages are: Words of Affirmation, Quality Time, Receiving Gifts, Acts of Service, and Physical Touch. Understanding your partner\'s love language can greatly improve your relationship!';
    }

    // Communication
    if (message.contains('communication') || message.contains('talk') || message.contains('speak')) {
      return 'Communication is key in any relationship. Try active listening and expressing your feelings openly. Remember to use "I" statements instead of "you" statements to avoid blame.';
    }

    // Trust
    if (message.contains('trust') || message.contains('honest')) {
      return 'Trust is the foundation of a strong relationship. It takes time to build and requires honesty and consistency. Be reliable, keep your promises, and communicate openly.';
    }

    // Date/Romance
    if (message.contains('date') || message.contains('romantic') || message.contains('romance')) {
      return 'Regular date nights are important! Try our Couples Games feature for fun activities together. Even simple activities like cooking together or taking walks can strengthen your bond.';
    }

    // Intimacy/Physical
    if (message.contains('intimacy') || message.contains('physical') || message.contains('sex')) {
      return 'Physical intimacy is an important part of relationships. Open communication about needs and boundaries is essential. Remember, emotional intimacy often leads to better physical connection.';
    }

    // Kegel exercises
    if (message.contains('exercise') || message.contains('kegel') || message.contains('pelvic')) {
      return 'Kegel exercises can improve intimate wellness for both partners. Check out our Kegel section for guided routines! Regular practice can enhance physical health and intimacy.';
    }

    // Conflict/Arguments
    if (message.contains('fight') || message.contains('argue') || message.contains('conflict') || message.contains('disagree')) {
      return 'Conflicts are normal in relationships. The key is how you handle them. Take breaks when emotions run high, listen to understand (not to respond), and focus on solving the problem together rather than winning the argument.';
    }

    // Quality time
    if (message.contains('time') || message.contains('busy') || message.contains('schedule')) {
      return 'Quality time is crucial! Even 15 minutes of undivided attention daily can make a big difference. Put away phones, make eye contact, and truly connect with your partner.';
    }

    // Appreciation/Gratitude
    if (message.contains('appreciate') || message.contains('grateful') || message.contains('thank')) {
      return 'Expressing gratitude strengthens relationships! Try telling your partner one thing you appreciate about them every day. Small acknowledgments can create big positive changes.';
    }

    // Distance/Long distance
    if (message.contains('distance') || message.contains('far') || message.contains('away')) {
      return 'Long-distance relationships require extra effort but can work! Schedule regular video calls, send thoughtful messages, plan visits, and maintain trust through open communication.';
    }

    // Jealousy
    if (message.contains('jealous') || message.contains('insecure')) {
      return 'Jealousy often stems from insecurity or past experiences. Talk openly with your partner about your feelings. Building trust and self-confidence can help overcome jealousy.';
    }

    // Help/Support
    if (message.contains('help') || message.contains('advice') || message.contains('support')) {
      return 'I\'m here to support your relationship journey! You can ask me about communication, trust, intimacy, quality time, or try our features like Couples Games and Kegel exercises.';
    }

    // Games
    if (message.contains('game') || message.contains('play') || message.contains('fun')) {
      return 'Games are a great way to connect! Check out our Couples Games section for fun activities that can help you learn more about each other and strengthen your bond.';
    }

    // Marriage/Commitment
    if (message.contains('marry') || message.contains('marriage') || message.contains('commit')) {
      return 'Marriage and commitment are beautiful steps! They require ongoing effort, communication, and mutual respect. Remember, it\'s about growing together while maintaining your individual identities.';
    }

    // Thank you
    if (message.contains('thank')) {
      return 'You\'re welcome! I\'m always here to help. Feel free to ask anything about your relationship.';
    }

    // Default response with variety
    final defaultResponses = [
      'That\'s an interesting question! Remember, every relationship is unique. Focus on open communication, mutual respect, and spending quality time together. Would you like specific advice on any aspect of your relationship?',
      'Great question! Building a strong relationship takes effort from both partners. What specific area would you like to work on - communication, trust, intimacy, or quality time?',
      'I\'m here to help! Could you tell me more about what you\'re experiencing? Whether it\'s about communication, trust, or connection, I can offer some guidance.',
      'Every relationship has its challenges and beautiful moments. What aspect of your relationship would you like to strengthen today?',
    ];

    // Return a random default response
    return defaultResponses[message.length % defaultResponses.length];
  }

  /// Clear chat history
  Future<void> clearChatHistory() async {
    if (currentUserId == null) return;

    try {
      final messages = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('chatMessages')
          .get();

      for (var doc in messages.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw 'Failed to clear chat history: $e';
    }
  }
}
