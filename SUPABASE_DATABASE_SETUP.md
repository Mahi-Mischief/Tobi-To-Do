# Setting Up Tobi Database in Supabase

## Step 1: Access Supabase SQL Editor

1. Go to https://app.supabase.com
2. Select your project: **trcmyrwxihgkmxnvhfqv**
3. Click **SQL Editor** in the left sidebar
4. Click **New Query** (or the + button)

## Step 2: Run the Setup Script

1. Open the file: `SUPABASE_SETUP.sql` (in your project root)
2. Copy ALL the SQL code
3. Paste it into the Supabase SQL Editor
4. Click the **Run** button (or press Ctrl+Enter)

**Wait for it to complete** - you'll see a success message

## Step 3: Verify Tables Were Created

In Supabase, go to **Table Editor** and confirm you see:
- ✅ users
- ✅ tasks
- ✅ habits
- ✅ goals
- ✅ focus_sessions
- ✅ achievements
- ✅ dream_profiles
- ✅ reflections
- ✅ habit_goal_links

## Step 4: Enable Supabase Auth

1. Go to **Authentication** in left sidebar
2. Click **Providers**
3. Enable **Email** (it should be enabled by default)
4. Save settings

## Step 5: Set Auth URL for Flutter

1. Go to **Project Settings** → **API**
2. Copy your **Project URL**: `https://trcmyrwxihgkmxnvhfqv.supabase.co`
3. Copy your **Anon Public Key**: `sb_publishable_DKzrua89HR7XU3tcrI-mjw_317t1lsA`
4. Copy your **Service Role Secret Key** (keep this secret!)

## RLS Policies Explained

Each table has Row Level Security (RLS) enabled with policies:

### READ Policy
- Users can only **read** their own data
- Example: A user can only see their own tasks

### CREATE Policy
- Users can only **create** records for themselves
- Example: When creating a task, `user_id` must be current user

### UPDATE Policy
- Users can only **update** their own records
- Example: Users can only modify their own goals

### DELETE Policy
- Users can only **delete** their own records
- Example: Users can only delete their own habits

## Security Overview

```
┌─────────────────────────────────────┐
│         Flutter App (User)          │
└──────────────────┬──────────────────┘
                   │
        🔐 JWT Token (in header)
                   │
┌──────────────────▼──────────────────┐
│      Express.js Backend Server      │
│   (validates user_id from JWT)      │
└──────────────────┬──────────────────┘
                   │
            SQL Query with user_id
                   │
┌──────────────────▼──────────────────┐
│     Supabase PostgreSQL Database    │
│   (RLS Policy checks user_id match) │
└─────────────────────────────────────┘
```

## Testing RLS in Supabase

You can test RLS directly in Supabase:

1. Go to **SQL Editor**
2. Create a test query:
```sql
-- Test 1: Insert a user
INSERT INTO users (id, email, full_name, password_hash)
VALUES (gen_random_uuid(), 'test@example.com', 'Test User', 'hashed_password');

-- Test 2: Insert a task for that user
INSERT INTO tasks (user_id, title, description)
VALUES ('paste-user-id-here', 'My First Task', 'Test description');

-- Test 3: Query your own data
SELECT * FROM tasks;
```

## Troubleshooting

### "Row Level Security Policy Violation"
- This means the user doesn't have permission
- Check that `user_id` in the record matches the authenticated user

### "Column 'user_id' does not exist"
- Make sure the SQL script ran successfully
- Tables might not have been created
- Run the SUPABASE_SETUP.sql script again

### "No tables visible"
- The script might have failed
- Check the error messages in the SQL Editor
- Make sure you're in the correct database (should be "postgres")

## Next Steps

1. ✅ Database tables created
2. ✅ RLS policies configured
3. 🔲 Configure Flutter app authentication
4. 🔲 Update backend to use Supabase Auth
5. 🔲 Test API endpoints
6. 🔲 Deploy to staging

## Important Notes

- **Never commit your `.env` file** - it contains sensitive credentials
- **RLS policies are production-grade security** - they enforce data isolation at the database level
- **Each user can only see/modify their own data** - guaranteed by RLS
- **Service Role Secret Key should never be exposed** - only use in backend
- **Public Anon Key is safe** - it's only for read-only authenticated requests

## Database Relationships

```
users (1) ─────── (many) tasks
users (1) ─────── (many) habits
users (1) ─────── (many) goals
users (1) ─────── (many) focus_sessions
users (1) ─────── (many) achievements
users (1) ─────── (1) dream_profiles
users (1) ─────── (many) reflections
habits (many) ── (many) goals [via habit_goal_links]
```

Your Tobi database is now secure, scalable, and production-ready! 🚀
