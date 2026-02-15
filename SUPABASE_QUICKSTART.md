# 🚀 Quick Start: Supabase Integration

## Your Setup Info
```
Project: Tobi To-Do
Supabase URL: https://trcmyrwxihgkmxnvhfqv.supabase.co
Project ID: trcmyrwxihgkmxnvhfqv
```

---

## ⚡ 5-Minute Setup

### 1️⃣ Get Database Password

1. Visit: https://app.supabase.com
2. Select "Tobi To-Do" project
3. Go to **Settings** → **Database**
4. Copy the **Password** from "Connection info"

### 2️⃣ Create Backend .env

Create `server/.env`:
```bash
DB_HOST=db.trcmyrwxihgkmxnvhfqv.supabase.co
DB_PORT=5432
DB_NAME=postgres
DB_USER=postgres
DB_PASSWORD=YOUR_PASSWORD_HERE
DB_SSL=true

JWT_SECRET=your_secret_key_min_32_chars
PORT=5000
```

### 3️⃣ Create Frontend .env

Create `client/.env`:
```bash
SUPABASE_URL=https://trcmyrwxihgkmxnvhfqv.supabase.co
SUPABASE_PUBLISHABLE_KEY=sb_publishable_DKzrua89HR7XU3tcrI-mjw_317t1lsA
API_BASE_URL=http://localhost:5000/api
```

### 4️⃣ Start Backend

```bash
cd server
npm install
npm start
```

Expected output:
```
✓ Database initialized successfully
Server running on port 5000
```

### 5️⃣ Start Frontend

```bash
cd client
flutter pub get
flutter run
```

---

## ✅ Verify It's Working

### Test Backend Health
```bash
curl http://localhost:5000/api/health
# Should return: {"status":"OK","message":"Server is running"}
```

### Check Supabase Tables
1. Go to: https://app.supabase.com/project/trcmyrwxihgkmxnvhfqv
2. Click **SQL Editor** (left menu)
3. Run: `SELECT tablename FROM pg_tables WHERE schemaname = 'public';`
4. Should see: users, tasks, goals, habits, focus_sessions, achievements, dream_profiles, reflections

---

## 📋 What's Configured

✅ **Backend**
- PostgreSQL via Supabase
- SSL connection enabled
- All 8 tables ready
- 30+ API endpoints

✅ **Frontend**
- Supabase URL configured
- Publishable key set
- API client ready
- 5 Riverpod providers

✅ **Database**
- 8 tables with relationships
- Proper indexes
- User authentication
- Timestamps everywhere

---

## 🔐 Security Checklist

- [ ] `.env` file added to `.gitignore` ✅ (Already done)
- [ ] Database password NOT in git
- [ ] JWT_SECRET changed (if deploying)
- [ ] SSL enabled for database ✅
- [ ] CORS configured for your domain

---

## 📱 Common Commands

```bash
# Backend
cd server
npm start                # Start development server
npm run dev              # Start with auto-reload (if configured)

# Frontend
cd client
flutter run              # Run on connected device
flutter run -d chrome    # Run on web
flutter run -d macos     # Run on macOS
```

---

## 🆘 Troubleshooting

### "Connection refused"
```
✗ Check: DB password in .env
✗ Check: DB_HOST is correct
✗ Check: DB_SSL=true
```

### "Too many connections"
```
✗ Reduce connection pool size in database.js
✗ Check for connection leaks
```

### "Table doesn't exist"
```
✗ Check server logs for errors
✗ Verify database.js ran initialization
✗ Check Supabase Dashboard → SQL Editor
```

### "CORS error"
```
✗ Add frontend URL to CORS_ORIGIN in .env
✗ Restart backend server
```

---

## 📚 Full Documentation

- **Setup Details:** [SUPABASE_SETUP.md](./SUPABASE_SETUP.md)
- **API Reference:** [API_REFERENCE.md](./API_REFERENCE.md)
- **Backend Info:** [server/README.md](./server/README.md)
- **Frontend Info:** [client/README.md](./client/README.md)

---

## 🎯 Next Steps

1. ✅ Add DB password to `.env`
2. ✅ Run `npm start` in server
3. ✅ Verify tables in Supabase Dashboard
4. ✅ Run `flutter run` in client
5. ✅ Test login/create task

---

**🚀 You're all set! Happy coding!**
