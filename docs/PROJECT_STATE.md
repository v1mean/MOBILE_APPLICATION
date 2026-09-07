# 📊 Jomnes — Current Project State & Screen Audit

*Last Updated: September 2026*  
*Repository Status: Clean working tree on `main` branch*

---

## 1. Executive Summary
The **Jomnes** Flutter codebase represents a fully realized, pixel-perfect frontend implementation based on the Figma UI/UX design specifications. All 9 core application screens, custom navigation, animations, and reusable widget components are functional with structured mock data.

---

## 2. Screen-by-Screen Implementation Audit

### 🌟 1. Splash / Onboarding Screen (`lib/screens/splash_screen.dart`)
- **Status**: ✅ 100% Complete
- **Components**:
  - Full-screen original hero illustration background (`assets/images/hero_bg.png`).
  - Dark gradient overlay for text legibility.
  - Animated title: *"Jomnes"* with subtitle *"Learn from the best mentors"*.
  - Primary call-to-action button *"Get Started"* linking to `/login`.
  - Micro-animation entrance via `flutter_animate`.

---

### 🔐 2. Authentication Screens (`lib/screens/login_screen.dart` & `register_screen.dart`)
- **Status**: ✅ 100% Complete
- **Components**:
  - Hero background illustration header.
  - Tab Switcher (`Sign In` vs `Sign Up`) with animated underline/pill indicator.
  - Form Fields: Email, Password (with toggleable visibility icon), Name & Confirm Password for registration.
  - *"Forgot Password?"* interactive text.
  - Primary Submit Button with press state and validation handling.
  - Social Login Section: Google, Apple, and Facebook branded buttons.
  - Route navigation directly to `/home` upon submission.

---

### 🏠 3. Home Screen (`lib/screens/home_screen.dart`)
- **Status**: ✅ 100% Complete
- **Components**:
  - **Dark Header**: Student avatar (`jessica_avatar.png`), name (*"Jessica Carl"*), status (*"Student"*), and notification bell icon.
  - **Search Trigger**: Interactive search field that routes directly to `/search`.
  - **Featured Courses Section**:
    - Horizontal scrollable card carousel.
    - Card assets: `featured_math.png`, `featured_geography.png`, `featured_chemistry.png`.
    - Subject tags & mentor attribution.
  - **Top Mentors Section**:
    - List of available mentors with live online status indicators.
    - Star ratings (`4.8`, `4.9`), student counts, hourly booking rates (`$300/hr`).
    - Direct tap navigation to `/mentor/:id`.
  - **Bottom Navigation Bar**: Synchronized active state on Tab 0 (Home).

---

### 🔍 4. Search & Discovery Screen (`lib/screens/search_screen.dart`)
- **Status**: ✅ 100% Complete
- **Components**:
  - Search input with clear button and real-time query filtering.
  - Horizontal category chips: `All`, `Math`, `Science`, `Language`, `Physics`, `Geography`.
  - Filtered mentor results cards showing subject tags, experience, and hourly pricing.
  - Empty state when no mentors match search query.

---

### 👩‍🏫 5. Mentor Profile Screen (`lib/screens/mentor_profile_screen.dart`)
- **Status**: ✅ 100% Complete
- **Components**:
  - Dynamic route parameter extraction (`/mentor/:id`).
  - Top navigation bar with Back button and favorite heart icon.
  - Large mentor portrait (`mentor_channara.png` / `mentor_thavy.png`).
  - Mentor stats row: Rating (⭐ 4.8), Students (`120k+`), Classes (`2.3M+`), Followers (`5.3M+`).
  - Subject chips and hourly booking rate badge (`$300/hr`).
  - Tab switcher: **About** (Bio, teaching experience) vs **Reviews** (Student testimonials & star breakdown).
  - Sticky bottom CTA bar: **"Book Session"** button.

---

### 📚 6. My Courses Screen (`lib/screens/my_courses_screen.dart`)
- **Status**: ✅ 100% Complete
- **Components**:
  - Tab filter: `Ongoing` vs `Completed`.
  - Active course cards with custom background colors (`pinkCard`, `blueCard`).
  - Live session indicator (`Live Now` with pulsing dot).
  - Time remaining badges (`30 mins remaining`).
  - Linear learning progress bar with percentage readout (`35% completed`).
  - Mentor attribution and lesson counts.

---

### 👤 7. User Profile Screen (`lib/screens/user_profile_screen.dart`)
- **Status**: ✅ 100% Complete
- **Components**:
  - Profile header with student avatar (`jessica_large.png`), email, and status.
  - Learning statistics metrics:
    - `12` Courses Enrolled
    - `48` Hours Learned
    - `4` Certificates Earned
  - Menu list items: *Edit Profile*, *Payment Methods*, *Certificates*, *Saved Mentors*, *Help & Support*.

---

### ⚙️ 8. Settings Screen (`lib/screens/settings_screen.dart`)
- **Status**: ✅ 100% Complete
- **Components**:
  - Account Settings section (Profile, Security, Email preferences).
  - Notifications toggle (Push notifications, Email alerts, SMS reminders).
  - Appearance section (Theme mode selector: System, Dark, Light).
  - Language selector (English, Khmer, etc.).
  - Privacy policy and Terms of service links.
  - **Log Out** button triggering confirmation dialog.

---

## 3. Asset Registry

| Asset Path | Size | Description |
| :--- | :--- | :--- |
| `assets/images/hero_bg.png` | 444 KB | High-res background illustration for splash and auth |
| `assets/images/featured_math.png` | 34 KB | Graphical card asset for Mathematics course |
| `assets/images/featured_geography.png` | 35 KB | Graphical card asset for Geography course |
| `assets/images/featured_chemistry.png` | 35 KB | Graphical card asset for Chemistry course |
| `assets/images/jessica_avatar.png` | 3.7 KB | Small student avatar used in top header |
| `assets/images/jessica_large.png` | 16 KB | High-res student portrait for User Profile |
| `assets/images/mentor_channara.png` | 29 KB | Portrait avatar for Ms. Sok ChanNara |
| `assets/images/mentor_thavy.png` | 27 KB | Portrait avatar for Pro. Sok Thavy |

---

## 4. Current Limitations & Next Development Phase
1. **Mock Data**: Data is currently served in-memory from [`lib/data/mock_data.dart`](file:///c:/Users/Thyrex%202.0/Desktop/MOBILE%20APPLICATION/MOBILE_APPLICATION/lib/data/mock_data.dart).
2. **Backend Services**: Ready to be connected to Supabase for PostgreSQL persistence, JWT auth, and live updates.
3. **Interactive Booking**: Time-slot picker modal to be connected to backend booking API.
