# Jomnes

Jomnes is a cross-platform Flutter application that connects students with subject mentors for one-on-one tutoring. Students can browse courses and mentors, book sessions, pay for courses, and track their progress, while mentors (teachers) have a separate portal to manage students, schedules, and course uploads. The app is backed by Supabase for authentication, database, and storage, and by a companion Node.js/Express API for server-side operations such as payments, course management, bookings, and reviews.

## Tech Stack

**Mobile app (Flutter)**
- Flutter / Dart, targeting Android, iOS, Web, Windows, macOS, and Linux
- `go_router` for declarative routing and navigation guards (auth/guest/role-based redirects)
- `supabase_flutter` for authentication (email/password, Google, Facebook) and data access
- `flutter_stripe` for in-app payments
- `google_fonts`, `flutter_animate` for styling and micro-animations
- `flutter_local_notifications`, `add_2_calendar`, `permission_handler`, `image_picker`, `file_picker`, `audioplayers`, `shared_preferences` for supporting device features

**Backend (`backend/`)**
- Node.js with Express 5
- `@supabase/supabase-js` for server-side Supabase access (auth sync, database operations)
- `stripe` for payment intent creation and verification
- `helmet`, `cors`, and `express-rate-limit` for basic API hardening
- `multer` for file uploads

## Project Structure

```text
MOBILE_APPLICATION/
├── lib/
│   ├── constants/        # Static data (course categories, mock data used as fallback)
│   ├── models/            # Mentor, user profile, and notification models
│   ├── screens/           # Student and teacher screens (auth, home, courses, settings, etc.)
│   ├── services/          # API client, auth, payments, notifications, file picking
│   ├── theme/             # Colors, text styles, and ThemeData
│   ├── widgets/           # Shared and reusable UI components
│   ├── main.dart          # App entry point, Supabase/Stripe initialization
│   └── router.dart        # GoRouter configuration, auth/role-based redirects
├── backend/
│   └── src/
│       ├── controllers/   # Auth, booking, course, payment, review, user logic
│       ├── routes/        # Express route definitions
│       ├── middleware/    # Auth middleware
│       ├── services/      # Auth service helpers
│       ├── config/        # Supabase client configuration
│       └── app.js, server.js
├── docs/                  # Architecture notes, project state, and backend integration plan
├── assets/                # Images used by the app
└── pubspec.yaml           # Flutter project configuration
```

## Features

- Student and mentor (teacher) authentication with role selection, including Google and Facebook sign-in
- Home, search, and course listing screens for discovering mentors and courses
- Mentor profile pages with booking
- Course purchase flow with Stripe payments
- In-app notifications with unread badge count
- Student-side settings: profile editing, password change, privacy/security, payment methods
- Teacher portal: dashboard, student list, schedules, course upload, and settings
- Backend REST API for authentication sync, bookings, reviews, courses, and payments, backed by Supabase Postgres

## Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart SDK `^3.12.2` per `pubspec.yaml`)
- [Node.js](https://nodejs.org/) (for the backend)
- A Supabase project (URL, anon/publishable key, and service role key for the backend)
- A Stripe account (test keys are sufficient for local development)

### 1. Install Flutter dependencies

```bash
flutter pub get
```

### 2. Configure the backend environment

Copy the example environment file and fill in your own Supabase and Stripe values:

```bash
cp .env.example .env
```

The backend (`backend/src/server.js`) loads this `.env` file from the project root. Required variables include `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY` / `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`, `PORT`, and `CORS_ORIGINS`.

Note: the Flutter app itself does not read `.env` — its Supabase URL/key and Stripe publishable key are currently set directly in `lib/main.dart`. Update them there if you point the app at a different Supabase project.

### 3. Run the backend

```bash
cd backend
npm install
npm start        # or: npm run dev (nodemon, auto-restart)
```

The API listens on the port set by `PORT` in `.env` (defaults to `5005`) and exposes a health check at `GET /api/health`.

### 4. Run the Flutter app

With the backend running in a separate terminal:

```bash
flutter devices        # list available devices/emulators
flutter run             # run on the default/connected device
flutter run -d chrome   # run in a browser
```

Useful commands:

| Command | Description |
| --- | --- |
| `flutter pub get` | Install/update Flutter dependencies |
| `flutter run` | Run on the default connected device |
| `flutter run -d chrome` | Run in Chrome |
| `flutter clean` | Clear the build cache |
| `flutter build apk` | Build a release APK |
| `flutter analyze` | Run static analysis |

## Additional Documentation

- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) - routing and widget architecture notes
- [docs/PROJECT_STATE.md](docs/PROJECT_STATE.md) - current status of screens and features
- [docs/BACKEND_INTEGRATION_PLAN.md](docs/BACKEND_INTEGRATION_PLAN.md) - Supabase schema and integration notes
