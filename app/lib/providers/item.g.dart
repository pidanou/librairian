// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$itemRepositoryHash() => r'bdb3cc76b9b088ddef0da6cf5ef22c332c7a8394';

/// See also [itemRepository].
@ProviderFor(itemRepository)
final itemRepositoryProvider = AutoDisposeProvider<ItemRepository>.internal(
  itemRepository,
  name: r'itemRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$itemRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ItemRepositoryRef = AutoDisposeProviderRef<ItemRepository>;
String _$itemControllerHash() => r'5ea8f35a2593be17a202d901fc459b2ea3be899a';

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

abstract class _$ItemController
    extends BuildlessAutoDisposeAsyncNotifier<Item?> {
  late final String? id;

  FutureOr<Item?> build(
    String? id,
  );
}

/// See also [ItemController].
@ProviderFor(ItemController)
const itemControllerProvider = ItemControllerFamily();

/// See also [ItemController].
class ItemControllerFamily extends Family<AsyncValue<Item?>> {
  /// See also [ItemController].
  const ItemControllerFamily();

  /// See also [ItemController].
  ItemControllerProvider call(
    String? id,
  ) {
    return ItemControllerProvider(
      id,
    );
  }

  @override
  ItemControllerProvider getProviderOverride(
    covariant ItemControllerProvider provider,
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
  String? get name => r'itemControllerProvider';
}

/// See also [ItemController].
class ItemControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ItemController, Item?> {
  /// See also [ItemController].
  ItemControllerProvider(
    String? id,
  ) : this._internal(
          () => ItemController()..id = id,
          from: itemControllerProvider,
          name: r'itemControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$itemControllerHash,
          dependencies: ItemControllerFamily._dependencies,
          allTransitiveDependencies:
              ItemControllerFamily._allTransitiveDependencies,
          id: id,
        );

  ItemControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String? id;

  @override
  FutureOr<Item?> runNotifierBuild(
    covariant ItemController notifier,
  ) {
    return notifier.build(
      id,
    );
  }

  @override
  Override overrideWith(ItemController Function() create) {
    return ProviderOverride(
      origin: this,
      override: ItemControllerProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<ItemController, Item?>
      createElement() {
    return _ItemControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ItemControllerProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ItemControllerRef on AutoDisposeAsyncNotifierProviderRef<Item?> {
  /// The parameter `id` of this provider.
  String? get id;
}

class _ItemControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ItemController, Item?>
    with ItemControllerRef {
  _ItemControllerProviderElement(super.provider);

  @override
  String? get id => (origin as ItemControllerProvider).id;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
