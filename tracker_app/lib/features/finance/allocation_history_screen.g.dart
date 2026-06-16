// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'allocation_history_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$ruleHistoryHash() => r'4176f0c1c169d4a8200869b406aaf9cc378c7b34';

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

/// See also [ruleHistory].
@ProviderFor(ruleHistory)
const ruleHistoryProvider = RuleHistoryFamily();

/// See also [ruleHistory].
class RuleHistoryFamily extends Family<AsyncValue<List<RuleMonthlyDetail>>> {
  /// See also [ruleHistory].
  const RuleHistoryFamily();

  /// See also [ruleHistory].
  RuleHistoryProvider call(
    int ruleId,
  ) {
    return RuleHistoryProvider(
      ruleId,
    );
  }

  @override
  RuleHistoryProvider getProviderOverride(
    covariant RuleHistoryProvider provider,
  ) {
    return call(
      provider.ruleId,
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
  String? get name => r'ruleHistoryProvider';
}

/// See also [ruleHistory].
class RuleHistoryProvider
    extends AutoDisposeFutureProvider<List<RuleMonthlyDetail>> {
  /// See also [ruleHistory].
  RuleHistoryProvider(
    int ruleId,
  ) : this._internal(
          (ref) => ruleHistory(
            ref as RuleHistoryRef,
            ruleId,
          ),
          from: ruleHistoryProvider,
          name: r'ruleHistoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$ruleHistoryHash,
          dependencies: RuleHistoryFamily._dependencies,
          allTransitiveDependencies:
              RuleHistoryFamily._allTransitiveDependencies,
          ruleId: ruleId,
        );

  RuleHistoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.ruleId,
  }) : super.internal();

  final int ruleId;

  @override
  Override overrideWith(
    FutureOr<List<RuleMonthlyDetail>> Function(RuleHistoryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RuleHistoryProvider._internal(
        (ref) => create(ref as RuleHistoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        ruleId: ruleId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<RuleMonthlyDetail>> createElement() {
    return _RuleHistoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RuleHistoryProvider && other.ruleId == ruleId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, ruleId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RuleHistoryRef on AutoDisposeFutureProviderRef<List<RuleMonthlyDetail>> {
  /// The parameter `ruleId` of this provider.
  int get ruleId;
}

class _RuleHistoryProviderElement
    extends AutoDisposeFutureProviderElement<List<RuleMonthlyDetail>>
    with RuleHistoryRef {
  _RuleHistoryProviderElement(super.provider);

  @override
  int get ruleId => (origin as RuleHistoryProvider).ruleId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
