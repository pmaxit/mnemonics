// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$lightThemeHash() => r'6769430a64e2ffadacb3973fb2e3535cb9a46683';

/// See also [lightTheme].
@ProviderFor(lightTheme)
final lightThemeProvider = AutoDisposeProvider<ThemeData>.internal(
  lightTheme,
  name: r'lightThemeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$lightThemeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef LightThemeRef = AutoDisposeProviderRef<ThemeData>;
String _$darkThemeHash() => r'9e4007d6354a503d04cc6325510d1348ce22513f';

/// See also [darkTheme].
@ProviderFor(darkTheme)
final darkThemeProvider = AutoDisposeProvider<ThemeData>.internal(
  darkTheme,
  name: r'darkThemeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$darkThemeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DarkThemeRef = AutoDisposeProviderRef<ThemeData>;
String _$themeNotifierHash() => r'324ecb0f915aa92d9f4083b9300ecd06690aadac';

/// See also [ThemeNotifier].
@ProviderFor(ThemeNotifier)
final themeNotifierProvider =
    AutoDisposeNotifierProvider<ThemeNotifier, ThemeMode>.internal(
  ThemeNotifier.new,
  name: r'themeNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$themeNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ThemeNotifier = AutoDisposeNotifier<ThemeMode>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
