# 🚀 Complete Setup Guide - Tobi To-Do MVP

This guide walks you through setting up the entire Tobi To-Do application locally.

## Prerequisites

### For Backend
- **Node.js** 16+ ([Download](https://nodejs.org/))
- **PostgreSQL** 12+ ([Download](https://www.postgresql.org/download/))
- **npm** (comes with Node.js)

### For Frontend
- **Flutter** 3.0+ ([Download](https://flutter.dev/docs/get-started/install))
- **Dart** 3.0+ (comes with Flutter)
- **Git** ([Download](https://git-scm.com/))

### Optional
- **Firebase Account** (for authentication)
- **VS Code** or **Android Studio** for development
- **Xcode** for iOS development (macOS only)

---

## Part 1: Backend Setup

### Step 1: Navigate to Server Directory
```bash
cd server
```

### Step 2: Install Dependencies
```bash
npm install
```

This installs all required packages listed in `package.json`:
- express
- cors
- dotenv
- firebase-admin
- jsonwebtoken
- bcryptjs
- pg (PostgreSQL client)
- joi (validation)

### Step 3: Create Environment File
```bash
cp .env.example .env
```

Edit `.env` and configure:

```env
# Server
PORT=5000
NODE_ENV=development

# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=tobi_todo
DB_USER=postgres
DB_PASSWORD=your_postgres_password

# JWT
JWT_SECRET=change_this_to_something_secure_at_least_32_chars_long
JWT_EXPIRY=7d

# Firebase (optional - leave if not using Firebase auth)
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_PRIVATE_KEY=your-firebase-private-key
FIREBASE_CLIENT_EMAIL=your-firebase-client-email

# CORS
CORS_ORIGIN=http://localhost:3000,http://localhost:8080
```

### Step 4: Set Up PostgreSQL Database

#### On macOS (using Homebrew):
```bash
brew install postgresql
brew services start postgresql
createdb tobi_todo
```

#### On Windows:
1. Install PostgreSQL from the official website
2. Open pgAdmin or Command Prompt
3. Run:
```bash
createdb -U postgres tobi_todo
```

#### On Linux:
```bash
sudo apt-get install postgresql postgresql-contrib
sudo -u postgres createdb tobi_todo
```

### Step 5: Start the Backend Server

```bash
# Development mode (with hot reload)
npm run dev

# Production mode
npm start
```

You should see:
```
✓ Database initialized
✓ Server running on http://localhost:5000
✓ API Health: http://localhost:5000/api/health
```

### Step 6: Test the Backend

```bash
# Health check
curl http://localhost:5000/api/health

# Should return:
# {"status":"OK","message":"Server is running"}
```

---

## Part 2: Frontend Setup

### Step 1: Navigate to Client Directory
```bash
cd client
```

### Step 2: Install Flutter Dependencies
```bash
flutter pub get
```

### Step 3: (Optional) Configure Firebase

If you want to use Firebase authentication:

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add Android and iOS apps
3. Download configuration files:
   - `google-services.json` for Android → `android/app/`
   - `GoogleService-Info.plist` for iOS → `ios/Runner/`

4. Update `lib/main.dart`:
```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}
```

### Step 4: Run the App

#### On Android Emulator:
```bash
flutter run -d emulator-5554
```

#### On iOS Simulator (macOS only):
```bash
flutter run -d iPhone-13-Pro
```

#### On Physical Device:
```bash
flutter devices  # List connected devices
flutter run -d <device_id>
```

#### Without specifying device:
```bash
flutter run
```

### Step 5: Test the App

Once the app loads:
1. Navigate through all 5 screens using bottom navigation
2. Try creating a task (tap the + button on Plan screen)
3. Check Dashboard for stats

---

## Part 3: Connect Frontend to Backend

### Update API Base URL

In `client/lib/services/api_client.dart`:

```dart
static const String baseUrl = 'http://localhost:5000/api';

// For Android Emulator, use:
// static const String baseUrl = 'http://10.0.2.2:5000/api';

// For iOS Simulator, use:
// static const String baseUrl = 'http://localhost:5000/api';
```

### Update API Client with Token

In `client/lib/services/api_client.dart`, add this to the interceptor:

```dart
onRequest: (options, handler) async {
  final token = await secureStorage.getToken();
  if (token != null) {
    options.headers['Authorization'] = 'Bearer $token';
  }
  return handler.next(options);
},
```

---

## Part 4: Testing the Full Flow

### 1. Register a New User

**Backend:**
```bash
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "fullName": "Test User"
  }'
```

**Response:**
```json
{
  "success": true,
  "user": {
    "id": "uuid",
    "email": "test@example.com",
    "full_name": "Test User",
    "created_at": "2024-02-14T10:00:00Z"
  },
  "token": "jwt_token_here"
}
```

### 2. Login

```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

### 3. Create a Task

```bash
curl -X POST http://localhost:5000/api/tasks \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "title": "Complete project",
    "description": "Finish the MVP",
    "priority": "high",
    "category": "work",
    "due_date": "2024-02-28T23:59:59Z"
  }'
```

### 4. Get Tasks

```bash
curl -X GET http://localhost:5000/api/tasks \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## Part 5: Troubleshooting

### Backend Issues

**Port Already in Use:**
```bash
# macOS/Linux: Kill process on port 5000
lsof -i :5000
kill -9 <PID>

# Windows: 
netstat -ano | findstr :5000
taskkill /PID <PID> /F
```

**Database Connection Error:**
```bash
# Check PostgreSQL is running
pg_isready

# Reset database
dropdb tobi_todo
createdb tobi_todo
```

**Node Modules Issues:**
```bash
rm -rf node_modules package-lock.json
npm install
```

### Frontend Issues

**Flutter Not Found:**
```bash
# Check Flutter installation
flutter doctor

# Update Flutter
flutter upgrade
```

**Build Cache Issues:**
```bash
flutter clean
flutter pub get
flutter run
```

**iOS Build Issues (macOS only):**
```bash
cd ios
pod repo update
pod install
cd ..
flutter run
```

**Android Build Issues:**
```bash
cd android
./gradlew clean
cd ..
flutter run
```

---

## Part 6: Development Workflow

### Backend Development

1. **Make changes** to code in `server/src/`
2. Server auto-reloads with `npm run dev`
3. Test with curl or Postman

### Frontend Development

1. **Make changes** to code in `client/lib/`
2. **Hot reload** in terminal: press `r`
3. **Hot restart** in terminal: press `R`
4. View changes instantly

### Debugging

#### Backend Logging
```javascript
// In server code
console.log('Debug message:', variable);
console.error('Error message:', error);
```

#### Frontend Logging
```dart
// In Flutter code
print('Debug message: $variable');
debugPrint('Debug message');
```

---

## Part 7: Next Steps

### 1. Implement Firebase Auth
- Set up Firebase Authentication in Flutter app
- Connect to backend Firebase Admin SDK verification

### 2. Add UI Polish
- Improve screen designs
- Add animations and transitions
- Better error handling and loading states

### 3. Implement AI Features
- Connect to Hugging Face API
- Implement task breakdown
- Implement smart scheduling

### 4. Add Database Features
- Implement goal CRUD
- Implement habit tracking
- Add focus session logging

### 5. Testing
- Write unit tests for backend
- Write widget tests for frontend
- Add integration tests

### 6. Deployment
- Docker setup for backend
- Deploy to cloud (Heroku, AWS, etc.)
- Deploy to app stores (Google Play, App Store)

---

## Part 8: Useful Commands

### Backend
```bash
npm start              # Run production
npm run dev           # Run development
npm test              # Run tests
npm run lint          # Check code style
```

### Frontend
```bash
flutter run           # Run app
flutter run --release # Release build
flutter test          # Run tests
flutter analyze       # Check code
flutter format .      # Format code
flutter clean         # Clean build
flutter pub get       # Get dependencies
```

### Database
```bash
psql -U postgres      # Connect to PostgreSQL
\l                    # List databases
\c tobi_todo         # Connect to database
\dt                  # List tables
SELECT * FROM users; # Query users
```

---

## 📱 Testing on Devices

### Android Physical Device
```bash
flutter devices
flutter run -d <device-id>
```

### iOS Physical Device (macOS only)
```bash
# Requires iOS developer account
flutter run -d <device-id>
```

### Build APK (Android)
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-app.apk
```

### Build IPA (iOS, macOS only)
```bash
flutter build ios --release
```

---

## 🎯 Quick Checklist

- [ ] Node.js and npm installed
- [ ] PostgreSQL installed and running
- [ ] Backend dependencies installed (`npm install`)
- [ ] `.env` file configured
- [ ] Database created (`createdb tobi_todo`)
- [ ] Backend running (`npm run dev`)
- [ ] Backend health check passing
- [ ] Flutter installed (`flutter doctor`)
- [ ] Frontend dependencies installed (`flutter pub get`)
- [ ] API base URL configured
- [ ] Frontend running (`flutter run`)
- [ ] All 5 screens navigating properly
- [ ] Backend test endpoints responding

---

## 📚 Additional Resources

- [Node.js Documentation](https://nodejs.org/docs/)
- [Express.js Guide](https://expressjs.com/)
- [PostgreSQL Docs](https://www.postgresql.org/docs/)
- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Riverpod Documentation](https://riverpod.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)

---

**Ready to start building? 🚀**

Begin with the Backend Setup section and follow each step carefully. If you encounter any issues, check the Troubleshooting section.
