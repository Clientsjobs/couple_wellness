# Implementation Guide - Language & Profile Picture Features

## Features Implemented

### 1. Multi-Language Support (Backend Connected)
- **Home Screen**: Language selector chips (EN, AR, FR) in top-right corner
- **Settings Screen**: Language option with popup dialog
- Both locations save selected language to Firebase Firestore
- Language preference syncs across app in real-time

### 2. Profile Picture Upload
- **Account Screen**: Camera icon on profile avatar
- User can choose from:
  - Camera (take new photo)
  - Gallery (select existing photo)
  - Remove picture (if already set)
- Images uploaded to Firebase Storage
- URLs saved to Firestore user document

## Packages Added
```yaml
image_picker: ^1.0.7
firebase_storage: ^13.0.6
```

## Permissions Configured

### Android (AndroidManifest.xml)
- INTERNET
- CAMERA
- READ_EXTERNAL_STORAGE
- WRITE_EXTERNAL_STORAGE
- READ_MEDIA_IMAGES

### iOS (Info.plist)
- NSCameraUsageDescription
- NSPhotoLibraryUsageDescription
- NSPhotoLibraryAddUsageDescription

## Firebase Setup Required

### 1. Firebase Storage Rules
Deploy the rules from `storage.rules` file:
```bash
firebase deploy --only storage
```

Or manually add in Firebase Console > Storage > Rules:
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profile_pictures/{userId}.jpg {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
      allow delete: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 2. Firestore Document Structure
User document fields:
```json
{
  "displayName": "string",
  "email": "string",
  "preferredLanguage": "en|ar|fr",
  "profilePictureUrl": "string (optional)",
  "subscriptionStatus": "free|trial|premium",
  "updatedAt": "timestamp"
}
```

## Backend Services Updated

### UserService (lib/services/user_service.dart)
New methods added:
- `uploadProfilePicture(File imageFile)` - Upload image to Storage
- `getProfilePictureUrl()` - Get current profile picture URL
- `deleteProfilePicture()` - Remove profile picture
- `updateLanguage(String languageCode)` - Update language preference

## UI Updates

### Account Screen (lib/screens/settings/account_screen.dart)
- Profile avatar with camera icon overlay
- Image picker dialog (Camera/Gallery/Remove)
- Real-time profile picture display
- Upload progress feedback

### Settings Screen (lib/screens/settings/settings_screen.dart)
- Language option with popup dialog
- Three language choices: English, Arabic, French
- Selected language highlighted
- Saves to Firebase on selection

### Home Screen (lib/screens/home/home_screen.dart)
- Language chips already connected to backend
- Real-time language sync via StreamBuilder

## Testing Checklist

- [ ] Run `flutter pub get`
- [ ] Deploy Firebase Storage rules
- [ ] Test camera permission on device
- [ ] Test gallery permission on device
- [ ] Upload profile picture from camera
- [ ] Upload profile picture from gallery
- [ ] Remove profile picture
- [ ] Change language from Home screen
- [ ] Change language from Settings screen
- [ ] Verify language persists after app restart
- [ ] Verify profile picture persists after app restart

## Next Steps

1. Install packages: `flutter pub get`
2. Deploy Firebase Storage rules
3. Test on physical device (camera/gallery need real device)
4. Add localization strings for multi-language UI text (optional)
