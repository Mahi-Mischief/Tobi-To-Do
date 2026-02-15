# ⚡ Quick Reference Guide

## 🚀 Get Started in 5 Minutes

### Terminal 1 - Backend
```bash
cd server
npm install
npm run dev
# Runs on http://localhost:5000
```

### Terminal 2 - Frontend
```bash
cd client
flutter pub get
flutter run
```

## 📡 API Endpoints Cheat Sheet

### Auth
```bash
# Register
POST /api/auth/register
{ "email": "user@example.com", "password": "pass123", "fullName": "John" }

# Login
POST /api/auth/login
{ "email": "user@example.com", "password": "pass123" }

# Get current user (requires Bearer token)
GET /api/auth/me
Header: Authorization: Bearer <token>

# Update profile
PATCH /api/auth/profile
Header: Authorization: Bearer <token>
{ "full_name": "New Name", "bio": "My bio" }
```

### Tasks
```bash
# Create task
POST /api/tasks
Header: Authorization: Bearer <token>
{ "title": "Task", "priority": "high", "due_date": "2024-02-28T23:59:59Z" }

# Get all tasks
GET /api/tasks?priority=high&status=todo
Header: Authorization: Bearer <token>

# Get single task
GET /api/tasks/{id}
Header: Authorization: Bearer <token>

# Update task
PATCH /api/tasks/{id}
Header: Authorization: Bearer <token>
{ "completed": true, "status": "completed" }

# Delete task
DELETE /api/tasks/{id}
Header: Authorization: Bearer <token>

# Get stats
GET /api/tasks/dashboard-stats
Header: Authorization: Bearer <token>
```

## 🔧 Useful Commands

### Backend
```bash
npm install              # Install dependencies
npm run dev             # Development (hot reload)
npm start               # Production
npm test                # Run tests
npm run lint            # Check code style
```

### Frontend
```bash
flutter pub get         # Get dependencies
flutter run             # Run app
flutter run --release  # Release build
flutter test            # Run tests
flutter analyze         # Check code
flutter format .        # Format code
flutter clean           # Clean build
flutter pub upgrade     # Update packages
```

### Database (PostgreSQL)
```bash
psql -U postgres                    # Connect
\l                                  # List databases
\c tobi_todo                       # Connect to database
\dt                                # List tables
SELECT * FROM users;               # Query
CREATE TABLE...                    # Create table
INSERT INTO users VALUES...        # Insert
UPDATE users SET...                # Update
DELETE FROM users...               # Delete
\q                                 # Quit
```

## 🎨 Customization Quick Links

### Colors & Theme
**File:** `client/lib/core/constants/app_colors.dart`
```dart
static const Color primary = Color(0xFFB19CD9);     // Change primary color
static const Color lightBackground = Color(0xFFFAFAFA);
```

### API Base URL
**File:** `client/lib/services/api_client.dart`
```dart
static const String baseUrl = 'http://localhost:5000/api';
```

### Database Config
**File:** `server/.env`
```env
DB_HOST=localhost
DB_NAME=tobi_todo
DB_USER=postgres
```

### Server Port
**File:** `server/.env`
```env
PORT=5000
```

## 📱 Screen Names

- `DashboardScreen` - Home with Tobi greeting
- `PlanScreen` - Task list & calendar
- `FocusScreen` - Pomodoro timer
- `GrowthScreen` - Goals & analytics
- `ProfileScreen` - User profile & settings

## 🔐 JWT Token Flow

1. User logs in → API returns token
2. Token stored securely in `flutter_secure_storage`
3. Token sent with every request in `Authorization: Bearer <token>` header
4. Backend verifies with JWT middleware
5. Token expires after 7 days (configurable)

## 🗄️ Database Tables

```sql
users       -- User profiles & auth
tasks       -- Task management
goals       -- Long-term goals
habits      -- Habit tracking
focus_sessions -- Pomodoro history
```

## 📊 Provider State in Flutter

```dart
// Auth
final authState = ref.watch(authProvider);

// Tasks
final tasks = ref.watch(taskProvider);
final completed = ref.watch(completedTasksCountProvider);
final pending = ref.watch(pendingTasksCountProvider);

// Focus
final session = ref.watch(focusProvider);
final timeLeft = ref.watch(timeRemainingProvider);

// Goals
final goals = ref.watch(goalsProvider);
```

## 🐛 Debugging Commands

### See Flutter Logs
```bash
flutter run -v
```

### See Backend Logs
```bash
# Already visible in npm run dev
```

### Hot Reload
```
In Flutter: press 'r'
```

### Full App Restart
```
In Flutter: press 'R'
```

## 🧪 Quick Test Example

```bash
# 1. Register user
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"pass123","fullName":"Test"}'

# Response will include token

# 2. Use token to create task
curl -X POST http://localhost:5000/api/tasks \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"title":"Learn Flutter","priority":"high"}'

# 3. Get all tasks
curl -X GET http://localhost:5000/api/tasks \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## 🎯 File Organization

```
Easy to find:
- Features: lib/features/[feature_name]/screens/
- State: lib/providers/[feature]_provider.dart
- Models: lib/models/[model]_model.dart
- Backend: src/[service]/[file].js
```

## 📚 Key Concepts

| Concept | Where | Purpose |
|---------|-------|---------|
| Riverpod | Flutter | State management |
| JWT | Backend | Authentication |
| Dio | Flutter | HTTP requests |
| Express | Backend | Web server |
| PostgreSQL | Backend | Database |
| Firebase | Optional | Auth service |

## ⏱️ Common Time Sinks & Solutions

| Problem | Solution |
|---------|----------|
| "Port 5000 in use" | Kill process on port 5000 |
| "Database not found" | `createdb tobi_todo` |
| "Flutter not found" | `flutter doctor` |
| "Hot reload not working" | `flutter clean` then `flutter run` |
| "Token expired" | Login again |
| "Cors error" | Check `CORS_ORIGIN` in `.env` |

## 🚀 Deployment Checklist

- [ ] Update `.env` with production values
- [ ] Set `NODE_ENV=production`
- [ ] Use strong `JWT_SECRET`
- [ ] Configure real database
- [ ] Set up Firebase properly
- [ ] Update API URL in Flutter app
- [ ] Test all flows
- [ ] Build release APK/IPA
- [ ] Deploy backend to cloud
- [ ] Submit to app stores

## 💡 Pro Tips

1. **Use Postman** - Test APIs before frontend
2. **Check logs** - Always check console for errors
3. **Commit often** - Git commit after each feature
4. **Read comments** - Check code comments for TODOs
5. **Test locally first** - Don't deploy untested
6. **Use meaningful names** - Makes code readable
7. **Comment complex logic** - Help future you
8. **Keep dependencies updated** - Security & features

## 📞 Getting Help

1. **Check README files** - Most info is there
2. **Check comments in code** - Marked with TODO
3. **Look at error messages** - They're usually helpful
4. **Check Flutter/Node documentation** - Official docs
5. **Search GitHub issues** - Others probably had same problem

---

**Now you're ready to build! Happy coding!** 🎉

**Next:** Read SETUP.md for detailed installation guide
