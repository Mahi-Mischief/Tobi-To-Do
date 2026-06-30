# 🚀 Tobi To-Do: Complete Feature Implementation Plan

**Mission:** Develop every single feature from the documentation into a fully functional MVP.

---

## 📋 Implementation Phases

### Phase 1: MVP Core (This Sprint) ✅ PARTIALLY DONE
- [x] Project structure & scaffolding
- [x] Basic authentication (email/password)
- [x] Task CRUD endpoints
- [x] Dashboard screen (basic)
- [x] Plan screen (basic)
- [x] Focus screen (basic)
- [x] Growth screen (basic)
- [x] Profile screen (basic)
- [x] Riverpod state management (basic)
- [ ] **Complete all features for MVP** ← CURRENT WORK

### Phase 2: Enhanced Features (Next)
- Firebase OAuth
- Habit tracking UI
- Goal management
- Calendar view
- Analytics visualization
- Form validation

### Phase 3: AI & Advanced
- Real AI integration
- Smart scheduling
- Burnout detection
- Weekly reflections

### Phase 4: Polish & Deploy
- Animations & transitions
- Performance optimization
- Testing suite
- Cloud deployment

---

## 🏗️ Backend Implementation (Node.js + Express)

### 1. Services Layer (Business Logic)

#### authService.js ✅ DONE
- Register user ✅
- Login user ✅
- Generate JWT ✅
- Hash password ✅
- Firebase login ✅
- Update profile ✅

#### taskService.js ✅ PARTIALLY DONE
- Create task ✅
- Get all tasks ✅
- Get single task ✅
- Update task ✅
- Delete task ✅
- Get dashboard stats ✅
- **TODO:** Filter by status, priority, due date
- **TODO:** Subtasks & dependencies
- **TODO:** Task search & global search
- **TODO:** Batch operations

#### habitService.js ❌ NEW NEEDED
```javascript
- Create habit
- Get user habits
- Update habit
- Delete habit
- Increment streak
- Reset streak
- Get streaks summary
```

#### goalService.js ❌ NEW NEEDED
```javascript
- Create goal
- Get user goals
- Update goal (progress)
- Delete goal
- Get goal probability
- Detect goal conflicts
- Link habit to goal
```

#### focusService.js ❌ NEW NEEDED
```javascript
- Start focus session
- End focus session
- Get session history
- Calculate total focus time
- Get longest streak
- Detect burnout indicators
```

#### analyticsService.js ❌ NEW NEEDED
```javascript
- Calculate completion rate
- Get habit consistency
- Get goal trends
- Generate productivity heatmap
- Calculate life balance score
- Analyze missed tasks
- Generate weekly summary
```

#### gamificationService.js ❌ NEW NEEDED
```javascript
- Award XP
- Calculate level
- Check achievements
- Generate skill tree
- Track streaks
- Get leaderboard
- Freeze streak token
```

#### dreamMeService.js ❌ NEW NEEDED
```javascript
- Create/update Dream Me profile
- Add identity statements
- Upload vision board
- Calculate alignment score
- Generate gap analysis
- Schedule monthly reflection
```

#### aiService.js ✅ PLACEHOLDER DONE
- Task breakdown (mock) ✅
- Smart scheduling (mock) ✅
- Procrastination detection (mock) ✅
- Time estimation (mock) ✅
- **TODO:** Real API integration

---

### 2. Controllers Layer (Request Handlers)

#### authController.js ✅ DONE
- register ✅
- login ✅
- firebaseLogin ✅
- getCurrentUser ✅
- updateProfile ✅

#### taskController.js ✅ PARTIALLY DONE
- createTask ✅
- getTasks ✅
- getTask ✅
- updateTask ✅
- deleteTask ✅
- getDashboardStats ✅
- **TODO:** Search tasks
- **TODO:** Batch update
- **TODO:** Export tasks

#### habitController.js ❌ NEW NEEDED
```javascript
- createHabit
- getHabits
- updateHabit
- deleteHabit
- completeHabit
- getStreakSummary
```

