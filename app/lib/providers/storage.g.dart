// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$deviceHash() => r'683116ac3f4c1ec2bb5d6593476e642426d13186';

/// See also [device].
@ProviderFor(device)
final deviceProvider = AutoDisposeProvider<List<st.Storage>>.internal(
  device,
  name: r'deviceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$deviceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DeviceRef = AutoDisposeProviderRef<List<st.Storage>>;
String _$storageHash() => r'4a3529a0c92b1cb8ed054e566ef4e92ec7d65230';

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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
