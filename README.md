# Luma - Pregnancy Assistant App

A comprehensive Flutter-based pregnancy tracking and AI assistant app designed to support expecting mothers throughout their pregnancy journey.

## Features

### 🏠 Home Dashboard
- Week-by-week pregnancy progress tracking
- Visual progress indicators with trimester-specific colors
- Due date countdown
- Quick action buttons for common tasks
- Upcoming appointments overview

### 📊 Tracking Features
- **Symptom Tracker**: Log and monitor pregnancy symptoms with severity levels
- **Weight Tracker**: Track weight progression with visual charts
- **Appointment Manager**: Schedule and manage doctor visits
- **Photo Journal**: Store weekly bump photos

### 🤖 AI Assistant
- Pregnancy-focused chatbot powered by Perplexity AI
- Context-aware responses based on current pregnancy week
- Categories: nutrition, symptoms, exercise, preparation
- Medical disclaimer and safety guidelines

### 📅 Calendar & Reminders
- Visual calendar with appointment scheduling
- Local notifications for appointments and reminders
- Medication/vitamin reminders
- Weekly milestone notifications

### 🎨 Beautiful UI/UX
- Pregnancy-themed color palette (soft pastels)
- Material Design 3 with smooth animations
- Accessibility features
- Responsive design for different screen sizes

## Architecture

- **Frontend**: Flutter (Android-focused, cross-platform ready)
- **Backend**: Node.js/Express API proxy for Perplexity API
- **Database**: Firebase Firestore for data persistence
- **AI**: Perplexity API via secure backend proxy
- **State Management**: Provider pattern
- **Notifications**: Flutter Local Notifications

## Setup Instructions

### Prerequisites

1. **Flutter SDK** (3.9.2 or higher)
2. **Node.js** (16 or higher)
3. **Firebase Account**
4. **Perplexity API Key**

### Backend Setup

1. Navigate to the backend directory:
```bash
cd backend
```

2. Install dependencies:
```bash
npm install
```

3. Create environment file:
```bash
cp .env.example .env
```

4. Add your Perplexity API key to `.env`:
```
PERPLEXITY_API_KEY=your_actual_api_key_here
```

5. Run locally:
```bash
npm run dev
```

6. Deploy to a cloud service (Railway, Render, or Vercel):
   - Follow the deployment instructions in `backend/README.md`
   - Update the `baseUrl` in `luma/lib/services/api_service.dart` with your deployed URL

### Firebase Setup

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)

2. Enable Firestore Database:
   - Go to Firestore Database
   - Create database in production mode
   - Set up security rules (for single-user app, you can use basic rules)

3. Get Firebase configuration:
   - Go to Project Settings > General
   - Add Android app with package name: `com.luma`
   - Download `google-services.json` and place it in `luma/android/app/`

4. Update Firebase configuration:
   - Run `flutterfire configure` in the luma directory
   - Or manually update `luma/lib/firebase_options.dart` with your project details

### Flutter App Setup

1. Navigate to the Flutter app directory:
```bash
cd luma
```

2. Install dependencies:
```bash
flutter pub get
```

3. Update API service URL:
   - Edit `lib/services/api_service.dart`
   - Replace `baseUrl` with your deployed backend URL

4. Run the app:
```bash
flutter run
```

## Building for Production

### Android APK

1. Generate a signed APK:
```bash
flutter build apk --release
```

2. The APK will be located at:
```
luma/build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (for Play Store)

1. Generate an app bundle:
```bash
flutter build appbundle --release
```

2. The bundle will be located at:
```
luma/build/app/outputs/bundle/release/app-release.aab
```

## Data Structure

### Firestore Collections

- `pregnancy_data`: Singleton document with due date and LMP
- `symptoms`: Timestamped symptom entries
- `appointments`: Scheduled doctor visits
- `weight_logs`: Weight tracking entries
- `chat_history`: AI conversation history
- `reminders`: Notification settings

### Security Rules

Since this is a single-user app, you can use basic security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

## Customization

### Colors and Theme
- Edit `lib/theme/app_theme.dart` to customize colors
- The app uses a pregnancy-themed palette with soft pastels

### AI Assistant
- Modify the system prompt in `backend/server.js`
- Add pregnancy-specific context and guidelines

### Features
- Add new tracking features by extending the models in `lib/models/`
- Create new screens in `lib/screens/`
- Add reusable widgets in `lib/widgets/`

## Privacy & Security

- **No Authentication**: App assumes single user per device
- **Local Data**: All data is stored locally and synced to Firebase
- **API Key Security**: Perplexity API key is kept secure on the backend
- **Medical Disclaimer**: AI responses include appropriate medical disclaimers

## Troubleshooting

### Common Issues

1. **Firebase Connection Issues**:
   - Ensure `google-services.json` is in the correct location
   - Check Firebase project configuration
   - Verify Firestore rules allow read/write

2. **API Connection Issues**:
   - Verify backend is deployed and accessible
   - Check API service URL in the app
   - Ensure Perplexity API key is valid

3. **Build Issues**:
   - Run `flutter clean` and `flutter pub get`
   - Check Flutter and Dart SDK versions
   - Ensure all dependencies are compatible

## Contributing

This is a personal project, but feel free to fork and customize for your own use.

## License

This project is for personal use. Please respect the terms of service of all third-party services used (Firebase, Perplexity AI, etc.).

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review Firebase and Flutter documentation
3. Ensure all setup steps are completed correctly

---

**Important**: This app is designed to support and inform, not replace professional medical care. Always consult with healthcare providers for medical advice.
