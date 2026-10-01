# 🏗️ Jomnes — Architecture & Technical Specifications

## 1. Architectural Overview: MVVM

The Flutter app uses one pattern throughout, **MVVM** (Model, View, ViewModel), with a repository layer underneath. Every screen follows it.

```text
lib/
├── views/              # Screens: layout and user input only
│   ├── auth/  student/  teacher/  settings/
├── viewmodels/         # One ChangeNotifier per screen: its state and its actions
│   ├── auth/  student/  teacher/  settings/
├── repositories/       # Every Supabase query and backend call
├── services/           # The clients repositories use (HTTP API, auth, notifications, file picker)
├── models/             # Plain data classes
├── widgets/            # Presentation widgets shared by several screens
├── config/             # AppConfig: values that differ between environments
├── constants/  theme/  # Static data and design tokens
├── app_providers.dart  # App-wide providers (repositories, notification view models)
├── route_guard.dart    # Which pages need a signed-in account
├── router.dart         # Routes; creates each screen's view model
└── main.dart           # Start-up: Supabase, Stripe, notifications
```

### Direction of dependencies

```text
views / widgets  →  view models  →  repositories  →  services
```

- A **view** reads state with `context.watch<XViewModel>()` and calls methods on the view model. It never talks to Supabase or the backend.
- A **view model** extends `BaseViewModel` (a `ChangeNotifier`), holds the screen's state, and gets its data from repositories passed to its constructor. It does not import views or widgets.
- A **repository** is the only place that queries Supabase or calls the backend API.
- **Models** are passed between all layers.

`test/architecture_test.dart` enforces these rules: it fails if a view or widget imports Supabase, `http`, a repository or a service, or if a view model reaches past the repositories.

### How the pieces are wired

- `app_providers.dart` provides every repository once, above the router.
- `router.dart` is the composition root. Each route wraps its screen in a `ChangeNotifierProvider` that builds the view model from those repositories, so a view model lives exactly as long as its page.
- The two notification view models are app-wide because the bell appears on several screens.

### Adding a screen

1. Put any new data access in a repository (`lib/repositories/`).
2. Create the view model in `lib/viewmodels/<area>/`, taking its repositories as constructor parameters.
3. Create the view in `lib/views/<area>/`.
4. Register the route in `router.dart` with `_screen(...)`.
5. Add a view model test in `test/viewmodels/` using the fakes in `test/helpers/fakes.dart`.

### Configuration

Service addresses and public keys live in `lib/config/app_config.dart` and can be overridden at build time:

```bash
flutter build apk --dart-define=API_BASE_URL=https://example.com/api
```

Only public identifiers belong there (Supabase URL and publishable key, Stripe publishable key, Facebook app id). Secret keys stay in the backend's environment.

---

## 2. Routing (`router.dart`, `route_guard.dart`)

The app uses **`go_router`**. Pages change without a transition animation (`_instant`), which keeps tab switches immediate.

`guardRoute()` in `route_guard.dart` decides where a navigation may go:

| Visitor | Can open |
| :--- | :--- |
| Not signed in | Splash, role selection, login, register and password reset screens |
| Guest | The student side (home, search, courses, mentor profiles, settings) |
| Signed in | Everything; the teacher area needs a signed-in account, never guest mode |

A signed-in user who opens the login or register screen is sent to their home. Which home a login opens (student or teacher) follows the account's stored role, not the screen that was used.

### Route groups

| Paths | Area |
| :--- | :--- |
| `/`, `/role-select`, `/login`, `/register`, `/forgot-password`, `/reset-password` | Sign-in |
| `/home`, `/search`, `/courses`, `/notifications`, `/mentor/:id`, `/course-listing/:subject` | Student |
| `/teacher-home`, `/teacher-students`, `/teacher-pc-request`, `/teacher-schedules`, `/teacher-upload`, `/teacher-settings`, `/teacher-notifications` | Teacher |
| `/settings`, `/edit-profile`, `/change-password`, `/privacy-security`, `/payment-methods` | Settings |

---

## 3. Design System & Theme Engine

### Color Tokens (`lib/theme/app_colors.dart`)
- **Dark Backgrounds**:
  - `darkBg` (`#0A0A12`): Main dark background for header and primary views.
  - `darkCard` (`#16161E`): Dark elevated surfaces.
  - `darkInput` (`#1C1C26`): Form input containers.
  - `darkBorder` (`#2D2D3A`): Subtle dark dividers.
- **Light Surfaces**:
  - `lightBg` (`#F2F2F5`): Contrast body background.
  - `white` / `cardWhite` (`#FFFFFF`): Main card background.
- **Brand Colors**:
  - `accentBlue` (`#2563EB`): Primary call-to-action buttons.
  - `liveRed` (`#EF4444`): Live badges and real-time status dots.
  - `featuredOrange` (`#E8820C`), `featuredTeal` (`#0C7B8C`), `featuredGreen` (`#0C8C5A`): Course cards.

### Typography Engine (`lib/theme/app_theme.dart`)
Configured globally using Google Fonts (`Inter`):
- `TextTheme.titleLarge`: `fontSize: 22, fontWeight: FontWeight.w700`
- `TextTheme.titleMedium`: `fontSize: 16, fontWeight: FontWeight.w600`
- `TextTheme.bodyMedium`: `fontSize: 14, fontWeight: FontWeight.w400`
- `TextTheme.labelSmall`: `fontSize: 11, fontWeight: FontWeight.w500`

---

## 4. Domain Data Layer (`lib/models/mentor.dart`)

### Domain Entities
1. **`Mentor`**:
   - `id: int`
   - `name: String`
   - `subject: String`
   - `experience: String`
   - `timeSlot: String`
   - `avatarUrl: String`
   - `rating: double`
   - `students: int`, `classes: int`, `followers: int`
   - `bookingPrice: double`
   - `bio: String`
   - `courses: List<Course>`

2. **`Course`**:
   - `id: int`
   - `title: String`
   - `description: String`
   - `rating: double`
   - `durationHours: int`
   - `isFavorited: bool`
   - `isLive: bool`
   - `minutesRemaining: int?`
   - `progress: double?`
   - `cardColor: String`

3. **`FeaturedCourse`**:
   - `id: int`
   - `mentorName: String`
   - `subject: String`
   - `cardColor: String`
   - `imageUrl: String`

---

## 5. UI Widget Architecture

### Key Presentation Widgets
* **`BottomNavBar`**: Persistent bottom navigation bar supporting 5 tabs (Home, Search, Courses, Profile, Settings) with active indicator pills and smooth route synchronization.
* **`MentorCard`**: Displays mentor avatar, name, subject badge, rating star, hourly price, and quick-action navigation.
* **`CourseCard`**: Supports both vertical and horizontal layouts, live badges, and linear progress indicators.
* **`FeaturedCourseCard`**: Custom curved card with high-res graphical asset and mentor attribution.
* **`AuthWidgets`**: Reusable text fields with focus transitions, password visibility icons, and social OAuth action buttons.
