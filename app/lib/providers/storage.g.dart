// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$storageHash() => r'541a7649732a7086f169c46cd7083586a205bb07';

/// See also [Storage].
@ProviderFor(Storage)
final storageProvider =
    AutoDisposeAsyncNotifierProvider<Storage, List<st.Storage>>.internal(
  Storage.new,
  name: r'storageProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$storageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Storage = AutoDisposeAsyncNotifier<List<st.Storage>>;
String _$defaultStorageHash() => r'd095680415c5c7dab689ee0884c8ec78f69295fa';

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
