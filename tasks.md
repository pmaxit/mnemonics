# Flutter Compilation Error Tasks

## High Priority - Core Model Issues

### Task 1: Fix Import Conflicts
- [ ] **File**: `lib/features/practice/providers/statistics_provider.dart`
- [ ] **Error**: 'DailyProgress' is imported from both statistics_data.dart and user_statistics.dart
- [ ] **Solution**: Remove conflicting import or rename one of the classes

### Task 2: Fix String to Enum Conversions - Practice Detail Screens
- [ ] **File**: `lib/features/practice/presentation/screens/details/words_today_detail_screen.dart`
  - [ ] Line 160: String 'medium' → WordDifficulty.medium
  - [ ] Line 489: WordDifficulty → String conversion for _getDifficultyColor
  - [ ] Line 537: WordDifficulty.toUpperCase() → WordDifficulty.displayName.toUpperCase()

- [ ] **File**: `lib/features/practice/presentation/screens/details/total_words_detail_screen.dart`
  - [ ] Line 174: String 'medium' → WordDifficulty.medium
  - [ ] Line 237-238: WordDifficulty → String for indexOf operations
  - [ ] Line 264: WordDifficulty → String for map keys
  - [ ] Line 265: LearningStage → String for map keys
  - [ ] Line 664: WordDifficulty → String for _getDifficultyColor
  - [ ] Line 665: LearningStage → String for _getStageColor
  - [ ] Line 712: WordDifficulty.toUpperCase() → displayName.toUpperCase()
  - [ ] Line 731: LearningStage.toUpperCase() → displayName.toUpperCase()

- [ ] **File**: `lib/features/practice/presentation/screens/details/accuracy_detail_screen.dart`
  - [ ] Line 188: String 'medium' → WordDifficulty.medium
  - [ ] Line 197: WordDifficulty → String conversion

- [ ] **File**: `lib/features/practice/presentation/screens/details/breakdown_detail_screen.dart`
  - [ ] Line 156: String 'medium' → WordDifficulty.medium
  - [ ] Line 176-177: Object → String conversion for display
  - [ ] Line 190: Add LearningStage.newWord case to switch
  - [ ] Line 704: LearningStage → String conversion
  - [ ] Line 708: LearningStage.toUpperCase() → displayName.toUpperCase()
  - [ ] Line 710: LearningStage → String conversion

- [ ] **File**: `lib/features/practice/presentation/screens/details/learning_stages_detail_screen.dart`
  - [ ] Line 182: LearningStage.toLowerCase() → use enum comparison
  - [ ] Line 192: String 'medium' → WordDifficulty.medium
  - [ ] Line 250-251: WordDifficulty → String conversion
  - [ ] Line 276: WordDifficulty → String conversion
  - [ ] Line 614: WordDifficulty → String conversion
  - [ ] Line 662: WordDifficulty.toUpperCase() → displayName.toUpperCase()

### Task 3: Fix Learning Session Provider Issues
- [ ] **File**: `lib/features/practice/providers/learning_session_provider.dart`
  - [ ] Line 143: String difficulty → ReviewDifficultyRating
  - [ ] Line 308: String → ReviewDifficultyRating conversion

### Task 4: Fix Learning Session Models
- [ ] **File**: `lib/features/practice/domain/learning_session_models.dart`
  - [ ] Line 101: ReviewDifficultyRating → String for map keys

### Task 5: Fix Home Screen Issues
- [ ] **File**: `lib/features/home/presentation/screens/learn_word_detail_screen.dart`
  - [ ] Line 324: WordDifficulty → String for _buildInfoChip and _getDifficultyColor
  - [ ] Line 426: String → ReviewDifficultyRating for recordReviewActivity
  - [ ] Line 564: WordDifficulty → String for _buildHeaderChip

### Task 6: Fix Practice Widget Issues
- [ ] **File**: `lib/features/practice/presentation/widgets/learning_flashcard_widget.dart`
  - [ ] Line 179: WordDifficulty.toLowerCase() → enum comparison

### Task 7: Fix Timer Screen Issues
- [ ] **File**: `lib/features/practice/presentation/screens/timer_screen.dart`
  - [ ] Multiple ReviewDifficulty enum usage issues

### Task 8: Fix Animated Flash Card Issues
- [ ] **File**: `lib/features/practice/presentation/widgets/animated_flash_card.dart`
  - [ ] Line 258-259: WordDifficulty → String conversion

## Medium Priority - Profile and Statistics Issues

### Task 9: Fix Profile Statistics Provider Issues
- [ ] **File**: `lib/features/profile/providers/profile_statistics_provider.dart`
  - [ ] Multiple String → WordDifficulty conversions
  - [ ] WordDifficulty comparison issues

### Task 10: Fix Detailed Statistics Provider Issues  
- [ ] **File**: `lib/features/profile/providers/detailed_statistics_provider.dart`
  - [ ] Multiple WordDifficulty.toLowerCase() → enum comparison
  - [ ] LearningStage string comparisons → enum comparisons

### Task 11: Fix Statistics Overview Widget Issues
- [ ] **File**: `lib/features/profile/presentation/widgets/statistics_overview_widget.dart`
  - [ ] Line 169, 214: studySessionsThisWeek getter missing from UserStatistics

### Task 12: Fix Profile Screen Issues
- [ ] **File**: `lib/features/profile/presentation/screens/detailed_word_statistics_screen.dart`
  - [ ] Multiple difficulty.toLowerCase() → enum comparison
  - [ ] LearningStage enum usage issues

### Task 13: Fix Activity Log Screen Issues
- [ ] **File**: `lib/features/profile/presentation/screens/activity_log_screen.dart`
  - [ ] Line 95: ReviewDifficultyRating → String conversion

## Low Priority - Session Completion Widget Issues

### Task 14: Fix Session Completion Widget
- [ ] **File**: `lib/features/practice/presentation/widgets/session_completion_widget.dart`
  - [ ] String difficulty keys → enum-based keys

## Implementation Strategy

### Phase 1: Create Compatibility Utilities
1. Create enum conversion utilities
2. Update method signatures to accept both types temporarily

### Phase 2: Fix Core Models
1. Fix import conflicts
2. Update core enum usage

### Phase 3: Fix UI Components
1. Update all UI components to use proper enum types
2. Fix string conversion issues

### Phase 4: Testing and Validation
1. Run flutter analyze
2. Test app compilation
3. Test runtime functionality

## Notes
- Most errors are related to string ↔ enum conversions
- Need to decide on consistent approach for map keys (use enum.name)
- Some methods need to be updated to accept enum types
- Display values should use enum.displayName extension