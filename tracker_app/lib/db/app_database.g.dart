// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProductsTable extends Products with TableInfo<$ProductsTable, Product> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _stockMeta = const VerificationMeta('stock');
  @override
  late final GeneratedColumn<int> stock = GeneratedColumn<int>(
      'stock', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _costPriceMeta =
      const VerificationMeta('costPrice');
  @override
  late final GeneratedColumn<double> costPrice = GeneratedColumn<double>(
      'cost_price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _lowStockThresholdMeta =
      const VerificationMeta('lowStockThreshold');
  @override
  late final GeneratedColumn<int> lowStockThreshold = GeneratedColumn<int>(
      'low_stock_threshold', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(3));
  static const VerificationMeta _alertEnabledMeta =
      const VerificationMeta('alertEnabled');
  @override
  late final GeneratedColumn<bool> alertEnabled = GeneratedColumn<bool>(
      'alert_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("alert_enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        stock,
        costPrice,
        lowStockThreshold,
        alertEnabled,
        note,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(Insertable<Product> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('stock')) {
      context.handle(
          _stockMeta, stock.isAcceptableOrUnknown(data['stock']!, _stockMeta));
    }
    if (data.containsKey('cost_price')) {
      context.handle(_costPriceMeta,
          costPrice.isAcceptableOrUnknown(data['cost_price']!, _costPriceMeta));
    } else if (isInserting) {
      context.missing(_costPriceMeta);
    }
    if (data.containsKey('low_stock_threshold')) {
      context.handle(
          _lowStockThresholdMeta,
          lowStockThreshold.isAcceptableOrUnknown(
              data['low_stock_threshold']!, _lowStockThresholdMeta));
    }
    if (data.containsKey('alert_enabled')) {
      context.handle(
          _alertEnabledMeta,
          alertEnabled.isAcceptableOrUnknown(
              data['alert_enabled']!, _alertEnabledMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Product map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Product(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      stock: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}stock'])!,
      costPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}cost_price'])!,
      lowStockThreshold: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}low_stock_threshold'])!,
      alertEnabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}alert_enabled'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class Product extends DataClass implements Insertable<Product> {
  final int id;
  final String name;
  final int stock;
  final double costPrice;
  final int lowStockThreshold;
  final bool alertEnabled;
  final String? note;
  final int createdAt;
  const Product(
      {required this.id,
      required this.name,
      required this.stock,
      required this.costPrice,
      required this.lowStockThreshold,
      required this.alertEnabled,
      this.note,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['stock'] = Variable<int>(stock);
    map['cost_price'] = Variable<double>(costPrice);
    map['low_stock_threshold'] = Variable<int>(lowStockThreshold);
    map['alert_enabled'] = Variable<bool>(alertEnabled);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      name: Value(name),
      stock: Value(stock),
      costPrice: Value(costPrice),
      lowStockThreshold: Value(lowStockThreshold),
      alertEnabled: Value(alertEnabled),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory Product.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Product(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      stock: serializer.fromJson<int>(json['stock']),
      costPrice: serializer.fromJson<double>(json['costPrice']),
      lowStockThreshold: serializer.fromJson<int>(json['lowStockThreshold']),
      alertEnabled: serializer.fromJson<bool>(json['alertEnabled']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'stock': serializer.toJson<int>(stock),
      'costPrice': serializer.toJson<double>(costPrice),
      'lowStockThreshold': serializer.toJson<int>(lowStockThreshold),
      'alertEnabled': serializer.toJson<bool>(alertEnabled),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  Product copyWith(
          {int? id,
          String? name,
          int? stock,
          double? costPrice,
          int? lowStockThreshold,
          bool? alertEnabled,
          Value<String?> note = const Value.absent(),
          int? createdAt}) =>
      Product(
        id: id ?? this.id,
        name: name ?? this.name,
        stock: stock ?? this.stock,
        costPrice: costPrice ?? this.costPrice,
        lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
        alertEnabled: alertEnabled ?? this.alertEnabled,
        note: note.present ? note.value : this.note,
        createdAt: createdAt ?? this.createdAt,
      );
  Product copyWithCompanion(ProductsCompanion data) {
    return Product(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      stock: data.stock.present ? data.stock.value : this.stock,
      costPrice: data.costPrice.present ? data.costPrice.value : this.costPrice,
      lowStockThreshold: data.lowStockThreshold.present
          ? data.lowStockThreshold.value
          : this.lowStockThreshold,
      alertEnabled: data.alertEnabled.present
          ? data.alertEnabled.value
          : this.alertEnabled,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Product(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('stock: $stock, ')
          ..write('costPrice: $costPrice, ')
          ..write('lowStockThreshold: $lowStockThreshold, ')
          ..write('alertEnabled: $alertEnabled, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, stock, costPrice, lowStockThreshold,
      alertEnabled, note, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Product &&
          other.id == this.id &&
          other.name == this.name &&
          other.stock == this.stock &&
          other.costPrice == this.costPrice &&
          other.lowStockThreshold == this.lowStockThreshold &&
          other.alertEnabled == this.alertEnabled &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class ProductsCompanion extends UpdateCompanion<Product> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> stock;
  final Value<double> costPrice;
  final Value<int> lowStockThreshold;
  final Value<bool> alertEnabled;
  final Value<String?> note;
  final Value<int> createdAt;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.stock = const Value.absent(),
    this.costPrice = const Value.absent(),
    this.lowStockThreshold = const Value.absent(),
    this.alertEnabled = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ProductsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.stock = const Value.absent(),
    required double costPrice,
    this.lowStockThreshold = const Value.absent(),
    this.alertEnabled = const Value.absent(),
    this.note = const Value.absent(),
    required int createdAt,
  })  : name = Value(name),
        costPrice = Value(costPrice),
        createdAt = Value(createdAt);
  static Insertable<Product> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? stock,
    Expression<double>? costPrice,
    Expression<int>? lowStockThreshold,
    Expression<bool>? alertEnabled,
    Expression<String>? note,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (stock != null) 'stock': stock,
      if (costPrice != null) 'cost_price': costPrice,
      if (lowStockThreshold != null) 'low_stock_threshold': lowStockThreshold,
      if (alertEnabled != null) 'alert_enabled': alertEnabled,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ProductsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<int>? stock,
      Value<double>? costPrice,
      Value<int>? lowStockThreshold,
      Value<bool>? alertEnabled,
      Value<String?>? note,
      Value<int>? createdAt}) {
    return ProductsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      stock: stock ?? this.stock,
      costPrice: costPrice ?? this.costPrice,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      alertEnabled: alertEnabled ?? this.alertEnabled,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (stock.present) {
      map['stock'] = Variable<int>(stock.value);
    }
    if (costPrice.present) {
      map['cost_price'] = Variable<double>(costPrice.value);
    }
    if (lowStockThreshold.present) {
      map['low_stock_threshold'] = Variable<int>(lowStockThreshold.value);
    }
    if (alertEnabled.present) {
      map['alert_enabled'] = Variable<bool>(alertEnabled.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('stock: $stock, ')
          ..write('costPrice: $costPrice, ')
          ..write('lowStockThreshold: $lowStockThreshold, ')
          ..write('alertEnabled: $alertEnabled, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $WalletsTable extends Wallets with TableInfo<$WalletsTable, Wallet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WalletsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _openingBalanceMeta =
      const VerificationMeta('openingBalance');
  @override
  late final GeneratedColumn<double> openingBalance = GeneratedColumn<double>(
      'opening_balance', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, type, openingBalance, isActive, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wallets';
  @override
  VerificationContext validateIntegrity(Insertable<Wallet> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('opening_balance')) {
      context.handle(
          _openingBalanceMeta,
          openingBalance.isAcceptableOrUnknown(
              data['opening_balance']!, _openingBalanceMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Wallet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Wallet(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      openingBalance: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}opening_balance'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $WalletsTable createAlias(String alias) {
    return $WalletsTable(attachedDatabase, alias);
  }
}

class Wallet extends DataClass implements Insertable<Wallet> {
  final int id;
  final String name;
  final String type;
  final double openingBalance;
  final bool isActive;
  final int createdAt;
  const Wallet(
      {required this.id,
      required this.name,
      required this.type,
      required this.openingBalance,
      required this.isActive,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['opening_balance'] = Variable<double>(openingBalance);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  WalletsCompanion toCompanion(bool nullToAbsent) {
    return WalletsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      openingBalance: Value(openingBalance),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory Wallet.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Wallet(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      openingBalance: serializer.fromJson<double>(json['openingBalance']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'openingBalance': serializer.toJson<double>(openingBalance),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  Wallet copyWith(
          {int? id,
          String? name,
          String? type,
          double? openingBalance,
          bool? isActive,
          int? createdAt}) =>
      Wallet(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        openingBalance: openingBalance ?? this.openingBalance,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
      );
  Wallet copyWithCompanion(WalletsCompanion data) {
    return Wallet(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      openingBalance: data.openingBalance.present
          ? data.openingBalance.value
          : this.openingBalance,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Wallet(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('openingBalance: $openingBalance, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, type, openingBalance, isActive, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Wallet &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.openingBalance == this.openingBalance &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class WalletsCompanion extends UpdateCompanion<Wallet> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> type;
  final Value<double> openingBalance;
  final Value<bool> isActive;
  final Value<int> createdAt;
  const WalletsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.openingBalance = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  WalletsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String type,
    this.openingBalance = const Value.absent(),
    this.isActive = const Value.absent(),
    required int createdAt,
  })  : name = Value(name),
        type = Value(type),
        createdAt = Value(createdAt);
  static Insertable<Wallet> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<double>? openingBalance,
    Expression<bool>? isActive,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (openingBalance != null) 'opening_balance': openingBalance,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  WalletsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? type,
      Value<double>? openingBalance,
      Value<bool>? isActive,
      Value<int>? createdAt}) {
    return WalletsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      openingBalance: openingBalance ?? this.openingBalance,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (openingBalance.present) {
      map['opening_balance'] = Variable<double>(openingBalance.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WalletsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('openingBalance: $openingBalance, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SalesTable extends Sales with TableInfo<$SalesTable, Sale> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
      'product_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES products (id)'));
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _sellingPriceMeta =
      const VerificationMeta('sellingPrice');
  @override
  late final GeneratedColumn<double> sellingPrice = GeneratedColumn<double>(
      'selling_price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
      'total', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _platformMeta =
      const VerificationMeta('platform');
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
      'platform', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _paymentStatusMeta =
      const VerificationMeta('paymentStatus');
  @override
  late final GeneratedColumn<String> paymentStatus = GeneratedColumn<String>(
      'payment_status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _customerNameMeta =
      const VerificationMeta('customerName');
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
      'customer_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isDiscountedMeta =
      const VerificationMeta('isDiscounted');
  @override
  late final GeneratedColumn<bool> isDiscounted = GeneratedColumn<bool>(
      'is_discounted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_discounted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _normalPriceMeta =
      const VerificationMeta('normalPrice');
  @override
  late final GeneratedColumn<double> normalPrice = GeneratedColumn<double>(
      'normal_price', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<int> date = GeneratedColumn<int>(
      'date', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _walletIdMeta =
      const VerificationMeta('walletId');
  @override
  late final GeneratedColumn<int> walletId = GeneratedColumn<int>(
      'wallet_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES wallets (id)'));
  static const VerificationMeta _ownershipMeta =
      const VerificationMeta('ownership');
  @override
  late final GeneratedColumn<String> ownership = GeneratedColumn<String>(
      'ownership', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('business'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        productId,
        quantity,
        sellingPrice,
        total,
        platform,
        paymentStatus,
        customerName,
        isDiscounted,
        normalPrice,
        date,
        createdAt,
        walletId,
        ownership
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sales';
  @override
  VerificationContext validateIntegrity(Insertable<Sale> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('selling_price')) {
      context.handle(
          _sellingPriceMeta,
          sellingPrice.isAcceptableOrUnknown(
              data['selling_price']!, _sellingPriceMeta));
    } else if (isInserting) {
      context.missing(_sellingPriceMeta);
    }
    if (data.containsKey('total')) {
      context.handle(
          _totalMeta, total.isAcceptableOrUnknown(data['total']!, _totalMeta));
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('platform')) {
      context.handle(_platformMeta,
          platform.isAcceptableOrUnknown(data['platform']!, _platformMeta));
    } else if (isInserting) {
      context.missing(_platformMeta);
    }
    if (data.containsKey('payment_status')) {
      context.handle(
          _paymentStatusMeta,
          paymentStatus.isAcceptableOrUnknown(
              data['payment_status']!, _paymentStatusMeta));
    } else if (isInserting) {
      context.missing(_paymentStatusMeta);
    }
    if (data.containsKey('customer_name')) {
      context.handle(
          _customerNameMeta,
          customerName.isAcceptableOrUnknown(
              data['customer_name']!, _customerNameMeta));
    }
    if (data.containsKey('is_discounted')) {
      context.handle(
          _isDiscountedMeta,
          isDiscounted.isAcceptableOrUnknown(
              data['is_discounted']!, _isDiscountedMeta));
    }
    if (data.containsKey('normal_price')) {
      context.handle(
          _normalPriceMeta,
          normalPrice.isAcceptableOrUnknown(
              data['normal_price']!, _normalPriceMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('wallet_id')) {
      context.handle(_walletIdMeta,
          walletId.isAcceptableOrUnknown(data['wallet_id']!, _walletIdMeta));
    }
    if (data.containsKey('ownership')) {
      context.handle(_ownershipMeta,
          ownership.isAcceptableOrUnknown(data['ownership']!, _ownershipMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Sale map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Sale(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}product_id'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      sellingPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}selling_price'])!,
      total: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total'])!,
      platform: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}platform'])!,
      paymentStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_status'])!,
      customerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_name']),
      isDiscounted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_discounted'])!,
      normalPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}normal_price']),
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}date'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      walletId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}wallet_id']),
      ownership: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ownership'])!,
    );
  }

  @override
  $SalesTable createAlias(String alias) {
    return $SalesTable(attachedDatabase, alias);
  }
}

class Sale extends DataClass implements Insertable<Sale> {
  final int id;
  final int productId;
  final int quantity;
  final double sellingPrice;
  final double total;
  final String platform;
  final String paymentStatus;
  final String? customerName;
  final bool isDiscounted;
  final double? normalPrice;
  final int date;
  final int createdAt;
  final int? walletId;
  final String ownership;
  const Sale(
      {required this.id,
      required this.productId,
      required this.quantity,
      required this.sellingPrice,
      required this.total,
      required this.platform,
      required this.paymentStatus,
      this.customerName,
      required this.isDiscounted,
      this.normalPrice,
      required this.date,
      required this.createdAt,
      this.walletId,
      required this.ownership});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['product_id'] = Variable<int>(productId);
    map['quantity'] = Variable<int>(quantity);
    map['selling_price'] = Variable<double>(sellingPrice);
    map['total'] = Variable<double>(total);
    map['platform'] = Variable<String>(platform);
    map['payment_status'] = Variable<String>(paymentStatus);
    if (!nullToAbsent || customerName != null) {
      map['customer_name'] = Variable<String>(customerName);
    }
    map['is_discounted'] = Variable<bool>(isDiscounted);
    if (!nullToAbsent || normalPrice != null) {
      map['normal_price'] = Variable<double>(normalPrice);
    }
    map['date'] = Variable<int>(date);
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || walletId != null) {
      map['wallet_id'] = Variable<int>(walletId);
    }
    map['ownership'] = Variable<String>(ownership);
    return map;
  }

  SalesCompanion toCompanion(bool nullToAbsent) {
    return SalesCompanion(
      id: Value(id),
      productId: Value(productId),
      quantity: Value(quantity),
      sellingPrice: Value(sellingPrice),
      total: Value(total),
      platform: Value(platform),
      paymentStatus: Value(paymentStatus),
      customerName: customerName == null && nullToAbsent
          ? const Value.absent()
          : Value(customerName),
      isDiscounted: Value(isDiscounted),
      normalPrice: normalPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(normalPrice),
      date: Value(date),
      createdAt: Value(createdAt),
      walletId: walletId == null && nullToAbsent
          ? const Value.absent()
          : Value(walletId),
      ownership: Value(ownership),
    );
  }

  factory Sale.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Sale(
      id: serializer.fromJson<int>(json['id']),
      productId: serializer.fromJson<int>(json['productId']),
      quantity: serializer.fromJson<int>(json['quantity']),
      sellingPrice: serializer.fromJson<double>(json['sellingPrice']),
      total: serializer.fromJson<double>(json['total']),
      platform: serializer.fromJson<String>(json['platform']),
      paymentStatus: serializer.fromJson<String>(json['paymentStatus']),
      customerName: serializer.fromJson<String?>(json['customerName']),
      isDiscounted: serializer.fromJson<bool>(json['isDiscounted']),
      normalPrice: serializer.fromJson<double?>(json['normalPrice']),
      date: serializer.fromJson<int>(json['date']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      walletId: serializer.fromJson<int?>(json['walletId']),
      ownership: serializer.fromJson<String>(json['ownership']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'productId': serializer.toJson<int>(productId),
      'quantity': serializer.toJson<int>(quantity),
      'sellingPrice': serializer.toJson<double>(sellingPrice),
      'total': serializer.toJson<double>(total),
      'platform': serializer.toJson<String>(platform),
      'paymentStatus': serializer.toJson<String>(paymentStatus),
      'customerName': serializer.toJson<String?>(customerName),
      'isDiscounted': serializer.toJson<bool>(isDiscounted),
      'normalPrice': serializer.toJson<double?>(normalPrice),
      'date': serializer.toJson<int>(date),
      'createdAt': serializer.toJson<int>(createdAt),
      'walletId': serializer.toJson<int?>(walletId),
      'ownership': serializer.toJson<String>(ownership),
    };
  }

  Sale copyWith(
          {int? id,
          int? productId,
          int? quantity,
          double? sellingPrice,
          double? total,
          String? platform,
          String? paymentStatus,
          Value<String?> customerName = const Value.absent(),
          bool? isDiscounted,
          Value<double?> normalPrice = const Value.absent(),
          int? date,
          int? createdAt,
          Value<int?> walletId = const Value.absent(),
          String? ownership}) =>
      Sale(
        id: id ?? this.id,
        productId: productId ?? this.productId,
        quantity: quantity ?? this.quantity,
        sellingPrice: sellingPrice ?? this.sellingPrice,
        total: total ?? this.total,
        platform: platform ?? this.platform,
        paymentStatus: paymentStatus ?? this.paymentStatus,
        customerName:
            customerName.present ? customerName.value : this.customerName,
        isDiscounted: isDiscounted ?? this.isDiscounted,
        normalPrice: normalPrice.present ? normalPrice.value : this.normalPrice,
        date: date ?? this.date,
        createdAt: createdAt ?? this.createdAt,
        walletId: walletId.present ? walletId.value : this.walletId,
        ownership: ownership ?? this.ownership,
      );
  Sale copyWithCompanion(SalesCompanion data) {
    return Sale(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      sellingPrice: data.sellingPrice.present
          ? data.sellingPrice.value
          : this.sellingPrice,
      total: data.total.present ? data.total.value : this.total,
      platform: data.platform.present ? data.platform.value : this.platform,
      paymentStatus: data.paymentStatus.present
          ? data.paymentStatus.value
          : this.paymentStatus,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      isDiscounted: data.isDiscounted.present
          ? data.isDiscounted.value
          : this.isDiscounted,
      normalPrice:
          data.normalPrice.present ? data.normalPrice.value : this.normalPrice,
      date: data.date.present ? data.date.value : this.date,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      walletId: data.walletId.present ? data.walletId.value : this.walletId,
      ownership: data.ownership.present ? data.ownership.value : this.ownership,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Sale(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('sellingPrice: $sellingPrice, ')
          ..write('total: $total, ')
          ..write('platform: $platform, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('customerName: $customerName, ')
          ..write('isDiscounted: $isDiscounted, ')
          ..write('normalPrice: $normalPrice, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt, ')
          ..write('walletId: $walletId, ')
          ..write('ownership: $ownership')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      productId,
      quantity,
      sellingPrice,
      total,
      platform,
      paymentStatus,
      customerName,
      isDiscounted,
      normalPrice,
      date,
      createdAt,
      walletId,
      ownership);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sale &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.quantity == this.quantity &&
          other.sellingPrice == this.sellingPrice &&
          other.total == this.total &&
          other.platform == this.platform &&
          other.paymentStatus == this.paymentStatus &&
          other.customerName == this.customerName &&
          other.isDiscounted == this.isDiscounted &&
          other.normalPrice == this.normalPrice &&
          other.date == this.date &&
          other.createdAt == this.createdAt &&
          other.walletId == this.walletId &&
          other.ownership == this.ownership);
}

class SalesCompanion extends UpdateCompanion<Sale> {
  final Value<int> id;
  final Value<int> productId;
  final Value<int> quantity;
  final Value<double> sellingPrice;
  final Value<double> total;
  final Value<String> platform;
  final Value<String> paymentStatus;
  final Value<String?> customerName;
  final Value<bool> isDiscounted;
  final Value<double?> normalPrice;
  final Value<int> date;
  final Value<int> createdAt;
  final Value<int?> walletId;
  final Value<String> ownership;
  const SalesCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.sellingPrice = const Value.absent(),
    this.total = const Value.absent(),
    this.platform = const Value.absent(),
    this.paymentStatus = const Value.absent(),
    this.customerName = const Value.absent(),
    this.isDiscounted = const Value.absent(),
    this.normalPrice = const Value.absent(),
    this.date = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.walletId = const Value.absent(),
    this.ownership = const Value.absent(),
  });
  SalesCompanion.insert({
    this.id = const Value.absent(),
    required int productId,
    required int quantity,
    required double sellingPrice,
    required double total,
    required String platform,
    required String paymentStatus,
    this.customerName = const Value.absent(),
    this.isDiscounted = const Value.absent(),
    this.normalPrice = const Value.absent(),
    required int date,
    required int createdAt,
    this.walletId = const Value.absent(),
    this.ownership = const Value.absent(),
  })  : productId = Value(productId),
        quantity = Value(quantity),
        sellingPrice = Value(sellingPrice),
        total = Value(total),
        platform = Value(platform),
        paymentStatus = Value(paymentStatus),
        date = Value(date),
        createdAt = Value(createdAt);
  static Insertable<Sale> custom({
    Expression<int>? id,
    Expression<int>? productId,
    Expression<int>? quantity,
    Expression<double>? sellingPrice,
    Expression<double>? total,
    Expression<String>? platform,
    Expression<String>? paymentStatus,
    Expression<String>? customerName,
    Expression<bool>? isDiscounted,
    Expression<double>? normalPrice,
    Expression<int>? date,
    Expression<int>? createdAt,
    Expression<int>? walletId,
    Expression<String>? ownership,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (quantity != null) 'quantity': quantity,
      if (sellingPrice != null) 'selling_price': sellingPrice,
      if (total != null) 'total': total,
      if (platform != null) 'platform': platform,
      if (paymentStatus != null) 'payment_status': paymentStatus,
      if (customerName != null) 'customer_name': customerName,
      if (isDiscounted != null) 'is_discounted': isDiscounted,
      if (normalPrice != null) 'normal_price': normalPrice,
      if (date != null) 'date': date,
      if (createdAt != null) 'created_at': createdAt,
      if (walletId != null) 'wallet_id': walletId,
      if (ownership != null) 'ownership': ownership,
    });
  }

  SalesCompanion copyWith(
      {Value<int>? id,
      Value<int>? productId,
      Value<int>? quantity,
      Value<double>? sellingPrice,
      Value<double>? total,
      Value<String>? platform,
      Value<String>? paymentStatus,
      Value<String?>? customerName,
      Value<bool>? isDiscounted,
      Value<double?>? normalPrice,
      Value<int>? date,
      Value<int>? createdAt,
      Value<int?>? walletId,
      Value<String>? ownership}) {
    return SalesCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      total: total ?? this.total,
      platform: platform ?? this.platform,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      customerName: customerName ?? this.customerName,
      isDiscounted: isDiscounted ?? this.isDiscounted,
      normalPrice: normalPrice ?? this.normalPrice,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      walletId: walletId ?? this.walletId,
      ownership: ownership ?? this.ownership,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (sellingPrice.present) {
      map['selling_price'] = Variable<double>(sellingPrice.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (paymentStatus.present) {
      map['payment_status'] = Variable<String>(paymentStatus.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (isDiscounted.present) {
      map['is_discounted'] = Variable<bool>(isDiscounted.value);
    }
    if (normalPrice.present) {
      map['normal_price'] = Variable<double>(normalPrice.value);
    }
    if (date.present) {
      map['date'] = Variable<int>(date.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (walletId.present) {
      map['wallet_id'] = Variable<int>(walletId.value);
    }
    if (ownership.present) {
      map['ownership'] = Variable<String>(ownership.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalesCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('sellingPrice: $sellingPrice, ')
          ..write('total: $total, ')
          ..write('platform: $platform, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('customerName: $customerName, ')
          ..write('isDiscounted: $isDiscounted, ')
          ..write('normalPrice: $normalPrice, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt, ')
          ..write('walletId: $walletId, ')
          ..write('ownership: $ownership')
          ..write(')'))
        .toString();
  }
}

class $AllocationRulesTable extends AllocationRules
    with TableInfo<$AllocationRulesTable, AllocationRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AllocationRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _percentageMeta =
      const VerificationMeta('percentage');
  @override
  late final GeneratedColumn<double> percentage = GeneratedColumn<double>(
      'percentage', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, label, percentage, sortOrder, isActive, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'allocation_rules';
  @override
  VerificationContext validateIntegrity(Insertable<AllocationRule> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('percentage')) {
      context.handle(
          _percentageMeta,
          percentage.isAcceptableOrUnknown(
              data['percentage']!, _percentageMeta));
    } else if (isInserting) {
      context.missing(_percentageMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AllocationRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AllocationRule(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label'])!,
      percentage: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}percentage'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $AllocationRulesTable createAlias(String alias) {
    return $AllocationRulesTable(attachedDatabase, alias);
  }
}

class AllocationRule extends DataClass implements Insertable<AllocationRule> {
  final int id;
  final String label;
  final double percentage;
  final int sortOrder;
  final bool isActive;
  final int createdAt;
  const AllocationRule(
      {required this.id,
      required this.label,
      required this.percentage,
      required this.sortOrder,
      required this.isActive,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['label'] = Variable<String>(label);
    map['percentage'] = Variable<double>(percentage);
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  AllocationRulesCompanion toCompanion(bool nullToAbsent) {
    return AllocationRulesCompanion(
      id: Value(id),
      label: Value(label),
      percentage: Value(percentage),
      sortOrder: Value(sortOrder),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory AllocationRule.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AllocationRule(
      id: serializer.fromJson<int>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      percentage: serializer.fromJson<double>(json['percentage']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'label': serializer.toJson<String>(label),
      'percentage': serializer.toJson<double>(percentage),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  AllocationRule copyWith(
          {int? id,
          String? label,
          double? percentage,
          int? sortOrder,
          bool? isActive,
          int? createdAt}) =>
      AllocationRule(
        id: id ?? this.id,
        label: label ?? this.label,
        percentage: percentage ?? this.percentage,
        sortOrder: sortOrder ?? this.sortOrder,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
      );
  AllocationRule copyWithCompanion(AllocationRulesCompanion data) {
    return AllocationRule(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      percentage:
          data.percentage.present ? data.percentage.value : this.percentage,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AllocationRule(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('percentage: $percentage, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, label, percentage, sortOrder, isActive, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AllocationRule &&
          other.id == this.id &&
          other.label == this.label &&
          other.percentage == this.percentage &&
          other.sortOrder == this.sortOrder &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class AllocationRulesCompanion extends UpdateCompanion<AllocationRule> {
  final Value<int> id;
  final Value<String> label;
  final Value<double> percentage;
  final Value<int> sortOrder;
  final Value<bool> isActive;
  final Value<int> createdAt;
  const AllocationRulesCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.percentage = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AllocationRulesCompanion.insert({
    this.id = const Value.absent(),
    required String label,
    required double percentage,
    this.sortOrder = const Value.absent(),
    this.isActive = const Value.absent(),
    required int createdAt,
  })  : label = Value(label),
        percentage = Value(percentage),
        createdAt = Value(createdAt);
  static Insertable<AllocationRule> custom({
    Expression<int>? id,
    Expression<String>? label,
    Expression<double>? percentage,
    Expression<int>? sortOrder,
    Expression<bool>? isActive,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (percentage != null) 'percentage': percentage,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AllocationRulesCompanion copyWith(
      {Value<int>? id,
      Value<String>? label,
      Value<double>? percentage,
      Value<int>? sortOrder,
      Value<bool>? isActive,
      Value<int>? createdAt}) {
    return AllocationRulesCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      percentage: percentage ?? this.percentage,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (percentage.present) {
      map['percentage'] = Variable<double>(percentage.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AllocationRulesCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('percentage: $percentage, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $BudgetBucketsTable extends BudgetBuckets
    with TableInfo<$BudgetBucketsTable, BudgetBucket> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetBucketsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _allocatedAmountMeta =
      const VerificationMeta('allocatedAmount');
  @override
  late final GeneratedColumn<double> allocatedAmount = GeneratedColumn<double>(
      'allocated_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, allocatedAmount, color, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budget_buckets';
  @override
  VerificationContext validateIntegrity(Insertable<BudgetBucket> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('allocated_amount')) {
      context.handle(
          _allocatedAmountMeta,
          allocatedAmount.isAcceptableOrUnknown(
              data['allocated_amount']!, _allocatedAmountMeta));
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BudgetBucket map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BudgetBucket(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      allocatedAmount: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}allocated_amount'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $BudgetBucketsTable createAlias(String alias) {
    return $BudgetBucketsTable(attachedDatabase, alias);
  }
}

class BudgetBucket extends DataClass implements Insertable<BudgetBucket> {
  final int id;
  final String name;
  final double allocatedAmount;
  final String? color;
  final int createdAt;
  const BudgetBucket(
      {required this.id,
      required this.name,
      required this.allocatedAmount,
      this.color,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['allocated_amount'] = Variable<double>(allocatedAmount);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  BudgetBucketsCompanion toCompanion(bool nullToAbsent) {
    return BudgetBucketsCompanion(
      id: Value(id),
      name: Value(name),
      allocatedAmount: Value(allocatedAmount),
      color:
          color == null && nullToAbsent ? const Value.absent() : Value(color),
      createdAt: Value(createdAt),
    );
  }

  factory BudgetBucket.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BudgetBucket(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      allocatedAmount: serializer.fromJson<double>(json['allocatedAmount']),
      color: serializer.fromJson<String?>(json['color']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'allocatedAmount': serializer.toJson<double>(allocatedAmount),
      'color': serializer.toJson<String?>(color),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  BudgetBucket copyWith(
          {int? id,
          String? name,
          double? allocatedAmount,
          Value<String?> color = const Value.absent(),
          int? createdAt}) =>
      BudgetBucket(
        id: id ?? this.id,
        name: name ?? this.name,
        allocatedAmount: allocatedAmount ?? this.allocatedAmount,
        color: color.present ? color.value : this.color,
        createdAt: createdAt ?? this.createdAt,
      );
  BudgetBucket copyWithCompanion(BudgetBucketsCompanion data) {
    return BudgetBucket(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      allocatedAmount: data.allocatedAmount.present
          ? data.allocatedAmount.value
          : this.allocatedAmount,
      color: data.color.present ? data.color.value : this.color,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BudgetBucket(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('allocatedAmount: $allocatedAmount, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, allocatedAmount, color, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BudgetBucket &&
          other.id == this.id &&
          other.name == this.name &&
          other.allocatedAmount == this.allocatedAmount &&
          other.color == this.color &&
          other.createdAt == this.createdAt);
}

class BudgetBucketsCompanion extends UpdateCompanion<BudgetBucket> {
  final Value<int> id;
  final Value<String> name;
  final Value<double> allocatedAmount;
  final Value<String?> color;
  final Value<int> createdAt;
  const BudgetBucketsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.allocatedAmount = const Value.absent(),
    this.color = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  BudgetBucketsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.allocatedAmount = const Value.absent(),
    this.color = const Value.absent(),
    required int createdAt,
  })  : name = Value(name),
        createdAt = Value(createdAt);
  static Insertable<BudgetBucket> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? allocatedAmount,
    Expression<String>? color,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (allocatedAmount != null) 'allocated_amount': allocatedAmount,
      if (color != null) 'color': color,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  BudgetBucketsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<double>? allocatedAmount,
      Value<String?>? color,
      Value<int>? createdAt}) {
    return BudgetBucketsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      allocatedAmount: allocatedAmount ?? this.allocatedAmount,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (allocatedAmount.present) {
      map['allocated_amount'] = Variable<double>(allocatedAmount.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetBucketsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('allocatedAmount: $allocatedAmount, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTable extends Expenses with TableInfo<$ExpensesTable, Expense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<int> date = GeneratedColumn<int>(
      'date', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _walletIdMeta =
      const VerificationMeta('walletId');
  @override
  late final GeneratedColumn<int> walletId = GeneratedColumn<int>(
      'wallet_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES wallets (id)'));
  static const VerificationMeta _ownershipMeta =
      const VerificationMeta('ownership');
  @override
  late final GeneratedColumn<String> ownership = GeneratedColumn<String>(
      'ownership', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('business'));
  static const VerificationMeta _allocationRuleIdMeta =
      const VerificationMeta('allocationRuleId');
  @override
  late final GeneratedColumn<int> allocationRuleId = GeneratedColumn<int>(
      'allocation_rule_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES allocation_rules (id)'));
  static const VerificationMeta _bucketIdMeta =
      const VerificationMeta('bucketId');
  @override
  late final GeneratedColumn<int> bucketId = GeneratedColumn<int>(
      'bucket_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES budget_buckets (id)'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        amount,
        category,
        note,
        date,
        createdAt,
        walletId,
        ownership,
        allocationRuleId,
        bucketId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(Insertable<Expense> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('wallet_id')) {
      context.handle(_walletIdMeta,
          walletId.isAcceptableOrUnknown(data['wallet_id']!, _walletIdMeta));
    }
    if (data.containsKey('ownership')) {
      context.handle(_ownershipMeta,
          ownership.isAcceptableOrUnknown(data['ownership']!, _ownershipMeta));
    }
    if (data.containsKey('allocation_rule_id')) {
      context.handle(
          _allocationRuleIdMeta,
          allocationRuleId.isAcceptableOrUnknown(
              data['allocation_rule_id']!, _allocationRuleIdMeta));
    }
    if (data.containsKey('bucket_id')) {
      context.handle(_bucketIdMeta,
          bucketId.isAcceptableOrUnknown(data['bucket_id']!, _bucketIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Expense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Expense(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}date'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      walletId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}wallet_id']),
      ownership: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ownership'])!,
      allocationRuleId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}allocation_rule_id']),
      bucketId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}bucket_id']),
    );
  }

  @override
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }
}

class Expense extends DataClass implements Insertable<Expense> {
  final int id;
  final double amount;
  final String category;
  final String? note;
  final int date;
  final int createdAt;
  final int? walletId;
  final String ownership;
  final int? allocationRuleId;
  final int? bucketId;
  const Expense(
      {required this.id,
      required this.amount,
      required this.category,
      this.note,
      required this.date,
      required this.createdAt,
      this.walletId,
      required this.ownership,
      this.allocationRuleId,
      this.bucketId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['amount'] = Variable<double>(amount);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['date'] = Variable<int>(date);
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || walletId != null) {
      map['wallet_id'] = Variable<int>(walletId);
    }
    map['ownership'] = Variable<String>(ownership);
    if (!nullToAbsent || allocationRuleId != null) {
      map['allocation_rule_id'] = Variable<int>(allocationRuleId);
    }
    if (!nullToAbsent || bucketId != null) {
      map['bucket_id'] = Variable<int>(bucketId);
    }
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      id: Value(id),
      amount: Value(amount),
      category: Value(category),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      date: Value(date),
      createdAt: Value(createdAt),
      walletId: walletId == null && nullToAbsent
          ? const Value.absent()
          : Value(walletId),
      ownership: Value(ownership),
      allocationRuleId: allocationRuleId == null && nullToAbsent
          ? const Value.absent()
          : Value(allocationRuleId),
      bucketId: bucketId == null && nullToAbsent
          ? const Value.absent()
          : Value(bucketId),
    );
  }

  factory Expense.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Expense(
      id: serializer.fromJson<int>(json['id']),
      amount: serializer.fromJson<double>(json['amount']),
      category: serializer.fromJson<String>(json['category']),
      note: serializer.fromJson<String?>(json['note']),
      date: serializer.fromJson<int>(json['date']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      walletId: serializer.fromJson<int?>(json['walletId']),
      ownership: serializer.fromJson<String>(json['ownership']),
      allocationRuleId: serializer.fromJson<int?>(json['allocationRuleId']),
      bucketId: serializer.fromJson<int?>(json['bucketId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'amount': serializer.toJson<double>(amount),
      'category': serializer.toJson<String>(category),
      'note': serializer.toJson<String?>(note),
      'date': serializer.toJson<int>(date),
      'createdAt': serializer.toJson<int>(createdAt),
      'walletId': serializer.toJson<int?>(walletId),
      'ownership': serializer.toJson<String>(ownership),
      'allocationRuleId': serializer.toJson<int?>(allocationRuleId),
      'bucketId': serializer.toJson<int?>(bucketId),
    };
  }

  Expense copyWith(
          {int? id,
          double? amount,
          String? category,
          Value<String?> note = const Value.absent(),
          int? date,
          int? createdAt,
          Value<int?> walletId = const Value.absent(),
          String? ownership,
          Value<int?> allocationRuleId = const Value.absent(),
          Value<int?> bucketId = const Value.absent()}) =>
      Expense(
        id: id ?? this.id,
        amount: amount ?? this.amount,
        category: category ?? this.category,
        note: note.present ? note.value : this.note,
        date: date ?? this.date,
        createdAt: createdAt ?? this.createdAt,
        walletId: walletId.present ? walletId.value : this.walletId,
        ownership: ownership ?? this.ownership,
        allocationRuleId: allocationRuleId.present
            ? allocationRuleId.value
            : this.allocationRuleId,
        bucketId: bucketId.present ? bucketId.value : this.bucketId,
      );
  Expense copyWithCompanion(ExpensesCompanion data) {
    return Expense(
      id: data.id.present ? data.id.value : this.id,
      amount: data.amount.present ? data.amount.value : this.amount,
      category: data.category.present ? data.category.value : this.category,
      note: data.note.present ? data.note.value : this.note,
      date: data.date.present ? data.date.value : this.date,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      walletId: data.walletId.present ? data.walletId.value : this.walletId,
      ownership: data.ownership.present ? data.ownership.value : this.ownership,
      allocationRuleId: data.allocationRuleId.present
          ? data.allocationRuleId.value
          : this.allocationRuleId,
      bucketId: data.bucketId.present ? data.bucketId.value : this.bucketId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Expense(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('note: $note, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt, ')
          ..write('walletId: $walletId, ')
          ..write('ownership: $ownership, ')
          ..write('allocationRuleId: $allocationRuleId, ')
          ..write('bucketId: $bucketId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, amount, category, note, date, createdAt,
      walletId, ownership, allocationRuleId, bucketId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Expense &&
          other.id == this.id &&
          other.amount == this.amount &&
          other.category == this.category &&
          other.note == this.note &&
          other.date == this.date &&
          other.createdAt == this.createdAt &&
          other.walletId == this.walletId &&
          other.ownership == this.ownership &&
          other.allocationRuleId == this.allocationRuleId &&
          other.bucketId == this.bucketId);
}

class ExpensesCompanion extends UpdateCompanion<Expense> {
  final Value<int> id;
  final Value<double> amount;
  final Value<String> category;
  final Value<String?> note;
  final Value<int> date;
  final Value<int> createdAt;
  final Value<int?> walletId;
  final Value<String> ownership;
  final Value<int?> allocationRuleId;
  final Value<int?> bucketId;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.amount = const Value.absent(),
    this.category = const Value.absent(),
    this.note = const Value.absent(),
    this.date = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.walletId = const Value.absent(),
    this.ownership = const Value.absent(),
    this.allocationRuleId = const Value.absent(),
    this.bucketId = const Value.absent(),
  });
  ExpensesCompanion.insert({
    this.id = const Value.absent(),
    required double amount,
    required String category,
    this.note = const Value.absent(),
    required int date,
    required int createdAt,
    this.walletId = const Value.absent(),
    this.ownership = const Value.absent(),
    this.allocationRuleId = const Value.absent(),
    this.bucketId = const Value.absent(),
  })  : amount = Value(amount),
        category = Value(category),
        date = Value(date),
        createdAt = Value(createdAt);
  static Insertable<Expense> custom({
    Expression<int>? id,
    Expression<double>? amount,
    Expression<String>? category,
    Expression<String>? note,
    Expression<int>? date,
    Expression<int>? createdAt,
    Expression<int>? walletId,
    Expression<String>? ownership,
    Expression<int>? allocationRuleId,
    Expression<int>? bucketId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amount != null) 'amount': amount,
      if (category != null) 'category': category,
      if (note != null) 'note': note,
      if (date != null) 'date': date,
      if (createdAt != null) 'created_at': createdAt,
      if (walletId != null) 'wallet_id': walletId,
      if (ownership != null) 'ownership': ownership,
      if (allocationRuleId != null) 'allocation_rule_id': allocationRuleId,
      if (bucketId != null) 'bucket_id': bucketId,
    });
  }

  ExpensesCompanion copyWith(
      {Value<int>? id,
      Value<double>? amount,
      Value<String>? category,
      Value<String?>? note,
      Value<int>? date,
      Value<int>? createdAt,
      Value<int?>? walletId,
      Value<String>? ownership,
      Value<int?>? allocationRuleId,
      Value<int?>? bucketId}) {
    return ExpensesCompanion(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      note: note ?? this.note,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      walletId: walletId ?? this.walletId,
      ownership: ownership ?? this.ownership,
      allocationRuleId: allocationRuleId ?? this.allocationRuleId,
      bucketId: bucketId ?? this.bucketId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (date.present) {
      map['date'] = Variable<int>(date.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (walletId.present) {
      map['wallet_id'] = Variable<int>(walletId.value);
    }
    if (ownership.present) {
      map['ownership'] = Variable<String>(ownership.value);
    }
    if (allocationRuleId.present) {
      map['allocation_rule_id'] = Variable<int>(allocationRuleId.value);
    }
    if (bucketId.present) {
      map['bucket_id'] = Variable<int>(bucketId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('note: $note, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt, ')
          ..write('walletId: $walletId, ')
          ..write('ownership: $ownership, ')
          ..write('allocationRuleId: $allocationRuleId, ')
          ..write('bucketId: $bucketId')
          ..write(')'))
        .toString();
  }
}

class $StockMovementsTable extends StockMovements
    with TableInfo<$StockMovementsTable, StockMovement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockMovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
      'product_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES products (id)'));
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<int> date = GeneratedColumn<int>(
      'date', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, productId, quantity, type, note, date];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_movements';
  @override
  VerificationContext validateIntegrity(Insertable<StockMovement> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockMovement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockMovement(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}product_id'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}date'])!,
    );
  }

  @override
  $StockMovementsTable createAlias(String alias) {
    return $StockMovementsTable(attachedDatabase, alias);
  }
}

class StockMovement extends DataClass implements Insertable<StockMovement> {
  final int id;
  final int productId;
  final int quantity;
  final String type;
  final String? note;
  final int date;
  const StockMovement(
      {required this.id,
      required this.productId,
      required this.quantity,
      required this.type,
      this.note,
      required this.date});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['product_id'] = Variable<int>(productId);
    map['quantity'] = Variable<int>(quantity);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['date'] = Variable<int>(date);
    return map;
  }

  StockMovementsCompanion toCompanion(bool nullToAbsent) {
    return StockMovementsCompanion(
      id: Value(id),
      productId: Value(productId),
      quantity: Value(quantity),
      type: Value(type),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      date: Value(date),
    );
  }

  factory StockMovement.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockMovement(
      id: serializer.fromJson<int>(json['id']),
      productId: serializer.fromJson<int>(json['productId']),
      quantity: serializer.fromJson<int>(json['quantity']),
      type: serializer.fromJson<String>(json['type']),
      note: serializer.fromJson<String?>(json['note']),
      date: serializer.fromJson<int>(json['date']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'productId': serializer.toJson<int>(productId),
      'quantity': serializer.toJson<int>(quantity),
      'type': serializer.toJson<String>(type),
      'note': serializer.toJson<String?>(note),
      'date': serializer.toJson<int>(date),
    };
  }

  StockMovement copyWith(
          {int? id,
          int? productId,
          int? quantity,
          String? type,
          Value<String?> note = const Value.absent(),
          int? date}) =>
      StockMovement(
        id: id ?? this.id,
        productId: productId ?? this.productId,
        quantity: quantity ?? this.quantity,
        type: type ?? this.type,
        note: note.present ? note.value : this.note,
        date: date ?? this.date,
      );
  StockMovement copyWithCompanion(StockMovementsCompanion data) {
    return StockMovement(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      type: data.type.present ? data.type.value : this.type,
      note: data.note.present ? data.note.value : this.note,
      date: data.date.present ? data.date.value : this.date,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockMovement(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('type: $type, ')
          ..write('note: $note, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, productId, quantity, type, note, date);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockMovement &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.quantity == this.quantity &&
          other.type == this.type &&
          other.note == this.note &&
          other.date == this.date);
}

class StockMovementsCompanion extends UpdateCompanion<StockMovement> {
  final Value<int> id;
  final Value<int> productId;
  final Value<int> quantity;
  final Value<String> type;
  final Value<String?> note;
  final Value<int> date;
  const StockMovementsCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.type = const Value.absent(),
    this.note = const Value.absent(),
    this.date = const Value.absent(),
  });
  StockMovementsCompanion.insert({
    this.id = const Value.absent(),
    required int productId,
    required int quantity,
    required String type,
    this.note = const Value.absent(),
    required int date,
  })  : productId = Value(productId),
        quantity = Value(quantity),
        type = Value(type),
        date = Value(date);
  static Insertable<StockMovement> custom({
    Expression<int>? id,
    Expression<int>? productId,
    Expression<int>? quantity,
    Expression<String>? type,
    Expression<String>? note,
    Expression<int>? date,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (quantity != null) 'quantity': quantity,
      if (type != null) 'type': type,
      if (note != null) 'note': note,
      if (date != null) 'date': date,
    });
  }

  StockMovementsCompanion copyWith(
      {Value<int>? id,
      Value<int>? productId,
      Value<int>? quantity,
      Value<String>? type,
      Value<String?>? note,
      Value<int>? date}) {
    return StockMovementsCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      type: type ?? this.type,
      note: note ?? this.note,
      date: date ?? this.date,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (date.present) {
      map['date'] = Variable<int>(date.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockMovementsCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('type: $type, ')
          ..write('note: $note, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }
}

class $AddOnTypesTable extends AddOnTypes
    with TableInfo<$AddOnTypesTable, AddOnType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AddOnTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, isActive, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'add_on_types';
  @override
  VerificationContext validateIntegrity(Insertable<AddOnType> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AddOnType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AddOnType(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $AddOnTypesTable createAlias(String alias) {
    return $AddOnTypesTable(attachedDatabase, alias);
  }
}

class AddOnType extends DataClass implements Insertable<AddOnType> {
  final int id;
  final String name;
  final bool isActive;
  final int createdAt;
  const AddOnType(
      {required this.id,
      required this.name,
      required this.isActive,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  AddOnTypesCompanion toCompanion(bool nullToAbsent) {
    return AddOnTypesCompanion(
      id: Value(id),
      name: Value(name),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory AddOnType.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AddOnType(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  AddOnType copyWith({int? id, String? name, bool? isActive, int? createdAt}) =>
      AddOnType(
        id: id ?? this.id,
        name: name ?? this.name,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
      );
  AddOnType copyWithCompanion(AddOnTypesCompanion data) {
    return AddOnType(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AddOnType(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, isActive, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AddOnType &&
          other.id == this.id &&
          other.name == this.name &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class AddOnTypesCompanion extends UpdateCompanion<AddOnType> {
  final Value<int> id;
  final Value<String> name;
  final Value<bool> isActive;
  final Value<int> createdAt;
  const AddOnTypesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AddOnTypesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.isActive = const Value.absent(),
    required int createdAt,
  })  : name = Value(name),
        createdAt = Value(createdAt);
  static Insertable<AddOnType> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<bool>? isActive,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AddOnTypesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<bool>? isActive,
      Value<int>? createdAt}) {
    return AddOnTypesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AddOnTypesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SaleAddOnsTable extends SaleAddOns
    with TableInfo<$SaleAddOnsTable, SaleAddOn> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SaleAddOnsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<int> saleId = GeneratedColumn<int>(
      'sale_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES sales (id)'));
  static const VerificationMeta _addOnTypeIdMeta =
      const VerificationMeta('addOnTypeId');
  @override
  late final GeneratedColumn<int> addOnTypeId = GeneratedColumn<int>(
      'add_on_type_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES add_on_types (id)'));
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _costMeta = const VerificationMeta('cost');
  @override
  late final GeneratedColumn<double> cost = GeneratedColumn<double>(
      'cost', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, saleId, addOnTypeId, quantity, cost];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sale_add_ons';
  @override
  VerificationContext validateIntegrity(Insertable<SaleAddOn> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sale_id')) {
      context.handle(_saleIdMeta,
          saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta));
    } else if (isInserting) {
      context.missing(_saleIdMeta);
    }
    if (data.containsKey('add_on_type_id')) {
      context.handle(
          _addOnTypeIdMeta,
          addOnTypeId.isAcceptableOrUnknown(
              data['add_on_type_id']!, _addOnTypeIdMeta));
    } else if (isInserting) {
      context.missing(_addOnTypeIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    }
    if (data.containsKey('cost')) {
      context.handle(
          _costMeta, cost.isAcceptableOrUnknown(data['cost']!, _costMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SaleAddOn map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaleAddOn(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      saleId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sale_id'])!,
      addOnTypeId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}add_on_type_id'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      cost: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}cost'])!,
    );
  }

  @override
  $SaleAddOnsTable createAlias(String alias) {
    return $SaleAddOnsTable(attachedDatabase, alias);
  }
}

class SaleAddOn extends DataClass implements Insertable<SaleAddOn> {
  final int id;
  final int saleId;
  final int addOnTypeId;
  final int quantity;
  final double cost;
  const SaleAddOn(
      {required this.id,
      required this.saleId,
      required this.addOnTypeId,
      required this.quantity,
      required this.cost});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sale_id'] = Variable<int>(saleId);
    map['add_on_type_id'] = Variable<int>(addOnTypeId);
    map['quantity'] = Variable<int>(quantity);
    map['cost'] = Variable<double>(cost);
    return map;
  }

  SaleAddOnsCompanion toCompanion(bool nullToAbsent) {
    return SaleAddOnsCompanion(
      id: Value(id),
      saleId: Value(saleId),
      addOnTypeId: Value(addOnTypeId),
      quantity: Value(quantity),
      cost: Value(cost),
    );
  }

  factory SaleAddOn.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaleAddOn(
      id: serializer.fromJson<int>(json['id']),
      saleId: serializer.fromJson<int>(json['saleId']),
      addOnTypeId: serializer.fromJson<int>(json['addOnTypeId']),
      quantity: serializer.fromJson<int>(json['quantity']),
      cost: serializer.fromJson<double>(json['cost']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'saleId': serializer.toJson<int>(saleId),
      'addOnTypeId': serializer.toJson<int>(addOnTypeId),
      'quantity': serializer.toJson<int>(quantity),
      'cost': serializer.toJson<double>(cost),
    };
  }

  SaleAddOn copyWith(
          {int? id,
          int? saleId,
          int? addOnTypeId,
          int? quantity,
          double? cost}) =>
      SaleAddOn(
        id: id ?? this.id,
        saleId: saleId ?? this.saleId,
        addOnTypeId: addOnTypeId ?? this.addOnTypeId,
        quantity: quantity ?? this.quantity,
        cost: cost ?? this.cost,
      );
  SaleAddOn copyWithCompanion(SaleAddOnsCompanion data) {
    return SaleAddOn(
      id: data.id.present ? data.id.value : this.id,
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      addOnTypeId:
          data.addOnTypeId.present ? data.addOnTypeId.value : this.addOnTypeId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      cost: data.cost.present ? data.cost.value : this.cost,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaleAddOn(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('addOnTypeId: $addOnTypeId, ')
          ..write('quantity: $quantity, ')
          ..write('cost: $cost')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, saleId, addOnTypeId, quantity, cost);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaleAddOn &&
          other.id == this.id &&
          other.saleId == this.saleId &&
          other.addOnTypeId == this.addOnTypeId &&
          other.quantity == this.quantity &&
          other.cost == this.cost);
}

class SaleAddOnsCompanion extends UpdateCompanion<SaleAddOn> {
  final Value<int> id;
  final Value<int> saleId;
  final Value<int> addOnTypeId;
  final Value<int> quantity;
  final Value<double> cost;
  const SaleAddOnsCompanion({
    this.id = const Value.absent(),
    this.saleId = const Value.absent(),
    this.addOnTypeId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.cost = const Value.absent(),
  });
  SaleAddOnsCompanion.insert({
    this.id = const Value.absent(),
    required int saleId,
    required int addOnTypeId,
    this.quantity = const Value.absent(),
    this.cost = const Value.absent(),
  })  : saleId = Value(saleId),
        addOnTypeId = Value(addOnTypeId);
  static Insertable<SaleAddOn> custom({
    Expression<int>? id,
    Expression<int>? saleId,
    Expression<int>? addOnTypeId,
    Expression<int>? quantity,
    Expression<double>? cost,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (saleId != null) 'sale_id': saleId,
      if (addOnTypeId != null) 'add_on_type_id': addOnTypeId,
      if (quantity != null) 'quantity': quantity,
      if (cost != null) 'cost': cost,
    });
  }

  SaleAddOnsCompanion copyWith(
      {Value<int>? id,
      Value<int>? saleId,
      Value<int>? addOnTypeId,
      Value<int>? quantity,
      Value<double>? cost}) {
    return SaleAddOnsCompanion(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      addOnTypeId: addOnTypeId ?? this.addOnTypeId,
      quantity: quantity ?? this.quantity,
      cost: cost ?? this.cost,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (saleId.present) {
      map['sale_id'] = Variable<int>(saleId.value);
    }
    if (addOnTypeId.present) {
      map['add_on_type_id'] = Variable<int>(addOnTypeId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (cost.present) {
      map['cost'] = Variable<double>(cost.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SaleAddOnsCompanion(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('addOnTypeId: $addOnTypeId, ')
          ..write('quantity: $quantity, ')
          ..write('cost: $cost')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $WalletsTable wallets = $WalletsTable(this);
  late final $SalesTable sales = $SalesTable(this);
  late final $AllocationRulesTable allocationRules =
      $AllocationRulesTable(this);
  late final $BudgetBucketsTable budgetBuckets = $BudgetBucketsTable(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  late final $StockMovementsTable stockMovements = $StockMovementsTable(this);
  late final $AddOnTypesTable addOnTypes = $AddOnTypesTable(this);
  late final $SaleAddOnsTable saleAddOns = $SaleAddOnsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        products,
        wallets,
        sales,
        allocationRules,
        budgetBuckets,
        expenses,
        stockMovements,
        addOnTypes,
        saleAddOns
      ];
}

typedef $$ProductsTableCreateCompanionBuilder = ProductsCompanion Function({
  Value<int> id,
  required String name,
  Value<int> stock,
  required double costPrice,
  Value<int> lowStockThreshold,
  Value<bool> alertEnabled,
  Value<String?> note,
  required int createdAt,
});
typedef $$ProductsTableUpdateCompanionBuilder = ProductsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int> stock,
  Value<double> costPrice,
  Value<int> lowStockThreshold,
  Value<bool> alertEnabled,
  Value<String?> note,
  Value<int> createdAt,
});

final class $$ProductsTableReferences
    extends BaseReferences<_$AppDatabase, $ProductsTable, Product> {
  $$ProductsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SalesTable, List<Sale>> _salesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.sales,
          aliasName: $_aliasNameGenerator(db.products.id, db.sales.productId));

  $$SalesTableProcessedTableManager get salesRefs {
    final manager = $$SalesTableTableManager($_db, $_db.sales)
        .filter((f) => f.productId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_salesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$StockMovementsTable, List<StockMovement>>
      _stockMovementsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.stockMovements,
              aliasName: $_aliasNameGenerator(
                  db.products.id, db.stockMovements.productId));

  $$StockMovementsTableProcessedTableManager get stockMovementsRefs {
    final manager = $$StockMovementsTableTableManager($_db, $_db.stockMovements)
        .filter((f) => f.productId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_stockMovementsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get stock => $composableBuilder(
      column: $table.stock, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get costPrice => $composableBuilder(
      column: $table.costPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lowStockThreshold => $composableBuilder(
      column: $table.lowStockThreshold,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get alertEnabled => $composableBuilder(
      column: $table.alertEnabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> salesRefs(
      Expression<bool> Function($$SalesTableFilterComposer f) f) {
    final $$SalesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sales,
        getReferencedColumn: (t) => t.productId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SalesTableFilterComposer(
              $db: $db,
              $table: $db.sales,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> stockMovementsRefs(
      Expression<bool> Function($$StockMovementsTableFilterComposer f) f) {
    final $$StockMovementsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.stockMovements,
        getReferencedColumn: (t) => t.productId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StockMovementsTableFilterComposer(
              $db: $db,
              $table: $db.stockMovements,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get stock => $composableBuilder(
      column: $table.stock, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get costPrice => $composableBuilder(
      column: $table.costPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lowStockThreshold => $composableBuilder(
      column: $table.lowStockThreshold,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get alertEnabled => $composableBuilder(
      column: $table.alertEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get stock =>
      $composableBuilder(column: $table.stock, builder: (column) => column);

  GeneratedColumn<double> get costPrice =>
      $composableBuilder(column: $table.costPrice, builder: (column) => column);

  GeneratedColumn<int> get lowStockThreshold => $composableBuilder(
      column: $table.lowStockThreshold, builder: (column) => column);

  GeneratedColumn<bool> get alertEnabled => $composableBuilder(
      column: $table.alertEnabled, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> salesRefs<T extends Object>(
      Expression<T> Function($$SalesTableAnnotationComposer a) f) {
    final $$SalesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sales,
        getReferencedColumn: (t) => t.productId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SalesTableAnnotationComposer(
              $db: $db,
              $table: $db.sales,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> stockMovementsRefs<T extends Object>(
      Expression<T> Function($$StockMovementsTableAnnotationComposer a) f) {
    final $$StockMovementsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.stockMovements,
        getReferencedColumn: (t) => t.productId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StockMovementsTableAnnotationComposer(
              $db: $db,
              $table: $db.stockMovements,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ProductsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProductsTable,
    Product,
    $$ProductsTableFilterComposer,
    $$ProductsTableOrderingComposer,
    $$ProductsTableAnnotationComposer,
    $$ProductsTableCreateCompanionBuilder,
    $$ProductsTableUpdateCompanionBuilder,
    (Product, $$ProductsTableReferences),
    Product,
    PrefetchHooks Function({bool salesRefs, bool stockMovementsRefs})> {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> stock = const Value.absent(),
            Value<double> costPrice = const Value.absent(),
            Value<int> lowStockThreshold = const Value.absent(),
            Value<bool> alertEnabled = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
          }) =>
              ProductsCompanion(
            id: id,
            name: name,
            stock: stock,
            costPrice: costPrice,
            lowStockThreshold: lowStockThreshold,
            alertEnabled: alertEnabled,
            note: note,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<int> stock = const Value.absent(),
            required double costPrice,
            Value<int> lowStockThreshold = const Value.absent(),
            Value<bool> alertEnabled = const Value.absent(),
            Value<String?> note = const Value.absent(),
            required int createdAt,
          }) =>
              ProductsCompanion.insert(
            id: id,
            name: name,
            stock: stock,
            costPrice: costPrice,
            lowStockThreshold: lowStockThreshold,
            alertEnabled: alertEnabled,
            note: note,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ProductsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {salesRefs = false, stockMovementsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (salesRefs) db.sales,
                if (stockMovementsRefs) db.stockMovements
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (salesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$ProductsTableReferences._salesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProductsTableReferences(db, table, p0).salesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.productId == item.id),
                        typedResults: items),
                  if (stockMovementsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$ProductsTableReferences
                            ._stockMovementsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProductsTableReferences(db, table, p0)
                                .stockMovementsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.productId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ProductsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProductsTable,
    Product,
    $$ProductsTableFilterComposer,
    $$ProductsTableOrderingComposer,
    $$ProductsTableAnnotationComposer,
    $$ProductsTableCreateCompanionBuilder,
    $$ProductsTableUpdateCompanionBuilder,
    (Product, $$ProductsTableReferences),
    Product,
    PrefetchHooks Function({bool salesRefs, bool stockMovementsRefs})>;
typedef $$WalletsTableCreateCompanionBuilder = WalletsCompanion Function({
  Value<int> id,
  required String name,
  required String type,
  Value<double> openingBalance,
  Value<bool> isActive,
  required int createdAt,
});
typedef $$WalletsTableUpdateCompanionBuilder = WalletsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> type,
  Value<double> openingBalance,
  Value<bool> isActive,
  Value<int> createdAt,
});

final class $$WalletsTableReferences
    extends BaseReferences<_$AppDatabase, $WalletsTable, Wallet> {
  $$WalletsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SalesTable, List<Sale>> _salesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.sales,
          aliasName: $_aliasNameGenerator(db.wallets.id, db.sales.walletId));

  $$SalesTableProcessedTableManager get salesRefs {
    final manager = $$SalesTableTableManager($_db, $_db.sales)
        .filter((f) => f.walletId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_salesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ExpensesTable, List<Expense>> _expensesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.expenses,
          aliasName: $_aliasNameGenerator(db.wallets.id, db.expenses.walletId));

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager($_db, $_db.expenses)
        .filter((f) => f.walletId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$WalletsTableFilterComposer
    extends Composer<_$AppDatabase, $WalletsTable> {
  $$WalletsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get openingBalance => $composableBuilder(
      column: $table.openingBalance,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> salesRefs(
      Expression<bool> Function($$SalesTableFilterComposer f) f) {
    final $$SalesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sales,
        getReferencedColumn: (t) => t.walletId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SalesTableFilterComposer(
              $db: $db,
              $table: $db.sales,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> expensesRefs(
      Expression<bool> Function($$ExpensesTableFilterComposer f) f) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.expenses,
        getReferencedColumn: (t) => t.walletId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExpensesTableFilterComposer(
              $db: $db,
              $table: $db.expenses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$WalletsTableOrderingComposer
    extends Composer<_$AppDatabase, $WalletsTable> {
  $$WalletsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get openingBalance => $composableBuilder(
      column: $table.openingBalance,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$WalletsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WalletsTable> {
  $$WalletsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get openingBalance => $composableBuilder(
      column: $table.openingBalance, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> salesRefs<T extends Object>(
      Expression<T> Function($$SalesTableAnnotationComposer a) f) {
    final $$SalesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sales,
        getReferencedColumn: (t) => t.walletId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SalesTableAnnotationComposer(
              $db: $db,
              $table: $db.sales,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> expensesRefs<T extends Object>(
      Expression<T> Function($$ExpensesTableAnnotationComposer a) f) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.expenses,
        getReferencedColumn: (t) => t.walletId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExpensesTableAnnotationComposer(
              $db: $db,
              $table: $db.expenses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$WalletsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WalletsTable,
    Wallet,
    $$WalletsTableFilterComposer,
    $$WalletsTableOrderingComposer,
    $$WalletsTableAnnotationComposer,
    $$WalletsTableCreateCompanionBuilder,
    $$WalletsTableUpdateCompanionBuilder,
    (Wallet, $$WalletsTableReferences),
    Wallet,
    PrefetchHooks Function({bool salesRefs, bool expensesRefs})> {
  $$WalletsTableTableManager(_$AppDatabase db, $WalletsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WalletsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WalletsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WalletsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<double> openingBalance = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
          }) =>
              WalletsCompanion(
            id: id,
            name: name,
            type: type,
            openingBalance: openingBalance,
            isActive: isActive,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String type,
            Value<double> openingBalance = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            required int createdAt,
          }) =>
              WalletsCompanion.insert(
            id: id,
            name: name,
            type: type,
            openingBalance: openingBalance,
            isActive: isActive,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$WalletsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({salesRefs = false, expensesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (salesRefs) db.sales,
                if (expensesRefs) db.expenses
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (salesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$WalletsTableReferences._salesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$WalletsTableReferences(db, table, p0).salesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.walletId == item.id),
                        typedResults: items),
                  if (expensesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$WalletsTableReferences._expensesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$WalletsTableReferences(db, table, p0)
                                .expensesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.walletId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$WalletsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WalletsTable,
    Wallet,
    $$WalletsTableFilterComposer,
    $$WalletsTableOrderingComposer,
    $$WalletsTableAnnotationComposer,
    $$WalletsTableCreateCompanionBuilder,
    $$WalletsTableUpdateCompanionBuilder,
    (Wallet, $$WalletsTableReferences),
    Wallet,
    PrefetchHooks Function({bool salesRefs, bool expensesRefs})>;
typedef $$SalesTableCreateCompanionBuilder = SalesCompanion Function({
  Value<int> id,
  required int productId,
  required int quantity,
  required double sellingPrice,
  required double total,
  required String platform,
  required String paymentStatus,
  Value<String?> customerName,
  Value<bool> isDiscounted,
  Value<double?> normalPrice,
  required int date,
  required int createdAt,
  Value<int?> walletId,
  Value<String> ownership,
});
typedef $$SalesTableUpdateCompanionBuilder = SalesCompanion Function({
  Value<int> id,
  Value<int> productId,
  Value<int> quantity,
  Value<double> sellingPrice,
  Value<double> total,
  Value<String> platform,
  Value<String> paymentStatus,
  Value<String?> customerName,
  Value<bool> isDiscounted,
  Value<double?> normalPrice,
  Value<int> date,
  Value<int> createdAt,
  Value<int?> walletId,
  Value<String> ownership,
});

final class $$SalesTableReferences
    extends BaseReferences<_$AppDatabase, $SalesTable, Sale> {
  $$SalesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProductsTable _productIdTable(_$AppDatabase db) => db.products
      .createAlias($_aliasNameGenerator(db.sales.productId, db.products.id));

  $$ProductsTableProcessedTableManager get productId {
    final manager = $$ProductsTableTableManager($_db, $_db.products)
        .filter((f) => f.id($_item.productId));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $WalletsTable _walletIdTable(_$AppDatabase db) => db.wallets
      .createAlias($_aliasNameGenerator(db.sales.walletId, db.wallets.id));

  $$WalletsTableProcessedTableManager? get walletId {
    if ($_item.walletId == null) return null;
    final manager = $$WalletsTableTableManager($_db, $_db.wallets)
        .filter((f) => f.id($_item.walletId!));
    final item = $_typedResult.readTableOrNull(_walletIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$SaleAddOnsTable, List<SaleAddOn>>
      _saleAddOnsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.saleAddOns,
          aliasName: $_aliasNameGenerator(db.sales.id, db.saleAddOns.saleId));

  $$SaleAddOnsTableProcessedTableManager get saleAddOnsRefs {
    final manager = $$SaleAddOnsTableTableManager($_db, $_db.saleAddOns)
        .filter((f) => f.saleId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_saleAddOnsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SalesTableFilterComposer extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get sellingPrice => $composableBuilder(
      column: $table.sellingPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get platform => $composableBuilder(
      column: $table.platform, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentStatus => $composableBuilder(
      column: $table.paymentStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerName => $composableBuilder(
      column: $table.customerName, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDiscounted => $composableBuilder(
      column: $table.isDiscounted, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get normalPrice => $composableBuilder(
      column: $table.normalPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownership => $composableBuilder(
      column: $table.ownership, builder: (column) => ColumnFilters(column));

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableFilterComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WalletsTableFilterComposer get walletId {
    final $$WalletsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.walletId,
        referencedTable: $db.wallets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WalletsTableFilterComposer(
              $db: $db,
              $table: $db.wallets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> saleAddOnsRefs(
      Expression<bool> Function($$SaleAddOnsTableFilterComposer f) f) {
    final $$SaleAddOnsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.saleAddOns,
        getReferencedColumn: (t) => t.saleId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SaleAddOnsTableFilterComposer(
              $db: $db,
              $table: $db.saleAddOns,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SalesTableOrderingComposer
    extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get sellingPrice => $composableBuilder(
      column: $table.sellingPrice,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get platform => $composableBuilder(
      column: $table.platform, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentStatus => $composableBuilder(
      column: $table.paymentStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerName => $composableBuilder(
      column: $table.customerName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDiscounted => $composableBuilder(
      column: $table.isDiscounted,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get normalPrice => $composableBuilder(
      column: $table.normalPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownership => $composableBuilder(
      column: $table.ownership, builder: (column) => ColumnOrderings(column));

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableOrderingComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WalletsTableOrderingComposer get walletId {
    final $$WalletsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.walletId,
        referencedTable: $db.wallets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WalletsTableOrderingComposer(
              $db: $db,
              $table: $db.wallets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SalesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get sellingPrice => $composableBuilder(
      column: $table.sellingPrice, builder: (column) => column);

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<String> get paymentStatus => $composableBuilder(
      column: $table.paymentStatus, builder: (column) => column);

  GeneratedColumn<String> get customerName => $composableBuilder(
      column: $table.customerName, builder: (column) => column);

  GeneratedColumn<bool> get isDiscounted => $composableBuilder(
      column: $table.isDiscounted, builder: (column) => column);

  GeneratedColumn<double> get normalPrice => $composableBuilder(
      column: $table.normalPrice, builder: (column) => column);

  GeneratedColumn<int> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get ownership =>
      $composableBuilder(column: $table.ownership, builder: (column) => column);

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableAnnotationComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WalletsTableAnnotationComposer get walletId {
    final $$WalletsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.walletId,
        referencedTable: $db.wallets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WalletsTableAnnotationComposer(
              $db: $db,
              $table: $db.wallets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> saleAddOnsRefs<T extends Object>(
      Expression<T> Function($$SaleAddOnsTableAnnotationComposer a) f) {
    final $$SaleAddOnsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.saleAddOns,
        getReferencedColumn: (t) => t.saleId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SaleAddOnsTableAnnotationComposer(
              $db: $db,
              $table: $db.saleAddOns,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SalesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SalesTable,
    Sale,
    $$SalesTableFilterComposer,
    $$SalesTableOrderingComposer,
    $$SalesTableAnnotationComposer,
    $$SalesTableCreateCompanionBuilder,
    $$SalesTableUpdateCompanionBuilder,
    (Sale, $$SalesTableReferences),
    Sale,
    PrefetchHooks Function(
        {bool productId, bool walletId, bool saleAddOnsRefs})> {
  $$SalesTableTableManager(_$AppDatabase db, $SalesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SalesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SalesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SalesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> productId = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<double> sellingPrice = const Value.absent(),
            Value<double> total = const Value.absent(),
            Value<String> platform = const Value.absent(),
            Value<String> paymentStatus = const Value.absent(),
            Value<String?> customerName = const Value.absent(),
            Value<bool> isDiscounted = const Value.absent(),
            Value<double?> normalPrice = const Value.absent(),
            Value<int> date = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int?> walletId = const Value.absent(),
            Value<String> ownership = const Value.absent(),
          }) =>
              SalesCompanion(
            id: id,
            productId: productId,
            quantity: quantity,
            sellingPrice: sellingPrice,
            total: total,
            platform: platform,
            paymentStatus: paymentStatus,
            customerName: customerName,
            isDiscounted: isDiscounted,
            normalPrice: normalPrice,
            date: date,
            createdAt: createdAt,
            walletId: walletId,
            ownership: ownership,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int productId,
            required int quantity,
            required double sellingPrice,
            required double total,
            required String platform,
            required String paymentStatus,
            Value<String?> customerName = const Value.absent(),
            Value<bool> isDiscounted = const Value.absent(),
            Value<double?> normalPrice = const Value.absent(),
            required int date,
            required int createdAt,
            Value<int?> walletId = const Value.absent(),
            Value<String> ownership = const Value.absent(),
          }) =>
              SalesCompanion.insert(
            id: id,
            productId: productId,
            quantity: quantity,
            sellingPrice: sellingPrice,
            total: total,
            platform: platform,
            paymentStatus: paymentStatus,
            customerName: customerName,
            isDiscounted: isDiscounted,
            normalPrice: normalPrice,
            date: date,
            createdAt: createdAt,
            walletId: walletId,
            ownership: ownership,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$SalesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {productId = false, walletId = false, saleAddOnsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (saleAddOnsRefs) db.saleAddOns],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (productId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.productId,
                    referencedTable: $$SalesTableReferences._productIdTable(db),
                    referencedColumn:
                        $$SalesTableReferences._productIdTable(db).id,
                  ) as T;
                }
                if (walletId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.walletId,
                    referencedTable: $$SalesTableReferences._walletIdTable(db),
                    referencedColumn:
                        $$SalesTableReferences._walletIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (saleAddOnsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$SalesTableReferences._saleAddOnsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SalesTableReferences(db, table, p0)
                                .saleAddOnsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.saleId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SalesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SalesTable,
    Sale,
    $$SalesTableFilterComposer,
    $$SalesTableOrderingComposer,
    $$SalesTableAnnotationComposer,
    $$SalesTableCreateCompanionBuilder,
    $$SalesTableUpdateCompanionBuilder,
    (Sale, $$SalesTableReferences),
    Sale,
    PrefetchHooks Function(
        {bool productId, bool walletId, bool saleAddOnsRefs})>;
typedef $$AllocationRulesTableCreateCompanionBuilder = AllocationRulesCompanion
    Function({
  Value<int> id,
  required String label,
  required double percentage,
  Value<int> sortOrder,
  Value<bool> isActive,
  required int createdAt,
});
typedef $$AllocationRulesTableUpdateCompanionBuilder = AllocationRulesCompanion
    Function({
  Value<int> id,
  Value<String> label,
  Value<double> percentage,
  Value<int> sortOrder,
  Value<bool> isActive,
  Value<int> createdAt,
});

final class $$AllocationRulesTableReferences extends BaseReferences<
    _$AppDatabase, $AllocationRulesTable, AllocationRule> {
  $$AllocationRulesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ExpensesTable, List<Expense>> _expensesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.expenses,
          aliasName: $_aliasNameGenerator(
              db.allocationRules.id, db.expenses.allocationRuleId));

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager($_db, $_db.expenses)
        .filter((f) => f.allocationRuleId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$AllocationRulesTableFilterComposer
    extends Composer<_$AppDatabase, $AllocationRulesTable> {
  $$AllocationRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get percentage => $composableBuilder(
      column: $table.percentage, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> expensesRefs(
      Expression<bool> Function($$ExpensesTableFilterComposer f) f) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.expenses,
        getReferencedColumn: (t) => t.allocationRuleId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExpensesTableFilterComposer(
              $db: $db,
              $table: $db.expenses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AllocationRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $AllocationRulesTable> {
  $$AllocationRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get percentage => $composableBuilder(
      column: $table.percentage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$AllocationRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AllocationRulesTable> {
  $$AllocationRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<double> get percentage => $composableBuilder(
      column: $table.percentage, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> expensesRefs<T extends Object>(
      Expression<T> Function($$ExpensesTableAnnotationComposer a) f) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.expenses,
        getReferencedColumn: (t) => t.allocationRuleId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExpensesTableAnnotationComposer(
              $db: $db,
              $table: $db.expenses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AllocationRulesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AllocationRulesTable,
    AllocationRule,
    $$AllocationRulesTableFilterComposer,
    $$AllocationRulesTableOrderingComposer,
    $$AllocationRulesTableAnnotationComposer,
    $$AllocationRulesTableCreateCompanionBuilder,
    $$AllocationRulesTableUpdateCompanionBuilder,
    (AllocationRule, $$AllocationRulesTableReferences),
    AllocationRule,
    PrefetchHooks Function({bool expensesRefs})> {
  $$AllocationRulesTableTableManager(
      _$AppDatabase db, $AllocationRulesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AllocationRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AllocationRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AllocationRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> label = const Value.absent(),
            Value<double> percentage = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
          }) =>
              AllocationRulesCompanion(
            id: id,
            label: label,
            percentage: percentage,
            sortOrder: sortOrder,
            isActive: isActive,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String label,
            required double percentage,
            Value<int> sortOrder = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            required int createdAt,
          }) =>
              AllocationRulesCompanion.insert(
            id: id,
            label: label,
            percentage: percentage,
            sortOrder: sortOrder,
            isActive: isActive,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$AllocationRulesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({expensesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (expensesRefs) db.expenses],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (expensesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$AllocationRulesTableReferences
                            ._expensesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AllocationRulesTableReferences(db, table, p0)
                                .expensesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.allocationRuleId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$AllocationRulesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AllocationRulesTable,
    AllocationRule,
    $$AllocationRulesTableFilterComposer,
    $$AllocationRulesTableOrderingComposer,
    $$AllocationRulesTableAnnotationComposer,
    $$AllocationRulesTableCreateCompanionBuilder,
    $$AllocationRulesTableUpdateCompanionBuilder,
    (AllocationRule, $$AllocationRulesTableReferences),
    AllocationRule,
    PrefetchHooks Function({bool expensesRefs})>;
typedef $$BudgetBucketsTableCreateCompanionBuilder = BudgetBucketsCompanion
    Function({
  Value<int> id,
  required String name,
  Value<double> allocatedAmount,
  Value<String?> color,
  required int createdAt,
});
typedef $$BudgetBucketsTableUpdateCompanionBuilder = BudgetBucketsCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<double> allocatedAmount,
  Value<String?> color,
  Value<int> createdAt,
});

final class $$BudgetBucketsTableReferences
    extends BaseReferences<_$AppDatabase, $BudgetBucketsTable, BudgetBucket> {
  $$BudgetBucketsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ExpensesTable, List<Expense>> _expensesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.expenses,
          aliasName:
              $_aliasNameGenerator(db.budgetBuckets.id, db.expenses.bucketId));

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager($_db, $_db.expenses)
        .filter((f) => f.bucketId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$BudgetBucketsTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetBucketsTable> {
  $$BudgetBucketsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get allocatedAmount => $composableBuilder(
      column: $table.allocatedAmount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> expensesRefs(
      Expression<bool> Function($$ExpensesTableFilterComposer f) f) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.expenses,
        getReferencedColumn: (t) => t.bucketId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExpensesTableFilterComposer(
              $db: $db,
              $table: $db.expenses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BudgetBucketsTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetBucketsTable> {
  $$BudgetBucketsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get allocatedAmount => $composableBuilder(
      column: $table.allocatedAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$BudgetBucketsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetBucketsTable> {
  $$BudgetBucketsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get allocatedAmount => $composableBuilder(
      column: $table.allocatedAmount, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> expensesRefs<T extends Object>(
      Expression<T> Function($$ExpensesTableAnnotationComposer a) f) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.expenses,
        getReferencedColumn: (t) => t.bucketId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExpensesTableAnnotationComposer(
              $db: $db,
              $table: $db.expenses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BudgetBucketsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BudgetBucketsTable,
    BudgetBucket,
    $$BudgetBucketsTableFilterComposer,
    $$BudgetBucketsTableOrderingComposer,
    $$BudgetBucketsTableAnnotationComposer,
    $$BudgetBucketsTableCreateCompanionBuilder,
    $$BudgetBucketsTableUpdateCompanionBuilder,
    (BudgetBucket, $$BudgetBucketsTableReferences),
    BudgetBucket,
    PrefetchHooks Function({bool expensesRefs})> {
  $$BudgetBucketsTableTableManager(_$AppDatabase db, $BudgetBucketsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetBucketsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetBucketsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetBucketsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<double> allocatedAmount = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
          }) =>
              BudgetBucketsCompanion(
            id: id,
            name: name,
            allocatedAmount: allocatedAmount,
            color: color,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<double> allocatedAmount = const Value.absent(),
            Value<String?> color = const Value.absent(),
            required int createdAt,
          }) =>
              BudgetBucketsCompanion.insert(
            id: id,
            name: name,
            allocatedAmount: allocatedAmount,
            color: color,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$BudgetBucketsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({expensesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (expensesRefs) db.expenses],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (expensesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$BudgetBucketsTableReferences
                            ._expensesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BudgetBucketsTableReferences(db, table, p0)
                                .expensesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.bucketId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$BudgetBucketsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BudgetBucketsTable,
    BudgetBucket,
    $$BudgetBucketsTableFilterComposer,
    $$BudgetBucketsTableOrderingComposer,
    $$BudgetBucketsTableAnnotationComposer,
    $$BudgetBucketsTableCreateCompanionBuilder,
    $$BudgetBucketsTableUpdateCompanionBuilder,
    (BudgetBucket, $$BudgetBucketsTableReferences),
    BudgetBucket,
    PrefetchHooks Function({bool expensesRefs})>;
typedef $$ExpensesTableCreateCompanionBuilder = ExpensesCompanion Function({
  Value<int> id,
  required double amount,
  required String category,
  Value<String?> note,
  required int date,
  required int createdAt,
  Value<int?> walletId,
  Value<String> ownership,
  Value<int?> allocationRuleId,
  Value<int?> bucketId,
});
typedef $$ExpensesTableUpdateCompanionBuilder = ExpensesCompanion Function({
  Value<int> id,
  Value<double> amount,
  Value<String> category,
  Value<String?> note,
  Value<int> date,
  Value<int> createdAt,
  Value<int?> walletId,
  Value<String> ownership,
  Value<int?> allocationRuleId,
  Value<int?> bucketId,
});

final class $$ExpensesTableReferences
    extends BaseReferences<_$AppDatabase, $ExpensesTable, Expense> {
  $$ExpensesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WalletsTable _walletIdTable(_$AppDatabase db) => db.wallets
      .createAlias($_aliasNameGenerator(db.expenses.walletId, db.wallets.id));

  $$WalletsTableProcessedTableManager? get walletId {
    if ($_item.walletId == null) return null;
    final manager = $$WalletsTableTableManager($_db, $_db.wallets)
        .filter((f) => f.id($_item.walletId!));
    final item = $_typedResult.readTableOrNull(_walletIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $AllocationRulesTable _allocationRuleIdTable(_$AppDatabase db) =>
      db.allocationRules.createAlias($_aliasNameGenerator(
          db.expenses.allocationRuleId, db.allocationRules.id));

  $$AllocationRulesTableProcessedTableManager? get allocationRuleId {
    if ($_item.allocationRuleId == null) return null;
    final manager =
        $$AllocationRulesTableTableManager($_db, $_db.allocationRules)
            .filter((f) => f.id($_item.allocationRuleId!));
    final item = $_typedResult.readTableOrNull(_allocationRuleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $BudgetBucketsTable _bucketIdTable(_$AppDatabase db) =>
      db.budgetBuckets.createAlias(
          $_aliasNameGenerator(db.expenses.bucketId, db.budgetBuckets.id));

  $$BudgetBucketsTableProcessedTableManager? get bucketId {
    if ($_item.bucketId == null) return null;
    final manager = $$BudgetBucketsTableTableManager($_db, $_db.budgetBuckets)
        .filter((f) => f.id($_item.bucketId!));
    final item = $_typedResult.readTableOrNull(_bucketIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownership => $composableBuilder(
      column: $table.ownership, builder: (column) => ColumnFilters(column));

  $$WalletsTableFilterComposer get walletId {
    final $$WalletsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.walletId,
        referencedTable: $db.wallets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WalletsTableFilterComposer(
              $db: $db,
              $table: $db.wallets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AllocationRulesTableFilterComposer get allocationRuleId {
    final $$AllocationRulesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.allocationRuleId,
        referencedTable: $db.allocationRules,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AllocationRulesTableFilterComposer(
              $db: $db,
              $table: $db.allocationRules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BudgetBucketsTableFilterComposer get bucketId {
    final $$BudgetBucketsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bucketId,
        referencedTable: $db.budgetBuckets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BudgetBucketsTableFilterComposer(
              $db: $db,
              $table: $db.budgetBuckets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownership => $composableBuilder(
      column: $table.ownership, builder: (column) => ColumnOrderings(column));

  $$WalletsTableOrderingComposer get walletId {
    final $$WalletsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.walletId,
        referencedTable: $db.wallets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WalletsTableOrderingComposer(
              $db: $db,
              $table: $db.wallets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AllocationRulesTableOrderingComposer get allocationRuleId {
    final $$AllocationRulesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.allocationRuleId,
        referencedTable: $db.allocationRules,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AllocationRulesTableOrderingComposer(
              $db: $db,
              $table: $db.allocationRules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BudgetBucketsTableOrderingComposer get bucketId {
    final $$BudgetBucketsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bucketId,
        referencedTable: $db.budgetBuckets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BudgetBucketsTableOrderingComposer(
              $db: $db,
              $table: $db.budgetBuckets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get ownership =>
      $composableBuilder(column: $table.ownership, builder: (column) => column);

  $$WalletsTableAnnotationComposer get walletId {
    final $$WalletsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.walletId,
        referencedTable: $db.wallets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WalletsTableAnnotationComposer(
              $db: $db,
              $table: $db.wallets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AllocationRulesTableAnnotationComposer get allocationRuleId {
    final $$AllocationRulesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.allocationRuleId,
        referencedTable: $db.allocationRules,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AllocationRulesTableAnnotationComposer(
              $db: $db,
              $table: $db.allocationRules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BudgetBucketsTableAnnotationComposer get bucketId {
    final $$BudgetBucketsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bucketId,
        referencedTable: $db.budgetBuckets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BudgetBucketsTableAnnotationComposer(
              $db: $db,
              $table: $db.budgetBuckets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ExpensesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExpensesTable,
    Expense,
    $$ExpensesTableFilterComposer,
    $$ExpensesTableOrderingComposer,
    $$ExpensesTableAnnotationComposer,
    $$ExpensesTableCreateCompanionBuilder,
    $$ExpensesTableUpdateCompanionBuilder,
    (Expense, $$ExpensesTableReferences),
    Expense,
    PrefetchHooks Function(
        {bool walletId, bool allocationRuleId, bool bucketId})> {
  $$ExpensesTableTableManager(_$AppDatabase db, $ExpensesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<int> date = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int?> walletId = const Value.absent(),
            Value<String> ownership = const Value.absent(),
            Value<int?> allocationRuleId = const Value.absent(),
            Value<int?> bucketId = const Value.absent(),
          }) =>
              ExpensesCompanion(
            id: id,
            amount: amount,
            category: category,
            note: note,
            date: date,
            createdAt: createdAt,
            walletId: walletId,
            ownership: ownership,
            allocationRuleId: allocationRuleId,
            bucketId: bucketId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required double amount,
            required String category,
            Value<String?> note = const Value.absent(),
            required int date,
            required int createdAt,
            Value<int?> walletId = const Value.absent(),
            Value<String> ownership = const Value.absent(),
            Value<int?> allocationRuleId = const Value.absent(),
            Value<int?> bucketId = const Value.absent(),
          }) =>
              ExpensesCompanion.insert(
            id: id,
            amount: amount,
            category: category,
            note: note,
            date: date,
            createdAt: createdAt,
            walletId: walletId,
            ownership: ownership,
            allocationRuleId: allocationRuleId,
            bucketId: bucketId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ExpensesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {walletId = false, allocationRuleId = false, bucketId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (walletId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.walletId,
                    referencedTable:
                        $$ExpensesTableReferences._walletIdTable(db),
                    referencedColumn:
                        $$ExpensesTableReferences._walletIdTable(db).id,
                  ) as T;
                }
                if (allocationRuleId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.allocationRuleId,
                    referencedTable:
                        $$ExpensesTableReferences._allocationRuleIdTable(db),
                    referencedColumn:
                        $$ExpensesTableReferences._allocationRuleIdTable(db).id,
                  ) as T;
                }
                if (bucketId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.bucketId,
                    referencedTable:
                        $$ExpensesTableReferences._bucketIdTable(db),
                    referencedColumn:
                        $$ExpensesTableReferences._bucketIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ExpensesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ExpensesTable,
    Expense,
    $$ExpensesTableFilterComposer,
    $$ExpensesTableOrderingComposer,
    $$ExpensesTableAnnotationComposer,
    $$ExpensesTableCreateCompanionBuilder,
    $$ExpensesTableUpdateCompanionBuilder,
    (Expense, $$ExpensesTableReferences),
    Expense,
    PrefetchHooks Function(
        {bool walletId, bool allocationRuleId, bool bucketId})>;
typedef $$StockMovementsTableCreateCompanionBuilder = StockMovementsCompanion
    Function({
  Value<int> id,
  required int productId,
  required int quantity,
  required String type,
  Value<String?> note,
  required int date,
});
typedef $$StockMovementsTableUpdateCompanionBuilder = StockMovementsCompanion
    Function({
  Value<int> id,
  Value<int> productId,
  Value<int> quantity,
  Value<String> type,
  Value<String?> note,
  Value<int> date,
});

final class $$StockMovementsTableReferences
    extends BaseReferences<_$AppDatabase, $StockMovementsTable, StockMovement> {
  $$StockMovementsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias(
          $_aliasNameGenerator(db.stockMovements.productId, db.products.id));

  $$ProductsTableProcessedTableManager get productId {
    final manager = $$ProductsTableTableManager($_db, $_db.products)
        .filter((f) => f.id($_item.productId));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$StockMovementsTableFilterComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableFilterComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StockMovementsTableOrderingComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableOrderingComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StockMovementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableAnnotationComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StockMovementsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StockMovementsTable,
    StockMovement,
    $$StockMovementsTableFilterComposer,
    $$StockMovementsTableOrderingComposer,
    $$StockMovementsTableAnnotationComposer,
    $$StockMovementsTableCreateCompanionBuilder,
    $$StockMovementsTableUpdateCompanionBuilder,
    (StockMovement, $$StockMovementsTableReferences),
    StockMovement,
    PrefetchHooks Function({bool productId})> {
  $$StockMovementsTableTableManager(
      _$AppDatabase db, $StockMovementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockMovementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockMovementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockMovementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> productId = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<int> date = const Value.absent(),
          }) =>
              StockMovementsCompanion(
            id: id,
            productId: productId,
            quantity: quantity,
            type: type,
            note: note,
            date: date,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int productId,
            required int quantity,
            required String type,
            Value<String?> note = const Value.absent(),
            required int date,
          }) =>
              StockMovementsCompanion.insert(
            id: id,
            productId: productId,
            quantity: quantity,
            type: type,
            note: note,
            date: date,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$StockMovementsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({productId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (productId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.productId,
                    referencedTable:
                        $$StockMovementsTableReferences._productIdTable(db),
                    referencedColumn:
                        $$StockMovementsTableReferences._productIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$StockMovementsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StockMovementsTable,
    StockMovement,
    $$StockMovementsTableFilterComposer,
    $$StockMovementsTableOrderingComposer,
    $$StockMovementsTableAnnotationComposer,
    $$StockMovementsTableCreateCompanionBuilder,
    $$StockMovementsTableUpdateCompanionBuilder,
    (StockMovement, $$StockMovementsTableReferences),
    StockMovement,
    PrefetchHooks Function({bool productId})>;
typedef $$AddOnTypesTableCreateCompanionBuilder = AddOnTypesCompanion Function({
  Value<int> id,
  required String name,
  Value<bool> isActive,
  required int createdAt,
});
typedef $$AddOnTypesTableUpdateCompanionBuilder = AddOnTypesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<bool> isActive,
  Value<int> createdAt,
});

final class $$AddOnTypesTableReferences
    extends BaseReferences<_$AppDatabase, $AddOnTypesTable, AddOnType> {
  $$AddOnTypesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SaleAddOnsTable, List<SaleAddOn>>
      _saleAddOnsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.saleAddOns,
              aliasName: $_aliasNameGenerator(
                  db.addOnTypes.id, db.saleAddOns.addOnTypeId));

  $$SaleAddOnsTableProcessedTableManager get saleAddOnsRefs {
    final manager = $$SaleAddOnsTableTableManager($_db, $_db.saleAddOns)
        .filter((f) => f.addOnTypeId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_saleAddOnsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$AddOnTypesTableFilterComposer
    extends Composer<_$AppDatabase, $AddOnTypesTable> {
  $$AddOnTypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> saleAddOnsRefs(
      Expression<bool> Function($$SaleAddOnsTableFilterComposer f) f) {
    final $$SaleAddOnsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.saleAddOns,
        getReferencedColumn: (t) => t.addOnTypeId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SaleAddOnsTableFilterComposer(
              $db: $db,
              $table: $db.saleAddOns,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AddOnTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $AddOnTypesTable> {
  $$AddOnTypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$AddOnTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AddOnTypesTable> {
  $$AddOnTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> saleAddOnsRefs<T extends Object>(
      Expression<T> Function($$SaleAddOnsTableAnnotationComposer a) f) {
    final $$SaleAddOnsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.saleAddOns,
        getReferencedColumn: (t) => t.addOnTypeId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SaleAddOnsTableAnnotationComposer(
              $db: $db,
              $table: $db.saleAddOns,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AddOnTypesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AddOnTypesTable,
    AddOnType,
    $$AddOnTypesTableFilterComposer,
    $$AddOnTypesTableOrderingComposer,
    $$AddOnTypesTableAnnotationComposer,
    $$AddOnTypesTableCreateCompanionBuilder,
    $$AddOnTypesTableUpdateCompanionBuilder,
    (AddOnType, $$AddOnTypesTableReferences),
    AddOnType,
    PrefetchHooks Function({bool saleAddOnsRefs})> {
  $$AddOnTypesTableTableManager(_$AppDatabase db, $AddOnTypesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AddOnTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AddOnTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AddOnTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
          }) =>
              AddOnTypesCompanion(
            id: id,
            name: name,
            isActive: isActive,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<bool> isActive = const Value.absent(),
            required int createdAt,
          }) =>
              AddOnTypesCompanion.insert(
            id: id,
            name: name,
            isActive: isActive,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$AddOnTypesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({saleAddOnsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (saleAddOnsRefs) db.saleAddOns],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (saleAddOnsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$AddOnTypesTableReferences
                            ._saleAddOnsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AddOnTypesTableReferences(db, table, p0)
                                .saleAddOnsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.addOnTypeId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$AddOnTypesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AddOnTypesTable,
    AddOnType,
    $$AddOnTypesTableFilterComposer,
    $$AddOnTypesTableOrderingComposer,
    $$AddOnTypesTableAnnotationComposer,
    $$AddOnTypesTableCreateCompanionBuilder,
    $$AddOnTypesTableUpdateCompanionBuilder,
    (AddOnType, $$AddOnTypesTableReferences),
    AddOnType,
    PrefetchHooks Function({bool saleAddOnsRefs})>;
typedef $$SaleAddOnsTableCreateCompanionBuilder = SaleAddOnsCompanion Function({
  Value<int> id,
  required int saleId,
  required int addOnTypeId,
  Value<int> quantity,
  Value<double> cost,
});
typedef $$SaleAddOnsTableUpdateCompanionBuilder = SaleAddOnsCompanion Function({
  Value<int> id,
  Value<int> saleId,
  Value<int> addOnTypeId,
  Value<int> quantity,
  Value<double> cost,
});

final class $$SaleAddOnsTableReferences
    extends BaseReferences<_$AppDatabase, $SaleAddOnsTable, SaleAddOn> {
  $$SaleAddOnsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SalesTable _saleIdTable(_$AppDatabase db) => db.sales
      .createAlias($_aliasNameGenerator(db.saleAddOns.saleId, db.sales.id));

  $$SalesTableProcessedTableManager get saleId {
    final manager = $$SalesTableTableManager($_db, $_db.sales)
        .filter((f) => f.id($_item.saleId));
    final item = $_typedResult.readTableOrNull(_saleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $AddOnTypesTable _addOnTypeIdTable(_$AppDatabase db) =>
      db.addOnTypes.createAlias(
          $_aliasNameGenerator(db.saleAddOns.addOnTypeId, db.addOnTypes.id));

  $$AddOnTypesTableProcessedTableManager get addOnTypeId {
    final manager = $$AddOnTypesTableTableManager($_db, $_db.addOnTypes)
        .filter((f) => f.id($_item.addOnTypeId));
    final item = $_typedResult.readTableOrNull(_addOnTypeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SaleAddOnsTableFilterComposer
    extends Composer<_$AppDatabase, $SaleAddOnsTable> {
  $$SaleAddOnsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get cost => $composableBuilder(
      column: $table.cost, builder: (column) => ColumnFilters(column));

  $$SalesTableFilterComposer get saleId {
    final $$SalesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.saleId,
        referencedTable: $db.sales,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SalesTableFilterComposer(
              $db: $db,
              $table: $db.sales,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AddOnTypesTableFilterComposer get addOnTypeId {
    final $$AddOnTypesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.addOnTypeId,
        referencedTable: $db.addOnTypes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AddOnTypesTableFilterComposer(
              $db: $db,
              $table: $db.addOnTypes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SaleAddOnsTableOrderingComposer
    extends Composer<_$AppDatabase, $SaleAddOnsTable> {
  $$SaleAddOnsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get cost => $composableBuilder(
      column: $table.cost, builder: (column) => ColumnOrderings(column));

  $$SalesTableOrderingComposer get saleId {
    final $$SalesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.saleId,
        referencedTable: $db.sales,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SalesTableOrderingComposer(
              $db: $db,
              $table: $db.sales,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AddOnTypesTableOrderingComposer get addOnTypeId {
    final $$AddOnTypesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.addOnTypeId,
        referencedTable: $db.addOnTypes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AddOnTypesTableOrderingComposer(
              $db: $db,
              $table: $db.addOnTypes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SaleAddOnsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SaleAddOnsTable> {
  $$SaleAddOnsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get cost =>
      $composableBuilder(column: $table.cost, builder: (column) => column);

  $$SalesTableAnnotationComposer get saleId {
    final $$SalesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.saleId,
        referencedTable: $db.sales,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SalesTableAnnotationComposer(
              $db: $db,
              $table: $db.sales,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AddOnTypesTableAnnotationComposer get addOnTypeId {
    final $$AddOnTypesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.addOnTypeId,
        referencedTable: $db.addOnTypes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AddOnTypesTableAnnotationComposer(
              $db: $db,
              $table: $db.addOnTypes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SaleAddOnsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SaleAddOnsTable,
    SaleAddOn,
    $$SaleAddOnsTableFilterComposer,
    $$SaleAddOnsTableOrderingComposer,
    $$SaleAddOnsTableAnnotationComposer,
    $$SaleAddOnsTableCreateCompanionBuilder,
    $$SaleAddOnsTableUpdateCompanionBuilder,
    (SaleAddOn, $$SaleAddOnsTableReferences),
    SaleAddOn,
    PrefetchHooks Function({bool saleId, bool addOnTypeId})> {
  $$SaleAddOnsTableTableManager(_$AppDatabase db, $SaleAddOnsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SaleAddOnsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SaleAddOnsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SaleAddOnsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> saleId = const Value.absent(),
            Value<int> addOnTypeId = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<double> cost = const Value.absent(),
          }) =>
              SaleAddOnsCompanion(
            id: id,
            saleId: saleId,
            addOnTypeId: addOnTypeId,
            quantity: quantity,
            cost: cost,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int saleId,
            required int addOnTypeId,
            Value<int> quantity = const Value.absent(),
            Value<double> cost = const Value.absent(),
          }) =>
              SaleAddOnsCompanion.insert(
            id: id,
            saleId: saleId,
            addOnTypeId: addOnTypeId,
            quantity: quantity,
            cost: cost,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SaleAddOnsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({saleId = false, addOnTypeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (saleId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.saleId,
                    referencedTable:
                        $$SaleAddOnsTableReferences._saleIdTable(db),
                    referencedColumn:
                        $$SaleAddOnsTableReferences._saleIdTable(db).id,
                  ) as T;
                }
                if (addOnTypeId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.addOnTypeId,
                    referencedTable:
                        $$SaleAddOnsTableReferences._addOnTypeIdTable(db),
                    referencedColumn:
                        $$SaleAddOnsTableReferences._addOnTypeIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$SaleAddOnsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SaleAddOnsTable,
    SaleAddOn,
    $$SaleAddOnsTableFilterComposer,
    $$SaleAddOnsTableOrderingComposer,
    $$SaleAddOnsTableAnnotationComposer,
    $$SaleAddOnsTableCreateCompanionBuilder,
    $$SaleAddOnsTableUpdateCompanionBuilder,
    (SaleAddOn, $$SaleAddOnsTableReferences),
    SaleAddOn,
    PrefetchHooks Function({bool saleId, bool addOnTypeId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$WalletsTableTableManager get wallets =>
      $$WalletsTableTableManager(_db, _db.wallets);
  $$SalesTableTableManager get sales =>
      $$SalesTableTableManager(_db, _db.sales);
  $$AllocationRulesTableTableManager get allocationRules =>
      $$AllocationRulesTableTableManager(_db, _db.allocationRules);
  $$BudgetBucketsTableTableManager get budgetBuckets =>
      $$BudgetBucketsTableTableManager(_db, _db.budgetBuckets);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
  $$StockMovementsTableTableManager get stockMovements =>
      $$StockMovementsTableTableManager(_db, _db.stockMovements);
  $$AddOnTypesTableTableManager get addOnTypes =>
      $$AddOnTypesTableTableManager(_db, _db.addOnTypes);
  $$SaleAddOnsTableTableManager get saleAddOns =>
      $$SaleAddOnsTableTableManager(_db, _db.saleAddOns);
}

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appDatabaseHash() => r'59cce38d45eeaba199eddd097d8e149d66f9f3e1';

/// See also [appDatabase].
@ProviderFor(appDatabase)
final appDatabaseProvider = Provider<AppDatabase>.internal(
  appDatabase,
  name: r'appDatabaseProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appDatabaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppDatabaseRef = ProviderRef<AppDatabase>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
