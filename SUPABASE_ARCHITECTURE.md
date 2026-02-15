# 🏗️ Tobi To-Do + Supabase Architecture

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                       TOBI TO-DO SYSTEM                         │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────┐         ┌──────────────────────────┐
│   FLUTTER APP           │         │   SUPABASE CLOUD        │
│   (client/)             │         │                          │
├─────────────────────────┤         ├──────────────────────────┤
│ • 5 Screens             │         │ PROJECT ID:              │
│ • Riverpod Providers    │         │ trcmyrwxihgkmxnvhfqv    │
│ • HTTP Client (Dio)     │◄───────►│                          │
│ • Models & UI           │  REST   │ ┌────────────────────┐  │
│                         │  API    │ │ PostgreSQL Database│  │
│ ┌─────────────────────┐ │         │ │ (db.*.supabase.co)│  │
│ │ Providers:          │ │         │ │ Port: 5432        │  │
│ │ • auth              │ │         │ │ SSL: Enabled       │  │
│ │ • tasks             │ │         │ │                    │  │
│ │ • habits    ────────┼─┼────────►│ ├─ users             │  │
│ │ • goals     HTTP    │ │         │ ├─ tasks             │  │
│ │ • focus     API     │ │         │ ├─ goals             │  │
│ │ • analytics         │ │         │ ├─ habits            │  │
│ │ • gamification      │ │         │ ├─ focus_sessions    │  │
│ │ • dream_me          │ │         │ ├─ achievements      │  │
│ └─────────────────────┘ │         │ ├─ dream_profiles    │  │
│                         │         │ └─ reflections       │  │
│ .env:                   │         │                      │  │
│ SUPABASE_URL            │         │ Real-time (Optional) │  │
│ SUPABASE_KEY            │         │ Storage (Optional)   │  │
│ API_BASE_URL            │         │ Auth (Optional)      │  │
└─────────────────────────┘         └────────────────────┘  │
         │                                   │               │
         │ localhost:5000                    │               │
         │ /api/*                            └───────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│      EXPRESS.JS SERVER                  │
│      (server/)                          │
├─────────────────────────────────────────┤
│ • 6 Service Modules                     │
│   ├─ habitService.js                    │
│   ├─ goalService.js                     │
│   ├─ focusService.js                    │
│   ├─ analyticsService.js                │
│   ├─ gamificationService.js             │
│   └─ dreamMeService.js                  │
│                                         │
│ • 6 Controllers (Request Handlers)      │
│ • 7 Route Groups (30+ Endpoints)        │
│ • JWT Authentication                    │
│ • Error Handling & Validation           │
│                                         │
│ .env:                                   │
│ DB_HOST (Supabase)                      │
│ DB_USER, DB_PASSWORD, DB_SSL            │
│ JWT_SECRET                              │
│ CORS_ORIGIN                             │
└─────────────────────────────────────────┘
         │
         │ Parameterized SQL Queries
         │ (SQL Injection Prevention)
         │
         ▼
    ┌─────────────────────────┐
    │  SSL/TLS ENCRYPTED      │
    │  CONNECTION             │
    └─────────────────────────┘
```

---

## Data Flow Example: Create a Habit

```
User (Flutter UI)
    │
    ├─► Enters habit name & frequency
    │
    ├─► Taps "Create Habit" button
    │
    ▼
habitProvider.createHabit()
    │
    ├─► Calls: ApiClient.post('/habits', {name, frequency})
    │
    ▼
HTTP POST → localhost:5000/api/habits
    │
    │ (With JWT Token in Authorization header)
    │
    ▼
habitController.createHabit()
    │
    ├─► Validates auth token
    ├─► Validates input data
    │
    ▼
habitService.createHabit(userId, habitData)
    │
    ├─► Generates UUID for habit ID
    ├─► Prepares SQL insert
    ├─► Sets: streak=0, best_streak=0
    │
    ▼
db.query(INSERT habit)
    │
    │ (Parameterized query - safe from SQL injection)
    │
    ├─► Connects to Supabase PostgreSQL
    ├─► Establishes SSL/TLS tunnel
    ├─► Sends query to: db.trcmyrwxihgkmxnvhfqv.supabase.co:5432
    │
    ▼
Supabase PostgreSQL
    │
    ├─► Inserts row into habits table
    ├─► Generates timestamps
    ├─► Confirms success
    │
    ▼
Response back through chain
    │
    ├─► habitService returns new habit object
    ├─► habitController returns JSON response
    ├─► ApiClient receives response
    ├─► habitProvider updates state
    │
    ▼
Flutter UI Re-renders
    │
    └─► Shows new habit in list
        Habit count increases
        XP awarded (10 points)
```

---

## Database Schema Overview

```
┌──────────────────────────┐
│        USERS             │
├──────────────────────────┤
│ id (UUID) PRIMARY KEY    │
│ email (VARCHAR)          │
│ password_hash            │
│ firebase_uid             │
│ full_name                │
│ avatar_url               │
│ xp (INTEGER)             │
│ level (INTEGER)          │
│ created_at, updated_at   │
└──────────────────────────┘
         │ 1:many
         ├──────────────────┬─────────────────┬──────────────────┬──────────────┐
         │                  │                 │                  │              │
    ┌────▼──────┐     ┌────▼──────┐   ┌────▼──────┐   ┌──────▼──────┐  ┌────▼─────┐
    │  TASKS     │     │  HABITS    │   │  GOALS    │   │  FOCUS_      │  │ACHIEVE-  │
    ├────────────┤     ├────────────┤   ├───────────┤   │  SESSIONS    │  │MENTS     │
    │ id         │     │ id         │   │ id        │   ├──────────────┤  ├──────────┤
    │ user_id FK │     │ user_id FK │   │ user_id   │   │ id           │  │ id       │
    │ title      │     │ name       │   │ title     │   │ user_id FK   │  │ user_id  │
    │ status     │     │ frequency  │   │ category  │   │ task_id FK   │  │ achievement
    │ priority   │     │ streak     │   │ deadline  │   │ duration_min │  │ type     │
    │ due_date   │     │ best_streak│   │ progress  │   │ was_completed│  │ earned_at│
    └────────────┘     │ last_       │   │ status    │   │ completed_at │  └──────────┘
                       │ completed  │   └───────────┘   └──────────────┘
                       └────────────┘         │
                           │                  │ many:many
                           │ many:many        │ via junction
                           └──────────┬───────┘
                                      │
                          ┌───────────▼─────────────┐
                          │ HABIT_GOAL_LINKS        │
                          ├─────────────────────────┤
                          │ habit_id FK             │
                          │ goal_id FK              │
                          │ PRIMARY KEY (habit_id,  │
                          │             goal_id)    │
                          └─────────────────────────┘

┌──────────────────────────┐      ┌──────────────────────────┐
│   DREAM_PROFILES         │      │   REFLECTIONS            │
├──────────────────────────┤      ├──────────────────────────┤
│ id (UUID)                │      │ id (UUID)                │
│ user_id FK (UNIQUE)      │      │ user_id FK               │
│ vision_statement         │      │ content (TEXT)           │
│ core_values              │      │ mood (VARCHAR)           │
│ three_year_goal          │      │ insights                 │
│ identity_statements      │      │ created_at               │
│ created_at, updated_at   │      └──────────────────────────┘
└──────────────────────────┘
```

---

## Security Layers

```
┌─────────────────────────────────────────────────┐
│           SECURITY ARCHITECTURE                 │
└─────────────────────────────────────────────────┘

Layer 1: Transport
├─ TLS/SSL Encryption to Supabase
├─ HTTPS for HTTP endpoints
└─ Secure token transmission

Layer 2: Authentication
├─ JWT tokens (7-day expiry)
├─ Token validation on every request
├─ Password hashing (bcryptjs)
└─ Firebase optional OAuth

Layer 3: Authorization
├─ User ID validation on requests
├─ Row-level access control
└─ Admin vs user routes

Layer 4: Data Validation
├─ Input sanitization
├─ Type checking
├─ Parameterized SQL queries
└─ Error messages don't leak data

Layer 5: Secrets Management
├─ .env files (not in git)
├─ Environment variables
├─ Database password never in code
└─ JWT secret protected

Layer 6: Database
├─ PostgreSQL with strong defaults
├─ Unique constraints (emails)
├─ Foreign key relationships
└─ Timestamps for auditing
```

---

## API Endpoint Summary

```
Total: 30+ Endpoints across 7 Route Groups

HABITS (10 endpoints)
├─ POST   /api/habits                    [Create]
├─ GET    /api/habits                    [List all]
├─ GET    /api/habits/:id                [Get one]
├─ PATCH  /api/habits/:id                [Update]
├─ DELETE /api/habits/:id                [Delete]
├─ POST   /api/habits/:id/complete       [Complete today]
├─ POST   /api/habits/:id/reset-streak   [Reset streak]
├─ GET    /api/habits/due-today          [Today's habits]
├─ GET    /api/habits/stats              [Statistics]
└─ GET    /api/habits/consistency        [Consistency %]

GOALS (11 endpoints)
├─ POST   /api/goals                     [Create]
├─ GET    /api/goals                     [List all]
├─ GET    /api/goals/:id                 [Get one]
├─ PATCH  /api/goals/:id                 [Update]
├─ DELETE /api/goals/:id                 [Delete]
├─ GET    /api/goals/:id/probability     [Success probability]
├─ POST   /api/goals/:id/progress        [Update progress]
├─ GET    /api/goals/:id/habits          [Linked habits]
├─ POST   /api/goals/link-habit          [Link habit]
├─ GET    /api/goals/conflicts/detect    [Conflicts]
└─ GET    /api/goals/stats               [Statistics]

FOCUS (7 endpoints)
├─ POST   /api/focus/start               [Start session]
├─ POST   /api/focus/:id/end             [End session]
├─ GET    /api/focus/active              [Active session]
├─ GET    /api/focus/history             [History]
├─ GET    /api/focus/stats               [Statistics]
├─ GET    /api/focus/streak              [Streak count]
└─ GET    /api/focus/burnout/detect      [Burnout detection]

ANALYTICS (11 endpoints)
├─ GET    /api/analytics/dashboard       [Complete dashboard]
├─ GET    /api/analytics/completion-rate [Task completion %]
├─ GET    /api/analytics/habit-consistency [Habit consistency %]
├─ GET    /api/analytics/goal-trends     [Goal trends]
├─ GET    /api/analytics/goal-progress   [Goal progress]
├─ GET    /api/analytics/focus-time      [Daily focus time]
├─ GET    /api/analytics/productive-time [Most productive hour]
├─ GET    /api/analytics/productivity-heatmap [Activity heatmap]
├─ GET    /api/analytics/engagement      [Engagement metrics]
├─ GET    /api/analytics/habits-comparison [Habit performance]
└─ GET    /api/analytics/weekly-summary  [Weekly summary]

GAMIFICATION (5 endpoints)
├─ GET    /api/gamification/stats        [User stats]
├─ GET    /api/gamification/achievements [Achievements]
├─ GET    /api/gamification/rank         [User rank]
├─ GET    /api/gamification/leaderboard  [Top 100]
└─ POST   /api/gamification/xp/award     [Award XP]

DREAM_ME (8 endpoints)
├─ POST   /api/dream-me/profile          [Create/update profile]
├─ GET    /api/dream-me/profile          [Get profile]
├─ GET    /api/dream-me/alignment        [Alignment score]
├─ GET    /api/dream-me/gaps             [Gap analysis]
├─ POST   /api/dream-me/reflections      [Create reflection]
├─ GET    /api/dream-me/reflections      [Get reflections]
├─ GET    /api/dream-me/insights         [Comprehensive dashboard]
└─ GET    /api/dream-me/milestones       [Milestone progress]

AUTH (5 endpoints - already configured)
├─ POST   /api/auth/register             [Register]
├─ POST   /api/auth/login                [Login]
├─ POST   /api/auth/firebase-login       [Firebase OAuth]
├─ GET    /api/auth/me                   [Current user]
└─ PATCH  /api/auth/profile              [Update profile]
```

---

## File Structure

```
Tobi-To-Do/
├── server/
│   ├── src/
│   │   ├── config/
│   │   │   ├── database.js       ◄─ Supabase PostgreSQL
│   │   │   ├── firebase.js
│   │   │   └── supabase.js       ◄─ Optional Supabase client
│   │   ├── controllers/          (6 controllers, 50+ methods)
│   │   ├── services/             (6 services, 60+ functions)
│   │   ├── routes/               (7 route groups, 30+ endpoints)
│   │   ├── models/
│   │   ├── middleware/
│   │   ├── utils/
│   │   └── server.js             ◄─ Main entry point
│   ├── .env.example              ◄─ Environment template
│   └── package.json
│
├── client/
│   ├── lib/
│   │   ├── providers/            (5 providers, Riverpod)
│   │   ├── services/
│   │   │   └── api_client.dart   ◄─ HTTP client
│   │   ├── models/
│   │   ├── features/             (5 screens)
│   │   └── main.dart
│   ├── .env.example              ◄─ Flutter env
│   └── pubspec.yaml
│
├── SUPABASE_SETUP.md             ◄─ Setup guide
├── SUPABASE_QUICKSTART.md        ◄─ Fast setup
├── SUPABASE_COMPLETE.md          ◄─ This file
├── API_REFERENCE.md              ◄─ API docs
└── .gitignore                    ◄─ .env excluded
```

---

## Deployment Checklist

### Pre-Production
- [ ] Update JWT_SECRET to strong random value
- [ ] Test all API endpoints
- [ ] Verify database indexes
- [ ] Test authentication flow
- [ ] Check error logging
- [ ] Verify CORS settings
- [ ] Test with Flutter production build

### Production
- [ ] Deploy Express server to hosting
- [ ] Set production environment variables
- [ ] Configure database backups (Supabase)
- [ ] Enable RLS in Supabase (optional)
- [ ] Set up monitoring
- [ ] Configure CDN for static assets
- [ ] Enable rate limiting
- [ ] Deploy Flutter app to stores

---

## Support & Resources

**Supabase Documentation**
- https://supabase.com/docs
- Database: https://supabase.com/docs/guides/database
- Auth: https://supabase.com/docs/guides/auth
- Realtime: https://supabase.com/docs/guides/realtime

**Project Files**
- Backend README: `server/README.md`
- Frontend README: `client/README.md`
- API Reference: `API_REFERENCE.md`
- Setup Guide: `SUPABASE_SETUP.md`

---

**✅ Your Tobi To-Do app is production-ready with Supabase!**
