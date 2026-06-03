// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$reportRepositoryHash() => r'2f739068092b19870b6c047a2d5270e38612a1b3';

/// See also [reportRepository].
@ProviderFor(reportRepository)
final reportRepositoryProvider = Provider<ReportRepository>.internal(
  reportRepository,
  name: r'reportRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reportRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ReportRepositoryRef = ProviderRef<ReportRepository>;
String _$dailySnapshotsHash() => r'ae5a72de60e833848546753454ff3b17783bba8b';

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

/// See also [dailySnapshots].
@ProviderFor(dailySnapshots)
const dailySnapshotsProvider = DailySnapshotsFamily();

/// See also [dailySnapshots].
class DailySnapshotsFamily extends Family<AsyncValue<List<DailySnapshot>>> {
  /// See also [dailySnapshots].
  const DailySnapshotsFamily();

  /// See also [dailySnapshots].
  DailySnapshotsProvider call(
    int year,
    int month,
  ) {
    return DailySnapshotsProvider(
      year,
      month,
    );
  }

  @override
  DailySnapshotsProvider getProviderOverride(
    covariant DailySnapshotsProvider provider,
  ) {
    return call(
      provider.year,
      provider.month,
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
  String? get name => r'dailySnapshotsProvider';
}

/// See also [dailySnapshots].
class DailySnapshotsProvider
    extends AutoDisposeFutureProvider<List<DailySnapshot>> {
  /// See also [dailySnapshots].
  DailySnapshotsProvider(
    int year,
    int month,
  ) : this._internal(
          (ref) => dailySnapshots(
            ref as DailySnapshotsRef,
            year,
            month,
          ),
          from: dailySnapshotsProvider,
          name: r'dailySnapshotsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$dailySnapshotsHash,
          dependencies: DailySnapshotsFamily._dependencies,
          allTransitiveDependencies:
              DailySnapshotsFamily._allTransitiveDependencies,
          year: year,
          month: month,
        );

  DailySnapshotsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.year,
    required this.month,
  }) : super.internal();

  final int year;
  final int month;

  @override
  Override overrideWith(
    FutureOr<List<DailySnapshot>> Function(DailySnapshotsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DailySnapshotsProvider._internal(
        (ref) => create(ref as DailySnapshotsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        year: year,
        month: month,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<DailySnapshot>> createElement() {
    return _DailySnapshotsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DailySnapshotsProvider &&
        other.year == year &&
        other.month == month;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, year.hashCode);
    hash = _SystemHash.combine(hash, month.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DailySnapshotsRef on AutoDisposeFutureProviderRef<List<DailySnapshot>> {
  /// The parameter `year` of this provider.
  int get year;

  /// The parameter `month` of this provider.
  int get month;
}

class _DailySnapshotsProviderElement
    extends AutoDisposeFutureProviderElement<List<DailySnapshot>>
    with DailySnapshotsRef {
  _DailySnapshotsProviderElement(super.provider);

  @override
  int get year => (origin as DailySnapshotsProvider).year;
  @override
  int get month => (origin as DailySnapshotsProvider).month;
}

String _$monthlySummariesHash() => r'67571bd48db42b659d7536cc0d0ac7fcbfa83f1c';

/// See also [monthlySummaries].
@ProviderFor(monthlySummaries)
const monthlySummariesProvider = MonthlySummariesFamily();

/// See also [monthlySummaries].
class MonthlySummariesFamily extends Family<AsyncValue<List<MonthlySummary>>> {
  /// See also [monthlySummaries].
  const MonthlySummariesFamily();

  /// See also [monthlySummaries].
  MonthlySummariesProvider call(
    int year,
  ) {
    return MonthlySummariesProvider(
      year,
    );
  }

  @override
  MonthlySummariesProvider getProviderOverride(
    covariant MonthlySummariesProvider provider,
  ) {
    return call(
      provider.year,
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
  String? get name => r'monthlySummariesProvider';
}

/// See also [monthlySummaries].
class MonthlySummariesProvider
    extends AutoDisposeFutureProvider<List<MonthlySummary>> {
  /// See also [monthlySummaries].
  MonthlySummariesProvider(
    int year,
  ) : this._internal(
          (ref) => monthlySummaries(
            ref as MonthlySummariesRef,
            year,
          ),
          from: monthlySummariesProvider,
          name: r'monthlySummariesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$monthlySummariesHash,
          dependencies: MonthlySummariesFamily._dependencies,
          allTransitiveDependencies:
              MonthlySummariesFamily._allTransitiveDependencies,
          year: year,
        );

  MonthlySummariesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.year,
  }) : super.internal();

  final int year;

  @override
  Override overrideWith(
    FutureOr<List<MonthlySummary>> Function(MonthlySummariesRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MonthlySummariesProvider._internal(
        (ref) => create(ref as MonthlySummariesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        year: year,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<MonthlySummary>> createElement() {
    return _MonthlySummariesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthlySummariesProvider && other.year == year;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, year.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MonthlySummariesRef
    on AutoDisposeFutureProviderRef<List<MonthlySummary>> {
  /// The parameter `year` of this provider.
  int get year;
}

class _MonthlySummariesProviderElement
    extends AutoDisposeFutureProviderElement<List<MonthlySummary>>
    with MonthlySummariesRef {
  _MonthlySummariesProviderElement(super.provider);

  @override
  int get year => (origin as MonthlySummariesProvider).year;
}

String _$productReportHash() => r'e341ab8f8eb1c4e128a44194b9223a90cf0136a9';

/// See also [productReport].
@ProviderFor(productReport)
final productReportProvider =
    AutoDisposeFutureProvider<List<ProductReportRow>>.internal(
  productReport,
  name: r'productReportProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$productReportHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProductReportRef = AutoDisposeFutureProviderRef<List<ProductReportRow>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
