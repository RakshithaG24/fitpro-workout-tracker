# 🏋️‍♂️ FitPro - Fitness Tracking App

A minimal, dark-themed fitness tracking app built with Flutter. Track your workouts, monitor muscle group progress, and stay on top of your fitness journey.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

## ✨ Features

### 🏋️‍♂️ **Workout Management**
- **Workout Dashboard**: View all your scheduled workouts
- **Workout Details**: See exercises, sets, reps, and weights
- **Live Workout Tracking**: Timer, exercise completion, and progress tracking
- **Muscle Group Monitoring**: Track growth and progress for different muscle groups

### 📊 **Progress Tracking**
- **Body Weight Tracking**: Monitor weight changes over time
- **Volume Lifted**: Track total weight lifted in sessions
- **Activity Calendar**: Visual representation of workout frequency
- **Progress Indicators**: Visual progress bars for muscle groups

### 🎨 **Minimal UI/UX**
- **Dark Theme**: Clean, near-black surfaces with a single accent color
- **Intuitive Navigation**: Bottom navigation with 3 main sections
- **Responsive Design**: Layouts adapt from phone to tablet/desktop widths
- **To the Point**: No clutter, no filler screens

### 🏗️ **Technical Features**
- **State Management**: Provider pattern for efficient state handling
- **Clean Architecture**: Well-organized code structure
- **Comprehensive Testing**: Unit and widget tests included
- **Cross-Platform**: Works on Android, iOS, Web, Windows, and macOS

### Main Dashboard
- Workout cards with scheduled days
- Body weight and volume tracking
- Activity calendar visualization

### Workout Detail
- Exercise list with sets and reps
- Muscle group progress indicators
- Start workout functionality

### Workout in Progress
- Live timer
- Exercise completion tracking

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code
- Git


## 🏗️ Project Structure

```
lib/
├── main.dart                    # App entry point
├── theme/
│   └── app_theme.dart          # Dark theme configuration
├── models/
│   └── workout.dart            # Data models
├── providers/
│   └── workout_provider.dart   # State management
├── screens/
│   ├── main_navigation_screen.dart
│   ├── workouts_screen.dart
│   ├── workout_detail_screen.dart
│   ├── workout_in_progress_screen.dart
│   ├── calendar_screen.dart
│   └── stats_screen.dart
└── widgets/
    ├── workout_card.dart
    ├── stats_card.dart
    ├── calendar_card.dart
    ├── muscle_group_card.dart
    ├── exercise_list_item.dart
    ├── exercise_progress_item.dart
    └── add_workout_card.dart
```

## 🧪 Testing

Run the test suite:

```bash
# Run all tests
flutter test

# Run specific test files
flutter test test/widget_test.dart
flutter test test/models/workout_test.dart
flutter test test/providers/workout_provider_test.dart
```

## 📦 Dependencies

- **provider**: State management
- **flutter_animate**: Animations
- **intl**: Date and time utilities
- **flutter_launcher_icons**: App icon generation

## 🎯 Roadmap

- [ ] User authentication
- [ ] Data persistence (SQLite/Firebase)
- [ ] Workout templates
- [ ] Progress charts and analytics
- [ ] Social features
- [ ] Nutrition tracking
- [ ] Wearable device integration


## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

🏋️‍♂️ **Happy Training!**
