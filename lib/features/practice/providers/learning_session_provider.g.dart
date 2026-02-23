// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learning_session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sessionRemainingTimeHash() =>
    r'6801dfb6bfea292b77aeb943162e7fb7e1a6a0ce';

/// See also [sessionRemainingTime].
@ProviderFor(sessionRemainingTime)
final sessionRemainingTimeProvider =
    AutoDisposeStreamProvider<Duration>.internal(
  sessionRemainingTime,
  name: r'sessionRemainingTimeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionRemainingTimeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SessionRemainingTimeRef = AutoDisposeStreamProviderRef<Duration>;
String _$learningSessionHash() => r'270391025064d17bdb52a318fb0212712b6e6a2e';

/// See also [LearningSession].
@ProviderFor(LearningSession)
final learningSessionProvider =
    AutoDisposeNotifierProvider<LearningSession, LearningSessionState>.internal(
  LearningSession.new,
  name: r'learningSessionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$learningSessionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LearningSession = AutoDisposeNotifier<LearningSessionState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
