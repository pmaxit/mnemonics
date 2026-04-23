# Mnemonics App — Design Guidelines for AI Agents

This file tells AI coding agents (Gemini, Cursor, Copilot, etc.) exactly how to build UI in this codebase. Follow these rules for every new screen, widget, and feature.

---

## 1. Design System — Always Use These Classes

All design tokens live in `lib/common/design/design_system.dart`. **Never hard-code colors, spacing, or font sizes.** Use the constants below.

### Colors — `MnemonicsColors`

| Token | Value | Use |
|-------|-------|-----|
| `primaryGreen` | `#4CAF8F` | Primary actions, success states, active indicators |
| `secondaryOrange` | `#F4A261` | Secondary actions, in-progress states, warnings |
| `background` | `#FFFFFF` | Page background (light) |
| `surface` | `#F8F9FA` | Page background (light, alternate) |
| `textPrimary` | `#2D3436` | Main body text, titles |
| `textSecondary` | `#636E72` | Subtitles, labels, hints |
| `darkBackground` | `#1A1A1A` | Page background (dark) |
| `darkSurface` | `#2D2D2D` | Card background (dark) |
| `darkTextPrimary` | `#E0E0E0` | Text (dark mode) |
| `darkTextSecondary` | `#A0A0A0` | Secondary text (dark mode) |
| `darkBorder` | `#404040` | Card borders (dark mode) |

### Typography — `MnemonicsTypography`

| Token | Size | Weight | Use |
|-------|------|--------|-----|
| `headingLarge` | 32px | Bold | Screen hero titles |
| `headingMedium` | 24px | SemiBold (w600) | Section headings, AppBar titles |
| `bodyLarge` | 18px | Medium (w500) | Card titles, word names |
| `bodyRegular` | 16px | Normal | Body text, descriptions |

Always use `.copyWith(...)` to override individual properties (color, size, weight).

### Spacing — `MnemonicsSpacing`

| Token | Value | Use |
|-------|-------|-----|
| `xs` | 4px | Tight gaps between inline elements |
| `s` | 8px | Gap between list items, sibling widgets |
| `m` | 16px | Standard card/section padding |
| `l` | 24px | Large card padding, section gaps |
| `xl` | 32px | Major vertical section spacing |
| `xxl` | 48px | Hero area padding |
| `radiusS` | 4px | Small pill tags |
| `radiusM` | 8px | Badges, small containers |
| `radiusL` | 12px | Buttons |
| `radiusXL` | 16px | Cards, bottom bars |

---

## 2. Scaffold & AppBar Pattern

```dart
Scaffold(
  backgroundColor: isDarkMode ? MnemonicsColors.darkBackground : MnemonicsColors.surface,
  appBar: AppBar(
    backgroundColor: isDarkMode ? MnemonicsColors.darkBackground : Colors.white,
    elevation: 0,
    scrolledUnderElevation: 0,
    leading: IconButton(
      icon: Icon(
        Icons.arrow_back_ios_new_rounded,
        color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
        size: 20,
      ),
      onPressed: () => context.pop(),
    ),
    title: Text(
      'Screen Title',
      style: MnemonicsTypography.headingMedium.copyWith(
        color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 20,
      ),
    ),
  ),
)
```

---

## 3. Card / Container Pattern

Every card follows this exact decoration. Always support both light and dark modes.

```dart
BoxDecoration _cardDecoration(bool isDarkMode) {
  return BoxDecoration(
    color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
    borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL), // 16px
    boxShadow: isDarkMode ? MnemonicsColors.darkCardShadow : MnemonicsColors.cardShadow,
    border: isDarkMode
        ? Border.all(color: MnemonicsColors.darkBorder.withOpacity(0.3), width: 1)
        : null,
  );
}
```

Use `MnemonicsSpacing.l` (24px) for card internal padding.

---

## 4. Dark Mode — Always Required

Every screen must read `themeNotifierProvider` and adapt:

```dart
final themeMode = ref.watch(themeNotifierProvider);
final isDarkMode = themeMode == ThemeMode.dark ||
    (themeMode == ThemeMode.system &&
        MediaQuery.of(context).platformBrightness == Brightness.dark);
```

Pass `isDarkMode` down to all sub-widgets that render cards or text.

---

## 5. Color Palette Mapping — Semantic Usage

| Purpose | Light mode | Dark mode |
|---------|-----------|-----------|
| Page background | `MnemonicsColors.surface` (`#F8F9FA`) | `MnemonicsColors.darkBackground` |
| Card background | `Colors.white` | `MnemonicsColors.darkSurface` |
| Primary action | `MnemonicsColors.primaryGreen` | same |
| In-progress / warn | `MnemonicsColors.secondaryOrange` | same |
| Danger / error | `Colors.redAccent` | same |
| Body text | `MnemonicsColors.textPrimary` | `MnemonicsColors.darkTextPrimary` |
| Label / hint text | `MnemonicsColors.textSecondary` | `MnemonicsColors.darkTextSecondary` |

---

## 6. Buttons

### Primary (full-width action)

```dart
SizedBox(
  width: double.infinity,
  height: 52,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: MnemonicsColors.primaryGreen,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
      ),
    ),
    onPressed: onPressed,
    child: const Text('Action Label',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
  ),
)
```

### Text / secondary

```dart
TextButton.icon(
  onPressed: onPressed,
  icon: const Icon(Icons.add_rounded, size: 16),
  label: const Text('Label'),
  style: TextButton.styleFrom(
    foregroundColor: MnemonicsColors.primaryGreen,
  ),
)
```

---

## 7. Status Badges / Chips

```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
  decoration: BoxDecoration(
    color: accentColor.withOpacity(0.1),
    borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusM),
  ),
  child: Text(
    label,
    style: MnemonicsTypography.bodyRegular.copyWith(
      color: accentColor,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
  ),
)
```

---

## 8. Navigation Patterns

- Use `context.push('/route')` for drilling into a sub-screen (preserves back stack)
- Use `context.go('/main/practice')` to jump to a root tab (clears back stack)
- Use `context.pop()` to go back
- After completing an async action (e.g. creating a plan), always navigate **and** show a `SnackBar` confirmation

```dart
context.go('/main/practice');
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: const Row(children: [
      Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
      SizedBox(width: 10),
      Text('Done! Check below.', style: TextStyle(fontWeight: FontWeight.w600)),
    ]),
    backgroundColor: MnemonicsColors.primaryGreen,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    duration: const Duration(seconds: 4),
  ),
);
```

---

## 9. Loading & Error States

```dart
// Loading
const Center(child: CircularProgressIndicator(color: MnemonicsColors.primaryGreen))

// Error
Center(
  child: Text(
    'Could not load data',
    style: MnemonicsTypography.bodyRegular.copyWith(color: MnemonicsColors.textSecondary),
  ),
)
```

---

## 10. What NOT to Do

- ❌ Never use hardcoded hex colors like `Color(0xFF0F172A)` (dark background) in new screens — use `MnemonicsColors` tokens
- ❌ Never use `Colors.black` or `Colors.white` as background or primary text color
- ❌ Never create screens without dark mode support
- ❌ Never navigate after an action without providing user feedback (SnackBar or dialog)
- ❌ Never use `bodySmall` or `bodyMedium` — they don't exist in `MnemonicsTypography`; use `bodyRegular` with `.copyWith(fontSize: 12)` for small text
