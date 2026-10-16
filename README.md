<div align="center">

# FitTrack

**A personal fitness and wellness tracker built with Flutter.**

Track your workouts, daily activities, goals, and wellness habits — then review your progress in one place.

</div>

---

## Overview

FitTrack is a Flutter application for organizing everyday fitness and wellness tracking. It brings activity logging, workout sessions, personal goals, daily notes, and health-related entries together in a single app. Progress and trends can be reviewed through the analytics screens, while light and dark themes let you choose your preferred appearance.

> **Current integration note:** Health-platform integration (such as Apple Health / HealthKit or Google Health Connect) is not connected yet. The current implementation uses manual tracking.

## Features

- **Dashboard** — review daily progress and key stats.
- **Activity tracking** — create and manage activities and log them by date.
- **Goals** — set personal goals and monitor progress.
- **Workout logging** — manage exercises and workout sessions, including sets.
- **Wellness tracking** — record water intake, sleep, and weight.
- **Personal records** — keep track of fitness milestones.
- **Analytics** — view progress charts, daily scores, streaks, and activity history.
- **Daily notes** — add notes to reflect on your day.
- **Theme preferences** — switch between light and dark appearance.
- **Local persistence** — app data is stored on the device using `SharedPreferences` and JSON serialization.

## Tech stack

| Technology | Purpose |
| --- | --- |
| [Flutter](https://flutter.dev/) | Cross-platform app UI |
| [Dart](https://dart.dev/) | Application language |
| [Provider](https://pub.dev/packages/provider) | State management |
| [SharedPreferences](https://pub.dev/packages/shared_preferences) | Local key-value persistence |
| [fl_chart](https://pub.dev/packages/fl_chart) | Charts and analytics |
| [Google Fonts](https://pub.dev/packages/google_fonts) | Typography |
| [intl](https://pub.dev/packages/intl) | Date and number formatting |
| [UUID](https://pub.dev/packages/uuid) | Unique identifiers |

## Getting started

### Prerequisites

Install the following before running the app:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) compatible with the SDK constraint in `pubspec.yaml` (`^3.13.4`).
- Dart SDK (included with Flutter).
- An editor such as [Visual Studio Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio).
- An emulator/simulator or a connected device.

Verify your setup:

```bash
flutter doctor
```

### Installation

1. Clone the repository:

   ```bash
   git clone <YOUR_GITHUB_REPOSITORY_URL>
   ```

2. Move into the project directory:

   ```bash
   cd fittrack
   ```

   If your downloaded/cloned folder has a different name, use that folder name instead.

3. Install dependencies:

   ```bash
   flutter pub get
   ```

4. Run the app on a connected device or running emulator:

   ```bash
   flutter run
   ```

### Useful development commands

```bash
# Check Dart/Flutter code for issues
flutter analyze

# Run automated tests
flutter test

# Build an Android APK
flutter build apk

# Build an Android App Bundle
flutter build appbundle

# Build for iOS (requires macOS and Xcode)
flutter build ios
```

## Project structure

The code is organized by responsibility:

```text
lib/
├── core/
│   ├── constants/       # Shared app constants
│   ├── theme/           # Theme configuration
│   └── utils/           # Formatting and date helpers
├── data/
│   ├── models/          # Data models
│   ├── repositories/    # Data access and domain operations
│   └── services/        # Local storage and service abstractions
├── navigation/          # Main app navigation
├── providers/           # Provider state management
├── screens/             # Dashboard, tracking, goals, workouts, analytics, etc.
└── widgets/             # Shared UI components
```

## Data and privacy

FitTrack currently persists its app data locally using `SharedPreferences`; the database service serializes records as JSON. The project does not currently implement a cloud account or cloud synchronization flow. The repository also contains a sync-service abstraction, but do not assume remote sync is available unless it is implemented and configured.

Because data is stored locally, uninstalling the app or clearing its storage may remove saved information. Back up important data before doing so.

## Screenshots

Screenshots help visitors understand the app quickly. Add images of the actual app UI to a folder such as `screenshots/`, then update this section. For example:

```markdown
![FitTrack dashboard](screenshots/dashboard.png)
```

<!-- Add verified app screenshots here when available. -->

## Roadmap

Potential next steps for the project:

- Connect to supported health platforms where appropriate.
- Add automated tests for repositories, providers, and core user flows.
- Add screenshots or a short demo to the repository.
- Document backup/export and synchronization behavior if those features are introduced.

## Contributing

Contributions and suggestions are welcome.

1. Fork the repository.
2. Create a branch for your change: `git checkout -b feat/your-change`.
3. Make your changes and run `flutter analyze` and `flutter test`.
4. Commit your work and open a pull request describing the change.

For larger changes, open an issue first to discuss the proposal.

## License

No license file is currently included. Unless a license is added, the project should not be assumed to be open source or freely reusable. Add a `LICENSE` file with the license you choose before inviting reuse.

---

<div align="center">

Made with Flutter 💙

</div>
