# 🚀 Tobi To-Do Backend (Node.js + Express)

**Tobi's brain.** REST API that powers the Flutter app with authentication, task management, and AI integration hooks.

> "Every great app has a smart backend. Tobi's backend is designed to be secure, scalable, and ready for AI integration."

---

## 🎯 Backend Mission

The backend serves as:
- 🔐 **Authentication Layer** — Secure user login & JWT management
- 📊 **Data Hub** — All app data storage & retrieval
- 🤖 **AI Gateway** — Interface to AI services (Mistral, Hugging Face)
- ⚡ **Business Logic** — Smart scheduling, analytics, streak tracking
- 🛡️ **Security Gatekeeper** — Validates requests, protects database

---

## 🛠️ Tech Stack

| Component | Technology | Version |
|-----------|-----------|---------|
| **Runtime** | Node.js | 16+ |
| **Framework** | Express.js | 4.18.2 |
| **Database** | PostgreSQL | 12+ |
| **Auth** | JWT | jsonwebtoken 9.1.2 |
| **Passwords** | Bcryptjs | 2.4.3 |
| **OAuth** | Firebase Admin SDK | 12.0.0 |
| **Configuration** | Dotenv | 16.3.1 |
| **HTTP Client** | Axios | (for external APIs) |
| **Validation** | Joi | (ready to use) |

---

## 🏗️ Project Structure

```
server/
├── src/
│   ├── config/
│   │   ├── database.js         # PostgreSQL connection & schema
│   │   └── firebase.js         # Firebase Admin SDK setup
│   ├── controllers/
│   │   ├── authController.js   # Auth logic (register, login, profile)
│   │   ├── taskController.js   # Task CRUD + AI endpoints
│   │   └── (future: goalController, habitController)
│   ├── middleware/
│   │   ├── auth.js            # JWT verification
│   │   └── errorHandler.js    # Global error handling
│   ├── models/
│   │   ├── User.js            # User schema
│   │   ├── Task.js            # Task schema
│   │   ├── Goal.js            # Goal schema
│   │   └── Habit.js           # Habit schema
│   ├── routes/
│   │   ├── authRoutes.js      # Auth endpoints
│   │   ├── taskRoutes.js      # Task endpoints
│   │   └── (future: goalRoutes, habitRoutes)
│   ├── services/
│   │   ├── authService.js     # Auth business logic
│   │   ├── taskService.js     # Task business logic
│   │   ├── aiService.js       # AI features (placeholder)
│   │   └── (future: analyticsService)
│   ├── utils/
│   │   └── helpers.js         # Utility functions
│   ├── server.js              # Express app setup
│   └── app.js                 # Main app instance
├── .env.example               # Environment template
├── .gitignore                 # Git ignores
├── package.json               # Dependencies & scripts
└── README.md                  # This file
```

---

## 🗄️ Database Schema

### Tables

#### **users**
```sql
id                UUID PRIMARY KEY
email             VARCHAR(255) UNIQUE NOT NULL
password_hash     VARCHAR(255)
firebase_uid      VARCHAR(255)
full_name         VARCHAR(255)
xp                INTEGER DEFAULT 0
level             INTEGER DEFAULT 1
avatar_url        TEXT
created_at        TIMESTAMP DEFAULT NOW()
updated_at        TIMESTAMP DEFAULT NOW()
```

#### **tasks**
```sql
id                UUID PRIMARY KEY
user_id           UUID NOT NULL (FK → users)
title             VARCHAR(255) NOT NULL
description       TEXT
priority          ENUM('low', 'medium', 'high')
status            ENUM('todo', 'in_progress', 'completed')
due_date          TIMESTAMP
completed_at      TIMESTAMP
created_at        TIMESTAMP DEFAULT NOW()
updated_at        TIMESTAMP DEFAULT NOW()
```

