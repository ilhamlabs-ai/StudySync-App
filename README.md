# StudySync

A Flutter-based collaborative study application with Firebase authentication and real-time features.

## Features

- **Google Sign-In Authentication**: Secure login with Google OAuth
- **Session Management**: Create and join collaborative study sessions
- **Notes**: Personal note-taking with cloud sync
- **Timer**: Pomodoro-style study timer
- **Real-time Chat**: Chat functionality within study sessions
- **Cross-Platform**: Runs on Android, iOS, Web, and Desktop

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Firebase account and project setup
- Google Cloud Console project for OAuth

### Installation

1. Clone the repository
```bash
git clone https://github.com/ilhamlabs-ai/StudySync-App.git
cd StudySync-App
```

2. Install dependencies
```bash
flutter pub get
```

3. Configure Firebase
   - Add your `google-services.json` to `android/app/`
   - Add your `GoogleService-Info.plist` to `ios/Runner/`
   - Update Firebase configuration in `lib/firebase_options.dart`

4. Run the app
```bash
flutter run
```

## Architecture

- **Provider Pattern**: State management using Provider package
- **GoRouter**: Declarative navigation with authentication guards  
- **Firebase**: Backend services (Auth, Firestore, etc.)
- **Material 3**: Modern UI design system

## Security

This project uses comprehensive `.gitignore` configurations to protect:
- Firebase API keys and configuration files
- OAuth client secrets
- Android keystores and signing certificates
- Platform-specific sensitive files

Never commit sensitive authentication files to version control.
