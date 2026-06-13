// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dashboardHash() => r'8daf6a148ed5bd23c884bc90a584c9602808ebd0';

/// See also [dashboard].
@ProviderFor(dashboard)
final dashboardProvider = AutoDisposeFutureProvider<DashboardSummary>.internal(
  dashboard,
  name: r'dashboardProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$dashboardHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DashboardRef = AutoDisposeFutureProviderRef<DashboardSummary>;
String _$walletBalancesHash() => r'7336e33749d1642c042e4bf63a614b4aa8d97bd9';

/// See also [walletBalances].
@ProviderFor(walletBalances)
final walletBalancesProvider =
    AutoDisposeStreamProvider<List<WalletWithBalance>>.internal(
  walletBalances,
  name: r'walletBalancesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$walletBalancesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WalletBalancesRef
    = AutoDisposeStreamProviderRef<List<WalletWithBalance>>;
String _$bucketAvailablesHash() => r'204cfde38f0cf43eb6e2e4df692a5bdfc31ef951';

/// See also [bucketAvailables].
@ProviderFor(bucketAvailables)
final bucketAvailablesProvider =
    AutoDisposeStreamProvider<List<BucketWithAvailable>>.internal(
  bucketAvailables,
  name: r'bucketAvailablesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bucketAvailablesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BucketAvailablesRef
    = AutoDisposeStreamProviderRef<List<BucketWithAvailable>>;
String _$currentDueHash() => r'f583a7b156a6b4e3e88a7938f454d75b170d650e';

/// See also [currentDue].
@ProviderFor(currentDue)
final currentDueProvider = AutoDisposeStreamProvider<double>.internal(
  currentDue,
  name: r'currentDueProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$currentDueHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentDueRef = AutoDisposeStreamProviderRef<double>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
