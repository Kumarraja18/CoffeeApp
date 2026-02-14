# ✅ Brew & Co — Plug-and-Play Status

## 🎉 Status: READY (Plug & Play)

This project is configured to work on **any Windows machine** with MySQL installed.

---

## 🚀 One-Click Start

Double-click `SETUP_AND_RUN.bat` — it does everything automatically.

### What it does:
1. ✅ Checks Java, Maven, Node.js, MySQL
2. ✅ Starts MySQL service (auto-detects service name)
3. ✅ Creates `brewco_db` database (if not exists)
4. ✅ Installs frontend dependencies (if needed)
5. ✅ Starts Backend on port 8080
6. ✅ Starts Frontend on port 5173
7. ✅ Creates default admin user on first boot

---

## 🌐 Access URLs

- **Frontend (React)**: http://localhost:5173
- **Backend API**: http://localhost:8080

---

## 🔐 Default Admin

| Field | Value |
|-------|-------|
| Email | `admin@brewco.com` |
| Password | `admin123` |

*(Customize in `.env` file)*

---

## 🔄 How Registration & Approval Works

1. **User registers** via multi-step form (personal details, address, work exp, govt proof)
2. User status = **PENDING** (isActive = false)
3. **Admin logs in** → sees pending users in dashboard
4. Admin clicks **Approve** → system generates random password
5. **Email sent** to user with their login credentials
6. User can now **login** with the emailed password

---

## 📧 Email Configuration (Optional)

Email works automatically if configured in `.env`:
```
MAIL_USERNAME=your_email@gmail.com
MAIL_PASSWORD=your_gmail_app_password
```

**Without email**: The app still works! Approval passwords are printed to the backend console log.

---

## 🔧 Plug-and-Play Features

| Feature | How It Works |
|---------|-------------|
| **Database auto-creation** | `createDatabaseIfNotExist=true` in JDBC URL |
| **Table auto-creation** | Hibernate `ddl-auto=update` |
| **Admin auto-creation** | `DataInitializer.java` on first boot |
| **No hardcoded passwords** | Everything from `.env` with safe defaults |
| **MySQL service auto-start** | Scripts try MySQL80, MySQL, MySQL57, etc. |
| **Works without .env** | Smart defaults: root user, empty password |
| **Email optional** | `@Autowired(required = false)` for mail sender |
| **Existing data import** | `brewco_db.sql` available for MySQL Workbench import |

---

## 📂 Scripts

| Script | Purpose |
|--------|---------|
| `SETUP_AND_RUN.bat` | One-click setup + run |
| `setup.bat` | Interactive MySQL setup (finds MySQL, prompts for password) |
| `setup-mysql.bat` | Quick DB setup using .env credentials |
| `start-all.bat` | Start both servers |
| `backend/start-backend.bat` | Start backend only |

---

## 🗄️ Database Details

- **Engine**: MySQL 8.x
- **Database**: brewco_db (auto-created)
- **Tables**: users, addresses, govt_proof, work_experience

### Import via MySQL Workbench
1. Open MySQL Workbench
2. Connect to localhost:3306
3. File → Open SQL Script → `backend/src/main/resources/brewco_db.sql`
4. Execute

---

## 🎊 Your project is plug-and-play! Works on any machine! 🎊
