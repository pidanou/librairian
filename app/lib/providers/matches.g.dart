// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'matches.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$matchesHash() => r'0f0508acf167a34059b0d5cf055802c8142405a6';

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

abstract class _$Matches
    extends BuildlessAutoDisposeAsyncNotifier<List<MatchItem>> {
  late final String input;
  late final double threshold;
  late final int maxResults;

  FutureOr<List<MatchItem>> build(
    String input,
    double threshold,
    int maxResults,
  );
}

/// See also [Matches].
@ProviderFor(Matches)
const matchesProvider = MatchesFamily();

/// See also [Matches].
class MatchesFamily extends Family<AsyncValue<List<MatchItem>>> {
  /// See also [Matches].
  const MatchesFamily();

  /// See also [Matches].
  MatchesProvider call(
    String input,
    double threshold,
    int maxResults,
  ) {
    return MatchesProvider(
      input,
      threshold,
      maxResults,
    );
  }

  @override
  MatchesProvider getProviderOverride(
    covariant MatchesProvider provider,
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
  String? get name => r'matchesProvider';
}

/// See also [Matches].
class MatchesProvider
    extends AutoDisposeAsyncNotifierProviderImpl<Matches, List<MatchItem>> {
  /// See also [Matches].
  MatchesProvider(
    String input,
    double threshold,
    int maxResults,
  ) : this._internal(
          () => Matches()
            ..input = input
            ..threshold = threshold
            ..maxResults = maxResults,
          from: matchesProvider,
          name: r'matchesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$matchesHash,
          dependencies: MatchesFamily._dependencies,
          allTransitiveDependencies: MatchesFamily._allTransitiveDependencies,
          input: input,
          threshold: threshold,
          maxResults: maxResults,
        );

  MatchesProvider._internal(
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
  FutureOr<List<MatchItem>> runNotifierBuild(
    covariant Matches notifier,
  ) {
    return notifier.build(
      input,
      threshold,
      maxResults,
    );
  }

  @override
  Override overrideWith(Matches Function() create) {
    return ProviderOverride(
      origin: this,
      override: MatchesProvider._internal(
        () => create()
          ..input = input
          ..threshold = threshold
          ..maxResults = maxResults,
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
  AutoDisposeAsyncNotifierProviderElement<Matches, List<MatchItem>>
      createElement() {
    return _MatchesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MatchesProvider &&
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

mixin MatchesRef on AutoDisposeAsyncNotifierProviderRef<List<MatchItem>> {
  /// The parameter `input` of this provider.
  String get input;

  /// The parameter `threshold` of this provider.
  double get threshold;

  /// The parameter `maxResults` of this provider.
  int get maxResults;
}

class _MatchesProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<Matches, List<MatchItem>>
    with MatchesRef {
  _MatchesProviderElement(super.provider);

  @override
  String get input => (origin as MatchesProvider).input;
  @override
  double get threshold => (origin as MatchesProvider).threshold;
  @override
  int get maxResults => (origin as MatchesProvider).maxResults;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
