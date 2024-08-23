// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$storagesHash() => r'f09795db317b733d316ee6ee671e925123d53ae4';

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
String _$defaultStorageHash() => r'18ef69c5fb6779431c40bcdb8a614b9344714bce';

/// See also [DefaultStorage].
@ProviderFor(DefaultStorage)
final defaultStorageProvider =
    AutoDisposeNotifierProvider<DefaultStorage, st.Storage?>.internal(
  DefaultStorage.new,
  name: r'defaultStorageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$defaultStorageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DefaultStorage = AutoDisposeNotifier<st.Storage?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
