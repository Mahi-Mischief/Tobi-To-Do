# ✨ Tobi To-Do Frontend (Flutter)

**Tobi is your AI-powered personal assistant and life planner.**

He's not just a to-do app. He's your companion for productivity, growth, and becoming the person you want to be.

> "Tobi To-Do is an AI-powered personal assistant and life planner that helps you organize tasks, track goals, and build habits while keeping your future self in mind. With smart scheduling, AI task breakdowns, habit tracking, gamification, and a Dream Me visualization feature, Tobi not only reminds you what to do, but motivates and guides you to become the person you want to be."

---

## 🎨 The Vision

Tobi isn't a typical productivity app—it's an **AI life operating system** for ambitious students and professionals.

### 5 Core Pillars (Everything Falls Into One)
1. **PLAN** — Structure & Organization
2. **EXECUTE** — Deep Work & Focus
3. **IMPROVE** — Analytics & Self-Evolution
4. **BECOME** — Identity & Dream Self
5. **ASSIST** — AI Companion Throughout

Every feature must clearly belong to one of these pillars. If it doesn't, it doesn't belong in Tobi.

---

## 🎨 Color Palette

### Primary Pastels (Backgrounds & Soft UI)
- **Soft Sky Blue**: `#A3D4FF`
- **Lavender**: `#C9B4E0`
- **Peach**: `#FFD5C2`
- **Mint Green**: `#BFF0D3`
- **Soft Yellow**: `#FFF3B0`

### Secondary Accents (Highlights & Selections)
- **Coral Pink**: `#FF9AA2`
- **Baby Blue**: `#9CCAFF`
- **Light Lilac**: `#D4C1EC`
- **Apricot**: `#FFCF9C`
- **Seafoam Green**: `#7FD8BE`

### Dark Colors (Text & Contrast)
- **Charcoal**: `#2E2E2E` — Main text & headers
- **Dark Slate Blue**: `#3C3B6E` — Strong buttons & selected states
- **Deep Teal**: `#2A6F6F` — Secondary buttons
- **Dark Coral**: `#C94C4C` — Errors & critical alerts
- **Midnight Blue**: `#1B1F3B` — Top nav & footers

### Neutrals (Subtle UI Elements)
- **White Smoke**: `#F5F5F5` — Background
- **Light Gray**: `#E0E0E0` — Borders & dividers
- **Medium Gray**: `#A0A0A0` — Secondary text
- **Dark Gray**: `#5A5A5A` — Tertiary text

---

## 📱 App Architecture & Layout

### Bottom Navigation (5 Tabs — The Heart of Tobi)

```
┌─────────────────────────────────┐
│Dashboard│Plan│Focus│Growth│Profile│
└─────────────────────────────────┘
      (Tobi floating always)
```

---

## 🏠 **1. DASHBOARD** (Control Center)

**Purpose**: Your life snapshot in 30 seconds.

**Contains:**
- ✨ Tobi greeting (context-aware, changes throughout day)
- 📊 AI Daily Briefing button
- 📋 Today overview (tasks, meetings, habits due today)
- 🎯 Quick stats row:
  - Productivity % (tasks completed today)
  - Discipline score (streaks intact, habits done)
  - Life balance score (academic, health, social distribution)
- 🔥 Streak preview (top 3 active streaks)
- ⭐ XP bar & level display
- ➕ Quick Add button (floating)

**Philosophy**: Motivation + visibility. Not heavy analytics, not deep editing.

---

## 📅 **2. PLAN** (Structure & Organization Engine)

**Purpose**: Where ALL planning tools live.

**Sections:**

### Calendar 🗓️
- Master calendar (month/week/timeline view)
- All tasks, meetings, habits in one place
- Recurring task visualization
- Smart conflict detection (⚠️ Overbooked warning)
- "Procrastinate" button (intelligently reschedule)
- Drag & drop rescheduling

