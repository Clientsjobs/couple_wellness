# Firebase Games Collection Structure

## Collection: `games`

This collection stores all available games dynamically. Add new games here and they will automatically appear in the app.

### Document Structure:

```json
{
  "name": "Game Name",
  "description": "Game description",
  "icon": "icon_name",
  "color": "#HEX_COLOR",
  "headerColor": "#HEX_COLOR",
  "players": "2 players",
  "time": "15 min",
  "isPremium": true/false,
  "isActive": true/false,
  "order": 1,
  "screenType": "truth_or_truth" | "quiz" | "trivia",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### Sample Documents to Add:

#### Document ID: `truth_or_truth`
```json
{
  "name": "Truth or Truth",
  "description": "Deep questions to spark meaningful conversations",
  "icon": "favorite_border",
  "color": "#FF4D8D",
  "headerColor": "#FF4D8D",
  "players": "2 players",
  "time": "15 min",
  "isPremium": false,
  "isActive": true,
  "order": 1,
  "screenType": "truth_or_truth",
  "createdAt": "2026-02-23T00:00:00Z",
  "updatedAt": "2026-02-23T00:00:00Z"
}
```

#### Document ID: `love_language_quiz`
```json
{
  "name": "Love Language Quiz",
  "description": "Discover how you both give and receive love",
  "icon": "people",
  "color": "#B388FF",
  "headerColor": "#B388FF",
  "players": "2 players",
  "time": "10 min",
  "isPremium": true,
  "isActive": true,
  "order": 2,
  "screenType": "quiz",
  "createdAt": "2026-02-23T00:00:00Z",
  "updatedAt": "2026-02-23T00:00:00Z"
}
```

### Icon Names (Flutter Icons):
- favorite_border
- people
- quiz
- sports_esports
- psychology
- favorite
- chat_bubble_outline
- emoji_emotions

### How to Add New Game:

1. Go to Firebase Console > Firestore
2. Open `games` collection
3. Click "Add Document"
4. Use game ID as document ID (e.g., "couples_trivia")
5. Add all fields as shown above
6. Set `isActive: true` to show in app
7. Game will automatically appear in app!

### Fields Explanation:

- **name**: Display name shown in app
- **description**: Short description (1-2 lines)
- **icon**: Flutter icon name (without Icons. prefix)
- **color**: Main color for game card
- **headerColor**: Color for game header/banner
- **players**: Display text for player count
- **time**: Estimated time to complete
- **isPremium**: true = requires premium, false = free for all
- **isActive**: true = show in app, false = hide
- **order**: Sort order (lower number = appears first)
- **screenType**: Which game screen to load
- **createdAt**: Creation timestamp
- **updatedAt**: Last update timestamp
