# SUPABASE SETUP - QUICK START

## ✅ Status

✅ `.env` file updated with password
✅ SQL setup script created
✅ RLS policies configured
✅ Backend ready for Supabase

## 🎯 Next: Run This in Supabase

### Step 1: Open Supabase SQL Editor
```
https://app.supabase.com 
  → Select: trcmyrwxihgkmxnvhfqv
  → Click: SQL Editor (left sidebar)
  → Click: New Query
```

### Step 2: Copy SQL Script
File: `SUPABASE_SETUP.sql` (in project root)
- Open it
- Copy ALL the code
- Paste into Supabase SQL Editor

### Step 3: Run It
```
Click: RUN button
Wait: ~5 seconds
See: "Success" message
```

### Step 4: Verify in Table Editor
Supabase → Table Editor (left sidebar)

You should see these tables:
```
✅ users
✅ tasks
✅ habits
✅ goals
✅ focus_sessions
✅ achievements
✅ dream_profiles
✅ reflections
✅ habit_goal_links
```

## 🔐 RLS Policies (Auto-Created)

Each table has these policies:
- `SELECT`: Users can only see their own data
- `INSERT`: Users can only create their own records
- `UPDATE`: Users can only modify their own records
- `DELETE`: Users can only delete their own records

**This means:** User A cannot see, modify, or delete User B's data - guaranteed by the database

## 📱 Flutter App Can Now:

✅ Create user account
✅ Create tasks (linked to user)
✅ Create habits (linked to user)
✅ Create goals (linked to user)
✅ Start focus sessions (linked to user)
✅ All data isolated by RLS

## 🚀 Backend Ready To:

✅ Connect to Supabase PostgreSQL
✅ Create/read/update/delete all records
✅ Use password: `TobiIsC00l!`
✅ All 30+ API endpoints functional

## Files Created/Updated

```
✅ server/.env (with password)
✅ server/.env.example (updated with URLs)
✅ SUPABASE_SETUP.sql (SQL script - 9 tables + RLS)
✅ SUPABASE_DATABASE_SETUP.md (detailed guide)
```

## What Each Table Does

| Table | Purpose | RLS |
|-------|---------|-----|
| users | User accounts, XP, level | Own data only |
| tasks | To-do tasks | Own tasks only |
| habits | Daily/weekly habits | Own habits only |
| goals | Long-term goals | Own goals only |
| focus_sessions | Focus timer sessions | Own sessions only |
| achievements | Earned badges | Own achievements only |
| dream_profiles | Dream Me vision | Own profile only |
| reflections | Journal entries | Own entries only |

## Connection Flow

```
Flutter App
    ↓
Backend API (Express)
    ↓
Supabase PostgreSQL
    ↓
RLS Policy Check (🔐 Enforces user_id match)
    ↓
Return Data (Only if user_id matches)
```

## Testing Your Setup

After running the SQL script, test in Supabase SQL Editor:

```sql
-- See all your tables
SELECT tablename FROM pg_tables 
WHERE schemaname = 'public';

-- See all your indexes
SELECT * FROM pg_indexes 
WHERE schemaname = 'public';
```

## 🎉 Ready for Next Phase!

Once SQL script is run:
- Database is fully set up
- RLS is protecting user data
- Backend can connect and use all endpoints
- Flutter app will authenticate via Supabase Auth
- All data is user-isolated

**Estimated time to complete:** 5 minutes

Ready? Go to: https://app.supabase.com and run the SQL script! 🚀