#### **goals**
```sql
id                UUID PRIMARY KEY
user_id           UUID NOT NULL (FK → users)
title             VARCHAR(255) NOT NULL
description       TEXT
category          VARCHAR(100)
deadline          TIMESTAMP
progress_percent  INTEGER DEFAULT 0
status            ENUM('active', 'completed', 'archived')
created_at        TIMESTAMP DEFAULT NOW()
updated_at        TIMESTAMP DEFAULT NOW()
```

#### **habits**
```sql
id                UUID PRIMARY KEY
user_id           UUID NOT NULL (FK → users)
name              VARCHAR(255) NOT NULL
frequency         ENUM('daily', 'weekly', 'monthly')
streak_count      INTEGER DEFAULT 0
best_streak       INTEGER DEFAULT 0
last_completed    TIMESTAMP
created_at        TIMESTAMP DEFAULT NOW()
updated_at        TIMESTAMP DEFAULT NOW()
```

#### **focus_sessions**
```sql
id                UUID PRIMARY KEY
user_id           UUID NOT NULL (FK → users)
task_id           UUID (FK → tasks, nullable)
duration_minutes  INTEGER NOT NULL
completed_at      TIMESTAMP DEFAULT NOW()
created_at        TIMESTAMP DEFAULT NOW()
```

---

## 🔌 API Endpoints

### **Authentication**

#### Register
```http
POST /api/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "securePassword123",
  "fullName": "John Doe"
}

Response: 201 Created
{
  "id": "uuid",
  "email": "user@example.com",
  "fullName": "John Doe",
  "token": "eyJhbGc..."
}
```

#### Login
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "securePassword123"
}

Response: 200 OK
{
  "user": { ... },
  "token": "eyJhbGc..."
}
```

#### Firebase Login
```http
POST /api/auth/firebase-login
Content-Type: application/json
Authorization: Bearer <firebase-id-token>

{
  "firebaseUid": "firebase-uid",
  "email": "user@example.com"
}

Response: 200 OK
{
  "user": { ... },
  "token": "eyJhbGc..."
}
```

#### Get Current User
```http
GET /api/auth/me
Authorization: Bearer <jwt-token>

Response: 200 OK
{
  "id": "uuid",
  "email": "user@example.com",
  "fullName": "John Doe",
  "xp": 150,
  "level": 3
}
```

#### Update Profile
```http
PATCH /api/auth/profile
Authorization: Bearer <jwt-token>
Content-Type: application/json

{
  "fullName": "Jane Doe",
  "avatarUrl": "https://..."
}

Response: 200 OK
{
  ...updated user...
}
```

---

### **Tasks**

#### Create Task
```http
POST /api/tasks
Authorization: Bearer <jwt-token>
Content-Type: application/json

{
  "title": "Complete Math Homework",
  "description": "Chapters 5-8",
  "priority": "high",
  "dueDate": "2026-02-20T18:00:00Z"
}

Response: 201 Created
{
  "id": "uuid",
  "userId": "uuid",
  "title": "Complete Math Homework",
  "status": "todo",
  "priority": "high",
  "dueDate": "2026-02-20T18:00:00Z",
  "createdAt": "2026-02-14T10:00:00Z"
}
```

#### Get All Tasks
```http
GET /api/tasks?status=todo&priority=high
Authorization: Bearer <jwt-token>

Response: 200 OK
{
  "tasks": [
    { ... },
    { ... }
  ],
  "total": 12,
  "completed": 3,
  "pending": 9
}
```

#### Get Single Task
```http
GET /api/tasks/:id
Authorization: Bearer <jwt-token>

Response: 200 OK
{
  ...task details...
}
```

#### Update Task
```http
PATCH /api/tasks/:id
Authorization: Bearer <jwt-token>
Content-Type: application/json

{
  "status": "completed",
  "title": "New title"
}

Response: 200 OK
{
  ...updated task...
}
```

#### Delete Task
```http
DELETE /api/tasks/:id
Authorization: Bearer <jwt-token>

Response: 204 No Content
```

---

### **Dashboard**

#### Get Dashboard Stats
```http
GET /api/dashboard/stats
Authorization: Bearer <jwt-token>

