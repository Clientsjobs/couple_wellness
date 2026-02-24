import 'package:flutter/material.dart';
import 'package:couple_wellness/services/game_service.dart';
import 'package:couple_wellness/utils/responsive_sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoveLanguageQuizScreen extends StatefulWidget {
  const LoveLanguageQuizScreen({super.key});

  @override
  State<LoveLanguageQuizScreen> createState() => _LoveLanguageQuizScreenState();
}

class _LoveLanguageQuizScreenState extends State<LoveLanguageQuizScreen> {
  final GameService _gameService = GameService();
  final TextEditingController _player1Controller = TextEditingController();
  final TextEditingController _player2Controller = TextEditingController();

  List<Map<String, dynamic>> _questions = [];
  int _currentQuestionIndex = 0;
  String? _sessionId;
  bool _isLoading = true;
  bool _gameCompleted = false;
  bool _isPlayer1Turn = true;

  // Player names
  String _player1Name = 'Player 1';
  String _player2Name = 'Player 2';
  bool _namesSet = false;

  // Love language scores for both players
  final Map<String, int> _player1Scores = {
    'words_of_affirmation': 0,
    'quality_time': 0,
    'receiving_gifts': 0,
    'acts_of_service': 0,
    'physical_touch': 0,
  };

  final Map<String, int> _player2Scores = {
    'words_of_affirmation': 0,
    'quality_time': 0,
    'receiving_gifts': 0,
    'acts_of_service': 0,
    'physical_touch': 0,
  };

