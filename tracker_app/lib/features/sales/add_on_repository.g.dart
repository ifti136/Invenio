// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_on_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$addOnRepositoryHash() => r'613ea1eb0e1394660955856d8d2e96565f78a0ca';

/// See also [addOnRepository].
@ProviderFor(addOnRepository)
final addOnRepositoryProvider = AutoDisposeProvider<AddOnRepository>.internal(
  addOnRepository,
  name: r'addOnRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$addOnRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AddOnRepositoryRef = AutoDisposeProviderRef<AddOnRepository>;
String _$addOnTypesHash() => r'0fc20907ba330500f383d465415c1e257ff17629';

/// See also [addOnTypes].
@ProviderFor(addOnTypes)
final addOnTypesProvider = AutoDisposeStreamProvider<List<AddOnType>>.internal(
  addOnTypes,
  name: r'addOnTypesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$addOnTypesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AddOnTypesRef = AutoDisposeStreamProviderRef<List<AddOnType>>;
String _$activeAddOnTypesHash() => r'46f0e6902c873fb9f11890cb2b46bb1852723e3f';

/// See also [activeAddOnTypes].
@ProviderFor(activeAddOnTypes)
final activeAddOnTypesProvider =
    AutoDisposeStreamProvider<List<AddOnType>>.internal(
  activeAddOnTypes,
  name: r'activeAddOnTypesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeAddOnTypesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveAddOnTypesRef = AutoDisposeStreamProviderRef<List<AddOnType>>;
String _$saleAddOnsHash() => r'ecb2801dd4483c9c5e7173aac28bca11873d5ee3';

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

/// See also [saleAddOns].
@ProviderFor(saleAddOns)
const saleAddOnsProvider = SaleAddOnsFamily();

/// See also [saleAddOns].
class SaleAddOnsFamily extends Family<AsyncValue<List<SaleAddOn>>> {
  /// See also [saleAddOns].
  const SaleAddOnsFamily();

  /// See also [saleAddOns].
  SaleAddOnsProvider call(
    int saleId,
  ) {
    return SaleAddOnsProvider(
      saleId,
    );
  }

  @override
  SaleAddOnsProvider getProviderOverride(
    covariant SaleAddOnsProvider provider,
  ) {
    return call(
      provider.saleId,
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
  String? get name => r'saleAddOnsProvider';
}

/// See also [saleAddOns].
class SaleAddOnsProvider extends AutoDisposeStreamProvider<List<SaleAddOn>> {
  /// See also [saleAddOns].
  SaleAddOnsProvider(
    int saleId,
  ) : this._internal(
          (ref) => saleAddOns(
            ref as SaleAddOnsRef,
            saleId,
          ),
          from: saleAddOnsProvider,
          name: r'saleAddOnsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$saleAddOnsHash,
          dependencies: SaleAddOnsFamily._dependencies,
          allTransitiveDependencies:
              SaleAddOnsFamily._allTransitiveDependencies,
          saleId: saleId,
        );

  SaleAddOnsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.saleId,
  }) : super.internal();

  final int saleId;

  @override
  Override overrideWith(
    Stream<List<SaleAddOn>> Function(SaleAddOnsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SaleAddOnsProvider._internal(
        (ref) => create(ref as SaleAddOnsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        saleId: saleId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<SaleAddOn>> createElement() {
    return _SaleAddOnsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SaleAddOnsProvider && other.saleId == saleId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, saleId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SaleAddOnsRef on AutoDisposeStreamProviderRef<List<SaleAddOn>> {
  /// The parameter `saleId` of this provider.
  int get saleId;
}

class _SaleAddOnsProviderElement
    extends AutoDisposeStreamProviderElement<List<SaleAddOn>>
    with SaleAddOnsRef {
  _SaleAddOnsProviderElement(super.provider);

  @override
  int get saleId => (origin as SaleAddOnsProvider).saleId;
}

String _$addOnTotalCostHash() => r'a024fafd06e695bcb5c4a7983c51adcd3a6b5c2b';

/// See also [addOnTotalCost].
@ProviderFor(addOnTotalCost)
const addOnTotalCostProvider = AddOnTotalCostFamily();

/// See also [addOnTotalCost].
class AddOnTotalCostFamily extends Family<AsyncValue<double>> {
  /// See also [addOnTotalCost].
  const AddOnTotalCostFamily();

  /// See also [addOnTotalCost].
  AddOnTotalCostProvider call(
    int saleId,
  ) {
    return AddOnTotalCostProvider(
      saleId,
    );
  }

  @override
  AddOnTotalCostProvider getProviderOverride(
    covariant AddOnTotalCostProvider provider,
  ) {
    return call(
      provider.saleId,
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
  String? get name => r'addOnTotalCostProvider';
}

/// See also [addOnTotalCost].
class AddOnTotalCostProvider extends AutoDisposeStreamProvider<double> {
  /// See also [addOnTotalCost].
  AddOnTotalCostProvider(
    int saleId,
  ) : this._internal(
          (ref) => addOnTotalCost(
            ref as AddOnTotalCostRef,
            saleId,
          ),
          from: addOnTotalCostProvider,
          name: r'addOnTotalCostProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$addOnTotalCostHash,
          dependencies: AddOnTotalCostFamily._dependencies,
          allTransitiveDependencies:
              AddOnTotalCostFamily._allTransitiveDependencies,
          saleId: saleId,
        );

  AddOnTotalCostProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.saleId,
  }) : super.internal();

  final int saleId;

  @override
  Override overrideWith(
    Stream<double> Function(AddOnTotalCostRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AddOnTotalCostProvider._internal(
        (ref) => create(ref as AddOnTotalCostRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        saleId: saleId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<double> createElement() {
    return _AddOnTotalCostProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AddOnTotalCostProvider && other.saleId == saleId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, saleId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AddOnTotalCostRef on AutoDisposeStreamProviderRef<double> {
  /// The parameter `saleId` of this provider.
  int get saleId;
}

class _AddOnTotalCostProviderElement
    extends AutoDisposeStreamProviderElement<double> with AddOnTotalCostRef {
  _AddOnTotalCostProviderElement(super.provider);

  @override
  int get saleId => (origin as AddOnTotalCostProvider).saleId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
