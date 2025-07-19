// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detailed_statistics_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filteredWordsHash() => r'3804f257cf65ff514d06614f463ea8cd4ae82444';

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

/// See also [filteredWords].
@ProviderFor(filteredWords)
const filteredWordsProvider = FilteredWordsFamily();

/// See also [filteredWords].
class FilteredWordsFamily extends Family<AsyncValue<List<WordWithUserData>>> {
  /// See also [filteredWords].
  const FilteredWordsFamily();

  /// See also [filteredWords].
  FilteredWordsProvider call(
    FilterParams params,
  ) {
    return FilteredWordsProvider(
      params,
    );
  }

  @override
  FilteredWordsProvider getProviderOverride(
    covariant FilteredWordsProvider provider,
  ) {
    return call(
      provider.params,
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
  String? get name => r'filteredWordsProvider';
}

/// See also [filteredWords].
class FilteredWordsProvider
    extends AutoDisposeFutureProvider<List<WordWithUserData>> {
  /// See also [filteredWords].
  FilteredWordsProvider(
    FilterParams params,
  ) : this._internal(
          (ref) => filteredWords(
            ref as FilteredWordsRef,
            params,
          ),
          from: filteredWordsProvider,
          name: r'filteredWordsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$filteredWordsHash,
          dependencies: FilteredWordsFamily._dependencies,
          allTransitiveDependencies:
              FilteredWordsFamily._allTransitiveDependencies,
          params: params,
        );

  FilteredWordsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.params,
  }) : super.internal();

  final FilterParams params;

  @override
  Override overrideWith(
    FutureOr<List<WordWithUserData>> Function(FilteredWordsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FilteredWordsProvider._internal(
        (ref) => create(ref as FilteredWordsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        params: params,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<WordWithUserData>> createElement() {
    return _FilteredWordsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredWordsProvider && other.params == params;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, params.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FilteredWordsRef on AutoDisposeFutureProviderRef<List<WordWithUserData>> {
  /// The parameter `params` of this provider.
  FilterParams get params;
}

class _FilteredWordsProviderElement
    extends AutoDisposeFutureProviderElement<List<WordWithUserData>>
    with FilteredWordsRef {
  _FilteredWordsProviderElement(super.provider);

  @override
  FilterParams get params => (origin as FilteredWordsProvider).params;
}

String _$categoryDetailedStatsHash() =>
    r'6f707ce216ba4f6a94d3b2c17bbc088a985c6a60';

/// See also [categoryDetailedStats].
@ProviderFor(categoryDetailedStats)
final categoryDetailedStatsProvider =
    AutoDisposeFutureProvider<Map<String, CategoryStats>>.internal(
  categoryDetailedStats,
  name: r'categoryDetailedStatsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$categoryDetailedStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CategoryDetailedStatsRef
    = AutoDisposeFutureProviderRef<Map<String, CategoryStats>>;
String _$difficultyDetailedStatsHash() =>
    r'fb13a1cfc32b28f0b17362b6755877545be5f19a';

/// See also [difficultyDetailedStats].
@ProviderFor(difficultyDetailedStats)
final difficultyDetailedStatsProvider =
    AutoDisposeFutureProvider<Map<String, DifficultyStats>>.internal(
  difficultyDetailedStats,
  name: r'difficultyDetailedStatsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$difficultyDetailedStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DifficultyDetailedStatsRef
    = AutoDisposeFutureProviderRef<Map<String, DifficultyStats>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