Response: 200 OK
{
  "tasksCompleted": 8,
  "tasksPending": 4,
  "productivityPercent": 67,
  "disciplineScore": 85,
  "lifeBalanceScore": 72,
  "currentStreak": 5,
  "todaysFocus": 120,
  "xp": 150,
  "level": 3
}
```

---

### **AI Features** (Placeholder)

#### AI Task Breakdown
```http
POST /api/tasks/ai/breakdown
Authorization: Bearer <jwt-token>
Content-Type: application/json

{
  "description": "Complete project proposal"
}

Response: 200 OK
{
  "taskId": "uuid",
  "subtasks": [
    "Research market",
    "Draft proposal",
    "Get feedback",
    "Finalize document"
  ]
}
```

#### AI Smart Scheduling
```http
GET /api/tasks/ai/schedule
Authorization: Bearer <jwt-token>

Response: 200 OK
{
  "suggestedSchedule": [
    {
      "taskId": "uuid",
      "title": "Math homework",
      "suggestedTime": "14:00",
      "duration": 90,
      "reason": "Energy peak, no conflicts"
    }
  ]
}
```

---

## 🔐 Authentication & Security

### JWT Flow
1. **User registers/logs in**
2. **Backend creates JWT** with user ID + expiration
3. **Frontend stores JWT** in secure storage
4. **Frontend sends JWT** in `Authorization: Bearer <token>` header
5. **Backend verifies JWT** on every protected route
6. **If invalid/expired** → 401 Unauthorized

### Token Expiration
- Default: 7 days
- Configurable in `.env`: `JWT_EXPIRES_IN`

### Password Security
- Hashed with bcryptjs (salt rounds: 10)
- Never stored in plain text
- Never returned to client

### Firebase Integration (Optional)
- Can verify Firebase ID tokens
- Supports Google OAuth
- Automatic user creation
- Email verification ready

---

## 🚀 Getting Started

### Prerequisites
- Node.js 16+
- PostgreSQL 12+
- npm or yarn

### Installation

1. **Clone repository**
   ```bash
   git clone <repo-url>
   cd server
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Create `.env` file**
   ```bash
   cp .env.example .env
   ```

4. **Configure `.env`**
   ```env
   NODE_ENV=development
   PORT=5000
   
   DB_HOST=localhost
   DB_PORT=5432
   DB_USER=postgres
   DB_PASSWORD=TobiIsC00l!
   DB_NAME=tobi_todo
   
   JWT_SECRET=your-secret-key-here
   JWT_EXPIRES_IN=7d
   
   FIREBASE_API_KEY=your-firebase-key
   FIREBASE_PROJECT_ID=your-project-id
   FIREBASE_PRIVATE_KEY=your-private-key
   
   CORS_ORIGIN=http://localhost:3000
   
   HUGGING_FACE_API_KEY=your-hf-api-key
   ```

5. **Create database**
   ```bash
   createdb tobi_todo
   ```

6. **Start server**
   ```bash
   npm run dev
   ```

   Server runs on `http://localhost:5000`

---

## 🔄 Database Setup

### Automatic Initialization
On first run, the database automatically:
- Creates all tables
- Sets up foreign keys
- Creates indexes
- Initializes schema

### Manual Setup (if needed)
```bash
# Connect to PostgreSQL
psql -U postgres

# Create database
CREATE DATABASE tobi_todo;

# Connect to database
\c tobi_todo

# Tables auto-created on server start
```

---

## 📝 Environment Variables

```env
# Server
NODE_ENV=development            # development, production, testing
PORT=5000                       # Express port

# Database
DB_HOST=localhost               # PostgreSQL host
DB_PORT=5432                    # PostgreSQL port
DB_USER=postgres                # PostgreSQL user
DB_PASSWORD=TobiIsC00l!         # PostgreSQL password
DB_NAME=tobi_todo               # Database name

# Authentication
JWT_SECRET=your-super-secret    # JWT signing key
JWT_EXPIRES_IN=7d               # Token expiration

# Firebase (optional)
FIREBASE_API_KEY=...            # Firebase API key
FIREBASE_PROJECT_ID=...         # Firebase project ID
FIREBASE_PRIVATE_KEY=...        # Firebase private key

# CORS
CORS_ORIGIN=*                   # Allowed origins

# AI
HUGGING_FACE_API_KEY=...        # Hugging Face API key
MISTRAL_API_KEY=...             # Mistral API key (if using)
```

