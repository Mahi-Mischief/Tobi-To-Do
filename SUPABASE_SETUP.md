# Supabase Integration Setup Guide

## Your Project Info
- **Project URL:** https://trcmyrwxihgkmxnvhfqv.supabase.co
- **Publishable Key:** sb_publishable_DKzrua89HR7XU3tcrI-mjw_317t1lsA
- **Project ID:** trcmyrwxihgkmxnvhfqv

---

## Step 1: Get Your Database Password

1. Go to your Supabase Dashboard: https://app.supabase.com
2. Select your project "Tobi To-Do"
3. Click **Settings** (bottom left)
4. Click **Database**
5. Under "Connection info" → Copy your **Password**
6. **OR** if you need to reset it:
   - Click **Reset password** button
   - Copy the new password

Your database connection details:
```
Host: db.trcmyrwxihgkmxnvhfqv.supabase.co
Port: 5432
Database: postgres
User: postgres
Password: [YOUR_PASSWORD_HERE]
```

---

## Step 2: Create .env File (Backend)

Create a file at `server/.env`:

```env
# Environment
NODE_ENV=development
PORT=5000

# Supabase Database
DB_HOST=db.trcmyrwxihgkmxnvhfqv.supabase.co
DB_PORT=5432
DB_NAME=postgres
DB_USER=postgres
DB_PASSWORD=YOUR_PASSWORD_HERE
DB_SSL=true

# CORS
CORS_ORIGIN=http://localhost:3000,http://localhost:8080

# JWT
JWT_SECRET=your_super_secret_key_change_this_in_production

# Firebase (optional, for OAuth)
FIREBASE_PROJECT_ID=
FIREBASE_PRIVATE_KEY=
FIREBASE_CLIENT_EMAIL=
```

---

## Step 3: Create .env File (Frontend)

Create a file at `client/.env`:

```env
# Supabase
SUPABASE_URL=https://trcmyrwxihgkmxnvhfqv.supabase.co
SUPABASE_PUBLISHABLE_KEY=sb_publishable_DKzrua89HR7XU3tcrI-mjw_317t1lsA

# Backend API
API_BASE_URL=http://localhost:5000/api
```

---

## Step 4: Install Dependencies

### Backend
```bash
cd server
npm install
```

### Frontend
```bash
cd client
flutter pub get
```

---

## Step 5: Initialize Database

The backend will automatically create all tables on first run:

```bash
cd server
npm start
```

You should see:
```
✓ Database initialized
Server running on port 5000
```

Check your Supabase Dashboard → SQL Editor to verify tables are created.

---

## Step 6: Test the Connection

```bash
# Backend health check
curl http://localhost:5000/api/health

# Should return:
# {"status":"OK","message":"Server is running"}
```

---

## Supabase Features Now Available

### PostgreSQL Database
- All tables automatically managed by backend
- Real-time subscriptions (optional)
- Row-Level Security (optional)

### Authentication (Optional)
- Supabase Auth for user management
- OAuth providers (Google, GitHub, etc.)
- Email/password authentication

### Storage (Optional)
- Profile avatars
- Documents
- Images

### Real-time (Optional)
- Live notifications
- Collaborative features
- Data synchronization

---

## Connection String Format

If needed, the connection string is:
```
postgresql://postgres:YOUR_PASSWORD@db.trcmyrwxihgkmxnvhfqv.supabase.co:5432/postgres?sslmode=require
```

---

## Important Notes

⚠️ **Never commit `.env` file to git!**
Add to `.gitignore`:
```
.env
.env.local
.env.*.local
```

✅ **Keep your database password private**
- Don't share it in messages
- Don't commit it to version control
- Rotate it regularly in production

✅ **SSL Connection**
- Supabase requires SSL
- Already configured in database.js

---

## Troubleshooting

### "Connection refused" error
- Check your password is correct
- Verify DB_HOST matches your project
- Make sure SSL is enabled (DB_SSL=true)

### "Too many connections" error
- Reduce connection pool size
- Close unused connections

### Tables not showing
- Check server logs for errors
- Verify database.js is running table creation
- Check in Supabase Dashboard → SQL Editor

---

## Next Steps

1. Add your password to `.env` files
2. Run `npm start` in server directory
3. Check Supabase Dashboard to verify tables
4. Run Flutter app: `flutter run`
5. Test API endpoints

---

**Ready? Start with Step 1 to get your database password!**
