// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$itemHash() => r'22c1978f37a7890bdcf5ab3fbe8fa8c873f6ce0a';

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

abstract class _$Item extends BuildlessAutoDisposeAsyncNotifier<im.Item> {
  late final String? id;

  FutureOr<im.Item> build(
    String? id,
  );
}

/// See also [Item].
@ProviderFor(Item)
const itemProvider = ItemFamily();

/// See also [Item].
class ItemFamily extends Family<AsyncValue<im.Item>> {
  /// See also [Item].
  const ItemFamily();

  /// See also [Item].
  ItemProvider call(
    String? id,
  ) {
    return ItemProvider(
      id,
    );
  }

  @override
  ItemProvider getProviderOverride(
    covariant ItemProvider provider,
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
  String? get name => r'itemProvider';
}

/// See also [Item].
class ItemProvider extends AutoDisposeAsyncNotifierProviderImpl<Item, im.Item> {
  /// See also [Item].
  ItemProvider(
    String? id,
  ) : this._internal(
          () => Item()..id = id,
          from: itemProvider,
          name: r'itemProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product') ? null : _$itemHash,
          dependencies: ItemFamily._dependencies,
          allTransitiveDependencies: ItemFamily._allTransitiveDependencies,
          id: id,
        );

  ItemProvider._internal(
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
  FutureOr<im.Item> runNotifierBuild(
    covariant Item notifier,
  ) {
    return notifier.build(
      id,
    );
  }

  @override
  Override overrideWith(Item Function() create) {
    return ProviderOverride(
      origin: this,
      override: ItemProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<Item, im.Item> createElement() {
    return _ItemProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ItemProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ItemRef on AutoDisposeAsyncNotifierProviderRef<im.Item> {
  /// The parameter `id` of this provider.
  String? get id;
}

class _ItemProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<Item, im.Item>
    with ItemRef {
  _ItemProviderElement(super.provider);

  @override
  String? get id => (origin as ItemProvider).id;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
