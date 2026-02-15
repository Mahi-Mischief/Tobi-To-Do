# API Reference - Complete Endpoint Documentation

## Base URL
```
http://localhost:5000/api
```

## Authentication
All protected endpoints require:
```
Authorization: Bearer {jwt_token}
```

---

## 🎯 Habits API

### Create Habit
```
POST /habits
Body: {
  "name": "Morning Exercise",
  "frequency": "daily|weekly|monthly",
  "description": "Optional description"
}
Response: Habit object with id, streak_count: 0
```

### Get All Habits
```
GET /habits
Response: Habit[]
```

### Get Habits Due Today
```
GET /habits/due-today
Response: Habit[]
Filter by frequency and last_completed
```

### Get Habit by ID
```
GET /habits/:habitId
Response: Habit object
```

### Update Habit
```
PATCH /habits/:habitId
Body: { name?, frequency?, description? }
Response: Updated Habit object
```

### Delete Habit
```
DELETE /habits/:habitId
Response: 204 No Content
```

### Complete Habit (Today)
```
POST /habits/:habitId/complete
Response: Habit object with updated streak_count
Awards: 5 XP
```

### Reset Streak
```
POST /habits/:habitId/reset-streak
Response: Habit object with streak_count: 0
```

### Get Habit Statistics
```
GET /habits/stats
Response: {
  total_habits: number,
  active_habits: number,
  total_streaks: number,
  avg_streak: number
}
```

### Get Habit Consistency
```
GET /habits/consistency
Response: { consistency: number } (0-100)
Based on habits completed last 7 days
```

### Get Streaks Summary
```
GET /habits/streaks
Response: {
  current_streaks: [{id, name, streak_count}],
  best_streaks: [{id, name, best_streak}]
}
```

---

## 🎯 Goals API

### Create Goal
```
POST /goals
Body: {
  "title": "Launch my startup",
  "description": "Optional",
  "category": "business|personal|health|education",
  "deadline": "2024-12-31T00:00:00Z",
  "targetValue": number (optional)
}
Response: Goal object with progress_percent: 0, status: "in_progress"
Awards: 15 XP
```

### Get All Goals
```
GET /goals?status=in_progress|completed|abandoned
Response: Goal[]
```

### Get Goal by ID
```
GET /goals/:goalId
Response: Goal object
```

### Update Goal
```
PATCH /goals/:goalId
Body: { title?, status?, progress_percent? }
Response: Updated Goal object
If status = "completed": Awards 50 XP
```

### Delete Goal
```
DELETE /goals/:goalId
Response: 204 No Content
```

### Get Goal Probability
```
GET /goals/:goalId/probability
Response: { probability: number } (0-100)
Algorithm: 50% progress + 30% completion_rate + 20% time_remaining
```

### Update Goal Progress
```
POST /goals/:goalId/progress
Body: { progress_percent: number (0-100) }
Response: Updated Goal object
Awards 10 XP at 25%, 50%, 75%, 100%
```

### Link Habit to Goal
```
POST /goals/link-habit
Body: { goalId, habitId }
Response: { message: "Habit linked to goal" }
```

### Get Linked Habits
```
GET /goals/:goalId/habits
Response: Habit[]
```

### Detect Goal Conflicts
```
GET /goals/conflicts/detect
Response: {
  conflicts: [{goal1_id, goal2_id, category}]
}
Goals in same category active simultaneously
```

### Get Goal Statistics
```
GET /goals/stats
Response: {
  total_goals: number,
  in_progress: number,
  completed: number,
  abandoned: number,
  avg_progress: number
}
```

---

## ⏱️ Focus API

### Start Focus Session
```
POST /focus/start
Body: {
  "taskId": "optional-task-id",
  "durationMinutes": 25
}
Response: FocusSession object
```

### End Focus Session
```
POST /focus/:sessionId/end
Body: { "completed": true|false }
Response: FocusSession object with completed_at
If completed & duration >= 25: Awards XP (1 per 5 min)
```