#### goalController.js ❌ NEW NEEDED
```javascript
- createGoal
- getGoals
- updateGoal (progress)
- deleteGoal
- linkHabitToGoal
- getGoalProbability
```

#### focusController.js ❌ NEW NEEDED
```javascript
- startSession
- endSession
- getSessionHistory
- getFocusStats
- getBurnoutIndicators
```

#### analyticsController.js ❌ NEW NEEDED
```javascript
- getProductivityScore
- getHabitConsistency
- getGoalTrends
- getProductivityHeatmap
- getWeeklyReport
- getMonthlyReport
```

#### dreamMeController.js ❌ NEW NEEDED
```javascript
- getDreamMe
- updateDreamMe
- getGapAnalysis
- getAlignmentScore
```

---

### 3. Routes

#### authRoutes.js ✅ DONE
- POST /api/auth/register ✅
- POST /api/auth/login ✅
- POST /api/auth/firebase-login ✅
- GET /api/auth/me ✅
- PATCH /api/auth/profile ✅

#### taskRoutes.js ✅ PARTIALLY DONE
- POST /api/tasks ✅
- GET /api/tasks ✅
- GET /api/tasks/:id ✅
- PATCH /api/tasks/:id ✅
- DELETE /api/tasks/:id ✅
- GET /api/dashboard/stats ✅
- POST /api/tasks/ai/breakdown ✅
- GET /api/tasks/ai/schedule ✅
- **TODO:** GET /api/tasks/search

#### habitRoutes.js ❌ NEW NEEDED
```
- POST /api/habits
- GET /api/habits
- PATCH /api/habits/:id
- DELETE /api/habits/:id
- POST /api/habits/:id/complete
```

#### goalRoutes.js ❌ NEW NEEDED
```
- POST /api/goals
- GET /api/goals
- PATCH /api/goals/:id
- DELETE /api/goals/:id
- POST /api/goals/:id/link-habit/:habitId
```

#### focusRoutes.js ❌ NEW NEEDED
```
- POST /api/focus/start
- POST /api/focus/end
- GET /api/focus/history
- GET /api/focus/stats
```

#### analyticsRoutes.js ❌ NEW NEEDED
```
- GET /api/analytics/productivity
- GET /api/analytics/habits
- GET /api/analytics/goals
- GET /api/analytics/heatmap
- GET /api/analytics/weekly
```

#### dreamMeRoutes.js ❌ NEW NEEDED
```
- GET /api/dream-me
- PATCH /api/dream-me
- GET /api/dream-me/gap-analysis
```

---

### 4. Models & Database

#### Existing Tables ✅
- users ✅
- tasks ✅
- goals ✅
- habits ✅
- focus_sessions ✅

#### New Tables Needed ❌
```sql
-- For Dream Me feature
CREATE TABLE dream_profiles (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL (FK),
  identity_statements TEXT[],
  vision_board_url TEXT,
  alignment_score INTEGER,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

-- For achievements
CREATE TABLE achievements (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL (FK),
  achievement_type VARCHAR(100),
  earned_at TIMESTAMP,
  created_at TIMESTAMP
);

-- For notes/reflections
CREATE TABLE reflections (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL (FK),
  content TEXT,
  type VARCHAR(50), -- weekly, monthly, custom
  created_at TIMESTAMP
);
```

---

## 📱 Frontend Implementation (Flutter + Riverpod)

### 1. Dashboard Screen (PLAN → Phase 1)

**Components Needed:**
- [ ] Tobi greeting widget (time-aware: morning/afternoon/evening)
- [ ] AI daily briefing button
- [ ] Today overview card (tasks due today, habits)
- [ ] Stats row (productivity %, discipline, life balance)
- [ ] Streak preview (top 3 streaks)
- [ ] XP bar + level display
- [ ] Quick add floating button

**Integration:**
- [ ] Connect to dashboardProvider (derive stats)
- [ ] Show real tasks from taskProvider
- [ ] Update xp/level from gamificationProvider
- [ ] Show active streaks from habitProvider

