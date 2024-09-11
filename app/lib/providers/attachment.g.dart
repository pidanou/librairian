// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$attachmentHash() => r'ec911fb6a54da3be10806e2424981422f354f433';

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

/// See also [attachment].
@ProviderFor(attachment)
const attachmentProvider = AttachmentFamily();

/// See also [attachment].
class AttachmentFamily extends Family<AsyncValue<Uint8List>> {
  /// See also [attachment].
  const AttachmentFamily();

  /// See also [attachment].
  AttachmentProvider call(
    String fileName,
  ) {
    return AttachmentProvider(
      fileName,
    );
  }

  @override
  AttachmentProvider getProviderOverride(
    covariant AttachmentProvider provider,
  ) {
    return call(
      provider.fileName,
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
  String? get name => r'attachmentProvider';
}

/// See also [attachment].
class AttachmentProvider extends AutoDisposeFutureProvider<Uint8List> {
  /// See also [attachment].
  AttachmentProvider(
    String fileName,
  ) : this._internal(
          (ref) => attachment(
            ref as AttachmentRef,
            fileName,
          ),
          from: attachmentProvider,
          name: r'attachmentProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$attachmentHash,
          dependencies: AttachmentFamily._dependencies,
          allTransitiveDependencies:
              AttachmentFamily._allTransitiveDependencies,
          fileName: fileName,
        );

  AttachmentProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.fileName,
  }) : super.internal();

  final String fileName;

  @override
  Override overrideWith(
    FutureOr<Uint8List> Function(AttachmentRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AttachmentProvider._internal(
        (ref) => create(ref as AttachmentRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        fileName: fileName,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Uint8List> createElement() {
    return _AttachmentProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AttachmentProvider && other.fileName == fileName;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, fileName.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin AttachmentRef on AutoDisposeFutureProviderRef<Uint8List> {
  /// The parameter `fileName` of this provider.
  String get fileName;
}

class _AttachmentProviderElement
    extends AutoDisposeFutureProviderElement<Uint8List> with AttachmentRef {
  _AttachmentProviderElement(super.provider);

  @override
  String get fileName => (origin as AttachmentProvider).fileName;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