### Get Active Focus Session
```
GET /focus/active
Response: FocusSession object with elapsedMinutes, remainingMinutes, isExpired
Or null if no active session
```

### Get Focus History
```
GET /focus/history?limit=50
Response: FocusSession[]
Default: last 50 sessions
```

### Get Focus Statistics
```
GET /focus/stats?days=30
Response: {
  totalSessions: number,
  completedSessions: number,
  totalMinutes: number,
  avgDuration: number,
  completionRate: number
}
```

### Get Focus Streak
```
GET /focus/streak
Response: { streak: number }
Consecutive days with completed sessions
```

### Get Burnout Detection
```
GET /focus/burnout/detect
Response: {
  burnoutLevel: "none|mild|moderate|severe",
  burnoutScore: number (0-100),
  factors: string[],
  recommendations: string[]
}
```

---

## 📊 Analytics API

### Get Analytics Dashboard
```
GET /analytics/dashboard
Response: {
  taskCompletionRate: number,
  habitConsistency: number,
  weeklySummary: {...},
  mostProductiveTime: {...},
  habitPerformance: [...]
}
```

### Get Task Completion Rate
```
GET /analytics/completion-rate?days=30
Response: { completionRate: number } (0-100)
```

### Get Habit Consistency
```
GET /analytics/habit-consistency?days=7
Response: { consistency: number } (0-100)
```

### Get Goal Trends
```
GET /analytics/goal-trends?days=90
Response: {
  date: string,
  completionRate: number,
  completed: number,
  total: number
}[]
```

### Get Goal Progress Tracking
```
GET /analytics/goal-progress
Response: {
  id, title, category, progress_percent, deadline,
  status, urgency, daysUntilDeadline
}[]
```

### Get Productivity Heatmap
```
GET /analytics/productivity-heatmap?weeks=4
Response: {
  heatmap: number[][] (7 days × 24 hours)
}
Each cell = task completion count for that hour/day
```

### Get Daily Focus Time
```
GET /analytics/focus-time?days=30
Response: {
  date: string,
  focusMinutes: number
}[]
```

### Get Most Productive Time
```
GET /analytics/productive-time?days=30
Response: {
  hour: number (0-23),
  period: "morning|afternoon|evening",
  taskCount: number
}
Or null if no data
```

### Get Habit Comparison
```
GET /analytics/habits-comparison
Response: {
  id, name, streak_count, best_streak,
  frequency, consistency_percent
}[]
```

### Get Engagement Metrics
```
GET /analytics/engagement
Response: {
  totalTasks: number,
  totalHabits: number,
  totalGoals: number,
  avgTasksPerDay: number,
  activeLastMonth: number
}
```

### Get Weekly Summary
```
GET /analytics/weekly-summary
Response: {
  tasksCompleted: number,
  habitsCompleted: number,
  focusMinutes: number,
  goalsActive: number
}
Current week (Sunday-Today)
```

---

## 🎮 Gamification API

### Get Gamification Stats
```
GET /gamification/stats
Response: {
  xp: number,
  level: number,
  nextLevelXP: number,
  levelProgress: number (0-100),
  achievements: number,
  activeStreaks: number
}
```

### Get User Achievements
```
GET /gamification/achievements
Response: {
  achievement_type: string,
  earned_at: timestamp
}[]
```

### Get User Rank
```
GET /gamification/rank
Response: { rank: number }
Position on leaderboard (1st = best)
```

### Get Leaderboard
```
GET /gamification/leaderboard?limit=100
Response: {
  rank: number,
  id: string,
  full_name: string,
  xp: number,
  level: number,
  avatar_url: string
}[]
```

### Award XP Manually
```
POST /gamification/xp/award
Body: {
  "amount": number,
  "source": "manual|task|habit|focus|goal|achievement"
}
Response: {
  xp: number,
  level: number,
  levelUp: boolean
}
```

---

## 💭 Dream Me API

### Save Dream Profile
```
POST /dream-me/profile
Body: {
  "visionStatement": "I want to...",
  "coreValues": "Family, Health, Growth",
  "threeYearGoal": "Build a thriving business",
  "identityStatements": ["I am a leader", "I am healthy"]
}
Response: DreamProfile object
Awards: 25 XP (if new profile)
```

