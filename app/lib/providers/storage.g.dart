// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$storageRepositoryHash() => r'62f185cb154ddbcb18dd23bf97305521d0b6af88';

/// See also [storageRepository].
@ProviderFor(storageRepository)
final storageRepositoryProvider =
    AutoDisposeProvider<StorageRepository>.internal(
  storageRepository,
  name: r'storageRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$storageRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef StorageRepositoryRef = AutoDisposeProviderRef<StorageRepository>;
String _$storageByIDHash() => r'45a033081e50c80c22533901da07f744fe7a7764';

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

abstract class _$StorageByID
    extends BuildlessAutoDisposeAsyncNotifier<st.Storage?> {
  late final String id;

  FutureOr<st.Storage?> build(
    String id,
  );
}

/// See also [StorageByID].
@ProviderFor(StorageByID)
const storageByIDProvider = StorageByIDFamily();

/// See also [StorageByID].
class StorageByIDFamily extends Family<AsyncValue<st.Storage?>> {
  /// See also [StorageByID].
  const StorageByIDFamily();

  /// See also [StorageByID].
  StorageByIDProvider call(
    String id,
  ) {
    return StorageByIDProvider(
      id,
    );
  }

  @override
  StorageByIDProvider getProviderOverride(
    covariant StorageByIDProvider provider,
  ) {
    return call(
      provider.id,
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
  String? get name => r'storageByIDProvider';
}

/// See also [StorageByID].
class StorageByIDProvider
    extends AutoDisposeAsyncNotifierProviderImpl<StorageByID, st.Storage?> {
  /// See also [StorageByID].
  StorageByIDProvider(
    String id,
  ) : this._internal(
          () => StorageByID()..id = id,
          from: storageByIDProvider,
          name: r'storageByIDProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$storageByIDHash,
          dependencies: StorageByIDFamily._dependencies,
          allTransitiveDependencies:
              StorageByIDFamily._allTransitiveDependencies,
          id: id,
        );

  StorageByIDProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  FutureOr<st.Storage?> runNotifierBuild(
    covariant StorageByID notifier,
  ) {
    return notifier.build(
      id,
    );
  }

  @override
  Override overrideWith(StorageByID Function() create) {
    return ProviderOverride(
      origin: this,
      override: StorageByIDProvider._internal(
        () => create()..id = id,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<StorageByID, st.Storage?>
      createElement() {
    return _StorageByIDProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StorageByIDProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin StorageByIDRef on AutoDisposeAsyncNotifierProviderRef<st.Storage?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _StorageByIDProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<StorageByID, st.Storage?>
    with StorageByIDRef {
  _StorageByIDProviderElement(super.provider);

  @override
  String get id => (origin as StorageByIDProvider).id;
}

String _$storagesHash() => r'1eb5c6c4c6c865b6ff68dc8a2142e1d660a7e7ec';

/// See also [Storages].
@ProviderFor(Storages)
final storagesProvider =
    AutoDisposeAsyncNotifierProvider<Storages, List<st.Storage>>.internal(
  Storages.new,
  name: r'storagesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$storagesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Storages = AutoDisposeAsyncNotifier<List<st.Storage>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
