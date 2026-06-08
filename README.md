# Mnemonics - Language Learning App

[![CI](https://img.shields.io/github/actions/workflow/status/pmaxit/mnemonics/ci.yml?branch=main&logo=github&label=CI)](https://github.com/pmaxit/mnemonics/actions)
[![Flutter](https://img.shields.io/badge/Flutter-3.16+-blue?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.2+-blue?logo=dart)](https://dart.dev)
[![license](https://img.shields.io/github/license/pmaxit/mnemonics.svg)](https://github.com/pmaxit/mnemonics/blob/main/LICENSE)
[![platforms](https://img.shields.io/badge/platforms-Android%20%7C%20iOS%20%7C%20macOS%20%7C%20Linux%20%7C%20Windows-green)](https://flutter.dev)

A language learning app that helps break the barriers of language through mnemonic techniques and spaced repetition.

## Features

### Mnemonic Learning System
Every word comes with a carefully crafted mnemonic, often bilingual (English-Hindi), that creates a memorable mental association. These mnemonics transform abstract vocabulary into vivid, recallable stories.

### Spaced Repetition
Built on proven spaced repetition algorithms, Mnemonics optimizes your review schedule. Words you struggle with appear more frequently while mastered words fade into longer intervals—maximizing retention with minimal effort.

### Rich Media Support
- **Images**: Visual mnemonics paired with each word
- **Videos**: Optional video explanations for complex concepts
- **Examples**: Real-world usage examples in sentences
- **Synonyms & Antonyms**: Expand your vocabulary network

### Word Sets & Categories
Organized vocabulary into focused sets:
- **SAT** - College admission test vocabulary
- **GRE** - Graduate school entrance exam vocabulary
- **Emotions** - Words about feelings and emotional states
- **Character** - Personality and trait vocabulary
- **Speech** - Communication and language words
- **Intellect** - Thinking and knowledge vocabulary
- **Conflict** - Opposition and struggle vocabulary
- **Power** - Authority and control vocabulary
- **Morality** - Ethics and values vocabulary
- **Criticism** - Judgment and evaluation vocabulary
- **Abundance** - Quantity and scarcity vocabulary
- **Change** - Transformation and transition vocabulary
- **Phrases** - Collocations and phrasal verbs
- **MyList** - Your personal custom word list

### Offline-First Design
Core learning works completely offline. Vocabulary data is bundled with the app, and progress is stored locally using Hive—no internet required for learning.

### Progress Tracking
Visualize your learning journey with:
- Words learned per day
- Current streak tracking
- Mastery level per word
- Category-wise progress charts

## Architecture

Mnemonics is built with modern Flutter architecture:

```
lib/
├── app.dart                    # App routing with GoRouter
├── main.dart                   # Entry point with Hive setup
├── common/                     # Shared design system & widgets
│   ├── design/                 # Theme configuration
│   └── widgets/                # Reusable components
└── features/                   # Feature modules
    ├── home/                   # Core vocabulary learning
    ├── practice/               # Review sessions
    ├── profile/                # User settings
    └── splash/                 # App initialization
```

### State Management
- **Riverpod** with code generation for reactive state
- **Hooks Riverpod** for local component state

### Data Layer
- **Hive** for local, fast NoSQL storage
- **JSON assets** for bundled vocabulary
- **Repository pattern** for data abstraction

### Domain Models
Immutable data classes using **Freezed**:
- `VocabularyWord` - Word with meaning, mnemonic, examples
- `UserWordData` - Spaced repetition state
- `ReviewActivity` - Session tracking

## Installation

### Prerequisites
- Flutter SDK 3.16+
- Dart SDK 3.2+

### Clone & Run

```bash
git clone https://github.com/pmaxit/mnemonics.git
cd mnemonics
flutter pub get
flutter run
```

### Build

```bash
# Android APK
flutter build apk

# iOS
flutter build ios

# Release build
flutter build apk --release
```

## Development

### Code Generation

```bash
# Generate models, providers, and serialization
flutter pub run build_runner build

# Force regenerate all files
flutter pub run build_runner build --delete-conflicting-outputs
```

### Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Analyze code
flutter analyze
```

## Tech Stack

| Category | Technology |
|----------|------------|
| Framework | Flutter 3.16+ |
| Language | Dart 3.2+ |
| State | Riverpod + Hooks Riverpod |
| Routing | GoRouter |
| Local Storage | Hive |
| Models | Freezed, JSON Serializable |
| Auth | Firebase Auth, Google Sign-In |

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Reporting Security Vulnerabilities

See our [security policy](https://github.com/pmaxit/mnemonics/security/policy).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Links

[![Documentation](https://img.shields.io/badge/Documentation-Read%20Online-green)](https://github.com/pmaxit/mnemonics)
[![API Reference](https://img.shields.io/badge/API%20Reference-dart.dev-blue)](https://pub.dev/packages/mnemonics)
[![Issues](https://img.shields.io/github/issues/pmaxit/mnemonics)](https://github.com/pmaxit/mnemonics/issues)
[![ Discussions](https://img.shields.io/github/discussions/pmaxit/mnemonics)](https://github.com/pmaxit/mnemonics/discussions)