### Get Dream Profile
```
GET /dream-me/profile
Response: DreamProfile object
Or 404 if not created
```

### Get Alignment Score
```
GET /dream-me/alignment
Response: {
  score: number (0-100),
  breakdown: {
    goalCount: number,
    habitConsistency: number,
    progressRealization: number,
    overallAlignment: number
  }
}
```

### Get Gap Analysis
```
GET /dream-me/gaps
Response: {
  gaps: string[],
  suggestions: string[],
  alignmentScore: number
}
Lists what's missing to reach Dream Me
```

### Record Reflection
```
POST /dream-me/reflections
Body: {
  "content": "Today I learned...",
  "mood": "happy|neutral|sad",
  "insights": "Key insights from today"
}
Response: Reflection object
```

### Get Reflections
```
GET /dream-me/reflections?limit=10
Response: {
  id, content, mood, insights, created_at
}[]
```

### Get Dream Me Insights
```
GET /dream-me/insights
Response: {
  dreamProfile: DreamProfile,
  alignmentScore: number,
  gaps: string[],
  suggestions: string[],
  recentGoals: Goal[],
  activeHabits: Habit[],
  lastReflection: Reflection
}
Complete dashboard view
```

### Get Milestone Progress
```
GET /dream-me/milestones
Response: {
  threeYearGoal: string,
  totalGoals: number,
  completedGoals: number,
  overallProgress: number (0-100),
  goals: [{
    id, title, category, progress_percent,
    status, daysUntilDeadline
  }]
}
Or null if no profile
```

---

## 📋 Status Codes

| Code | Meaning |
|------|---------|
| 200 | OK - Request successful |
| 201 | Created - Resource created successfully |
| 204 | No Content - Successful deletion |
| 400 | Bad Request - Invalid input |
| 401 | Unauthorized - Missing/invalid token |
| 404 | Not Found - Resource doesn't exist |
| 500 | Server Error - Something went wrong |

---

## 🔄 Common Response Formats

### Success Response
```json
{
  "id": "uuid",
  "field1": "value1",
  "field2": "value2",
  "created_at": "2024-01-15T10:30:00Z",
  "updated_at": "2024-01-15T10:30:00Z"
}
```

### Error Response
```json
{
  "error": "Descriptive error message"
}
```

### List Response
```json
[
  { "id": "uuid1", ...},
  { "id": "uuid2", ...},
  { "id": "uuid3", ...}
]
```

---

## 🔑 Authentication Flow

1. **Register**
   ```
   POST /auth/register
   { "email": "user@example.com", "password": "..." }
   Response: { token, user }
   ```

2. **Login**
   ```
   POST /auth/login
   { "email": "user@example.com", "password": "..." }
   Response: { token, user }
   ```

3. **Use Token**
   ```
   GET /habits
   Headers: { Authorization: "Bearer {token}" }
   ```

4. **Token Valid for 7 days**
   - After expiration, user must login again

---

## 📱 Rate Limiting (Recommended)

Suggested limits to implement:
- Login: 5 attempts per minute
- API: 100 requests per minute per user
- Creates: 50 per hour

---

## 🧪 Testing Example

```bash
# Start server
npm start

# Test health
curl http://localhost:5000/api/health

# Create habit
curl -X POST http://localhost:5000/api/habits \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Morning Exercise",
    "frequency": "daily"
  }'

# Get stats
curl http://localhost:5000/api/gamification/stats \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## 🔗 Relationships

```
User
  ├── Tasks (1:many)
  ├── Habits (1:many)
  │   └── Linked to Goals (many:many via habit_goal_links)
  ├── Goals (1:many)
  ├── Focus Sessions (1:many)
  ├── Achievements (1:many)
  ├── Dream Profile (1:1)
  └── Reflections (1:many)
```

---

**API Version:** 1.0
**Last Updated:** 2024
**Status:** Production Ready ✅