---

## 🧪 Testing

### Run Tests
```bash
npm test
```

### Run Specific Test
```bash
npm test -- authController.test.js
```

### Test Coverage
```bash
npm run test:coverage
```

---

## 🚀 Development

### Start Development Server
```bash
npm run dev
```

### Hot Reload
- Server automatically restarts on file changes (via nodemon)
- Check terminal for restart confirmation

### Debug Mode
```bash
npm run dev -- --debug
```

### Linting
```bash
npm run lint
npm run lint:fix
```

---

## 🏗️ Folder Purposes

### `/config`
- Database connection setup
- Environment configuration
- Firebase initialization

### `/controllers`
- Handle HTTP request/response
- Validate input
- Call services
- Return responses

### `/services`
- Business logic
- Database queries
- Complex calculations
- AI service calls

### `/middleware`
- JWT verification
- Request validation
- Error handling
- Logging

### `/models`
- Data structure definitions
- Serialization methods
- Schema validation

### `/routes`
- API endpoint definitions
- Route handlers
- Middleware application

### `/utils`
- Helper functions
- Date formatting
- Score calculations
- Error formatting

---

## 📊 Key Features

### ✅ Currently Implemented
- User registration & login
- JWT authentication
- Firebase OAuth support
- Task CRUD operations
- Dashboard statistics
- Middleware for auth & errors
- Database schema with indexes
- Password hashing (bcryptjs)
- Secure token management

### 🔄 Ready to Implement (Phase 2)
- Goal management endpoints
- Habit tracking endpoints
- AI service integration
- Push notifications
- Analytics aggregation
- Calendar sync
- Batch operations

### 🚀 Future Features (Phase 3+)
- Real AI integration
- Machine learning models
- Advanced analytics
- Team collaboration
- Webhook support
- Rate limiting
- API versioning

---

## 🔍 Code Examples

### Create a Task Service
```javascript
import { db } from '../config/database.js';
import Task from '../models/Task.js';

export async function createTask(userId, taskData) {
  const query = `
    INSERT INTO tasks (id, user_id, title, description, priority, due_date)
    VALUES ($1, $2, $3, $4, $5, $6)
    RETURNING *
  `;
  
  const result = await db.query(query, [
    generateId(),
    userId,
    taskData.title,
    taskData.description,
    taskData.priority,
    taskData.dueDate
  ]);
  
  return new Task(result.rows[0]);
}
```

### Middleware: JWT Verification
```javascript
export function authMiddleware(req, res, next) {
  const token = req.headers.authorization?.split(' ')[1];
  
  if (!token) {
    return res.status(401).json({ error: 'No token provided' });
  }
  
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.userId = decoded.userId;
    next();
  } catch (error) {
    res.status(401).json({ error: 'Invalid token' });
  }
}
```

### Controller: Handle Request
```javascript
export async function createTask(req, res, next) {
  try {
    const task = await taskService.createTask(req.userId, req.body);
    res.status(201).json(task);
  } catch (error) {
    next(error);
  }
}
```

---

## 🐛 Troubleshooting

### Database Connection Failed
```bash
# Check PostgreSQL is running
psql -U postgres -c "SELECT 1"

# Verify credentials in .env
# Check DB_HOST, DB_PORT, DB_USER, DB_PASSWORD, DB_NAME

# Restart server after changes
npm run dev
```

### JWT Token Issues
```
- Verify JWT_SECRET in .env is set
- Check token expiration: JWT_EXPIRES_IN
- Ensure Authorization header format: "Bearer <token>"
```

### CORS Errors
```
- Check CORS_ORIGIN in .env matches frontend URL
- Verify middleware order in server.js
- Test with Postman first
```

