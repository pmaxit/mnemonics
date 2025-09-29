# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter-based language learning app called "Mnemonics" that helps users learn vocabulary through mnemonic techniques. The app uses a spaced repetition system for effective vocabulary retention and includes flashcard-style learning with visual and mnemonic aids.

## Development Commands

### Essential Flutter Commands
- `flutter pub get` - Install dependencies
- `flutter run` - Run the app in development mode
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS app
- `flutter test` - Run unit and widget tests
- `flutter analyze` - Run static analysis/linting

### Code Generation
- `flutter packages pub run build_runner build` - Generate code for models, providers, and serialization
- `flutter packages pub run build_runner build --delete-conflicting-outputs` - Force regenerate all generated files

### Testing
- `flutter test` - Run all tests
- `flutter test test/widget_test.dart` - Run specific test file

## Architecture and Structure

### Clean Architecture with Feature-Based Organization
The codebase follows a feature-based clean architecture pattern:

```
lib/
├── app.dart                    # App-level routing configuration
├── main.dart                   # App entry point with Hive setup
├── common/                     # Shared utilities and widgets
│   ├── design/                 # Theme and design system
│   └── widgets/                # Reusable UI components
└── features/                   # Feature modules
    ├── home/                   # Core vocabulary learning
    ├── practice/               # Practice and progress tracking
    ├── profile/                # User settings and preferences
    └── splash/                 # App initialization
```

### State Management
- **Riverpod**: Primary state management solution
- **Hooks Riverpod**: For local component state
- Uses `@riverpod` code generation for providers

### Data Layer
- **Hive**: Local database for offline-first functionality
- **JSON Assets**: Vocabulary data stored in `assets/vocabulary.json` and `assets/word_sets.json`
- **Repository Pattern**: Data access abstraction in `infrastructure/` folders

### Domain Models
Key models use **Freezed** for immutable data classes:
- `VocabularyWord`: Core vocabulary entity with word, meaning, mnemonic, examples
- `UserWordData`: Tracks user progress and spaced repetition state
- `UserSettings`: App preferences and configuration
- `ReviewActivity`: Learning session tracking

### Navigation
- **GoRouter**: Declarative routing with nested routes
- Main shell route with bottom navigation for core tabs
- Deep linking support for word details and practice sessions

### Key Dependencies
- `flutter_riverpod`: State management
- `go_router`: Navigation and routing
- `hive`: Local database
- `freezed`: Immutable data classes
- `json_annotation`: JSON serialization
- `chewie` & `video_player`: Video content support
- `file_picker`: File selection capabilities

### Generated Files
The project uses code generation extensively. Generated files include:
- `*.g.dart`: JSON serialization and Hive adapters
- `*.freezed.dart`: Freezed immutable classes
- `theme_provider.g.dart`: Riverpod provider generation

## Data Structure

Vocabulary words are structured with:
- Basic info: word, meaning, example, difficulty, category
- Learning aids: mnemonic (often bilingual), image/video URLs
- Metadata: synonyms, antonyms, associated word sets
- User tracking: spaced repetition intervals, review history

## Development Notes

### Internationalization
The app appears to support bilingual mnemonics (English/Hindi) based on the vocabulary data structure.

### Offline-First Design
All core functionality works offline using local Hive database and bundled JSON assets.

### Theme Support
Implements both light and dark theme variants with a custom design system.