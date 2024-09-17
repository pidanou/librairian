// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'items_in_storage.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$itemsInStorageHash() => r'f6da8f7a886dcf821f56ce38a47eb4bbf8925d03';

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

abstract class _$ItemsInStorage
    extends BuildlessAutoDisposeAsyncNotifier<PaginatedItemsList?> {
  late final int page;
  late final int limit;
  late final String? storageID;
  late final String? orderBy;
  late final bool? asc;

  FutureOr<PaginatedItemsList?> build(
    int page,
    int limit, [
    String? storageID,
    String? orderBy = "name",
    bool? asc = false,
  ]);
}

/// See also [ItemsInStorage].
@ProviderFor(ItemsInStorage)
const itemsInStorageProvider = ItemsInStorageFamily();

/// See also [ItemsInStorage].
class ItemsInStorageFamily extends Family<AsyncValue<PaginatedItemsList?>> {
  /// See also [ItemsInStorage].
  const ItemsInStorageFamily();

  /// See also [ItemsInStorage].
  ItemsInStorageProvider call(
    int page,
    int limit, [
    String? storageID,
    String? orderBy = "name",
    bool? asc = false,
  ]) {
    return ItemsInStorageProvider(
      page,
      limit,
      storageID,
      orderBy,
      asc,
    );
  }

  @override
  ItemsInStorageProvider getProviderOverride(
    covariant ItemsInStorageProvider provider,
  ) {
    return call(
      provider.page,
      provider.limit,
      provider.storageID,
      provider.orderBy,
      provider.asc,
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
  String? get name => r'itemsInStorageProvider';
}

/// See also [ItemsInStorage].
class ItemsInStorageProvider extends AutoDisposeAsyncNotifierProviderImpl<
    ItemsInStorage, PaginatedItemsList?> {
  /// See also [ItemsInStorage].
  ItemsInStorageProvider(
    int page,
    int limit, [
    String? storageID,
    String? orderBy = "name",
    bool? asc = false,
  ]) : this._internal(
          () => ItemsInStorage()
            ..page = page
            ..limit = limit
            ..storageID = storageID
            ..orderBy = orderBy
            ..asc = asc,
          from: itemsInStorageProvider,
          name: r'itemsInStorageProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$itemsInStorageHash,
          dependencies: ItemsInStorageFamily._dependencies,
          allTransitiveDependencies:
              ItemsInStorageFamily._allTransitiveDependencies,
          page: page,
          limit: limit,
          storageID: storageID,
          orderBy: orderBy,
          asc: asc,
        );

  ItemsInStorageProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.page,
    required this.limit,
    required this.storageID,
    required this.orderBy,
    required this.asc,
  }) : super.internal();

  final int page;
  final int limit;
  final String? storageID;
  final String? orderBy;
  final bool? asc;

  @override
  FutureOr<PaginatedItemsList?> runNotifierBuild(
    covariant ItemsInStorage notifier,
  ) {
    return notifier.build(
      page,
      limit,
      storageID,
      orderBy,
      asc,
    );
  }

  @override
  Override overrideWith(ItemsInStorage Function() create) {
    return ProviderOverride(
      origin: this,
      override: ItemsInStorageProvider._internal(
        () => create()
          ..page = page
          ..limit = limit
          ..storageID = storageID
          ..orderBy = orderBy
          ..asc = asc,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        page: page,
        limit: limit,
        storageID: storageID,
        orderBy: orderBy,
        asc: asc,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ItemsInStorage, PaginatedItemsList?>
      createElement() {
    return _ItemsInStorageProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ItemsInStorageProvider &&
        other.page == page &&
        other.limit == limit &&
        other.storageID == storageID &&
        other.orderBy == orderBy &&
        other.asc == asc;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, page.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);
    hash = _SystemHash.combine(hash, storageID.hashCode);
    hash = _SystemHash.combine(hash, orderBy.hashCode);
    hash = _SystemHash.combine(hash, asc.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ItemsInStorageRef
    on AutoDisposeAsyncNotifierProviderRef<PaginatedItemsList?> {
  /// The parameter `page` of this provider.
  int get page;

  /// The parameter `limit` of this provider.
  int get limit;

  /// The parameter `storageID` of this provider.
  String? get storageID;

  /// The parameter `orderBy` of this provider.
  String? get orderBy;

  /// The parameter `asc` of this provider.
  bool? get asc;
}

class _ItemsInStorageProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ItemsInStorage,
        PaginatedItemsList?> with ItemsInStorageRef {
  _ItemsInStorageProviderElement(super.provider);

  @override
  int get page => (origin as ItemsInStorageProvider).page;
  @override
  int get limit => (origin as ItemsInStorageProvider).limit;
  @override
  String? get storageID => (origin as ItemsInStorageProvider).storageID;
  @override
  String? get orderBy => (origin as ItemsInStorageProvider).orderBy;
  @override
  bool? get asc => (origin as ItemsInStorageProvider).asc;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