---

## 📈 Performance Tips

✅ Use database indexes on frequently queried fields
✅ Implement query pagination for large datasets
✅ Cache responses when appropriate
✅ Use connection pooling (pg-pool)
✅ Profile queries with slow query log
✅ Batch database operations
✅ Use middleware for common operations

---

## 🔐 Security Checklist

✅ Hash passwords (bcryptjs)
✅ Validate all input (Joi)
✅ Use JWT expiration
✅ Never expose database keys
✅ Enable CORS properly
✅ Use environment variables
✅ Add rate limiting (future)
✅ Implement request logging
✅ Use HTTPS in production
✅ Regular security audits

---

## 📚 Dependencies Used

```json
{
  "express": "4.18.2",           // Web framework
  "pg": "8.11.2",                // PostgreSQL driver
  "jsonwebtoken": "9.1.2",       // JWT creation/verification
  "bcryptjs": "2.4.3",           // Password hashing
  "firebase-admin": "12.0.0",    // Firebase integration
  "dotenv": "16.3.1",            // Environment variables
  "cors": "2.8.5",               // CORS support
  "uuid": "9.0.1",               // Unique ID generation
  "joi": "17.11.0",              // Data validation
  "axios": "1.6.2",              // HTTP client (for external APIs)
  "nodemon": "3.0.2"             // Dev auto-reload
}
```

---

## 🚀 Deployment

### Prepare for Production
1. Set `NODE_ENV=production`
2. Use strong `JWT_SECRET` (32+ chars)
3. Set `CORS_ORIGIN` to frontend URL
4. Use managed PostgreSQL (AWS RDS, Supabase, etc.)
5. Set up environment variables on host
6. Enable HTTPS
7. Add rate limiting
8. Set up monitoring & logging

### Deploy to Render
```bash
# Connect GitHub repo
# Set environment variables in Render
# Deploy automatically
```

### Deploy to Railway
```bash
# Connect GitHub repo
# Railway auto-detects Node.js
# Configure PostgreSQL plugin
# Deploy with git push
```

---

## 📊 API Documentation

Full OpenAPI/Swagger docs coming soon:
- API spec file
- Interactive API explorer
- Client SDK generation

---

## 🎓 Learning Resources

### Express.js
- [Express Docs](https://expressjs.com)
- [Express Best Practices](https://expressjs.com/en/advanced/best-practice-security.html)

### PostgreSQL
- [PostgreSQL Docs](https://www.postgresql.org/docs)
- [Query Optimization](https://www.postgresql.org/docs/current/queries.html)

### JWT
- [JWT.io](https://jwt.io)
- [JWT Handbook](https://auth0.com/resources/whitepapers/jwt-handbook)

### Firebase
- [Firebase Docs](https://firebase.google.com/docs)

---

## 📝 TODO

- [ ] Add Joi validation for all endpoints
- [ ] Implement rate limiting
- [ ] Add comprehensive logging
- [ ] Create API documentation (Swagger)
- [ ] Add unit tests
- [ ] Implement caching (Redis)
- [ ] Add batch operations
- [ ] Create monitoring alerts
- [ ] Set up CI/CD pipeline
- [ ] Add analytics service
- [ ] Implement goal endpoints
- [ ] Implement habit endpoints
- [ ] Real AI integration
- [ ] Push notification service

---

## 🌟 Special Notes

**AI Integration Strategy:**
- Start with logic-based solutions (scheduling, stats)
- Use Hugging Face Mistral for NLP (free tier)
- Cache AI responses to minimize API calls
- Fall back to logic when AI calls fail

**Database:**
- Password: `TobiIsC00l!`
- Auto-initialization on first run
- Indexes on user_id fields
- UUID primary keys throughout

**Security:**
- All passwords hashed
- JWT tokens signed
- CORS enabled for frontend
- Firebase OAuth supported
- Input validation ready

---

**Version:** 1.0.0  
**Last Updated:** February 14, 2026  
**Status:** MVP Ready for Development

Built with 💜 for the Tobi To-Do community.
