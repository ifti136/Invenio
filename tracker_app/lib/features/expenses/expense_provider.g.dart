// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$expenseListHash() => r'c3a75321beaeff11e453ced5eeb00b3e009bde31';

/// See also [expenseList].
@ProviderFor(expenseList)
final expenseListProvider = StreamProvider<List<Expense>>.internal(
  expenseList,
  name: r'expenseListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$expenseListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ExpenseListRef = StreamProviderRef<List<Expense>>;
String _$filteredExpenseListHash() =>
    r'2234e9aa030ffc3569c61e832705da1ce2a981e5';

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

/// See also [filteredExpenseList].
@ProviderFor(filteredExpenseList)
const filteredExpenseListProvider = FilteredExpenseListFamily();

/// See also [filteredExpenseList].
class FilteredExpenseListFamily extends Family<AsyncValue<List<Expense>>> {
  /// See also [filteredExpenseList].
  const FilteredExpenseListFamily();

  /// See also [filteredExpenseList].
  FilteredExpenseListProvider call(
    ExpenseFilter filter,
  ) {
    return FilteredExpenseListProvider(
      filter,
    );
  }

  @override
  FilteredExpenseListProvider getProviderOverride(
    covariant FilteredExpenseListProvider provider,
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
  String? get name => r'filteredExpenseListProvider';
}

/// See also [filteredExpenseList].
class FilteredExpenseListProvider extends StreamProvider<List<Expense>> {
  /// See also [filteredExpenseList].
  FilteredExpenseListProvider(
    ExpenseFilter filter,
  ) : this._internal(
          (ref) => filteredExpenseList(
            ref as FilteredExpenseListRef,
            filter,
          ),
          from: filteredExpenseListProvider,
          name: r'filteredExpenseListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$filteredExpenseListHash,
          dependencies: FilteredExpenseListFamily._dependencies,
          allTransitiveDependencies:
              FilteredExpenseListFamily._allTransitiveDependencies,
          filter: filter,
        );

  FilteredExpenseListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.filter,
  }) : super.internal();

  final ExpenseFilter filter;

  @override
  Override overrideWith(
    Stream<List<Expense>> Function(FilteredExpenseListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FilteredExpenseListProvider._internal(
        (ref) => create(ref as FilteredExpenseListRef),
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
  StreamProviderElement<List<Expense>> createElement() {
    return _FilteredExpenseListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredExpenseListProvider && other.filter == filter;
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
mixin FilteredExpenseListRef on StreamProviderRef<List<Expense>> {
  /// The parameter `filter` of this provider.
  ExpenseFilter get filter;
}

class _FilteredExpenseListProviderElement
    extends StreamProviderElement<List<Expense>> with FilteredExpenseListRef {
  _FilteredExpenseListProviderElement(super.provider);

  @override
  ExpenseFilter get filter => (origin as FilteredExpenseListProvider).filter;
}

String _$expenseDetailHash() => r'be539d83ce6e2f1df4cd8b6f39bb5a5173120fbc';

/// See also [expenseDetail].
@ProviderFor(expenseDetail)
const expenseDetailProvider = ExpenseDetailFamily();

/// See also [expenseDetail].
class ExpenseDetailFamily extends Family<AsyncValue<Expense?>> {
  /// See also [expenseDetail].
  const ExpenseDetailFamily();

  /// See also [expenseDetail].
  ExpenseDetailProvider call(
    int id,
  ) {
    return ExpenseDetailProvider(
      id,
    );
  }

  @override
  ExpenseDetailProvider getProviderOverride(
    covariant ExpenseDetailProvider provider,
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
  String? get name => r'expenseDetailProvider';
}

/// See also [expenseDetail].
class ExpenseDetailProvider extends AutoDisposeFutureProvider<Expense?> {
  /// See also [expenseDetail].
  ExpenseDetailProvider(
    int id,
  ) : this._internal(
          (ref) => expenseDetail(
            ref as ExpenseDetailRef,
            id,
          ),
          from: expenseDetailProvider,
          name: r'expenseDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$expenseDetailHash,
          dependencies: ExpenseDetailFamily._dependencies,
          allTransitiveDependencies:
              ExpenseDetailFamily._allTransitiveDependencies,
          id: id,
        );

  ExpenseDetailProvider._internal(
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
    FutureOr<Expense?> Function(ExpenseDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ExpenseDetailProvider._internal(
        (ref) => create(ref as ExpenseDetailRef),
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
  AutoDisposeFutureProviderElement<Expense?> createElement() {
    return _ExpenseDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ExpenseDetailProvider && other.id == id;
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
mixin ExpenseDetailRef on AutoDisposeFutureProviderRef<Expense?> {
  /// The parameter `id` of this provider.
  int get id;
}

class _ExpenseDetailProviderElement
    extends AutoDisposeFutureProviderElement<Expense?> with ExpenseDetailRef {
  _ExpenseDetailProviderElement(super.provider);

  @override
  int get id => (origin as ExpenseDetailProvider).id;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
