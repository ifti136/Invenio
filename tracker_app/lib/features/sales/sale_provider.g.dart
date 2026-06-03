// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$saleListHash() => r'a4300e20c04fc4b5f3de72201155f4b462c3ae40';

/// See also [saleList].
@ProviderFor(saleList)
final saleListProvider = AutoDisposeStreamProvider<List<Sale>>.internal(
  saleList,
  name: r'saleListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$saleListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SaleListRef = AutoDisposeStreamProviderRef<List<Sale>>;
String _$filteredSaleListHash() => r'6c200079852e45e873e86e675fa08b51f674e8f7';

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

/// See also [filteredSaleList].
@ProviderFor(filteredSaleList)
const filteredSaleListProvider = FilteredSaleListFamily();

/// See also [filteredSaleList].
class FilteredSaleListFamily extends Family<AsyncValue<List<Sale>>> {
  /// See also [filteredSaleList].
  const FilteredSaleListFamily();

  /// See also [filteredSaleList].
  FilteredSaleListProvider call(
    SaleFilter filter,
  ) {
    return FilteredSaleListProvider(
      filter,
    );
  }

  @override
  FilteredSaleListProvider getProviderOverride(
    covariant FilteredSaleListProvider provider,
  ) {
    return call(
      provider.filter,
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
  String? get name => r'filteredSaleListProvider';
}

/// See also [filteredSaleList].
class FilteredSaleListProvider extends AutoDisposeStreamProvider<List<Sale>> {
  /// See also [filteredSaleList].
  FilteredSaleListProvider(
    SaleFilter filter,
  ) : this._internal(
          (ref) => filteredSaleList(
            ref as FilteredSaleListRef,
            filter,
          ),
          from: filteredSaleListProvider,
          name: r'filteredSaleListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$filteredSaleListHash,
          dependencies: FilteredSaleListFamily._dependencies,
          allTransitiveDependencies:
              FilteredSaleListFamily._allTransitiveDependencies,
          filter: filter,
        );

  FilteredSaleListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.filter,
  }) : super.internal();

  final SaleFilter filter;

  @override
  Override overrideWith(
    Stream<List<Sale>> Function(FilteredSaleListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FilteredSaleListProvider._internal(
        (ref) => create(ref as FilteredSaleListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        filter: filter,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Sale>> createElement() {
    return _FilteredSaleListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredSaleListProvider && other.filter == filter;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, filter.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FilteredSaleListRef on AutoDisposeStreamProviderRef<List<Sale>> {
  /// The parameter `filter` of this provider.
  SaleFilter get filter;
}

class _FilteredSaleListProviderElement
    extends AutoDisposeStreamProviderElement<List<Sale>>
    with FilteredSaleListRef {
  _FilteredSaleListProviderElement(super.provider);

  @override
  SaleFilter get filter => (origin as FilteredSaleListProvider).filter;
}

String _$saleDetailHash() => r'93c17c166949da4e23022da9d1193dfbad2c64bd';

/// See also [saleDetail].
@ProviderFor(saleDetail)
const saleDetailProvider = SaleDetailFamily();

/// See also [saleDetail].
class SaleDetailFamily extends Family<AsyncValue<Sale?>> {
  /// See also [saleDetail].
  const SaleDetailFamily();

  /// See also [saleDetail].
  SaleDetailProvider call(
    int id,
  ) {
    return SaleDetailProvider(
      id,
    );
  }

  @override
  SaleDetailProvider getProviderOverride(
    covariant SaleDetailProvider provider,
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
  String? get name => r'saleDetailProvider';
}

/// See also [saleDetail].
class SaleDetailProvider extends AutoDisposeFutureProvider<Sale?> {
  /// See also [saleDetail].
  SaleDetailProvider(
    int id,
  ) : this._internal(
          (ref) => saleDetail(
            ref as SaleDetailRef,
            id,
          ),
          from: saleDetailProvider,
          name: r'saleDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$saleDetailHash,
          dependencies: SaleDetailFamily._dependencies,
          allTransitiveDependencies:
              SaleDetailFamily._allTransitiveDependencies,
          id: id,
        );

  SaleDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final int id;

  @override
  Override overrideWith(
    FutureOr<Sale?> Function(SaleDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SaleDetailProvider._internal(
        (ref) => create(ref as SaleDetailRef),
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
  AutoDisposeFutureProviderElement<Sale?> createElement() {
    return _SaleDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SaleDetailProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SaleDetailRef on AutoDisposeFutureProviderRef<Sale?> {
  /// The parameter `id` of this provider.
  int get id;
}

class _SaleDetailProviderElement extends AutoDisposeFutureProviderElement<Sale?>
    with SaleDetailRef {
  _SaleDetailProviderElement(super.provider);

  @override
  int get id => (origin as SaleDetailProvider).id;
}

String _$lastSellingPriceHash() => r'de81aff5e79f1c338c4cecc65928b461eedc6674';

/// See also [lastSellingPrice].
@ProviderFor(lastSellingPrice)
const lastSellingPriceProvider = LastSellingPriceFamily();

/// See also [lastSellingPrice].
class LastSellingPriceFamily extends Family<AsyncValue<double?>> {
  /// See also [lastSellingPrice].
  const LastSellingPriceFamily();

  /// See also [lastSellingPrice].
  LastSellingPriceProvider call(
    int productId,
  ) {
    return LastSellingPriceProvider(
      productId,
    );
  }

  @override
  LastSellingPriceProvider getProviderOverride(
    covariant LastSellingPriceProvider provider,
  ) {
    return call(
      provider.productId,
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
  String? get name => r'lastSellingPriceProvider';
}

/// See also [lastSellingPrice].
class LastSellingPriceProvider extends AutoDisposeFutureProvider<double?> {
  /// See also [lastSellingPrice].
  LastSellingPriceProvider(
    int productId,
  ) : this._internal(
          (ref) => lastSellingPrice(
            ref as LastSellingPriceRef,
            productId,
          ),
          from: lastSellingPriceProvider,
          name: r'lastSellingPriceProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$lastSellingPriceHash,
          dependencies: LastSellingPriceFamily._dependencies,
          allTransitiveDependencies:
              LastSellingPriceFamily._allTransitiveDependencies,
          productId: productId,
        );

  LastSellingPriceProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.productId,
  }) : super.internal();

  final int productId;

  @override
  Override overrideWith(
    FutureOr<double?> Function(LastSellingPriceRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LastSellingPriceProvider._internal(
        (ref) => create(ref as LastSellingPriceRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        productId: productId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<double?> createElement() {
    return _LastSellingPriceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LastSellingPriceProvider && other.productId == productId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, productId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LastSellingPriceRef on AutoDisposeFutureProviderRef<double?> {
  /// The parameter `productId` of this provider.
  int get productId;
}

class _LastSellingPriceProviderElement
    extends AutoDisposeFutureProviderElement<double?> with LastSellingPriceRef {
  _LastSellingPriceProviderElement(super.provider);

  @override
  int get productId => (origin as LastSellingPriceProvider).productId;
}

String _$productCostMapHash() => r'042daa8618e97dd8ecdde9480075343efff45751';

/// See also [productCostMap].
@ProviderFor(productCostMap)
final productCostMapProvider =
    AutoDisposeFutureProvider<Map<int, double>>.internal(
  productCostMap,
  name: r'productCostMapProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$productCostMapHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProductCostMapRef = AutoDisposeFutureProviderRef<Map<int, double>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