### 2. Plan Screen (PLAN → Phase 1)

**Views:**
- [ ] Calendar view (month/week)
- [ ] Task list view
- [ ] Kanban board (todo/in-progress/done)
- [ ] Eisenhower matrix

**Features:**
- [ ] Create task with priority/due date
- [ ] Drag & drop reschedule
- [ ] Mark complete
- [ ] Filter by status/priority
- [ ] Search tasks
- [ ] Project management
- [ ] Procrastinate button (reschedule)

**Integration:**
- [ ] taskProvider for CRUD
- [ ] API calls for persistence
- [ ] Form validation

### 3. Focus Screen (EXECUTE → Phase 1)

**Components:**
- [ ] Circular timer display (MM:SS)
- [ ] Play/pause/stop buttons
- [ ] Session selector (25/45/90 min)
- [ ] Task selector (what are you working on?)
- [ ] Session history list
- [ ] Longest streak display
- [ ] Burnout indicator

**Logic:**
- [ ] Timer countdown
- [ ] Session persistence
- [ ] XP award on completion
- [ ] Streak tracking
- [ ] Break timer

**Integration:**
- [ ] focusProvider for timer state
- [ ] Post session to backend
- [ ] Update analytics

### 4. Growth Screen (IMPROVE + BECOME → Phase 1)

**Sections:**

#### A. Goals & Habits
- [ ] Goal list with progress bars
- [ ] Create goal form
- [ ] Habit list with streaks
- [ ] Create habit form
- [ ] Link habit to goal
- [ ] Goal probability indicator

#### B. Dream Me
- [ ] Dream profile form
- [ ] Identity statements input
- [ ] Vision board upload (placeholder)
- [ ] Alignment score visualization
- [ ] Gap analysis display

#### C. Analytics
- [ ] Completion rate chart
- [ ] Habit consistency radar
- [ ] Goal trends graph
- [ ] Focus time breakdown
- [ ] Weekly summary
- [ ] Export button

#### D. Personal Development
- [ ] Notes section (linked to tasks/goals)
- [ ] Gratitude journaling
- [ ] Mood tracker
- [ ] Resume/activities log

### 5. Profile Screen (Infrastructure → Phase 1)

**Components:**
- [ ] User avatar + name
- [ ] Level & XP display
- [ ] Achievements grid
- [ ] Skill tree preview
- [ ] Dark mode toggle
- [ ] Notification settings
- [ ] Integrations (Google)
- [ ] Data export
- [ ] Logout button

**Integration:**
- [ ] authProvider for user info
- [ ] gamificationProvider for level/xp/achievements
- [ ] settingsProvider for preferences

---

### 2. State Providers (Riverpod)

#### Existing ✅
- authProvider ✅
- taskProvider ✅
- focusProvider ✅
- goalProvider ✅

#### New Needed ❌

**habitProvider**
```dart
- addHabit(habit)
- updateHabit(habit)
- removeHabit(habitId)
- completeHabit(habitId)
- activeHabitsProvider
- todayHabitsProvider
- streakProvider
```

**gamificationProvider**
```dart
- addXP(amount)
- calculateLevel(xp)
- checkAchievement(type)
- xpProvider
- levelProvider
- achievementsProvider
- skillTreeProvider
```

**dreamMeProvider**
```dart
- setDreamProfile(profile)
- addIdentityStatement(statement)
- calculateAlignmentScore()
- getGapAnalysis()
- dreamMeProvider
- alignmentScoreProvider
```

**analyticsProvider**
```dart
- calculateCompletionRate()
- calculateHabitConsistency()
- getGoalTrends()
- getProductivityHeatmap()
- productivityProvider
- habitsAnalyticsProvider
- goalsAnalyticsProvider
```

**settingsProvider**
```dart
- darkModeProvider
- notificationsProvider
- privacyProvider
- integrationProvider
```

**reflectionProvider**
```dart
- saveReflection(reflection)
- getWeeklyReflection()
- getMonthlyReflection()
- reflectionsProvider
```

---

