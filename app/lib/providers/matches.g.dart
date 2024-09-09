// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'matches.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$matchesByDescriptionHash() =>
    r'86c5aebb5b8b6b931a09904dd9352f0d59152ca5';

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

/// See also [matchesByDescription].
@ProviderFor(matchesByDescription)
const matchesByDescriptionProvider = MatchesByDescriptionFamily();

/// See also [matchesByDescription].
class MatchesByDescriptionFamily extends Family<AsyncValue<List<MatchItem>>> {
  /// See also [matchesByDescription].
  const MatchesByDescriptionFamily();

  /// See also [matchesByDescription].
  MatchesByDescriptionProvider call(
    String input,
    double threshold,
    int maxResults,
  ) {
    return MatchesByDescriptionProvider(
      input,
      threshold,
      maxResults,
    );
  }

  @override
  MatchesByDescriptionProvider getProviderOverride(
    covariant MatchesByDescriptionProvider provider,
  ) {
    return call(
      provider.input,
      provider.threshold,
      provider.maxResults,
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
  String? get name => r'matchesByDescriptionProvider';
}

/// See also [matchesByDescription].
class MatchesByDescriptionProvider
    extends AutoDisposeFutureProvider<List<MatchItem>> {
  /// See also [matchesByDescription].
  MatchesByDescriptionProvider(
    String input,
    double threshold,
    int maxResults,
  ) : this._internal(
          (ref) => matchesByDescription(
            ref as MatchesByDescriptionRef,
            input,
            threshold,
            maxResults,
          ),
          from: matchesByDescriptionProvider,
          name: r'matchesByDescriptionProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$matchesByDescriptionHash,
          dependencies: MatchesByDescriptionFamily._dependencies,
          allTransitiveDependencies:
              MatchesByDescriptionFamily._allTransitiveDependencies,
          input: input,
          threshold: threshold,
          maxResults: maxResults,
        );

  MatchesByDescriptionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.input,
    required this.threshold,
    required this.maxResults,
  }) : super.internal();

  final String input;
  final double threshold;
  final int maxResults;

  @override
  Override overrideWith(
    FutureOr<List<MatchItem>> Function(MatchesByDescriptionRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MatchesByDescriptionProvider._internal(
        (ref) => create(ref as MatchesByDescriptionRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        input: input,
        threshold: threshold,
        maxResults: maxResults,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<MatchItem>> createElement() {
    return _MatchesByDescriptionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MatchesByDescriptionProvider &&
        other.input == input &&
        other.threshold == threshold &&
        other.maxResults == maxResults;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, input.hashCode);
    hash = _SystemHash.combine(hash, threshold.hashCode);
    hash = _SystemHash.combine(hash, maxResults.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MatchesByDescriptionRef on AutoDisposeFutureProviderRef<List<MatchItem>> {
  /// The parameter `input` of this provider.
  String get input;

  /// The parameter `threshold` of this provider.
  double get threshold;

  /// The parameter `maxResults` of this provider.
  int get maxResults;
}

class _MatchesByDescriptionProviderElement
    extends AutoDisposeFutureProviderElement<List<MatchItem>>
    with MatchesByDescriptionRef {
  _MatchesByDescriptionProviderElement(super.provider);

  @override
  String get input => (origin as MatchesByDescriptionProvider).input;
  @override
  double get threshold => (origin as MatchesByDescriptionProvider).threshold;
  @override
  int get maxResults => (origin as MatchesByDescriptionProvider).maxResults;
}

String _$matchesByNameHash() => r'894a89118d83d42d787b409638900c7521da9b85';

/// See also [matchesByName].
@ProviderFor(matchesByName)
const matchesByNameProvider = MatchesByNameFamily();

/// See also [matchesByName].
class MatchesByNameFamily extends Family<AsyncValue<List<MatchItem>>> {
  /// See also [matchesByName].
  const MatchesByNameFamily();

  /// See also [matchesByName].
  MatchesByNameProvider call(
    String input,
    int maxResults,
  ) {
    return MatchesByNameProvider(
      input,
      maxResults,
    );
  }

  @override
  MatchesByNameProvider getProviderOverride(
    covariant MatchesByNameProvider provider,
  ) {
    return call(
      provider.input,
      provider.maxResults,
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
  String? get name => r'matchesByNameProvider';
}

/// See also [matchesByName].
class MatchesByNameProvider extends AutoDisposeFutureProvider<List<MatchItem>> {
  /// See also [matchesByName].
  MatchesByNameProvider(
    String input,
    int maxResults,
  ) : this._internal(
          (ref) => matchesByName(
            ref as MatchesByNameRef,
            input,
            maxResults,
          ),
          from: matchesByNameProvider,
          name: r'matchesByNameProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$matchesByNameHash,
          dependencies: MatchesByNameFamily._dependencies,
          allTransitiveDependencies:
              MatchesByNameFamily._allTransitiveDependencies,
          input: input,
          maxResults: maxResults,
        );

  MatchesByNameProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.input,
    required this.maxResults,
  }) : super.internal();

  final String input;
  final int maxResults;

  @override
  Override overrideWith(
    FutureOr<List<MatchItem>> Function(MatchesByNameRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MatchesByNameProvider._internal(
        (ref) => create(ref as MatchesByNameRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        input: input,
        maxResults: maxResults,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<MatchItem>> createElement() {
    return _MatchesByNameProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MatchesByNameProvider &&
        other.input == input &&
        other.maxResults == maxResults;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, input.hashCode);
    hash = _SystemHash.combine(hash, maxResults.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MatchesByNameRef on AutoDisposeFutureProviderRef<List<MatchItem>> {
  /// The parameter `input` of this provider.
  String get input;

  /// The parameter `maxResults` of this provider.
  int get maxResults;
}

class _MatchesByNameProviderElement
    extends AutoDisposeFutureProviderElement<List<MatchItem>>
    with MatchesByNameRef {
  _MatchesByNameProviderElement(super.provider);

  @override
  String get input => (origin as MatchesByNameProvider).input;
  @override
  int get maxResults => (origin as MatchesByNameProvider).maxResults;
}

String _$matchesHash() => r'9c0b3fc63e8384886b5e31fe3a656ae54bc5ef65';

/// See also [Matches].
@ProviderFor(Matches)
final matchesProvider =
    AutoDisposeNotifierProvider<Matches, List<MatchItem>>.internal(
  Matches.new,
  name: r'matchesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$matchesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Matches = AutoDisposeNotifier<List<MatchItem>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
