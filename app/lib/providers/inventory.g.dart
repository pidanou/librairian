// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$inventoryLimitHash() => r'016822d83236c2c69b46c24339424fd352bfaf0c';

/// See also [inventoryLimit].
@ProviderFor(inventoryLimit)
final inventoryLimitProvider = AutoDisposeProvider<int>.internal(
  inventoryLimit,
  name: r'inventoryLimitProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$inventoryLimitHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef InventoryLimitRef = AutoDisposeProviderRef<int>;
String _$inventoryHash() => r'648f7cd24cfc054d139871a9f6bf9f8c47f23799';

/// See also [inventory].
@ProviderFor(inventory)
final inventoryProvider =
    AutoDisposeFutureProvider<PaginatedItemsList?>.internal(
  inventory,
  name: r'inventoryProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$inventoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef InventoryRef = AutoDisposeFutureProviderRef<PaginatedItemsList?>;
String _$inventoryPageHash() => r'b1cd02be51b798b3a2ffcb4a8630d046f76d9a08';

/// See also [InventoryPage].
@ProviderFor(InventoryPage)
final inventoryPageProvider =
    AutoDisposeNotifierProvider<InventoryPage, int>.internal(
  InventoryPage.new,
  name: r'inventoryPageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$inventoryPageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$InventoryPage = AutoDisposeNotifier<int>;
String _$inventoryOrderHash() => r'9c446e0f6de1345a954f8fb6c098a37fb1880694';

/// See also [InventoryOrder].
@ProviderFor(InventoryOrder)
final inventoryOrderProvider =
    AutoDisposeNotifierProvider<InventoryOrder, String>.internal(
  InventoryOrder.new,
  name: r'inventoryOrderProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$inventoryOrderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$InventoryOrder = AutoDisposeNotifier<String>;
String _$inventoryAscHash() => r'2d96d4881c15821f57ebfda55859e363f67a463b';

/// See also [InventoryAsc].
@ProviderFor(InventoryAsc)
final inventoryAscProvider =
    AutoDisposeNotifierProvider<InventoryAsc, bool>.internal(
  InventoryAsc.new,
  name: r'inventoryAscProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$inventoryAscHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$InventoryAsc = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
