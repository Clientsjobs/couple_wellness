import 'package:flutter/material.dart';
import 'package:couple_wellness/services/game_service.dart';
import 'package:couple_wellness/utils/responsive_sizer.dart';
import 'package:couple_wellness/screens/game/truth_or_truth_game.dart';
import 'package:couple_wellness/screens/game/love_language_quiz.dart';
import 'package:couple_wellness/l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  final GameService _gameService = GameService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      if (!mounted) return;

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Load games from Firestore dynamically
      final gamesSnapshot = await _firestore
          .collection('games')
          .where('isActive', isEqualTo: true)
          .orderBy('order')
          .get();

      List<Map<String, dynamic>> loadedGames = [];

      if (gamesSnapshot.docs.isEmpty) {
        // Fallback to default games if Firestore is empty
        loadedGames = _getDefaultGames();
      } else {
        loadedGames = gamesSnapshot.docs.map((doc) {
          return {
            'id': doc.id,
            ...doc.data(),
          };
        }).toList();
      }

      // Load user progress
      final progress = await _gameService.getUserGameProgress();

      if (!mounted) return;

      setState(() {
        _games = loadedGames;
        _userProgress = progress;
        _isLoading = false;
      });
    } catch (e) {
      // If Firestore fails, use default games
      if (!mounted) return;

      setState(() {
        _games = _getDefaultGames();
        _isLoading = false;
      });

      // Still try to load progress
      try {
        final progress = await _gameService.getUserGameProgress();
        if (!mounted) return;

        setState(() {
          _userProgress = progress;
        });
      } catch (e) {
        // Ignore progress error
      }
    }
  }

  List<Map<String, dynamic>> _getDefaultGames() {
    return [
      {
        'id': 'truth_or_truth',
        'name': 'Truth or Truth',
        'description': 'Deep questions to spark meaningful conversations',
        'icon': 'favorite_border',
        'color': '#FF4D8D',
        'headerColor': '#FF4D8D',
        'players': '2 players',
        'time': '15 min',
        'isPremium': false,
        'screenType': 'truth_or_truth',
      },
      {
        'id': 'love_language_quiz',
        'name': 'Love Language Quiz',
        'description': 'Discover how you both give and receive love',
        'icon': 'people',
        'color': '#B388FF',
        'headerColor': '#B388FF',
        'players': '2 players',
        'time': '10 min',
        'isPremium': true,
        'screenType': 'quiz',
      },
    ];
  }

  Future<void> _startGame(String gameId) async {
    try {
      // Check if user can play
      final canPlay = await _gameService.canPlayGame(gameId);

      if (!canPlay) {
        _showPremiumDialog();
        return;
      }

      // Find game data
      final gameData = _games.firstWhere(
        (game) => game['id'] == gameId,
        orElse: () => {},
      );

      if (gameData.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).gameNotFound)),
          );
        }
        return;
      }

      // Navigate to specific game screen based on screenType
      final screenType = gameData['screenType'] ?? gameId;
      Widget gameScreen;

      switch (screenType) {
        case 'truth_or_truth':
          gameScreen = const TruthOrTruthGameScreen();
          break;
        case 'quiz':
          gameScreen = const LoveLanguageQuizScreen();
          break;
        default:
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context).gameComingSoon)),
            );
          }
          return;
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => gameScreen),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${AppLocalizations.of(context).errorStartingGame}: $e')));
      }
    }
  }

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).premiumFeature),
        content: Text(AppLocalizations.of(context).premiumGameMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to subscription/premium screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B42FF),
            ),
            child: Text(AppLocalizations.of(context).upgrade),
          ),
        ],
      ),
    );
  }

  String _getGameStatus(String gameId) {
    if (_userProgress == null) return AppLocalizations.of(context).notStarted;

    final playedGames = _userProgress!['playedGames'] as List<dynamic>? ?? [];
    final isPlayed = playedGames.any((g) => g['gameId'] == gameId);

    if (isPlayed) {
      final gameData = playedGames.firstWhere((g) => g['gameId'] == gameId);
      final completedAt = gameData['completedAt'];
      if (completedAt != null) {
        return AppLocalizations.of(context).completed;
      }
      return AppLocalizations.of(context).inProgress;
    }

    return AppLocalizations.of(context).notStarted;
  }

  int _getTimesPlayed(String gameId) {
    if (_userProgress == null) return 0;

    final sessions = _userProgress!['sessions'] as List<dynamic>? ?? [];
    return sessions.where((s) => s['gameId'] == gameId).length;
  }

  Color _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) {
      return const Color(0xFF8B42FF); // Default purple
    }
    try {
      // Remove # if present
      final hexColor = colorString.replaceAll('#', '');
      return Color(int.parse('FF$hexColor', radix: 16));
    } catch (e) {
      return const Color(0xFF8B42FF); // Default purple
    }
  }

  IconData _parseIcon(String? iconName) {
    if (iconName == null || iconName.isEmpty) {
      return Icons.sports_esports;
    }

    // Map of icon names to IconData
    final iconMap = {
      'favorite_border': Icons.favorite_border,
      'favorite': Icons.favorite,
      'people': Icons.people,
      'quiz': Icons.quiz,
      'sports_esports': Icons.sports_esports,
      'psychology': Icons.psychology,
      'chat_bubble_outline': Icons.chat_bubble_outline,
      'emoji_emotions': Icons.emoji_emotions,
      'casino': Icons.casino,
      'extension': Icons.extension,
      'lightbulb_outline': Icons.lightbulb_outline,
      'celebration': Icons.celebration,
    };

    return iconMap[iconName] ?? Icons.sports_esports;
  }

  @override
  Widget build(BuildContext context) {
    // Specific local colors for this screen's UI elements
    const Color headerPink = Color(0xFFE91E63);

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
                  AppLocalizations.of(context).couplesGames,
                  style: TextStyle(
                    fontSize: 32.fSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  AppLocalizations.of(context).playTogether,
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
                          child: Text(AppLocalizations.of(context).retry),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadGames,
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 24.h,
                      ),
                      children: [
                        // Dynamic games from Firestore
                        ..._games.map((game) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 24.h),
                            child: _buildGameCard(
                              gameId: game['id'],
                              title: game['name'],
                              description: game['description'],
                              players: game['players'],
                              time: game['time'],
                              headerColor: _parseColor(game['headerColor']),
                              icon: _parseIcon(game['icon']),
                            ),
                          );
                        }),
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
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
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
                    '${AppLocalizations.of(context).played} $timesPlayed ${timesPlayed == 1 ? AppLocalizations.of(context).time : AppLocalizations.of(context).times}',
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
                    Flexible(child: _buildIconLabel(Icons.people_outline, players)),
                    SizedBox(width: 16.w),
                    // Time Info
                    Flexible(child: _buildIconLabel(Icons.timer_outlined, time)),

                    const Spacer(),

                    // Play Button
                    SizedBox(
                      height: 44.h,
                      child: ElevatedButton.icon(
                        onPressed: () => _startGame(gameId),
                        icon: Icon(Icons.play_arrow, size: 18.adaptSize),
                        label: Text(
                          status == AppLocalizations.of(context).notStarted ? AppLocalizations.of(context).playNow : AppLocalizations.of(context).playAgain,
                          style: TextStyle(
                            fontSize: Localizations.localeOf(context).languageCode == 'fr' ? 12.fSize : 14.fSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B42FF),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18.adaptSize, color: Colors.grey.shade500),
        SizedBox(width: 6.w),
        Flexible(
          child: Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13.fSize),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
