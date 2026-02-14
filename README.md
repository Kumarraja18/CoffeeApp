# ☕ Brew & Co — Coffee Ordering Platform

A full-stack coffee ordering platform built with **Spring Boot** (backend) and **React + Vite** (frontend).

## 🚀 Quick Start (One-Click)

### Prerequisites
1. **Java 17+** — [Download](https://adoptium.net/)
2. **Maven** — [Download](https://maven.apache.org/download.cgi)
3. **Node.js 18+** — [Download](https://nodejs.org/)
4. **MySQL 8.x** — [Download](https://dev.mysql.com/downloads/installer/)

### Option A: One-Click Setup & Run
```
SETUP_AND_RUN.bat
```
This checks everything, sets up the database, and starts both servers automatically.

### Option B: Step-by-Step
```bash
# 1. Setup database (interactive — prompts for MySQL password)
setup.bat

# 2. Edit .env with your settings (optional)
copy .env.example .env
notepad .env

# 3. Start everything
start-all.bat
```

### Option C: Manual
```bash
# Terminal 1 — Backend
cd backend
start-backend.bat

# Terminal 2 — Frontend
cd frontend
npm install    # first time only
npm run dev
```

## 🌐 Access
- **Frontend**: http://localhost:5173
- **Backend API**: http://localhost:8080

## 🔐 Default Admin
| | |
|---|---|
| **Email** | admin@brewco.com |
| **Password** | admin123 |

*(Override via `.env` file)*

## 📧 How Registration Works
1. User fills out multi-step registration form
2. Admin receives notification and reviews the application
3. Admin **approves** → System generates random password → Email sent to user
4. User logs in with the emailed credentials

## 🗄️ Database
- **Engine**: MySQL 8.x
- **Database**: `brewco_db` (auto-created on first boot)
- **Tables**: Auto-created by Hibernate (`ddl-auto=update`)

### Import Existing Data
If you have the `brewco_db.sql` dump:
```bash
mysql -u root -p < backend/src/main/resources/brewco_db.sql
```

## 📁 Project Structure
```
KumarSpringBoot/
├── backend/              # Spring Boot API
│   ├── src/main/java/com/brewco/
│   │   ├── config/       # DataInitializer
│   │   ├── controller/   # REST endpoints
│   │   ├── dto/          # Data Transfer Objects
│   │   ├── entity/       # JPA entities
│   │   ├── repository/   # Spring Data repos
│   │   └── service/      # Business logic
│   └── src/main/resources/
│       ├── application.properties
│       └── brewco_db.sql  # DB dump
├── frontend/             # React + Vite
├── .env                  # Your local config (gitignored)
├── .env.example          # Template
├── setup.bat             # Interactive DB setup
├── SETUP_AND_RUN.bat     # One-click everything
└── start-all.bat         # Start both servers
```

## 🔧 Troubleshooting

### "Access denied for user 'root'"
Update `DB_PASSWORD` in your `.env` file to match your MySQL root password.

### "Can't connect to MySQL"
1. Open **Services** (Win+R → `services.msc`)
2. Find **MySQL80** (or similar) → Right-click → **Start**

### "Email not sending"
- Email is **optional**. The app works without it.
- Approval passwords are logged to the backend console.
- To enable: Get a [Gmail App Password](https://myaccount.google.com/apppasswords) and set `MAIL_USERNAME` / `MAIL_PASSWORD` in `.env`

### Changing machines / laptops
1. Install prerequisites (Java, Maven, Node.js, MySQL)
2. Clone the repo
3. Run `setup.bat` (it auto-detects everything)
4. Run `SETUP_AND_RUN.bat`

## 📊 API Endpoints

### Authentication
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/register` | Register new user |
| POST | `/api/auth/login` | User login |
| GET | `/api/auth/user/{id}` | Get user profile |
| PUT | `/api/auth/user/{id}` | Update user profile |

### Registration (Multi-Step)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/register/step1/personal-details` | Save personal info |
| POST | `/api/register/step2/address/{userId}` | Save address |
| POST | `/api/register/step3/work-experience/{userId}` | Save work exp |
| POST | `/api/register/step4/govt-proof/{userId}` | Save govt proof |
| GET | `/api/register/status/{userId}` | Check status |

### Admin
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/admin/dashboard-stats` | Dashboard stats |
| GET | `/api/admin/users` | List all users |
| GET | `/api/admin/pending-users` | List pending users |
| GET | `/api/admin/user/{id}` | User full details |
| PUT | `/api/admin/approve/{id}` | Approve user |
| DELETE | `/api/admin/reject/{id}` | Reject user |
| PUT | `/api/admin/activate/{id}` | Activate user |
| PUT | `/api/admin/deactivate/{id}` | Deactivate user |
