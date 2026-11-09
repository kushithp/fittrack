<div align="center">

# FitTrack

**A comprehensive, local-first personal fitness, workout, and wellness tracker built with Flutter.**

[![Flutter](https://img.shields.io/badge/Flutter-3.47.5-02569B?logo=flutter)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.13.4-0175C2?logo=dart)](https://dart.dev/)
[![Tests](https://img.shields.io/badge/Tests-40%20Passing-brightgreen?logo=checkmarx)](test/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Track your gym routines, cardio habits, nutrition, sleep, body weight, and daily wellness notes — all in a single offline-first application with interactive charts and automated record tracking.

</div>

---

## 🌟 Key Features

### 1. 🏋️ Workout Logging & Custom Routines
- **Reusable Exercise Catalog** across all muscle groups (Chest, Back, Legs, Shoulders, Arms, Core, Cardio).
- **Pre-Built & Custom Routines**: Jumpstart workouts with 1 tap using pre-built templates (*Chest + Triceps Hypertrophy, Back + Biceps Pull Power, Legs & Core Strength, Full Body Foundational*) or design your own.
- **In-Workout Rest Timer**: Persistent countdown timer with presets (30s, 60s, 90s, 120s, 180s), progress ring, +30s extension, and pause/resume controls.
- **Live Set Logging**: Track weight (kg) and reps set-by-set with in-flight completion toggles.
- **Automated Personal Records (PRs)**: Automatically detects and records all-time best weights and cardio milestones.

### 2. 🏃 Activity & Habit Tracking
- Create custom daily habits and activities (Endurance, Strength, Nutrition, Wellness, Sleep).
- Daily checklist toggles and numeric targets (steps, km, minutes, calories, reps).
- Cardio PR detection (highest daily step counts and longest distance runs).

### 3. 🎯 Goals & Milestones
- Set distance, duration, frequency, and weight goals.
- Live visual progress bars, percentage indicators, and deadline countdowns.
- Spotlight banner on Dashboard for fast progress reviews.

### 4. 💧 Body & Wellness Metrics
- **Body Weight Tracker**: Historical logs with trend analysis and difference calculations.
- **Hydration Logger**: 1-tap quick logging (+250ml / +500ml) with daily target gauges.
- **Sleep Quality Tracker**: Sleep duration, bedtime, wake time, and 1–5 star quality ratings.
- **Daily Reflection Notes**: Daily ratings for Energy, Mood, and Recovery (1–10) with searchable tags.

### 5. 📊 Interactive Analytics & Heatmap
- **Progress Charts (`fl_chart`)**: Multi-metric timeline charts for volume, consistency, and metrics.
- **90-Day Contribution Heatmap**: GitHub-style activity grid visualizing daily workout frequency.
- **Configurable Daily Health Score**: Weighted scoring formula dynamically computed from daily activities, workouts, water, and sleep.
- **Streak Tracker**: Tracks current and best streaks with weekly and monthly consistency percentages.

### 6. ⏰ Reminders & Scheduled Notifications
- Scheduled local notifications (`flutter_local_notifications`).
- Custom frequencies: One-time, Daily, or specific days of the week.
- Per-reminder active toggle and vibration/sound support.

### 7. 💾 Data Safety, Export & Full Backup
- **CSV Data Export**: Export Activity Logs, Workout Sessions, and Weight Entries to CSV files.
- **Full JSON Backup & Restore**: Round-trip backup of all 12+ app entities into a single versioned JSON payload.
- **Local-First Architecture**: High privacy, fast offline performance using `SharedPreferences` and JSON serialization.

---

## 🛠️ Tech Stack

| Technology | Purpose |
| :--- | :--- |
| [Flutter](https://flutter.dev/) | Cross-platform UI toolkit |
| [Dart](https://dart.dev/) | Strongly typed application language |
| [Provider](https://pub.dev/packages/provider) | Clean reactive state management |
| [SharedPreferences](https://pub.dev/packages/shared_preferences) | Fast offline key-value storage |
| [fl_chart](https://pub.dev/packages/fl_chart) | Interactive charts and analytics |
| [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) | Local push reminders |
| [csv](https://pub.dev/packages/csv) | CSV data generation |
| [path_provider](https://pub.dev/packages/path_provider) | Document directory file resolution |
| [Google Fonts](https://pub.dev/packages/google_fonts) | Clean modern typography |
| [intl](https://pub.dev/packages/intl) | Date and metric formatting |
| [UUID](https://pub.dev/packages/uuid) | Unique record ID generation |

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`^3.13.4` / Flutter 3.x)
- Dart SDK (included with Flutter)
- Windows, macOS, Linux, Android, or iOS development toolchain

Verify setup:
```bash
flutter doctor
```

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/kushithp/fittrack.git
   cd fittrack
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   # Desktop (Windows)
   flutter run -d windows

   # Chrome (Web)
   flutter run -d chrome

   # Mobile (Android / iOS)
   flutter run
   ```

---

## 🧪 Testing

FitTrack includes a comprehensive automated test suite covering models, repositories, providers, and UI widgets:

```bash
flutter test
```

**Status**: 40 tests passing across all 7 architectural stages.

---

## 📁 Project Structure

```text
lib/
├── core/
│   ├── constants/       # App constants and configuration
│   ├── theme/           # Obsidian Dark and Clean Light themes
│   └── utils/           # Formatting and date helpers
├── data/
│   ├── models/          # 12+ Domain models (Activity, Goal, Workout, Template, Note, etc.)
│   ├── repositories/    # Clean architecture repository layer
│   └── services/        # Database, Notification, Export, and Backup services
├── navigation/          # Adaptive navigation shell
├── providers/           # Provider state management controllers
├── screens/             # Dashboard, Workout, Tracking, Analytics, Goals, Notes, Settings
└── widgets/             # Reusable UI widgets and cards
```

---

## 📄 License

This project is licensed under the [MIT License](LICENSE) — see the [LICENSE](LICENSE) file for details.

---

<div align="center">

Made with ❤️ by [Kushith P](https://github.com/kushithp) using Flutter

</div>