### Tasks ✅
- **Multiple views:**
  - List view (default)
  - Kanban board (todo/in-progress/done)
  - Eisenhower matrix (urgent/important grid)
- **Features:**
  - Priority levels (high/medium/low)
  - Subtasks & dependencies
  - Attach files & embed docs/slides
  - Smart sorting & filtering
  - Task completion velocity tracking
  - Missed-task pattern breakdown

### Projects 📦
- Project folders (group related tasks)
- Milestones within projects
- Time invested tracking
- Tasks linked to projects

---

## 🎯 **3. FOCUS** (Execution Engine)

**Purpose**: Deep work only. No distractions.

**Contains:**
- ⏲️ **Pomodoro Timer** (25-minute default)
- 🔥 **Deep Focus Mode** (burnout tracking)
- ⚡ **AI Time Estimation**
- 📊 **Session Analytics**

**When session ends:**
- → Logs to analytics
- → Updates XP (+10 per session)
- → Suggests reflection

---

## 📈 **4. GROWTH** (Improvement + Identity)

**Purpose**: Where you evolve.

**4 Major Sections:**

### A. Goals & Habits 🎯
- Short-term & long-term goals
- AI-generated step breakdown
- Habit tracking (daily/weekly/monthly)
- Streak tracking
- Goal probability %
- Goal conflict detection

### B. Dream Me 💭 (Future Self)
- Identity statements ("I am someone who...")
- Vision board (image upload)
- Alignment score
- AI gap analysis (current vs 1-year/5-year)
- Monthly reflections

### C. Analytics & Reports 📊
- Task completion rate
- Habit consistency radar
- Goal success trends
- Focus time graphs
- Productivity heatmap
- Missed-task analytics
- Export PDF/CSV

### D. Personal Development 📖
- Notes (linked to tasks/goals)
- Gratitude journaling
- Mood tracking
- Resume/activities log
- College application tracker
- Workout planning
- Reading tracker
- Networking tracker

---

## 👤 **5. PROFILE** (Infrastructure)

**Purpose**: Account & system controls.

**Contains:**
- 🎮 Avatar customization
- 🏆 Achievements & skill tree
- 🌙 Dark mode toggle
- 🔌 Integrations (Google/Apple)
- 📤 Data export
- 🔐 Account management

---

## 🤖 Tobi: The AI Assistant

**Tobi is NOT a tab.** He's a persistent floating assistant.

### Appears In:
- **Dashboard** → Daily briefing
- **Plan** → Smart scheduling
- **Focus** → Burnout alerts
- **Growth** → Gap analysis

### Does:
- 🧠 Task Breakdown
- 📅 Smart Scheduling
- 🚨 Procrastination Detection
- ⏱️ Time Estimation
- 💬 Motivational Messages
- 🔥 Burnout Prediction
- 📊 Pattern Analysis
- 🤔 Weekly Reflections
- 🎓 Semester Planner
- ⚖️ Workload Balancer
- 🔮 Consistency Predictor

---

## 📊 Gamification System

### **XP & Leveling**
- Task completion = XP earned
- Difficult tasks = Higher multipliers
- Levels unlock skill tree
- Visual progress bar

### **Streaks**
- Daily/weekly habit streaks
- Freeze tokens (skip 1 day)
- Leaderboard (optional)

### **Achievements**
- First task completed
- 7-day streak
- 100 XP earned
- All habits done
- Goal achieved

### **Skill Tree**
- Productivity skills
- Avatar upgrades
- Seasonal challenges

---

## 🔄 Intuitive User Flow

### **Morning**
Dashboard → AI briefing → See tasks

### **Afternoon**
Plan → Adjust schedule → Focus session

### **Evening**
Focus → Complete work → XP increases

### **Night**
Growth → Reflection → Dream Me update

### **Weekly**
Growth → Analytics → Adjust goals

**Everything feeds everything.** Nothing feels random.

---

## 🚀 Getting Started

### Prerequisites
- Flutter 3.0+
- Dart 3.0+
- iOS 12+ or Android API 21+

