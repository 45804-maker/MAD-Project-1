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