## 🎮 Gamification System

### XP & Leveling
- [ ] Task completion: 10 XP per task
- [ ] Difficult task: 2x multiplier
- [ ] Habit maintenance: 5 XP per day
- [ ] Focus session: 10 XP per session
- [ ] Goal completion: 50 XP
- [ ] Levels: Every 100 XP = 1 level

### Streaks
- [ ] Daily habit: +1 streak
- [ ] Reset on miss (or use freeze token)
- [ ] Display on Dashboard
- [ ] Freeze token (skip 1 day)

### Achievements
- [ ] First task completed
- [ ] 7-day streak
- [ ] 100 XP earned
- [ ] All habits done in week
- [ ] Goal completed
- [ ] 10 focus sessions

### Skill Tree
- [ ] Node structure
- [ ] Unlock on level up
- [ ] Cosmetic rewards
- [ ] Skill descriptions

---

## 🤖 AI Features (Phase 1 = Placeholder, Phase 3 = Real)

### Task Breakdown
- [ ] Service method created ✅
- [ ] Placeholder responses ✅
- [ ] **TODO (Phase 3):** Real Mistral API integration

### Smart Scheduling
- [ ] Service method created ✅
- [ ] Placeholder responses ✅
- [ ] **TODO (Phase 3):** Energy-aware scheduling logic

### Procrastination Detection
- [ ] Logic-based detection ✅ (placeholder)
- [ ] **TODO (Phase 3):** ML-based pattern recognition

### Time Estimation
- [ ] History-based estimation ✅ (placeholder)
- [ ] **TODO (Phase 3):** Improve with AI

### Weekly Reflection
- [ ] Rule-based summary ✅ (placeholder)
- [ ] **TODO (Phase 3):** AI-generated reflections

---

## ✅ Implementation Checklist

### Backend Priority Order
1. [ ] habitService & habitController & habitRoutes
2. [ ] goalService & goalController & goalRoutes
3. [ ] focusService & focusController & focusRoutes
4. [ ] analyticsService & analyticsController & analyticsRoutes
5. [ ] gamificationService & gamificationController
6. [ ] dreamMeService & dreamMeController & dreamMeRoutes
7. [ ] Enhance taskService (subtasks, dependencies, search)
8. [ ] Create missing database tables
9. [ ] Add validation middleware
10. [ ] Add comprehensive error handling

### Frontend Priority Order
1. [ ] Enhance Dashboard (all components)
2. [ ] Enhance Plan (all views + features)
3. [ ] Enhance Focus (timer + analytics)
4. [ ] Implement Growth (4 sections)
5. [ ] Implement Profile (all components)
6. [ ] Implement habitProvider
7. [ ] Implement gamificationProvider
8. [ ] Implement analyticsProvider
9. [ ] Implement dreamMeProvider
10. [ ] Add all animations & polish

### Testing
1. [ ] Unit tests for services
2. [ ] Widget tests for screens
3. [ ] Integration tests for flows
4. [ ] Manual testing on device
5. [ ] Bug fixes

---

## 📊 Estimated Timeline

**Phase 1 MVP (This Week):**
- Backend: 8-10 hours
- Frontend: 12-15 hours
- Testing: 4-6 hours
- **Total: 24-31 hours**

**Phase 2 (Next Week):**
- Firebase OAuth: 4-6 hours
- Enhanced features: 8-10 hours

**Phase 3 (Week 3):**
- AI integration: 6-8 hours
- Real APIs: 4-6 hours

**Phase 4 (Week 4):**
- Polish: 4-6 hours
- Deployment: 4-6 hours

---

## 🎯 Success Criteria

✅ All 5 screens fully functional
✅ All CRUD operations working
✅ All state management connected
✅ Authentication working (email/password)
✅ Database operations working
✅ Gamification system working
✅ Dream Me feature working
✅ Analytics working
✅ All features from docs implemented
✅ No major bugs
✅ Ready to add Firebase OAuth
✅ Ready for Phase 3 (real AI)

---

**Let's build this! 🚀**
