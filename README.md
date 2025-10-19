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
- **Backend**: Node.js/Express API with Prisma ORM
- **Database**: Self-hosted PostgreSQL (Production) / Local PostgreSQL (Development)
- **AI**: Google Gemini API via secure backend proxy
- **State Management**: Provider pattern
- **Notifications**: Flutter Local Notifications

## Setup Instructions

### Prerequisites

1. **Flutter SDK** (3.9.2 or higher)
2. **Node.js** (16 or higher)
3. **DigitalOcean Droplet** (for production deployment)
4. **Google Gemini API Key**

### Database Setup (Self-hosted PostgreSQL)

1. **Set up DigitalOcean Droplet**:
   - Create a Ubuntu 22.04 LTS droplet
   - Install PostgreSQL on the server
   - Configure database user and permissions

2. **Configure Environment Variables**:
   ```bash
   cd backend
   cp env.example .env
   ```
   
   Add your production database credentials to `.env`:
   ```bash
   PROD_DB_HOST=your-server-ip
   PROD_DB_PORT=5432
   PROD_DB_NAME=pregnancy_assistant
   PROD_DB_USER=your_db_user
   PROD_DB_PASSWORD=your_secure_password
   GEMINI_API_KEY=your_gemini_api_key
   NODE_ENV=production
   ```

3. **Deploy Database** (One Command):
   ```bash
   npm run deploy:db
   ```

   This automatically:
   - ✅ Validates environment variables
   - ✅ Sets up database connection
   - ✅ Creates all tables
   - ✅ Tests connection

### Backend Setup

1. Install dependencies:
```bash
npm install
```

2. Run locally (development):
```bash
npm run dev
```

3. Deploy to DigitalOcean:
   - Follow instructions in `DIGITALOCEAN_DEPLOYMENT.md`
   - Use the automated deployment script
   - Configure environment variables on the server

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
   - Edit `lib/config/api_config.dart`
   - Replace `baseUrl` with your deployed backend URL

4. Run the app:
```bash
flutter run
```

## 🚀 Quick Commands

### Database Deployment
```bash
cd backend
npm run deploy:db    # Full database deployment
npm run test:db      # Test database connection
```

### Development
```bash
cd backend
npm run dev          # Start development server
npm run db:studio    # Open Prisma Studio
```

### Production
```bash
cd backend
npm start            # Start production server
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

### PostgreSQL Tables

- `pregnancy_data`: Singleton record with due date and LMP
- `symptoms`: Timestamped symptom entries
- `appointments`: Scheduled doctor visits
- `weight_entries`: Weight tracking entries
- `chat_sessions` & `chat_messages`: AI conversation history
- `user_profiles`: User information and preferences

### Database Security

Since this is a single-user app, the database is configured with:
- Secure user credentials
- Local network access only
- Regular automated backups

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
- **Local Data**: All data is stored locally and synced to PostgreSQL
- **API Key Security**: Google Gemini API key is kept secure on the backend
- **Medical Disclaimer**: AI responses include appropriate medical disclaimers

## Troubleshooting

### Common Issues

1. **Database Connection Issues**:
   - Ensure PostgreSQL is running on the server
   - Check database credentials and connection string
   - Verify network connectivity to the database server

2. **API Connection Issues**:
   - Verify backend is deployed and accessible
   - Check API service URL in the app
   - Ensure Google Gemini API key is valid

3. **Build Issues**:
   - Run `flutter clean` and `flutter pub get`
   - Check Flutter and Dart SDK versions
   - Ensure all dependencies are compatible

## Contributing

This is a personal project, but feel free to fork and customize for your own use.

## License

This project is for personal use. Please respect the terms of service of all third-party services used (Google Gemini AI, etc.).

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review PostgreSQL and Flutter documentation
3. Ensure all setup steps are completed correctly
4. Check the DigitalOcean deployment guide

---

**Important**: This app is designed to support and inform, not replace professional medical care. Always consult with healthcare providers for medical advice.
