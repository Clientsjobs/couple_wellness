# Games Backend Implementation Guide

## Overview
Games feature is now fully implemented with Firebase backend integration. Users can play games, track progress, and save results to Firestore.

## Implemented Games

### 1. Truth or Truth
- **Game ID**: `truth_or_truth`
- **Type**: Question-based conversation game
- **Features**:
  - 8 default questions about relationships
  - Progress tracking
  - Session recording
  - Completion status

### 2. Love Language Quiz
- **Game ID**: `love_language_quiz`
- **Type**: Quiz with scoring
- **Features**:
  - 5 questions with multiple choice
  - Calculates primary love language
  - Shows score breakdown
  - Saves results to user profile

## Firebase Collections Structure

### Collection: `game_questions`
Stores questions for each game type.

**Document Structure:**
```json
{
  "gameType": "truth_or_truth" | "love_language_quiz",
  "order": 1,
  "question": "Question text here",
  "category": "memories" | "appreciation" | "future" | etc,
  "options": [  // Only for quiz games
    {
      "text": "Option text",
      "language": "words_of_affirmation" | "quality_time" | etc
    }
  ]
}
```

**Example - Truth or Truth Question:**
```json
{
  "gameType": "truth_or_truth",
  "order": 1,
  "question": "What is your favorite memory of us together?",
  "category": "memories"
}
```

**Example - Love Language Quiz Question:**
```json
{
  "gameType": "love_language_quiz",
  "order": 1,
  "question": "What makes you feel most loved?",
  "options": [
    {
      "text": "Hearing 'I love you' and compliments",
      "language": "words_of_affirmation"
    },
    {
      "text": "Spending quality time together",
      "language": "quality_time"
    },
    {
      "text": "Receiving thoughtful gifts",
      "language": "receiving_gifts"
    },
    {
      "text": "Having someone help with tasks",
      "language": "acts_of_service"
    },
    {
      "text": "Hugs, kisses, and physical closeness",
      "language": "physical_touch"
    }
  ]
}
```

### Collection: `user_games`
Stores individual game sessions.

**Document Structure:**
```json
{
  "userId": "user_uid",
  "gameId": "truth_or_truth",
  "gameType": "truth_or_truth",
  "status": "active" | "completed",
  "currentQuestionIndex": 0,
  "score": 0,
  "startedAt": "timestamp",
  "completedAt": "timestamp",
  "updatedAt": "timestamp",
  "responses": []
}
```

### Collection: `user_game_progress`
Stores overall user progress across all games.

**Document ID**: `{userId}`

**Document Structure:**
```json
{
  "userId": "user_uid",
  "playedGames": [
    {
      "gameId": "truth_or_truth",
      "startedAt": "timestamp",
      "completedAt": "timestamp"
    }
  ],
  "sessions": [
    {
      "gameId": "truth_or_truth",
      "startedAt": "timestamp"
    }
  ],
  "totalScore": 0,
  "favoriteGames": [],
  "loveLanguageResult": {  // Only for Love Language Quiz
    "primaryLanguage": "quality_time",
    "scores": {
      "words_of_affirmation": 1,
      "quality_time": 3,
      "receiving_gifts": 0,
      "acts_of_service": 1,
      "physical_touch": 0
    },
    "completedAt": "timestamp"
  },
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

## Firestore Security Rules

Add these rules to your `firestore.rules`:

```javascript
// Game questions - read only
match /game_questions/{questionId} {
  allow read: if request.auth != null;
  allow write: if false; // Only admins via console
}

// User game sessions
match /user_games/{sessionId} {
  allow read: if request.auth != null &&
              resource.data.userId == request.auth.uid;
  allow create: if request.auth != null &&
                request.resource.data.userId == request.auth.uid;
  allow update: if request.auth != null &&
                resource.data.userId == request.auth.uid;
  allow delete: if request.auth != null &&
                resource.data.userId == request.auth.uid;
}

// User game progress
match /user_game_progress/{userId} {
  allow read: if request.auth != null && userId == request.auth.uid;
  allow write: if request.auth != null && userId == request.auth.uid;
}
```

## How to Add Questions to Firebase

### Option 1: Firebase Console (Manual)
1. Go to Firebase Console > Firestore Database
2. Create collection `game_questions`
3. Add documents with the structure shown above
4. Make sure to set the `order` field for proper sequencing

### Option 2: Using Firebase CLI (Bulk Import)
Create a JSON file with questions and import using Firebase CLI.

### Option 3: Default Questions
If no questions exist in Firestore, the app uses default hardcoded questions automatically.

## Game Flow

### Truth or Truth:
1. User clicks "Play Now" on game card
2. `GameService.canPlayGame()` checks subscription status
3. `GameService.startGameSessionById()` creates session in Firestore
4. Questions loaded from Firestore (or defaults)
5. User navigates through questions
6. On completion, session marked as "completed"
7. Progress updated in `user_game_progress`

### Love Language Quiz:
1. Same initial flow as Truth or Truth
2. User selects one option per question
3. Scores calculated for each love language
4. Results saved to `user_game_progress.loveLanguageResult`
5. User sees primary love language and score breakdown

## Premium Access Control

Free users can play:
- Truth or Truth (free game)

Premium/Trial users can play:
- All games including Love Language Quiz

This is controlled in `GameService.canPlayGame()` method.

## Files Created/Modified

### New Files:
- `lib/screens/game/truth_or_truth_game.dart` - Truth or Truth game screen
- `lib/screens/game/love_language_quiz.dart` - Love Language Quiz screen

### Modified Files:
- `lib/screens/game/gamescreen.dart` - Updated imports and navigation
- `lib/services/game_service.dart` - Already had all necessary methods

## Testing Checklist

- [ ] Create `game_questions` collection in Firestore
- [ ] Add sample questions for both games
- [ ] Test game launch from games screen
- [ ] Test premium access control
- [ ] Test game completion and progress tracking
- [ ] Test Love Language Quiz scoring
- [ ] Verify data saved to Firestore
- [ ] Test with free user (should only access Truth or Truth)
- [ ] Test with premium user (should access all games)

## Next Steps

1. Add more games by creating new game screens
2. Add game IDs to the games list in `gamescreen.dart`
3. Create corresponding questions in Firestore
4. Update `canPlayGame()` to control access

## Notes

- Games work offline with default questions
- Questions are cached after first load
- Progress syncs in real-time with Firestore
- All game sessions are tracked for analytics
