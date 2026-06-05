// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$productListHash() => r'a1b780f252568b8614a703280422a78a494b8a8a';

/// See also [productList].
@ProviderFor(productList)
final productListProvider = StreamProvider<List<Product>>.internal(
  productList,
  name: r'productListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$productListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProductListRef = StreamProviderRef<List<Product>>;
String _$filteredProductListHash() =>
    r'69fe30059014c393101918535bd63f8b161c77bb';

/// See also [filteredProductList].
@ProviderFor(filteredProductList)
final filteredProductListProvider = Provider<List<Product>>.internal(
  filteredProductList,
  name: r'filteredProductListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredProductListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredProductListRef = ProviderRef<List<Product>>;
String _$productByIdHash() => r'8c4767cbadd884193aff3a947335731eed855303';

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

/// See also [productById].
@ProviderFor(productById)
const productByIdProvider = ProductByIdFamily();

/// See also [productById].
class ProductByIdFamily extends Family<AsyncValue<Product?>> {
  /// See also [productById].
  const ProductByIdFamily();

  /// See also [productById].
  ProductByIdProvider call(
    int id,
  ) {
    return ProductByIdProvider(
      id,
    );
  }

  @override
  ProductByIdProvider getProviderOverride(
    covariant ProductByIdProvider provider,
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
  String? get name => r'productByIdProvider';
}

/// See also [productById].
class ProductByIdProvider extends AutoDisposeFutureProvider<Product?> {
  /// See also [productById].
  ProductByIdProvider(
    int id,
  ) : this._internal(
          (ref) => productById(
            ref as ProductByIdRef,
            id,
          ),
          from: productByIdProvider,
          name: r'productByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$productByIdHash,
          dependencies: ProductByIdFamily._dependencies,
          allTransitiveDependencies:
              ProductByIdFamily._allTransitiveDependencies,
          id: id,
        );

  ProductByIdProvider._internal(
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
    FutureOr<Product?> Function(ProductByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProductByIdProvider._internal(
        (ref) => create(ref as ProductByIdRef),
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
  AutoDisposeFutureProviderElement<Product?> createElement() {
    return _ProductByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductByIdProvider && other.id == id;
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
mixin ProductByIdRef on AutoDisposeFutureProviderRef<Product?> {
  /// The parameter `id` of this provider.
  int get id;
}

class _ProductByIdProviderElement
    extends AutoDisposeFutureProviderElement<Product?> with ProductByIdRef {
  _ProductByIdProviderElement(super.provider);

  @override
  int get id => (origin as ProductByIdProvider).id;
}

String _$productMovementsHash() => r'21344017a0b5f7822f5d49336f9c336ec06c55c6';

/// See also [productMovements].
@ProviderFor(productMovements)
const productMovementsProvider = ProductMovementsFamily();

/// See also [productMovements].
class ProductMovementsFamily extends Family<AsyncValue<List<StockMovement>>> {
  /// See also [productMovements].
  const ProductMovementsFamily();

  /// See also [productMovements].
  ProductMovementsProvider call(
    int productId,
  ) {
    return ProductMovementsProvider(
      productId,
    );
  }

  @override
  ProductMovementsProvider getProviderOverride(
    covariant ProductMovementsProvider provider,
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
  String? get name => r'productMovementsProvider';
}

/// See also [productMovements].
class ProductMovementsProvider
    extends AutoDisposeStreamProvider<List<StockMovement>> {
  /// See also [productMovements].
  ProductMovementsProvider(
    int productId,
  ) : this._internal(
          (ref) => productMovements(
            ref as ProductMovementsRef,
            productId,
          ),
          from: productMovementsProvider,
          name: r'productMovementsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$productMovementsHash,
          dependencies: ProductMovementsFamily._dependencies,
          allTransitiveDependencies:
              ProductMovementsFamily._allTransitiveDependencies,
          productId: productId,
        );

  ProductMovementsProvider._internal(
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
    Stream<List<StockMovement>> Function(ProductMovementsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProductMovementsProvider._internal(
        (ref) => create(ref as ProductMovementsRef),
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
  AutoDisposeStreamProviderElement<List<StockMovement>> createElement() {
    return _ProductMovementsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductMovementsProvider && other.productId == productId;
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
mixin ProductMovementsRef on AutoDisposeStreamProviderRef<List<StockMovement>> {
  /// The parameter `productId` of this provider.
  int get productId;
}

class _ProductMovementsProviderElement
    extends AutoDisposeStreamProviderElement<List<StockMovement>>
    with ProductMovementsRef {
  _ProductMovementsProviderElement(super.provider);

  @override
  int get productId => (origin as ProductMovementsProvider).productId;
}

String _$productSalesHash() => r'a4f1eef139dc02f41ce1a90c6e370f994d0ea37c';

/// See also [productSales].
@ProviderFor(productSales)
const productSalesProvider = ProductSalesFamily();

/// See also [productSales].
class ProductSalesFamily extends Family<AsyncValue<List<Sale>>> {
  /// See also [productSales].
  const ProductSalesFamily();

  /// See also [productSales].
  ProductSalesProvider call(
    int productId,
  ) {
    return ProductSalesProvider(
      productId,
    );
  }

  @override
  ProductSalesProvider getProviderOverride(
    covariant ProductSalesProvider provider,
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
  String? get name => r'productSalesProvider';
}

/// See also [productSales].
class ProductSalesProvider extends AutoDisposeStreamProvider<List<Sale>> {
  /// See also [productSales].
  ProductSalesProvider(
    int productId,
  ) : this._internal(
          (ref) => productSales(
            ref as ProductSalesRef,
            productId,
          ),
          from: productSalesProvider,
          name: r'productSalesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$productSalesHash,
          dependencies: ProductSalesFamily._dependencies,
          allTransitiveDependencies:
              ProductSalesFamily._allTransitiveDependencies,
          productId: productId,
        );

  ProductSalesProvider._internal(
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
    Stream<List<Sale>> Function(ProductSalesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProductSalesProvider._internal(
        (ref) => create(ref as ProductSalesRef),
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
  AutoDisposeStreamProviderElement<List<Sale>> createElement() {
    return _ProductSalesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductSalesProvider && other.productId == productId;
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
mixin ProductSalesRef on AutoDisposeStreamProviderRef<List<Sale>> {
  /// The parameter `productId` of this provider.
  int get productId;
}

class _ProductSalesProviderElement
    extends AutoDisposeStreamProviderElement<List<Sale>> with ProductSalesRef {
  _ProductSalesProviderElement(super.provider);

  @override
  int get productId => (origin as ProductSalesProvider).productId;
}

String _$productFilterHash() => r'3789906644e8145905dbfbe9d39b331d86b5604b';

/// See also [ProductFilter].
@ProviderFor(ProductFilter)
final productFilterProvider =
    NotifierProvider<ProductFilter, ProductFilterState>.internal(
  ProductFilter.new,
  name: r'productFilterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$productFilterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ProductFilter = Notifier<ProductFilterState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
