# Quran Learning App (MAD Project 1)

A feature-rich Flutter application designed for online Quran education, interactive learning, assignment tracking, and student-teacher collaboration.

## 📖 Overview
The **Quran Learning App** provides a unified mobile platform tailored for both Quran instructors (Teachers) and learners (Students). The app features an intuitive role-based workflow, interactive lessons, progress tracking, and custom animated UI components for an engaging user experience.

## ✨ Core Features
- **Dual-Role Authentication**: Dedicated portals for Teachers and Students with persistent session management.
- **Course & Lesson Management**: Structured Islamic and Quranic studies modules.
- **Interactive Quizzes & Assessments**: Real-time feedback, grading, and score calculation.
- **Assignment Submissions**: Submission tracking with teacher review and remarks.
- **Fluid Animations**: Custom `AnimatedContainer` and `AnimatedCrossFade` transitions for modern micro-interactions.

## 🏗️ Architecture & Tech Stack
- **Framework**: Flutter 3.x (Dart 3.x)
- **Local Storage**: `shared_preferences` for offline data persistence
- **State Management**: Reactive StatefulWidget architecture with modular Store pattern
- **Design System**: Emerald Green & Islamic Gold aesthetic with Material 3 styling

## 🎨 Interactive Animations Showcase
The app uses customized implicit animation widgets to provide tactile feedback and elevate user engagement:
- **`Tap` Animation**: An interactive container wrapper utilizing `AnimatedScale` for subtle tactile bounce and smooth recovery on user interaction.
- **`AuthCrossFade`**: Smooth `AnimatedCrossFade` transitions switching seamlessly between Login and Sign Up screens without page reloads.
- **`DoneCrossFade`**: Real-time lecture completion indicator transforming from an action button into a completed status chip with custom easing curves.
- **`BookCover`**: Dynamic 3D-styled book covers with gradients reflecting course progress and status.

## 👥 Role Workflows & Modules

### 🎓 Student Portal
1. **Explore Courses**: Browse enrolled Quranic recitation, Tajweed, and Tafseer modules.
2. **Interactive Lessons**: Read notes, listen/watch lectures, and mark lessons as complete with instant feedback.
3. **Tasks & Submissions**: View assigned coursework, upload responses, and track real-time grading and teacher remarks.
4. **Performance Record**: Track attendance rate, average score, and cumulative lectures completed.

### 🧑‍🏫 Teacher Management Portal
1. **Course Creation & Updates**: Add new lessons, lectures, and resources for students.
2. **Assignment Publishing**: Distribute tasks with deadlines and point allocations.
3. **Submissions Review**: Review submitted assignments, grade out of 100, and provide constructive feedback.
4. **Student Directory**: Monitor roster of enrolled students and overall engagement.

## 📁 Repository Structure
```text
lib/
├── main.dart                      # Core app initialization, routing, screens & reactive store
├── animated_container_widget.dart # Custom AnimatedContainer & AnimatedScale components
└── animated_cross_fade_widget.dart# Implicit AnimatedCrossFade transitions for forms & chips
android/                           # Android native configuration & Gradle scripts
ios/                               # iOS project files & AppFramework configurations
web/                               # Progressive Web App assets and HTML entry
test/                              # Flutter unit & widget integration tests
```

## 🚀 Getting Started & Installation

### Prerequisites
- Flutter SDK (`^3.5.0` or later)
- Dart SDK (`^3.5.0` or later)
- Android Studio / VS Code with Flutter extension
- An Android Device / Emulator or Chrome browser

### Installation Steps
1. **Clone the repository:**
   ```bash
   git clone https://github.com/45804-maker/MAD-Project-1.git
   cd MAD-Project-1
   ```
2. **Install project dependencies:**
   ```bash
   flutter pub get
   ```
3. **Run the application:**
   ```bash
   flutter run
   ```
4. **Execute tests:**
   ```bash
   flutter test
   ```

## 📋 Release Changelog & Development Milestones

### Version 1.0.0 (October 2026)
- **Oct 11, 2026**: Project initialized with Flutter 3 skeleton and fundamental assets.
- **Oct 12, 2026**: Architectural blueprint established; enhanced authentication validators with strict Gmail & password security checks.
- **Oct 13, 2026**: Integrated implicit animation system featuring tactile `Tap` feedback and interactive card transitions.
- **Oct 14, 2026**: Enhanced `AuthCrossFade` and `DoneCrossFade` with cubic easing curves and accessible responsive sizing.
- **Oct 15, 2026**: Implemented student performance tracking cards and graded coursework summaries.
- **Oct 16, 2026**: Added teacher assignment grading workflow, score validation (0-100), and remarks dialog.
- **Oct 17, 2026**: Elevated `BookCover` aesthetics with layered gold foil borders and realistic spine drop shadows.
- **Oct 18, 2026**: Fortified `Store` state management with defensive JSON parsing and real-time subscriber notifications.
- **Oct 19, 2026**: Configured comprehensive test suite verifying root widget hierarchy, theme binding, and screen routing.
- **Oct 20, 2026**: Cleaned up documentation, finalized architecture diagrams, and published v1.0.0 milestone.

## 📄 License
This project is licensed under the MIT License - see the LICENSE file for details.