### Installation

```bash
# Get dependencies
cd client
flutter pub get

# Run app
flutter run

# Run on specific device
flutter devices
flutter run -d <device-id>
```

### Configure Firebase (Optional)
1. Create Firebase project at firebase.google.com
2. Add iOS and Android apps
3. Download configuration files:
   - `google-services.json` (Android)
   - `GoogleService-Info.plist` (iOS)
4. Add to project directories

---

## 📱 Project Structure

```
client/lib/
├── main.dart                    # App entry + navigation
├── core/
│   ├── constants/
│   │   └── app_colors.dart     # Colors, typography, spacing
│   └── theme/
│       └── app_theme.dart      # Light & dark themes
├── features/
│   ├── dashboard/screens/
│   ├── plan/screens/
│   ├── focus/screens/
│   ├── growth/screens/
│   └── profile/screens/
├── models/
│   ├── user_model.dart
│   ├── task_model.dart
│   ├── goal_model.dart
│   └── habit_model.dart
├── providers/
│   ├── auth_provider.dart
│   ├── task_provider.dart
│   ├── focus_provider.dart
│   └── goal_provider.dart
├── services/
│   ├── api_client.dart
│   ├── firebase_auth_service.dart
│   └── secure_storage_service.dart
└── shared/
    └── tobi_assistant_widget.dart
```

---

## 🔌 State Management (Riverpod)

### Auth Provider
```dart
// Register
await ref.read(authProvider.notifier).register(
  email: 'user@example.com',
  password: 'secure123',
);

// Login
await ref.read(authProvider.notifier).login(
  email: 'user@example.com',
  password: 'secure123',
);

// Logout
await ref.read(authProvider.notifier).logout();

// Watch auth state
final user = ref.watch(userTokenProvider);
final isAuthenticated = ref.watch(isAuthenticatedProvider);
```

### Task Provider
```dart
// Fetch tasks
await ref.read(taskProvider.notifier).fetchTasks();

// Create task
await ref.read(taskProvider.notifier).createTask(Task(...));

// Update/Delete
await ref.read(taskProvider.notifier).updateTask(Task(...));
await ref.read(taskProvider.notifier).deleteTask(taskId);

// Watch derived states
final completed = ref.watch(completedTasksCountProvider);
final pending = ref.watch(pendingTasksCountProvider);
final highPriority = ref.watch(highPriorityTasksProvider);
```

### Focus Provider
```dart
// Start session
await ref.read(focusProvider.notifier).startSession();

// Pause/Resume
await ref.read(focusProvider.notifier).pauseSession();
await ref.read(focusProvider.notifier).resumeSession();

// End session
await ref.read(focusProvider.notifier).endSession();

// Watch time
final timeRemaining = ref.watch(timeRemainingProvider);
final inFocus = ref.watch(isInFocusSessionProvider);
```

### Goal Provider
```dart
// Add/Update/Remove goals
await ref.read(goalProvider.notifier).addGoal(Goal(...));
await ref.read(goalProvider.notifier).updateGoal(Goal(...));
await ref.read(goalProvider.notifier).removeGoal(goalId);

// Watch derived states
final activeGoals = ref.watch(activeGoalsProvider);
final dreamGoals = ref.watch(dreamGoalsProvider);
```

---

## 🔐 Authentication Flow

1. **User enters credentials**
2. **Flutter sends to backend** (`POST /api/auth/register` or `/login`)
3. **Backend verifies** (password hash or Firebase OAuth)
4. **Backend returns JWT token**
5. **Flutter stores token** in secure storage
6. **All future requests** include `Authorization: Bearer <token>`
7. **Backend middleware** verifies token

---

## 📡 API Endpoints

### Auth
- `POST /api/auth/register` — Create account
- `POST /api/auth/login` — Email/password login
- `POST /api/auth/firebase-login` — OAuth login
- `GET /api/auth/me` — Get current user
- `PATCH /api/auth/profile` — Update profile

