import 'package:flutter/material.dart';
import 'package:couple_wellness/services/game_service.dart';
import 'package:couple_wellness/utils/responsive_sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TruthOrTruthGameScreen extends StatefulWidget {
  const TruthOrTruthGameScreen({super.key});

  @override
  State<TruthOrTruthGameScreen> createState() => _TruthOrTruthGameScreenState();
}

class _TruthOrTruthGameScreenState extends State<TruthOrTruthGameScreen> {
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

  // Answers storage
  Map<int, Map<String, String>> _answers = {}; // {questionIndex: {player1: answer, player2: answer}}

  // Scores
  int _player1Score = 0;
  int _player2Score = 0;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    try {
      // Start game session
      _sessionId = await _gameService.startGameSessionById('truth_or_truth');

      // Load questions from Firestore
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
          SnackBar(content: Text('Error loading game: $e')),
        );
      }
    }
  }

  Future<void> _loadQuestions() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('game_questions')
          .where('gameType', isEqualTo: 'truth_or_truth')
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
        'question': 'What is your favorite memory of us together?',
        'category': 'memories',
      },
      {
        'id': '2',
        'question': 'What do you appreciate most about our relationship?',
        'category': 'appreciation',
      },
      {
        'id': '3',
        'question': 'What is one thing you would like us to do together?',
        'category': 'future',
      },
      {
        'id': '4',
        'question': 'What makes you feel most loved by me?',
        'category': 'love',
      },
      {
        'id': '5',
        'question': 'What is something you have always wanted to tell me?',
        'category': 'communication',
      },
      {
        'id': '6',
        'question': 'What is your biggest dream for our future together?',
        'category': 'future',
      },
      {
        'id': '7',
        'question': 'What is one thing I do that always makes you smile?',
        'category': 'happiness',
      },
      {
        'id': '8',
        'question': 'What is your favorite thing about spending time with me?',
        'category': 'quality_time',
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

  void _submitAnswer() {
    final controller = _isPlayer1Turn ? _player1Controller : _player2Controller;
    final answer = controller.text.trim();

    if (answer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your answer')),
      );
      return;
    }

    // Store answer
    if (_answers[_currentQuestionIndex] == null) {
      _answers[_currentQuestionIndex] = {};
    }

    if (_isPlayer1Turn) {
      _answers[_currentQuestionIndex]!['player1'] = answer;
      // Award point for answering
      _player1Score++;
    } else {
      _answers[_currentQuestionIndex]!['player2'] = answer;
      // Award point for answering
      _player2Score++;
    }

    controller.clear();

    // Check if both players answered
    if (_answers[_currentQuestionIndex]!.length == 2) {
      // Both answered, move to next question
      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _isPlayer1Turn = true;
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

  void _skipQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _isPlayer1Turn = true;
        _player1Controller.clear();
        _player2Controller.clear();
      });
    } else {
      _completeGame();
    }
  }

  Future<void> _completeGame() async {
    try {
      if (_sessionId != null) {
        await _gameService.completeGameSession(_sessionId!);
      }
      setState(() {
        _gameCompleted = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error completing game: $e')),
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
    const Color primaryColor = Color(0xFFFF4D8D);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9F9FF),
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: const Text('Truth or Truth'),
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
          title: const Text('Truth or Truth'),
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
                    'Start Game',
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
      final winner = _player1Score > _player2Score
          ? _player1Name
          : _player2Score > _player1Score
              ? _player2Name
              : 'Tie';

      return Scaffold(
        backgroundColor: const Color(0xFFF9F9FF),
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: const Text('Truth or Truth'),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24.adaptSize),
            child: Column(
              children: [
                SizedBox(height: 20.h),
                Icon(
                  Icons.emoji_events,
                  size: 80.adaptSize,
                  color: primaryColor,
                ),
                SizedBox(height: 24.h),
                Text(
                  winner == 'Tie' ? 'It\'s a Tie!' : '$winner Wins!',
                  style: TextStyle(
                    fontSize: 28.fSize,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2933),
                  ),
                ),
                SizedBox(height: 32.h),
                Container(
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
                    children: [
                      Text(
                        'Final Scores',
                        style: TextStyle(
                          fontSize: 20.fSize,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F2933),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                _player1Name,
                                style: TextStyle(
                                  fontSize: 16.fSize,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                '$_player1Score',
                                style: TextStyle(
                                  fontSize: 32.fSize,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'VS',
                            style: TextStyle(
                              fontSize: 20.fSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                _player2Name,
                                style: TextStyle(
                                  fontSize: 16.fSize,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                '$_player2Score',
                                style: TextStyle(
                                  fontSize: 32.fSize,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
    final currentPlayer = _isPlayer1Turn ? _player1Name : _player2Name;
    final currentController = _isPlayer1Turn ? _player1Controller : _player2Controller;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Truth or Truth'),
        elevation: 0,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Center(
              child: Text(
                '$_player1Score - $_player2Score',
                style: TextStyle(
                  fontSize: 18.fSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
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

          // Question and answer area
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.adaptSize),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(32.adaptSize),
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
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 60.adaptSize,
                          color: primaryColor,
                        ),
                        SizedBox(height: 24.h),
                        Text(
                          currentQuestion['question'] ?? '',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22.fSize,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F2933),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  TextField(
                    controller: currentController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Your Answer',
                      hintText: 'Type your answer here...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.adaptSize),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Action buttons
          Container(
            padding: EdgeInsets.all(24.adaptSize),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _skipQuestion,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      side: BorderSide(color: Colors.grey.shade400),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.adaptSize),
                      ),
                    ),
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 16.fSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _submitAnswer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
