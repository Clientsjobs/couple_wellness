import 'package:flutter/material.dart';
import 'package:couple_wellness/services/auth_service.dart';
import 'package:couple_wellness/services/game_service.dart';
import 'package:couple_wellness/utils/responsive_sizer.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  final GameService _gameService = GameService();
  final AuthService _authService = AuthService();

  List<Map<String, dynamic>> _games = [];
  Map<String, dynamic>? _userProgress;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Load games from Firestore
      final games = await _gameService.getAllGames();
      final progress = await _gameService.getUserGameProgress();

      setState(() {
        _games = games;
        _userProgress = progress;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load games: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _startGame(String gameId) async {
    try {
      // Check if user can play
      final canPlay = await _gameService.canPlayGame(gameId);

      if (!canPlay) {
        _showPremiumDialog();
        return;
      }

      // Record game start
      await _gameService.startGameSessionById(gameId);

      // Navigate to specific game screen based on gameId
      Widget gameScreen;
      switch (gameId) {
        case 'truth_or_truth':
          gameScreen = const TruthOrTruthGameScreen();
          break;
        case 'love_language_quiz':
          gameScreen = const LoveLanguageQuizScreen();
          break;
        default:
          gameScreen = const PlaceholderGameScreen();
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => gameScreen),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting game: $e')),
        );
      }
    }
  }

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium Feature'),
        content: const Text(
            'This game requires a premium subscription. Upgrade to access all games!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to subscription/premium screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B42FF),
            ),
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  String _getGameStatus(String gameId) {
    if (_userProgress == null) return 'Not Started';

    final playedGames = _userProgress!['playedGames'] as List<dynamic>? ?? [];
    final isPlayed = playedGames.any((g) => g['gameId'] == gameId);

    if (isPlayed) {
      final gameData = playedGames.firstWhere((g) => g['gameId'] == gameId);
      final completedAt = gameData['completedAt'];
      if (completedAt != null) {
        return 'Completed';
      }
      return 'In Progress';
    }

    return 'Not Started';
  }

  int _getTimesPlayed(String gameId) {
    if (_userProgress == null) return 0;

    final sessions = _userProgress!['sessions'] as List<dynamic>? ?? [];
    return sessions.where((s) => s['gameId'] == gameId).length;
  }

  @override
  Widget build(BuildContext context) {
    // Specific local colors for this screen's UI elements
    const Color headerPink = Color(0xFFE91E63);
    const Color cardPinkHeader = Color(0xFFFF4D8D);
    const Color cardPurpleHeader = Color(0xFFB388FF);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 240.h,
            decoration: const BoxDecoration(
              color: headerPink,
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
                Text(
                  "Couples Games",
                  style: TextStyle(
                    fontSize: 32.fSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "Play together, grow together",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16.fSize,
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Game Cards
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_errorMessage!),
                            ElevatedButton(
                              onPressed: _loadGames,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadGames,
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                              horizontal: 24.w, vertical: 24.h),
                          children: [
                            // Static games with Firebase integration
                            _buildGameCard(
                              gameId: 'truth_or_truth',
                              title: "Truth or Truth",
                              description:
                                  "Deep questions to spark meaningful conversations",
                              players: "2 players",
                              time: "15 min",
                              headerColor: cardPinkHeader,
                              icon: Icons.favorite_border,
                            ),
                            SizedBox(height: 24.h),
                            _buildGameCard(
                              gameId: 'love_language_quiz',
                              title: "Love Language Quiz",
                              description:
                                  "Discover how you both give and receive love",
                              players: "2 players",
                              time: "10 min",
                              headerColor: cardPurpleHeader,
                              icon: Icons.people,
                            ),
                            SizedBox(height: 40.h),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard({
    required String gameId,
    required String title,
    required String description,
    required String players,
    required String time,
    required Color headerColor,
    required IconData icon,
  }) {
    final status = _getGameStatus(gameId);
    final timesPlayed = _getTimesPlayed(gameId);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.adaptSize),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header Image Area
          Container(
            height: 150.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(25.adaptSize),
              ),
            ),
            child: Center(
              child: Icon(icon, color: Colors.white, size: 70.adaptSize),
            ),
          ),

          // Card Details
          Padding(
            padding: EdgeInsets.all(20.adaptSize),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 20.fSize,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F2933),
                        ),
                      ),
                    ),
                    // Status badge
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: status == 'Completed'
                            ? Colors.green.withOpacity(0.1)
                            : status == 'In Progress'
                                ? Colors.orange.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 12.fSize,
                          color: status == 'Completed'
                              ? Colors.green
                              : status == 'In Progress'
                                  ? Colors.orange
                                  : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14.fSize,
                    height: 1.4,
                  ),
                ),
                if (timesPlayed > 0) ...[
                  SizedBox(height: 8.h),
                  Text(
                    'Played $timesPlayed ${timesPlayed == 1 ? 'time' : 'times'}',
                    style: TextStyle(
                      color: headerColor,
                      fontSize: 12.fSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                SizedBox(height: 20.h),

                // Bottom Info Row
                Row(
                  children: [
                    // Players Info
                    _buildIconLabel(Icons.people_outline, players),
                    SizedBox(width: 16.w),
                    // Time Info
                    _buildIconLabel(Icons.timer_outlined, time),

                    const Spacer(),

                    // Play Button
                    SizedBox(
                      height: 44.h,
                      child: ElevatedButton.icon(
                        onPressed: () => _startGame(gameId),
                        icon: Icon(Icons.play_arrow, size: 18.adaptSize),
                        label: Text(
                          status == 'Not Started' ? "Play Now" : "Play Again",
                          style: TextStyle(
                            fontSize: 14.fSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B42FF),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.adaptSize),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconLabel(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18.adaptSize, color: Colors.grey.shade500),
        SizedBox(width: 6.w),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13.fSize),
        ),
      ],
    );
  }
}

// Placeholder screens for individual games
class TruthOrTruthGameScreen extends StatelessWidget {
  const TruthOrTruthGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Truth or Truth'),
        backgroundColor: const Color(0xFFFF4D8D),
      ),
      body: const Center(
        child: Text('Truth or Truth Game Content'),
      ),
    );
  }
}

class LoveLanguageQuizScreen extends StatelessWidget {
  const LoveLanguageQuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Love Language Quiz'),
        backgroundColor: const Color(0xFFB388FF),
      ),
      body: const Center(
        child: Text('Love Language Quiz Content'),
      ),
    );
  }
}

class PlaceholderGameScreen extends StatelessWidget {
  const PlaceholderGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game'),
        backgroundColor: const Color(0xFF8B42FF),
      ),
      body: const Center(
        child: Text('Game Content Coming Soon'),
      ),
    );
  }
}