  String? _player1SelectedAnswer;
  String? _player2SelectedAnswer;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    try {
      _sessionId = await _gameService.startGameSessionById('love_language_quiz');
      await _loadQuestions();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading quiz: $e')),
        );
      }
    }
  }

  Future<void> _loadQuestions() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('game_questions')
          .where('gameType', isEqualTo: 'love_language_quiz')
          .orderBy('order')
          .get();

      if (snapshot.docs.isEmpty) {
        _questions = _getDefaultQuestions();
      } else {
        _questions = snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList();
      }
    } catch (e) {
      _questions = _getDefaultQuestions();
    }
  }

  List<Map<String, dynamic>> _getDefaultQuestions() {
    return [
      {
        'id': '1',
        'question': 'What makes you feel most loved?',
        'options': [
          {'text': 'Hearing "I love you" and compliments', 'language': 'words_of_affirmation'},
          {'text': 'Spending quality time together', 'language': 'quality_time'},
          {'text': 'Receiving thoughtful gifts', 'language': 'receiving_gifts'},
          {'text': 'Having someone help with tasks', 'language': 'acts_of_service'},
          {'text': 'Hugs, kisses, and physical closeness', 'language': 'physical_touch'},
        ],
      },
      {
        'id': '2',
        'question': 'How do you prefer to show love?',
        'options': [
          {'text': 'Expressing feelings with words', 'language': 'words_of_affirmation'},
          {'text': 'Planning activities together', 'language': 'quality_time'},
          {'text': 'Giving meaningful presents', 'language': 'receiving_gifts'},
          {'text': 'Doing helpful things', 'language': 'acts_of_service'},
          {'text': 'Physical affection', 'language': 'physical_touch'},
        ],
      },
      {
        'id': '3',
        'question': 'What hurts you most in a relationship?',
        'options': [
          {'text': 'Harsh or critical words', 'language': 'words_of_affirmation'},
          {'text': 'Not spending enough time together', 'language': 'quality_time'},
          {'text': 'Forgetting special occasions', 'language': 'receiving_gifts'},
          {'text': 'Not helping when needed', 'language': 'acts_of_service'},
          {'text': 'Lack of physical affection', 'language': 'physical_touch'},
        ],
      },
      {
        'id': '4',
        'question': 'What would be your ideal date?',
        'options': [
          {'text': 'Deep conversation and sharing feelings', 'language': 'words_of_affirmation'},
          {'text': 'Doing an activity together', 'language': 'quality_time'},
          {'text': 'Exchanging thoughtful surprises', 'language': 'receiving_gifts'},
          {'text': 'Cooking a meal together', 'language': 'acts_of_service'},
          {'text': 'Cuddling and being close', 'language': 'physical_touch'},
        ],
      },
      {
        'id': '5',
        'question': 'What makes you feel appreciated?',
        'options': [
          {'text': 'Being told I\'m valued', 'language': 'words_of_affirmation'},
          {'text': 'Having undivided attention', 'language': 'quality_time'},
          {'text': 'Receiving a surprise gift', 'language': 'receiving_gifts'},
          {'text': 'Someone doing something for me', 'language': 'acts_of_service'},
          {'text': 'A warm hug or touch', 'language': 'physical_touch'},
        ],
      },
    ];
  }

  void _setPlayerNames() {
    if (_player1Controller.text.trim().isEmpty || _player2Controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both player names')),
      );
      return;
    }

    setState(() {
      _player1Name = _player1Controller.text.trim();
      _player2Name = _player2Controller.text.trim();
      _namesSet = true;
    });
  }

  void _selectAnswer(String language) {
    setState(() {
      if (_isPlayer1Turn) {
        _player1SelectedAnswer = language;
      } else {
        _player2SelectedAnswer = language;
      }
    });
  }

  void _submitAnswer() {
    final selectedAnswer = _isPlayer1Turn ? _player1SelectedAnswer : _player2SelectedAnswer;

    if (selectedAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an answer')),
      );
      return;
    }

    // Update score
    if (_isPlayer1Turn) {
      _player1Scores[selectedAnswer] = (_player1Scores[selectedAnswer] ?? 0) + 1;
    } else {
      _player2Scores[selectedAnswer] = (_player2Scores[selectedAnswer] ?? 0) + 1;
    }

    // Check if both players answered
    if (_player1SelectedAnswer != null && _player2SelectedAnswer != null) {
      // Both answered, move to next question
      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _isPlayer1Turn = true;
          _player1SelectedAnswer = null;
          _player2SelectedAnswer = null;
        });
      } else {
        _completeGame();
      }
    } else {
      // Switch to other player
      setState(() {
        _isPlayer1Turn = !_isPlayer1Turn;
      });
    }
  }

  String _getPrimaryLoveLanguage(Map<String, int> scores) {
    String primary = '';
    int maxScore = 0;

    scores.forEach((language, score) {
      if (score > maxScore) {
        maxScore = score;
        primary = language;
      }
    });

    return primary;
  }

  String _getLoveLanguageTitle(String language) {
    switch (language) {
      case 'words_of_affirmation':
        return 'Words of Affirmation';
      case 'quality_time':
        return 'Quality Time';
      case 'receiving_gifts':
        return 'Receiving Gifts';
      case 'acts_of_service':
        return 'Acts of Service';
      case 'physical_touch':
        return 'Physical Touch';
      default:
        return '';
    }
  }

  String _getLoveLanguageDescription(String language) {
    switch (language) {
      case 'words_of_affirmation':
        return 'Feels most loved through verbal expressions of love, compliments, and encouragement.';
      case 'quality_time':
        return 'Feels most loved when spending meaningful time together with undivided attention.';
      case 'receiving_gifts':
        return 'Feels most loved through thoughtful gifts that show care and consideration.';
      case 'acts_of_service':
        return 'Feels most loved when someone does helpful things for them.';
      case 'physical_touch':
        return 'Feels most loved through physical affection like hugs, kisses, and closeness.';
      default:
        return '';
    }
  }

  int _calculateCompatibility() {
    final player1Primary = _getPrimaryLoveLanguage(_player1Scores);
    final player2Primary = _getPrimaryLoveLanguage(_player2Scores);

    // Calculate compatibility based on matching scores
    int matchingPoints = 0;
    int totalPoints = 0;

    _player1Scores.forEach((language, score1) {
      final score2 = _player2Scores[language] ?? 0;
      final minScore = score1 < score2 ? score1 : score2;
      matchingPoints += minScore;
      totalPoints += score1 + score2;
    });

    if (totalPoints == 0) return 0;

    // Bonus if primary languages match
    if (player1Primary == player2Primary) {
      matchingPoints += 2;
      totalPoints += 2;
    }

    return ((matchingPoints / totalPoints) * 100).round();
  }

  Future<void> _completeGame() async {
    try {
      if (_sessionId != null) {
        await _gameService.completeGameSession(_sessionId!);

        // Save both players' results
        final player1Primary = _getPrimaryLoveLanguage(_player1Scores);
        final player2Primary = _getPrimaryLoveLanguage(_player2Scores);

        await FirebaseFirestore.instance
            .collection('user_game_progress')
            .doc(_gameService.currentUserId)
            .update({
          'loveLanguageResult': {
            'player1': {
              'name': _player1Name,
              'primaryLanguage': player1Primary,
              'scores': _player1Scores,
            },
            'player2': {
              'name': _player2Name,
              'primaryLanguage': player2Primary,
              'scores': _player2Scores,
            },
            'compatibility': _calculateCompatibility(),
            'completedAt': FieldValue.serverTimestamp(),
          },
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      setState(() {
        _gameCompleted = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error completing quiz: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _player1Controller.dispose();
    _player2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFB388FF);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9F9FF),
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: const Text('Love Language Quiz'),
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
      );
    }

    // Player names input screen
    if (!_namesSet) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9F9FF),
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: const Text('Love Language Quiz'),
          elevation: 0,
        ),
        body: Padding(
          padding: EdgeInsets.all(24.adaptSize),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite,
                size: 80.adaptSize,
                color: primaryColor,
              ),
              SizedBox(height: 24.h),
              Text(
                'Enter Player Names',
                style: TextStyle(
                  fontSize: 28.fSize,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2933),
                ),
              ),
              SizedBox(height: 40.h),
              TextField(
                controller: _player1Controller,
                decoration: InputDecoration(
                  labelText: 'Player 1 Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.adaptSize),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: _player2Controller,
                decoration: InputDecoration(
                  labelText: 'Player 2 Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.adaptSize),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _setPlayerNames,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.adaptSize),
                    ),
                  ),
                  child: Text(
                    'Start Quiz',
                    style: TextStyle(
                      fontSize: 16.fSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Game completed screen
    if (_gameCompleted) {
      final player1Primary = _getPrimaryLoveLanguage(_player1Scores);
      final player2Primary = _getPrimaryLoveLanguage(_player2Scores);
      final compatibility = _calculateCompatibility();

      return Scaffold(
        backgroundColor: const Color(0xFFF9F9FF),
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: const Text('Love Language Quiz'),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24.adaptSize),
            child: Column(
              children: [
                SizedBox(height: 20.h),
                Icon(
                  Icons.favorite,
                  size: 80.adaptSize,
                  color: primaryColor,
                ),
                SizedBox(height: 24.h),
                Text(
                  'Quiz Complete!',
                  style: TextStyle(
                    fontSize: 28.fSize,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2933),
                  ),
                ),
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.all(20.adaptSize),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.adaptSize),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Compatibility Score',
                        style: TextStyle(
                          fontSize: 18.fSize,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F2933),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        '$compatibility%',
                        style: TextStyle(
                          fontSize: 48.fSize,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),
                _buildPlayerResult(_player1Name, player1Primary, _player1Scores),
                SizedBox(height: 24.h),
                _buildPlayerResult(_player2Name, player2Primary, _player2Scores),
                SizedBox(height: 40.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.adaptSize),
                      ),
                    ),
                    child: Text(
                      'Back to Games',
                      style: TextStyle(
                        fontSize: 16.fSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Game play screen
    final currentQuestion = _questions[_currentQuestionIndex];
    final options = currentQuestion['options'] as List<dynamic>;
    final currentPlayer = _isPlayer1Turn ? _player1Name : _player2Name;
    final selectedAnswer = _isPlayer1Turn ? _player1SelectedAnswer : _player2SelectedAnswer;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Love Language Quiz'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.adaptSize),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                      style: TextStyle(
                        fontSize: 14.fSize,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$currentPlayer\'s Turn',
                        style: TextStyle(
                          fontSize: 12.fSize,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) / _questions.length,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              ],
            ),
          ),

          // Question and options
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.adaptSize),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentQuestion['question'] ?? '',
                    style: TextStyle(
                      fontSize: 22.fSize,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2933),
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  ...options.map((option) {
                    final optionText = option['text'] as String;
                    final language = option['language'] as String;
                    final isSelected = selectedAnswer == language;

                    return GestureDetector(
                      onTap: () => _selectAnswer(language),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        padding: EdgeInsets.all(16.adaptSize),
                        decoration: BoxDecoration(
                          color: isSelected ? primaryColor.withOpacity(0.1) : Colors.white,
                          borderRadius: BorderRadius.circular(12.adaptSize),
                          border: Border.all(
                            color: isSelected ? primaryColor : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                              color: isSelected ? primaryColor : Colors.grey.shade400,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                optionText,
                                style: TextStyle(
                                  fontSize: 16.fSize,
                                  color: isSelected ? primaryColor : Colors.grey.shade700,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Submit button
          Container(
            padding: EdgeInsets.all(24.adaptSize),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedAnswer != null ? _submitAnswer : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.adaptSize),
                  ),
                ),
                child: Text(
                  'Submit Answer',
                  style: TextStyle(
                    fontSize: 16.fSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerResult(String playerName, String primaryLanguage, Map<String, int> scores) {
    const Color primaryColor = Color(0xFFB388FF);

    return Container(
      padding: EdgeInsets.all(24.adaptSize),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.adaptSize),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            playerName,
            style: TextStyle(
              fontSize: 20.fSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2933),
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(16.adaptSize),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.adaptSize),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getLoveLanguageTitle(primaryLanguage),
                  style: TextStyle(
                    fontSize: 18.fSize,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  _getLoveLanguageDescription(primaryLanguage),
                  style: TextStyle(
                    fontSize: 14.fSize,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          ...scores.entries.map((entry) {
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      _getLoveLanguageTitle(entry.key),
                      style: TextStyle(
                        fontSize: 12.fSize,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: entry.value / _questions.length,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '${entry.value}',
                    style: TextStyle(
                      fontSize: 12.fSize,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
