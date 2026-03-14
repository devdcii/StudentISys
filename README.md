# StudentISys
### Student Information Management System

> A Flutter mobile app connected to a PHP/MySQL REST API backend - full CRUD operations for managing student records including name, student ID, email, course, year level, and GPA. Runs over a local network using XAMPP.

---

## Overview

StudentISys is a mobile-first student information system designed for school administrators. The Flutter app connects to a local XAMPP server over WiFi by entering the server's IP address. Once connected, users can view, add, edit, search, and delete student records in real time. Student data is also cached locally using Hive so the list remains accessible even without a server connection.

---

## Features

- **Server Authentication** — Enter server IP address to connect; validates connection via `/authenticate.php`
- **Student List** — View all students with name, student ID, email, course, year level, and GPA badges
- **Search** — Real-time search by name, student ID, course, or email via floating search bar
- **Add Student** — Form dialog with validation (name, student ID, email, course, year level, GPA optional)
- **Edit Student** — Tap any student card to open and edit their full profile (partial updates supported)
- **Delete Student** — Swipe left on any card to delete with instant server sync
- **Offline Cache** — Student list cached locally with Hive; shows last known data if server is unreachable
- **Success / Error Dialogs** — Custom dialogs for all API responses
- **Back Confirmation** — Confirms before returning to the connection screen

---

## App Navigation Flow

```
App Launch
    │
    ▼
AuthenticationScreen
    ├── Enter server IP address (e.g., 192.168.1.5)
    ├── Tap [Connect to Server]
    │       ├── Calls GET /authenticate.php
    │       ├── ❌ Failed → Show error message (retry)
    │       └── ✅ Success → Navigate to StudentDashboard
    │
    ▼
StudentDashboard
    ├── Loads all students (GET /index.php)
    ├── Shows student count badge (top right)
    ├── [Floating Search Bar] → Filter by name / ID / course / email (local filter)
    ├── [✏️ Add Button] → Add Student Dialog
    │       ├── Fields: Name, Student ID, Email, Course, Year Level, GPA (optional)
    │       ├── Validates required fields
    │       ├── POST /add_student.php
    │       ├── ❌ Error → Show error dialog
    │       └── ✅ Success → Refresh list + show success dialog
    │
    ├── [Tap student card] → Edit Student Dialog (Student Profile)
    │       ├── Pre-filled fields: Name, Student ID, Email, Course, Year Level, GPA
    │       ├── POST /edit_student.php (partial update supported)
    │       ├── ❌ Error → Show error dialog
    │       └── ✅ Success → Refresh list + show success dialog
    │
    ├── [Swipe left on card] → Delete Student
    │       ├── POST /delete_student.php
    │       └── ✅ Success → Refresh list
    │
    └── [Back button] → Confirmation dialog → Return to AuthenticationScreen
```

---

## Screens

| Screen | Description |
|---|---|
| AuthenticationScreen | IP input + connect button with animated gear background |
| StudentDashboard | Student list with search, add, edit, delete actions |
| Add Student Dialog | Form for creating a new student record |
| Edit Student Dialog | Pre-filled form for updating an existing student |
| Success Dialog | Green checkmark confirmation after successful operations |
| Error Dialog | Red alert for validation or server errors |

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile App | Flutter 3.x (Dart) |
| UI Style | Material + Cupertino (mixed) |
| HTTP Client | http package |
| Local Cache | Hive / hive_flutter |
| Backend | PHP (REST API) |
| Database | MySQL (via XAMPP) |
| Local Server | XAMPP (Apache + MySQL) |
| Data Format | JSON |

---

## Backend (PHP/MySQL)

### Server Setup

1. Install **XAMPP** and start **Apache** and **MySQL**
2. Place backend files in:
   ```
   C:\xampp\htdocs\sqlacc\
   ```
3. Import the database (see Database section below)
4. Backend base URL: `http://<your-ip>/sqlacc`

### API Endpoints

Base URL: `http://<server-ip>/sqlacc`

| Endpoint | Method | Description |
|---|---|---|
| `/authenticate.php` | GET | Health check — returns `"Server Connected!"` |
| `/index.php` | GET | List all students (sorted by name) |
| `/index.php?search=term` | GET | Search by name, student\_id, or course |
| `/add_student.php` | POST | Add a new student record |
| `/edit_student.php` | POST | Update an existing student (partial update) |
| `/delete_student.php` | POST | Delete a student by ID |

### Request / Response Examples

**Add Student** — `POST /add_student.php`
```json
{
  "name": "Juan Dela Cruz",
  "student_id": "2024-00001",
  "email": "juan@email.com",
  "course": "BSCPE",
  "year_level": 3,
  "gpa": 1.75
}
```

**Edit Student** — `POST /edit_student.php`
```json
{
  "id": 1,
  "name": "Juan Dela Cruz",
  "gpa": 1.5
}
```

**Delete Student** — `POST /delete_student.php`
```json
{
  "id": 1
}
```

**Response Format**
```json
{
  "status": "success",
  "message": "Student added successfully!",
  "data": { ... }
}
```

### Database

**Database name:** `sqlacc`
**Table name:** `sqlinfo`

| Column | Type | Notes |
|---|---|---|
| id | INT | Auto-increment primary key |
| name | VARCHAR | Student full name |
| student\_id | VARCHAR | Unique student ID |
| email | VARCHAR | Email address |
| course | VARCHAR | e.g., BSCPE, BSIT |
| year\_level | INT | 1–5 |
| gpa | FLOAT | Optional, nullable |

**Database connection:** `config/dbcon.php` → `localhost` / `root` / no password / `sqlacc`

---

## Project Structure

```
student-isys/
├── app/                          # Flutter Mobile App
│   ├── lib/
│   │   ├── main.dart             # Full app (screens + API calls)
│   │   └── variables.dart        # Global server URL variable
│   └── pubspec.yaml
│
├── backend/                      # PHP REST API
│   ├── config/
│   │   └── dbcon.php             # Database connection (gitignored)
│   ├── authenticate.php          # Health check endpoint
│   ├── index.php                 # List / search students
│   ├── add_student.php           # Create student
│   ├── edit_student.php          # Update student
│   └── delete_student.php        # Delete student
│
├── .gitignore
└── README.md
```

---

## Mobile App Setup

### Prerequisites

- Flutter SDK 3.0+
- Dart SDK 3.0+
- Android Studio or VS Code

### Installation

```bash
cd app
flutter pub get
flutter run
```

### Connecting to the Server

1. Make sure phone and laptop are on the **same WiFi network**
2. Find your laptop's IP address:
   - Windows: open CMD → type `ipconfig` → look for **IPv4 Address**
   - Example: `192.168.1.5`
3. Start XAMPP → Start Apache and MySQL
4. Open app → Enter IP address (e.g., `192.168.1.5`) → Tap Connect

---

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  http: ^1.5.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```
