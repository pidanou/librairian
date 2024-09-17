// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$attachmentRepositoryHash() =>
    r'b77c76e60655408ece244d4740f5489f3c6885b4';

/// See also [attachmentRepository].
@ProviderFor(attachmentRepository)
final attachmentRepositoryProvider =
    AutoDisposeProvider<AttachmentRepository>.internal(
  attachmentRepository,
  name: r'attachmentRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$attachmentRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AttachmentRepositoryRef = AutoDisposeProviderRef<AttachmentRepository>;
String _$attachmentHash() => r'944e29a5ec1263fa93bd0e11705524db90c3bdab';

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

String _$itemAttachmentsControllerHash() =>
    r'c937ec8f81794f8f20f25561037ea7571751f097';

abstract class _$ItemAttachmentsController
    extends BuildlessAutoDisposeAsyncNotifier<List<Attachment>> {
  late final String? itemId;

  FutureOr<List<Attachment>> build(
    String? itemId,
  );
}

/// See also [ItemAttachmentsController].
@ProviderFor(ItemAttachmentsController)
const itemAttachmentsControllerProvider = ItemAttachmentsControllerFamily();

/// See also [ItemAttachmentsController].
class ItemAttachmentsControllerFamily
    extends Family<AsyncValue<List<Attachment>>> {
  /// See also [ItemAttachmentsController].
  const ItemAttachmentsControllerFamily();

  /// See also [ItemAttachmentsController].
  ItemAttachmentsControllerProvider call(
    String? itemId,
  ) {
    return ItemAttachmentsControllerProvider(
      itemId,
    );
  }

  @override
  ItemAttachmentsControllerProvider getProviderOverride(
    covariant ItemAttachmentsControllerProvider provider,
  ) {
    return call(
      provider.itemId,
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
  String? get name => r'itemAttachmentsControllerProvider';
}

/// See also [ItemAttachmentsController].
class ItemAttachmentsControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ItemAttachmentsController,
        List<Attachment>> {
  /// See also [ItemAttachmentsController].
  ItemAttachmentsControllerProvider(
    String? itemId,
  ) : this._internal(
          () => ItemAttachmentsController()..itemId = itemId,
          from: itemAttachmentsControllerProvider,
          name: r'itemAttachmentsControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$itemAttachmentsControllerHash,
          dependencies: ItemAttachmentsControllerFamily._dependencies,
          allTransitiveDependencies:
              ItemAttachmentsControllerFamily._allTransitiveDependencies,
          itemId: itemId,
        );

  ItemAttachmentsControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.itemId,
  }) : super.internal();

  final String? itemId;

  @override
  FutureOr<List<Attachment>> runNotifierBuild(
    covariant ItemAttachmentsController notifier,
  ) {
    return notifier.build(
      itemId,
    );
  }

  @override
  Override overrideWith(ItemAttachmentsController Function() create) {
    return ProviderOverride(
      origin: this,
      override: ItemAttachmentsControllerProvider._internal(
        () => create()..itemId = itemId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        itemId: itemId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ItemAttachmentsController,
      List<Attachment>> createElement() {
    return _ItemAttachmentsControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ItemAttachmentsControllerProvider && other.itemId == itemId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, itemId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ItemAttachmentsControllerRef
    on AutoDisposeAsyncNotifierProviderRef<List<Attachment>> {
  /// The parameter `itemId` of this provider.
  String? get itemId;
}

class _ItemAttachmentsControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ItemAttachmentsController,
        List<Attachment>> with ItemAttachmentsControllerRef {
  _ItemAttachmentsControllerProviderElement(super.provider);

  @override
  String? get itemId => (origin as ItemAttachmentsControllerProvider).itemId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
