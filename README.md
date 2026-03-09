# Rehabilitation Mobile App

A comprehensive rehabilitation mobile application with Flutter frontend and Node.js backend.

## Project Structure

```
.
├── flutter_app/          # Flutter mobile application (main project)
│   ├── lib/
│   │   ├── main.dart
│   │   ├── controllers/
│   │   ├── core/
│   │   ├── features/
│   │   ├── services/
│   │   └── ui/          # All UI screens
│   ├── android/
│   ├── assets/
│   ├── web/
│   └── pubspec.yaml
│
├── backend/              # Node.js Express backend
│   ├── server.js
│   ├── controllers/
│   ├── routes/
│   ├── middleware/
│   └── data/
│
└── postman/              # API testing configurations

```

## Getting Started

### Flutter App

1. Navigate to the Flutter app directory:
   ```bash
   cd flutter_app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Backend

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Start the server:
   ```bash
   node server.js
   ```

## Important Notes

- **All Flutter code is in the `flutter_app/` directory**
- The root `build/` folder (if present) can be safely deleted - it's a build artifact
- Run Flutter commands from within the `flutter_app/` directory