### Tasks
- `POST /api/tasks` — Create task
- `GET /api/tasks` — Get all (filters: status, priority)
- `GET /api/tasks/:id` — Get single task
- `PATCH /api/tasks/:id` — Update task
- `DELETE /api/tasks/:id` — Delete task

### Dashboard
- `GET /api/dashboard/stats` — Daily stats

### AI (Placeholder)
- `POST /api/tasks/ai/breakdown` — AI task breakdown
- `GET /api/tasks/ai/schedule` — AI smart scheduling

---

## 🎨 Theme & Design

### Light Theme
- Primary: Lavender (#C9B4E0)
- Secondary: Baby Blue (#9CCAFF)
- Surface: White Smoke (#F5F5F5)
- Text: Charcoal (#2E2E2E)

### Dark Theme
- Primary: Dark Slate Blue (#3C3B6E)
- Secondary: Seafoam Green (#7FD8BE)
- Surface: Midnight Blue (#1B1F3B)
- Text: White Smoke (#F5F5F5)

---

## 🚀 Development Workflow

### Run Development
```bash
flutter run -v
```

### Hot Reload
- Press `r` — Hot reload (keeps state)
- Press `R` — Hot restart (resets app)

### Format Code
```bash
flutter format .
flutter analyze
```

### Run Tests
```bash
flutter test
flutter test -k "Dashboard"
```

---

## 📦 Build & Release

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

---

## 📚 Dependencies

| Package | Purpose |
|---------|---------|
| riverpod | State management |
| flutter_riverpod | Riverpod for Flutter |
| firebase_core | Firebase setup |
| firebase_auth | Authentication |
| dio | HTTP client |
| flutter_secure_storage | Encrypted storage |
| shared_preferences | Local storage |
| go_router | Navigation |
| google_fonts | Typography |
| uuid | ID generation |
| intl | Internationalization |

---

## 📝 Development Checklist

### Phase 1: Core ✅
- [x] Auth (email/password)
- [x] Task creation & CRUD
- [x] Dashboard overview
- [x] Riverpod state
- [x] API client

### Phase 2: Advanced 🔄
- [ ] Firebase OAuth
- [ ] Habit tracking UI
- [ ] Goal management
- [ ] Analytics
- [ ] Offline support

### Phase 3: AI 📅
- [ ] AI service integration
- [ ] Task breakdown
- [ ] Smart scheduling
- [ ] Burnout detection
- [ ] Reflections

### Phase 4: Polish 🚀
- [ ] Full animations
- [ ] Performance optimization
- [ ] Testing
- [ ] Deployment
- [ ] App store

---

## 🎯 Key Metrics

- **Target Users:** High school & college students
- **Primary Use:** Academic productivity
- **Core Value:** AI + gamification + Dream Me
- **Success:** Daily task completion + streaks maintained
- **Retention Goal:** 80%+ MAU

---

## 🔧 Troubleshooting

### Hot reload not working
```bash
flutter clean
flutter pub get
flutter run
```

### Build errors
```bash
cd android && ./gradlew clean && cd ..
flutter clean && flutter pub get && flutter run
```

### iOS issues
```bash
cd ios && rm -rf Pods && rm Podfile.lock && cd ..
flutter clean && flutter pub get && flutter run
```

---

## 💡 Pro Tips

✅ Use `const` constructors for performance
✅ Keep providers focused (one responsibility)
✅ Test after every code change
✅ Profile with DevTools regularly
✅ Commit code often
✅ Document complex logic
✅ Use Postman for API testing
✅ Keep UI modular & reusable

---

## 🌟 Special Thanks

Built with 💜 for ambitious students who want to become their best selves.

**Remember:** Tobi isn't just a to-do app. It's your companion on the journey to becoming who you want to be.

---

**Version:** 1.0.0  
**Last Updated:** February 14, 2026  
**Status:** MVP Ready for Development
