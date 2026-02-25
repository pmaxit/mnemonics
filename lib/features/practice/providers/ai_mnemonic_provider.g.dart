// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_mnemonic_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$aiMnemonicHash() => r'12b538f2770e26d1f97a7b272153fcaca13622eb';

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

abstract class _$AiMnemonic
    extends BuildlessAutoDisposeNotifier<AsyncValue<String?>> {
  late final String word;

  AsyncValue<String?> build(
    String word,
  );
}

/// See also [AiMnemonic].
@ProviderFor(AiMnemonic)
const aiMnemonicProvider = AiMnemonicFamily();

/// See also [AiMnemonic].
class AiMnemonicFamily extends Family<AsyncValue<String?>> {
  /// See also [AiMnemonic].
  const AiMnemonicFamily();

  /// See also [AiMnemonic].
  AiMnemonicProvider call(
    String word,
  ) {
    return AiMnemonicProvider(
      word,
    );
  }

  @override
  AiMnemonicProvider getProviderOverride(
    covariant AiMnemonicProvider provider,
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
  String? get name => r'aiMnemonicProvider';
}

/// See also [AiMnemonic].
class AiMnemonicProvider
    extends AutoDisposeNotifierProviderImpl<AiMnemonic, AsyncValue<String?>> {
  /// See also [AiMnemonic].
  AiMnemonicProvider(
    String word,
  ) : this._internal(
          () => AiMnemonic()..word = word,
          from: aiMnemonicProvider,
          name: r'aiMnemonicProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$aiMnemonicHash,
          dependencies: AiMnemonicFamily._dependencies,
          allTransitiveDependencies:
              AiMnemonicFamily._allTransitiveDependencies,
          word: word,
        );

  AiMnemonicProvider._internal(
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
  AsyncValue<String?> runNotifierBuild(
    covariant AiMnemonic notifier,
  ) {
    return notifier.build(
      word,
    );
  }

  @override
  Override overrideWith(AiMnemonic Function() create) {
    return ProviderOverride(
      origin: this,
      override: AiMnemonicProvider._internal(
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
  AutoDisposeNotifierProviderElement<AiMnemonic, AsyncValue<String?>>
      createElement() {
    return _AiMnemonicProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AiMnemonicProvider && other.word == word;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, word.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin AiMnemonicRef on AutoDisposeNotifierProviderRef<AsyncValue<String?>> {
  /// The parameter `word` of this provider.
  String get word;
}

class _AiMnemonicProviderElement
    extends AutoDisposeNotifierProviderElement<AiMnemonic, AsyncValue<String?>>
    with AiMnemonicRef {
  _AiMnemonicProviderElement(super.provider);

  @override
  String get word => (origin as AiMnemonicProvider).word;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
