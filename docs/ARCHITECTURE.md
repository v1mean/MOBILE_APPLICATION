# 🏗️ Jomnes — Architecture & Technical Specifications

## 1. Architectural Overview

The Jomnes mobile application follows a modular, feature-oriented Flutter structure designed for high maintainability, declarative navigation, and smooth user interactions.

```text
lib/
├── data/          # Mock data sets and local repositories
├── models/        # Plain Old Dart Objects (PODO) for domain entities
├── screens/       # Top-level screen widgets mapped directly to routes
├── theme/         # Design tokens, color palettes, and global ThemeData
├── widgets/       # Modular, reusable presentation widgets
├── main.dart      # Application bootstrapper and SystemUI configuration
└── router.dart    # Declarative GoRouter routing definitions
```

---

## 2. Declarative Routing Architecture (`router.dart`)

The app leverages **`go_router` (v14.6.3)** to manage deep-linkable URLs and screen transitions:

### Custom Slide & Fade Transition
All routes utilize a unified ease-out cubic slide transition:
```dart
CustomTransitionPage<void> _slide(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
  );
}
```

### Route Registry

| Path | Screen Widget | Description |
| :--- | :--- | :--- |
| `/` | `SplashScreen` | App entry point and onboarding animation |
| `/login` | `LoginScreen` | User authentication & social OAuth links |
| `/register` | `RegisterScreen` | New student account registration |
| `/home` | `HomeScreen` | Featured courses & top mentors dashboard |
| `/search` | `SearchScreen` | Category chips & mentor keyword search |
| `/courses` | `MyCoursesScreen` | Course progress and live course alerts |
| `/profile` | `UserProfileScreen` | Student profile stats and achievements |
| `/settings` | `SettingsScreen` | App preferences, themes, security & logout |
| `/mentor/:id` | `MentorProfileScreen` | Dynamic mentor profile matching route parameter |

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
