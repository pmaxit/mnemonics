// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_word_insights_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$aiWordInsightsHash() => r'43825bc559f90314e00aff41c6da33db8425fe9f';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$AiWordInsights
    extends BuildlessAutoDisposeNotifier<AsyncValue<WordInsights?>> {
  late final String word;

  AsyncValue<WordInsights?> build(
    String word,
  );
}

/// See also [AiWordInsights].
@ProviderFor(AiWordInsights)
const aiWordInsightsProvider = AiWordInsightsFamily();

/// See also [AiWordInsights].
class AiWordInsightsFamily extends Family<AsyncValue<WordInsights?>> {
  /// See also [AiWordInsights].
  const AiWordInsightsFamily();

  /// See also [AiWordInsights].
  AiWordInsightsProvider call(
    String word,
  ) {
    return AiWordInsightsProvider(
      word,
    );
  }

  @override
  AiWordInsightsProvider getProviderOverride(
    covariant AiWordInsightsProvider provider,
  ) {
    return call(
      provider.word,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'aiWordInsightsProvider';
}

/// See also [AiWordInsights].
class AiWordInsightsProvider extends AutoDisposeNotifierProviderImpl<
    AiWordInsights, AsyncValue<WordInsights?>> {
  /// See also [AiWordInsights].
  AiWordInsightsProvider(
    String word,
  ) : this._internal(
          () => AiWordInsights()..word = word,
          from: aiWordInsightsProvider,
          name: r'aiWordInsightsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$aiWordInsightsHash,
          dependencies: AiWordInsightsFamily._dependencies,
          allTransitiveDependencies:
              AiWordInsightsFamily._allTransitiveDependencies,
          word: word,
        );

  AiWordInsightsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.word,
  }) : super.internal();

  final String word;

  @override
  AsyncValue<WordInsights?> runNotifierBuild(
    covariant AiWordInsights notifier,
  ) {
    return notifier.build(
      word,
    );
  }

  @override
  Override overrideWith(AiWordInsights Function() create) {
    return ProviderOverride(
      origin: this,
      override: AiWordInsightsProvider._internal(
        () => create()..word = word,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        word: word,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<AiWordInsights, AsyncValue<WordInsights?>>
      createElement() {
    return _AiWordInsightsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AiWordInsightsProvider && other.word == word;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, word.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin AiWordInsightsRef
    on AutoDisposeNotifierProviderRef<AsyncValue<WordInsights?>> {
  /// The parameter `word` of this provider.
  String get word;
}

class _AiWordInsightsProviderElement extends AutoDisposeNotifierProviderElement<
    AiWordInsights, AsyncValue<WordInsights?>> with AiWordInsightsRef {
  _AiWordInsightsProviderElement(super.provider);

  @override
  String get word => (origin as AiWordInsightsProvider).word;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
