// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _slugMeta = const VerificationMeta('slug');
  @override
  late final GeneratedColumn<String> slug = GeneratedColumn<String>(
    'slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSystemMeta = const VerificationMeta(
    'isSystem',
  );
  @override
  late final GeneratedColumn<bool> isSystem = GeneratedColumn<bool>(
    'is_system',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_system" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, slug, name, isSystem, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('slug')) {
      context.handle(
        _slugMeta,
        slug.isAcceptableOrUnknown(data['slug']!, _slugMeta),
      );
    } else if (isInserting) {
      context.missing(_slugMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_system')) {
      context.handle(
        _isSystemMeta,
        isSystem.isAcceptableOrUnknown(data['is_system']!, _isSystemMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      slug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slug'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final String slug;
  final String name;
  final bool isSystem;
  final int sortOrder;
  const Category({
    required this.id,
    required this.slug,
    required this.name,
    required this.isSystem,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['slug'] = Variable<String>(slug);
    map['name'] = Variable<String>(name);
    map['is_system'] = Variable<bool>(isSystem);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      slug: Value(slug),
      name: Value(name),
      isSystem: Value(isSystem),
      sortOrder: Value(sortOrder),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      slug: serializer.fromJson<String>(json['slug']),
      name: serializer.fromJson<String>(json['name']),
      isSystem: serializer.fromJson<bool>(json['isSystem']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'slug': serializer.toJson<String>(slug),
      'name': serializer.toJson<String>(name),
      'isSystem': serializer.toJson<bool>(isSystem),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Category copyWith({
    int? id,
    String? slug,
    String? name,
    bool? isSystem,
    int? sortOrder,
  }) => Category(
    id: id ?? this.id,
    slug: slug ?? this.slug,
    name: name ?? this.name,
    isSystem: isSystem ?? this.isSystem,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      slug: data.slug.present ? data.slug.value : this.slug,
      name: data.name.present ? data.name.value : this.name,
      isSystem: data.isSystem.present ? data.isSystem.value : this.isSystem,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('slug: $slug, ')
          ..write('name: $name, ')
          ..write('isSystem: $isSystem, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, slug, name, isSystem, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.slug == this.slug &&
          other.name == this.name &&
          other.isSystem == this.isSystem &&
          other.sortOrder == this.sortOrder);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<String> slug;
  final Value<String> name;
  final Value<bool> isSystem;
  final Value<int> sortOrder;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.slug = const Value.absent(),
    this.name = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String slug,
    required String name,
    this.isSystem = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : slug = Value(slug),
       name = Value(name);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<String>? slug,
    Expression<String>? name,
    Expression<bool>? isSystem,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (slug != null) 'slug': slug,
      if (name != null) 'name': name,
      if (isSystem != null) 'is_system': isSystem,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? slug,
    Value<String>? name,
    Value<bool>? isSystem,
    Value<int>? sortOrder,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      name: name ?? this.name,
      isSystem: isSystem ?? this.isSystem,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (slug.present) {
      map['slug'] = Variable<String>(slug.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isSystem.present) {
      map['is_system'] = Variable<bool>(isSystem.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('slug: $slug, ')
          ..write('name: $name, ')
          ..write('isSystem: $isSystem, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $MerchantsTable extends Merchants
    with TableInfo<$MerchantsTable, Merchant> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MerchantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _canonicalNameMeta = const VerificationMeta(
    'canonicalName',
  );
  @override
  late final GeneratedColumn<String> canonicalName = GeneratedColumn<String>(
    'canonical_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _defaultCategoryIdMeta = const VerificationMeta(
    'defaultCategoryId',
  );
  @override
  late final GeneratedColumn<int> defaultCategoryId = GeneratedColumn<int>(
    'default_category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    canonicalName,
    defaultCategoryId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'merchants';
  @override
  VerificationContext validateIntegrity(
    Insertable<Merchant> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('canonical_name')) {
      context.handle(
        _canonicalNameMeta,
        canonicalName.isAcceptableOrUnknown(
          data['canonical_name']!,
          _canonicalNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_canonicalNameMeta);
    }
    if (data.containsKey('default_category_id')) {
      context.handle(
        _defaultCategoryIdMeta,
        defaultCategoryId.isAcceptableOrUnknown(
          data['default_category_id']!,
          _defaultCategoryIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Merchant map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Merchant(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      canonicalName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}canonical_name'],
      )!,
      defaultCategoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_category_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MerchantsTable createAlias(String alias) {
    return $MerchantsTable(attachedDatabase, alias);
  }
}

class Merchant extends DataClass implements Insertable<Merchant> {
  final int id;
  final String canonicalName;
  final int? defaultCategoryId;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Merchant({
    required this.id,
    required this.canonicalName,
    this.defaultCategoryId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['canonical_name'] = Variable<String>(canonicalName);
    if (!nullToAbsent || defaultCategoryId != null) {
      map['default_category_id'] = Variable<int>(defaultCategoryId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MerchantsCompanion toCompanion(bool nullToAbsent) {
    return MerchantsCompanion(
      id: Value(id),
      canonicalName: Value(canonicalName),
      defaultCategoryId: defaultCategoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultCategoryId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Merchant.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Merchant(
      id: serializer.fromJson<int>(json['id']),
      canonicalName: serializer.fromJson<String>(json['canonicalName']),
      defaultCategoryId: serializer.fromJson<int?>(json['defaultCategoryId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'canonicalName': serializer.toJson<String>(canonicalName),
      'defaultCategoryId': serializer.toJson<int?>(defaultCategoryId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Merchant copyWith({
    int? id,
    String? canonicalName,
    Value<int?> defaultCategoryId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Merchant(
    id: id ?? this.id,
    canonicalName: canonicalName ?? this.canonicalName,
    defaultCategoryId: defaultCategoryId.present
        ? defaultCategoryId.value
        : this.defaultCategoryId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Merchant copyWithCompanion(MerchantsCompanion data) {
    return Merchant(
      id: data.id.present ? data.id.value : this.id,
      canonicalName: data.canonicalName.present
          ? data.canonicalName.value
          : this.canonicalName,
      defaultCategoryId: data.defaultCategoryId.present
          ? data.defaultCategoryId.value
          : this.defaultCategoryId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Merchant(')
          ..write('id: $id, ')
          ..write('canonicalName: $canonicalName, ')
          ..write('defaultCategoryId: $defaultCategoryId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, canonicalName, defaultCategoryId, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Merchant &&
          other.id == this.id &&
          other.canonicalName == this.canonicalName &&
          other.defaultCategoryId == this.defaultCategoryId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MerchantsCompanion extends UpdateCompanion<Merchant> {
  final Value<int> id;
  final Value<String> canonicalName;
  final Value<int?> defaultCategoryId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const MerchantsCompanion({
    this.id = const Value.absent(),
    this.canonicalName = const Value.absent(),
    this.defaultCategoryId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  MerchantsCompanion.insert({
    this.id = const Value.absent(),
    required String canonicalName,
    this.defaultCategoryId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : canonicalName = Value(canonicalName);
  static Insertable<Merchant> custom({
    Expression<int>? id,
    Expression<String>? canonicalName,
    Expression<int>? defaultCategoryId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (canonicalName != null) 'canonical_name': canonicalName,
      if (defaultCategoryId != null) 'default_category_id': defaultCategoryId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  MerchantsCompanion copyWith({
    Value<int>? id,
    Value<String>? canonicalName,
    Value<int?>? defaultCategoryId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return MerchantsCompanion(
      id: id ?? this.id,
      canonicalName: canonicalName ?? this.canonicalName,
      defaultCategoryId: defaultCategoryId ?? this.defaultCategoryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (canonicalName.present) {
      map['canonical_name'] = Variable<String>(canonicalName.value);
    }
    if (defaultCategoryId.present) {
      map['default_category_id'] = Variable<int>(defaultCategoryId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MerchantsCompanion(')
          ..write('id: $id, ')
          ..write('canonicalName: $canonicalName, ')
          ..write('defaultCategoryId: $defaultCategoryId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $MerchantAliasesTable extends MerchantAliases
    with TableInfo<$MerchantAliasesTable, MerchantAliase> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MerchantAliasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _rawNameMeta = const VerificationMeta(
    'rawName',
  );
  @override
  late final GeneratedColumn<String> rawName = GeneratedColumn<String>(
    'raw_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _merchantIdMeta = const VerificationMeta(
    'merchantId',
  );
  @override
  late final GeneratedColumn<int> merchantId = GeneratedColumn<int>(
    'merchant_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES merchants (id)',
    ),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    rawName,
    merchantId,
    source,
    confidence,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'merchant_aliases';
  @override
  VerificationContext validateIntegrity(
    Insertable<MerchantAliase> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('raw_name')) {
      context.handle(
        _rawNameMeta,
        rawName.isAcceptableOrUnknown(data['raw_name']!, _rawNameMeta),
      );
    } else if (isInserting) {
      context.missing(_rawNameMeta);
    }
    if (data.containsKey('merchant_id')) {
      context.handle(
        _merchantIdMeta,
        merchantId.isAcceptableOrUnknown(data['merchant_id']!, _merchantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_merchantIdMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {rawName},
  ];
  @override
  MerchantAliase map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MerchantAliase(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      rawName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_name'],
      )!,
      merchantId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}merchant_id'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MerchantAliasesTable createAlias(String alias) {
    return $MerchantAliasesTable(attachedDatabase, alias);
  }
}

class MerchantAliase extends DataClass implements Insertable<MerchantAliase> {
  final int id;
  final String rawName;
  final int merchantId;

  /// Origin of the mapping: system | llm | user.
  final String source;

  /// LLM confidence 0–1 when [source] is llm.
  final double? confidence;
  final DateTime createdAt;
  const MerchantAliase({
    required this.id,
    required this.rawName,
    required this.merchantId,
    required this.source,
    this.confidence,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['raw_name'] = Variable<String>(rawName);
    map['merchant_id'] = Variable<int>(merchantId);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<double>(confidence);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MerchantAliasesCompanion toCompanion(bool nullToAbsent) {
    return MerchantAliasesCompanion(
      id: Value(id),
      rawName: Value(rawName),
      merchantId: Value(merchantId),
      source: Value(source),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
      createdAt: Value(createdAt),
    );
  }

  factory MerchantAliase.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MerchantAliase(
      id: serializer.fromJson<int>(json['id']),
      rawName: serializer.fromJson<String>(json['rawName']),
      merchantId: serializer.fromJson<int>(json['merchantId']),
      source: serializer.fromJson<String>(json['source']),
      confidence: serializer.fromJson<double?>(json['confidence']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rawName': serializer.toJson<String>(rawName),
      'merchantId': serializer.toJson<int>(merchantId),
      'source': serializer.toJson<String>(source),
      'confidence': serializer.toJson<double?>(confidence),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MerchantAliase copyWith({
    int? id,
    String? rawName,
    int? merchantId,
    String? source,
    Value<double?> confidence = const Value.absent(),
    DateTime? createdAt,
  }) => MerchantAliase(
    id: id ?? this.id,
    rawName: rawName ?? this.rawName,
    merchantId: merchantId ?? this.merchantId,
    source: source ?? this.source,
    confidence: confidence.present ? confidence.value : this.confidence,
    createdAt: createdAt ?? this.createdAt,
  );
  MerchantAliase copyWithCompanion(MerchantAliasesCompanion data) {
    return MerchantAliase(
      id: data.id.present ? data.id.value : this.id,
      rawName: data.rawName.present ? data.rawName.value : this.rawName,
      merchantId: data.merchantId.present
          ? data.merchantId.value
          : this.merchantId,
      source: data.source.present ? data.source.value : this.source,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MerchantAliase(')
          ..write('id: $id, ')
          ..write('rawName: $rawName, ')
          ..write('merchantId: $merchantId, ')
          ..write('source: $source, ')
          ..write('confidence: $confidence, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, rawName, merchantId, source, confidence, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MerchantAliase &&
          other.id == this.id &&
          other.rawName == this.rawName &&
          other.merchantId == this.merchantId &&
          other.source == this.source &&
          other.confidence == this.confidence &&
          other.createdAt == this.createdAt);
}

class MerchantAliasesCompanion extends UpdateCompanion<MerchantAliase> {
  final Value<int> id;
  final Value<String> rawName;
  final Value<int> merchantId;
  final Value<String> source;
  final Value<double?> confidence;
  final Value<DateTime> createdAt;
  const MerchantAliasesCompanion({
    this.id = const Value.absent(),
    this.rawName = const Value.absent(),
    this.merchantId = const Value.absent(),
    this.source = const Value.absent(),
    this.confidence = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MerchantAliasesCompanion.insert({
    this.id = const Value.absent(),
    required String rawName,
    required int merchantId,
    required String source,
    this.confidence = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : rawName = Value(rawName),
       merchantId = Value(merchantId),
       source = Value(source);
  static Insertable<MerchantAliase> custom({
    Expression<int>? id,
    Expression<String>? rawName,
    Expression<int>? merchantId,
    Expression<String>? source,
    Expression<double>? confidence,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rawName != null) 'raw_name': rawName,
      if (merchantId != null) 'merchant_id': merchantId,
      if (source != null) 'source': source,
      if (confidence != null) 'confidence': confidence,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MerchantAliasesCompanion copyWith({
    Value<int>? id,
    Value<String>? rawName,
    Value<int>? merchantId,
    Value<String>? source,
    Value<double?>? confidence,
    Value<DateTime>? createdAt,
  }) {
    return MerchantAliasesCompanion(
      id: id ?? this.id,
      rawName: rawName ?? this.rawName,
      merchantId: merchantId ?? this.merchantId,
      source: source ?? this.source,
      confidence: confidence ?? this.confidence,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (rawName.present) {
      map['raw_name'] = Variable<String>(rawName.value);
    }
    if (merchantId.present) {
      map['merchant_id'] = Variable<int>(merchantId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MerchantAliasesCompanion(')
          ..write('id: $id, ')
          ..write('rawName: $rawName, ')
          ..write('merchantId: $merchantId, ')
          ..write('source: $source, ')
          ..write('confidence: $confidence, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ImportsTable extends Imports with TableInfo<$ImportsTable, Import> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sourceTypeMeta = const VerificationMeta(
    'sourceType',
  );
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
    'source_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceLabelMeta = const VerificationMeta(
    'sourceLabel',
  );
  @override
  late final GeneratedColumn<String> sourceLabel = GeneratedColumn<String>(
    'source_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentHashMeta = const VerificationMeta(
    'contentHash',
  );
  @override
  late final GeneratedColumn<String> contentHash = GeneratedColumn<String>(
    'content_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
    'imported_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _rowCountMeta = const VerificationMeta(
    'rowCount',
  );
  @override
  late final GeneratedColumn<int> rowCount = GeneratedColumn<int>(
    'row_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _parsedCountMeta = const VerificationMeta(
    'parsedCount',
  );
  @override
  late final GeneratedColumn<int> parsedCount = GeneratedColumn<int>(
    'parsed_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _skippedCountMeta = const VerificationMeta(
    'skippedCount',
  );
  @override
  late final GeneratedColumn<int> skippedCount = GeneratedColumn<int>(
    'skipped_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _duplicateCountMeta = const VerificationMeta(
    'duplicateCount',
  );
  @override
  late final GeneratedColumn<int> duplicateCount = GeneratedColumn<int>(
    'duplicate_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceType,
    sourceLabel,
    contentHash,
    importedAt,
    status,
    rowCount,
    parsedCount,
    skippedCount,
    duplicateCount,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'imports';
  @override
  VerificationContext validateIntegrity(
    Insertable<Import> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('source_type')) {
      context.handle(
        _sourceTypeMeta,
        sourceType.isAcceptableOrUnknown(data['source_type']!, _sourceTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    if (data.containsKey('source_label')) {
      context.handle(
        _sourceLabelMeta,
        sourceLabel.isAcceptableOrUnknown(
          data['source_label']!,
          _sourceLabelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceLabelMeta);
    }
    if (data.containsKey('content_hash')) {
      context.handle(
        _contentHashMeta,
        contentHash.isAcceptableOrUnknown(
          data['content_hash']!,
          _contentHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentHashMeta);
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('row_count')) {
      context.handle(
        _rowCountMeta,
        rowCount.isAcceptableOrUnknown(data['row_count']!, _rowCountMeta),
      );
    }
    if (data.containsKey('parsed_count')) {
      context.handle(
        _parsedCountMeta,
        parsedCount.isAcceptableOrUnknown(
          data['parsed_count']!,
          _parsedCountMeta,
        ),
      );
    }
    if (data.containsKey('skipped_count')) {
      context.handle(
        _skippedCountMeta,
        skippedCount.isAcceptableOrUnknown(
          data['skipped_count']!,
          _skippedCountMeta,
        ),
      );
    }
    if (data.containsKey('duplicate_count')) {
      context.handle(
        _duplicateCountMeta,
        duplicateCount.isAcceptableOrUnknown(
          data['duplicate_count']!,
          _duplicateCountMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Import map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Import(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_type'],
      )!,
      sourceLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_label'],
      )!,
      contentHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_hash'],
      )!,
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}imported_at'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      rowCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row_count'],
      )!,
      parsedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parsed_count'],
      )!,
      skippedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}skipped_count'],
      )!,
      duplicateCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duplicate_count'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $ImportsTable createAlias(String alias) {
    return $ImportsTable(attachedDatabase, alias);
  }
}

class Import extends DataClass implements Insertable<Import> {
  final int id;

  /// sms | pdf | csv | excel
  final String sourceType;
  final String sourceLabel;

  /// Content hash of the imported payload (for skipping identical re-imports).
  final String contentHash;
  final DateTime importedAt;

  /// pending | succeeded | failed | partial | duplicate_file
  final String status;
  final int rowCount;
  final int parsedCount;
  final int skippedCount;
  final int duplicateCount;
  final String? notes;
  const Import({
    required this.id,
    required this.sourceType,
    required this.sourceLabel,
    required this.contentHash,
    required this.importedAt,
    required this.status,
    required this.rowCount,
    required this.parsedCount,
    required this.skippedCount,
    required this.duplicateCount,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['source_type'] = Variable<String>(sourceType);
    map['source_label'] = Variable<String>(sourceLabel);
    map['content_hash'] = Variable<String>(contentHash);
    map['imported_at'] = Variable<DateTime>(importedAt);
    map['status'] = Variable<String>(status);
    map['row_count'] = Variable<int>(rowCount);
    map['parsed_count'] = Variable<int>(parsedCount);
    map['skipped_count'] = Variable<int>(skippedCount);
    map['duplicate_count'] = Variable<int>(duplicateCount);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  ImportsCompanion toCompanion(bool nullToAbsent) {
    return ImportsCompanion(
      id: Value(id),
      sourceType: Value(sourceType),
      sourceLabel: Value(sourceLabel),
      contentHash: Value(contentHash),
      importedAt: Value(importedAt),
      status: Value(status),
      rowCount: Value(rowCount),
      parsedCount: Value(parsedCount),
      skippedCount: Value(skippedCount),
      duplicateCount: Value(duplicateCount),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory Import.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Import(
      id: serializer.fromJson<int>(json['id']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      sourceLabel: serializer.fromJson<String>(json['sourceLabel']),
      contentHash: serializer.fromJson<String>(json['contentHash']),
      importedAt: serializer.fromJson<DateTime>(json['importedAt']),
      status: serializer.fromJson<String>(json['status']),
      rowCount: serializer.fromJson<int>(json['rowCount']),
      parsedCount: serializer.fromJson<int>(json['parsedCount']),
      skippedCount: serializer.fromJson<int>(json['skippedCount']),
      duplicateCount: serializer.fromJson<int>(json['duplicateCount']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sourceType': serializer.toJson<String>(sourceType),
      'sourceLabel': serializer.toJson<String>(sourceLabel),
      'contentHash': serializer.toJson<String>(contentHash),
      'importedAt': serializer.toJson<DateTime>(importedAt),
      'status': serializer.toJson<String>(status),
      'rowCount': serializer.toJson<int>(rowCount),
      'parsedCount': serializer.toJson<int>(parsedCount),
      'skippedCount': serializer.toJson<int>(skippedCount),
      'duplicateCount': serializer.toJson<int>(duplicateCount),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  Import copyWith({
    int? id,
    String? sourceType,
    String? sourceLabel,
    String? contentHash,
    DateTime? importedAt,
    String? status,
    int? rowCount,
    int? parsedCount,
    int? skippedCount,
    int? duplicateCount,
    Value<String?> notes = const Value.absent(),
  }) => Import(
    id: id ?? this.id,
    sourceType: sourceType ?? this.sourceType,
    sourceLabel: sourceLabel ?? this.sourceLabel,
    contentHash: contentHash ?? this.contentHash,
    importedAt: importedAt ?? this.importedAt,
    status: status ?? this.status,
    rowCount: rowCount ?? this.rowCount,
    parsedCount: parsedCount ?? this.parsedCount,
    skippedCount: skippedCount ?? this.skippedCount,
    duplicateCount: duplicateCount ?? this.duplicateCount,
    notes: notes.present ? notes.value : this.notes,
  );
  Import copyWithCompanion(ImportsCompanion data) {
    return Import(
      id: data.id.present ? data.id.value : this.id,
      sourceType: data.sourceType.present
          ? data.sourceType.value
          : this.sourceType,
      sourceLabel: data.sourceLabel.present
          ? data.sourceLabel.value
          : this.sourceLabel,
      contentHash: data.contentHash.present
          ? data.contentHash.value
          : this.contentHash,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
      status: data.status.present ? data.status.value : this.status,
      rowCount: data.rowCount.present ? data.rowCount.value : this.rowCount,
      parsedCount: data.parsedCount.present
          ? data.parsedCount.value
          : this.parsedCount,
      skippedCount: data.skippedCount.present
          ? data.skippedCount.value
          : this.skippedCount,
      duplicateCount: data.duplicateCount.present
          ? data.duplicateCount.value
          : this.duplicateCount,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Import(')
          ..write('id: $id, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceLabel: $sourceLabel, ')
          ..write('contentHash: $contentHash, ')
          ..write('importedAt: $importedAt, ')
          ..write('status: $status, ')
          ..write('rowCount: $rowCount, ')
          ..write('parsedCount: $parsedCount, ')
          ..write('skippedCount: $skippedCount, ')
          ..write('duplicateCount: $duplicateCount, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sourceType,
    sourceLabel,
    contentHash,
    importedAt,
    status,
    rowCount,
    parsedCount,
    skippedCount,
    duplicateCount,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Import &&
          other.id == this.id &&
          other.sourceType == this.sourceType &&
          other.sourceLabel == this.sourceLabel &&
          other.contentHash == this.contentHash &&
          other.importedAt == this.importedAt &&
          other.status == this.status &&
          other.rowCount == this.rowCount &&
          other.parsedCount == this.parsedCount &&
          other.skippedCount == this.skippedCount &&
          other.duplicateCount == this.duplicateCount &&
          other.notes == this.notes);
}

class ImportsCompanion extends UpdateCompanion<Import> {
  final Value<int> id;
  final Value<String> sourceType;
  final Value<String> sourceLabel;
  final Value<String> contentHash;
  final Value<DateTime> importedAt;
  final Value<String> status;
  final Value<int> rowCount;
  final Value<int> parsedCount;
  final Value<int> skippedCount;
  final Value<int> duplicateCount;
  final Value<String?> notes;
  const ImportsCompanion({
    this.id = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.sourceLabel = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.rowCount = const Value.absent(),
    this.parsedCount = const Value.absent(),
    this.skippedCount = const Value.absent(),
    this.duplicateCount = const Value.absent(),
    this.notes = const Value.absent(),
  });
  ImportsCompanion.insert({
    this.id = const Value.absent(),
    required String sourceType,
    required String sourceLabel,
    required String contentHash,
    this.importedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.rowCount = const Value.absent(),
    this.parsedCount = const Value.absent(),
    this.skippedCount = const Value.absent(),
    this.duplicateCount = const Value.absent(),
    this.notes = const Value.absent(),
  }) : sourceType = Value(sourceType),
       sourceLabel = Value(sourceLabel),
       contentHash = Value(contentHash);
  static Insertable<Import> custom({
    Expression<int>? id,
    Expression<String>? sourceType,
    Expression<String>? sourceLabel,
    Expression<String>? contentHash,
    Expression<DateTime>? importedAt,
    Expression<String>? status,
    Expression<int>? rowCount,
    Expression<int>? parsedCount,
    Expression<int>? skippedCount,
    Expression<int>? duplicateCount,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceType != null) 'source_type': sourceType,
      if (sourceLabel != null) 'source_label': sourceLabel,
      if (contentHash != null) 'content_hash': contentHash,
      if (importedAt != null) 'imported_at': importedAt,
      if (status != null) 'status': status,
      if (rowCount != null) 'row_count': rowCount,
      if (parsedCount != null) 'parsed_count': parsedCount,
      if (skippedCount != null) 'skipped_count': skippedCount,
      if (duplicateCount != null) 'duplicate_count': duplicateCount,
      if (notes != null) 'notes': notes,
    });
  }

  ImportsCompanion copyWith({
    Value<int>? id,
    Value<String>? sourceType,
    Value<String>? sourceLabel,
    Value<String>? contentHash,
    Value<DateTime>? importedAt,
    Value<String>? status,
    Value<int>? rowCount,
    Value<int>? parsedCount,
    Value<int>? skippedCount,
    Value<int>? duplicateCount,
    Value<String?>? notes,
  }) {
    return ImportsCompanion(
      id: id ?? this.id,
      sourceType: sourceType ?? this.sourceType,
      sourceLabel: sourceLabel ?? this.sourceLabel,
      contentHash: contentHash ?? this.contentHash,
      importedAt: importedAt ?? this.importedAt,
      status: status ?? this.status,
      rowCount: rowCount ?? this.rowCount,
      parsedCount: parsedCount ?? this.parsedCount,
      skippedCount: skippedCount ?? this.skippedCount,
      duplicateCount: duplicateCount ?? this.duplicateCount,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (sourceLabel.present) {
      map['source_label'] = Variable<String>(sourceLabel.value);
    }
    if (contentHash.present) {
      map['content_hash'] = Variable<String>(contentHash.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowCount.present) {
      map['row_count'] = Variable<int>(rowCount.value);
    }
    if (parsedCount.present) {
      map['parsed_count'] = Variable<int>(parsedCount.value);
    }
    if (skippedCount.present) {
      map['skipped_count'] = Variable<int>(skippedCount.value);
    }
    if (duplicateCount.present) {
      map['duplicate_count'] = Variable<int>(duplicateCount.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportsCompanion(')
          ..write('id: $id, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceLabel: $sourceLabel, ')
          ..write('contentHash: $contentHash, ')
          ..write('importedAt: $importedAt, ')
          ..write('status: $status, ')
          ..write('rowCount: $rowCount, ')
          ..write('parsedCount: $parsedCount, ')
          ..write('skippedCount: $skippedCount, ')
          ..write('duplicateCount: $duplicateCount, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('INR'),
  );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _txnTypeMeta = const VerificationMeta(
    'txnType',
  );
  @override
  late final GeneratedColumn<String> txnType = GeneratedColumn<String>(
    'txn_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookedAtMeta = const VerificationMeta(
    'bookedAt',
  );
  @override
  late final GeneratedColumn<DateTime> bookedAt = GeneratedColumn<DateTime>(
    'booked_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueDateMeta = const VerificationMeta(
    'valueDate',
  );
  @override
  late final GeneratedColumn<DateTime> valueDate = GeneratedColumn<DateTime>(
    'value_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bankCodeMeta = const VerificationMeta(
    'bankCode',
  );
  @override
  late final GeneratedColumn<String> bankCode = GeneratedColumn<String>(
    'bank_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountHintMeta = const VerificationMeta(
    'accountHint',
  );
  @override
  late final GeneratedColumn<String> accountHint = GeneratedColumn<String>(
    'account_hint',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _merchantIdMeta = const VerificationMeta(
    'merchantId',
  );
  @override
  late final GeneratedColumn<int> merchantId = GeneratedColumn<int>(
    'merchant_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES merchants (id)',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _suggestedCategorySlugMeta =
      const VerificationMeta('suggestedCategorySlug');
  @override
  late final GeneratedColumn<String> suggestedCategorySlug =
      GeneratedColumn<String>(
        'suggested_category_slug',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _categorySourceMeta = const VerificationMeta(
    'categorySource',
  );
  @override
  late final GeneratedColumn<String> categorySource = GeneratedColumn<String>(
    'category_source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawMerchantMeta = const VerificationMeta(
    'rawMerchant',
  );
  @override
  late final GeneratedColumn<String> rawMerchant = GeneratedColumn<String>(
    'raw_merchant',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawDescriptionMeta = const VerificationMeta(
    'rawDescription',
  );
  @override
  late final GeneratedColumn<String> rawDescription = GeneratedColumn<String>(
    'raw_description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _upiPayerVpaMeta = const VerificationMeta(
    'upiPayerVpa',
  );
  @override
  late final GeneratedColumn<String> upiPayerVpa = GeneratedColumn<String>(
    'upi_payer_vpa',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _upiPayeeVpaMeta = const VerificationMeta(
    'upiPayeeVpa',
  );
  @override
  late final GeneratedColumn<String> upiPayeeVpa = GeneratedColumn<String>(
    'upi_payee_vpa',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _upiRefMeta = const VerificationMeta('upiRef');
  @override
  late final GeneratedColumn<String> upiRef = GeneratedColumn<String>(
    'upi_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remarksMeta = const VerificationMeta(
    'remarks',
  );
  @override
  late final GeneratedColumn<String> remarks = GeneratedColumn<String>(
    'remarks',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _externalRefMeta = const VerificationMeta(
    'externalRef',
  );
  @override
  late final GeneratedColumn<String> externalRef = GeneratedColumn<String>(
    'external_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _balanceAfterPaiseMeta = const VerificationMeta(
    'balanceAfterPaise',
  );
  @override
  late final GeneratedColumn<int> balanceAfterPaise = GeneratedColumn<int>(
    'balance_after_paise',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dedupeHashMeta = const VerificationMeta(
    'dedupeHash',
  );
  @override
  late final GeneratedColumn<String> dedupeHash = GeneratedColumn<String>(
    'dedupe_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _importIdMeta = const VerificationMeta(
    'importId',
  );
  @override
  late final GeneratedColumn<int> importId = GeneratedColumn<int>(
    'import_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES imports (id)',
    ),
  );
  static const VerificationMeta _isRecurringCandidateMeta =
      const VerificationMeta('isRecurringCandidate');
  @override
  late final GeneratedColumn<bool> isRecurringCandidate = GeneratedColumn<bool>(
    'is_recurring_candidate',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_recurring_candidate" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _recurringKindMeta = const VerificationMeta(
    'recurringKind',
  );
  @override
  late final GeneratedColumn<String> recurringKind = GeneratedColumn<String>(
    'recurring_kind',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accountKindMeta = const VerificationMeta(
    'accountKind',
  );
  @override
  late final GeneratedColumn<String> accountKind = GeneratedColumn<String>(
    'account_kind',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    amountPaise,
    currency,
    direction,
    txnType,
    bookedAt,
    valueDate,
    bankCode,
    accountHint,
    merchantId,
    categoryId,
    suggestedCategorySlug,
    categorySource,
    rawMerchant,
    rawDescription,
    upiPayerVpa,
    upiPayeeVpa,
    upiRef,
    remarks,
    externalRef,
    balanceAfterPaise,
    dedupeHash,
    importId,
    isRecurringCandidate,
    recurringKind,
    accountKind,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPaiseMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('txn_type')) {
      context.handle(
        _txnTypeMeta,
        txnType.isAcceptableOrUnknown(data['txn_type']!, _txnTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_txnTypeMeta);
    }
    if (data.containsKey('booked_at')) {
      context.handle(
        _bookedAtMeta,
        bookedAt.isAcceptableOrUnknown(data['booked_at']!, _bookedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_bookedAtMeta);
    }
    if (data.containsKey('value_date')) {
      context.handle(
        _valueDateMeta,
        valueDate.isAcceptableOrUnknown(data['value_date']!, _valueDateMeta),
      );
    }
    if (data.containsKey('bank_code')) {
      context.handle(
        _bankCodeMeta,
        bankCode.isAcceptableOrUnknown(data['bank_code']!, _bankCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_bankCodeMeta);
    }
    if (data.containsKey('account_hint')) {
      context.handle(
        _accountHintMeta,
        accountHint.isAcceptableOrUnknown(
          data['account_hint']!,
          _accountHintMeta,
        ),
      );
    }
    if (data.containsKey('merchant_id')) {
      context.handle(
        _merchantIdMeta,
        merchantId.isAcceptableOrUnknown(data['merchant_id']!, _merchantIdMeta),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('suggested_category_slug')) {
      context.handle(
        _suggestedCategorySlugMeta,
        suggestedCategorySlug.isAcceptableOrUnknown(
          data['suggested_category_slug']!,
          _suggestedCategorySlugMeta,
        ),
      );
    }
    if (data.containsKey('category_source')) {
      context.handle(
        _categorySourceMeta,
        categorySource.isAcceptableOrUnknown(
          data['category_source']!,
          _categorySourceMeta,
        ),
      );
    }
    if (data.containsKey('raw_merchant')) {
      context.handle(
        _rawMerchantMeta,
        rawMerchant.isAcceptableOrUnknown(
          data['raw_merchant']!,
          _rawMerchantMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rawMerchantMeta);
    }
    if (data.containsKey('raw_description')) {
      context.handle(
        _rawDescriptionMeta,
        rawDescription.isAcceptableOrUnknown(
          data['raw_description']!,
          _rawDescriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rawDescriptionMeta);
    }
    if (data.containsKey('upi_payer_vpa')) {
      context.handle(
        _upiPayerVpaMeta,
        upiPayerVpa.isAcceptableOrUnknown(
          data['upi_payer_vpa']!,
          _upiPayerVpaMeta,
        ),
      );
    }
    if (data.containsKey('upi_payee_vpa')) {
      context.handle(
        _upiPayeeVpaMeta,
        upiPayeeVpa.isAcceptableOrUnknown(
          data['upi_payee_vpa']!,
          _upiPayeeVpaMeta,
        ),
      );
    }
    if (data.containsKey('upi_ref')) {
      context.handle(
        _upiRefMeta,
        upiRef.isAcceptableOrUnknown(data['upi_ref']!, _upiRefMeta),
      );
    }
    if (data.containsKey('remarks')) {
      context.handle(
        _remarksMeta,
        remarks.isAcceptableOrUnknown(data['remarks']!, _remarksMeta),
      );
    }
    if (data.containsKey('external_ref')) {
      context.handle(
        _externalRefMeta,
        externalRef.isAcceptableOrUnknown(
          data['external_ref']!,
          _externalRefMeta,
        ),
      );
    }
    if (data.containsKey('balance_after_paise')) {
      context.handle(
        _balanceAfterPaiseMeta,
        balanceAfterPaise.isAcceptableOrUnknown(
          data['balance_after_paise']!,
          _balanceAfterPaiseMeta,
        ),
      );
    }
    if (data.containsKey('dedupe_hash')) {
      context.handle(
        _dedupeHashMeta,
        dedupeHash.isAcceptableOrUnknown(data['dedupe_hash']!, _dedupeHashMeta),
      );
    } else if (isInserting) {
      context.missing(_dedupeHashMeta);
    }
    if (data.containsKey('import_id')) {
      context.handle(
        _importIdMeta,
        importId.isAcceptableOrUnknown(data['import_id']!, _importIdMeta),
      );
    }
    if (data.containsKey('is_recurring_candidate')) {
      context.handle(
        _isRecurringCandidateMeta,
        isRecurringCandidate.isAcceptableOrUnknown(
          data['is_recurring_candidate']!,
          _isRecurringCandidateMeta,
        ),
      );
    }
    if (data.containsKey('recurring_kind')) {
      context.handle(
        _recurringKindMeta,
        recurringKind.isAcceptableOrUnknown(
          data['recurring_kind']!,
          _recurringKindMeta,
        ),
      );
    }
    if (data.containsKey('account_kind')) {
      context.handle(
        _accountKindMeta,
        accountKind.isAcceptableOrUnknown(
          data['account_kind']!,
          _accountKindMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction'],
      )!,
      txnType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}txn_type'],
      )!,
      bookedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}booked_at'],
      )!,
      valueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}value_date'],
      ),
      bankCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bank_code'],
      )!,
      accountHint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_hint'],
      ),
      merchantId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}merchant_id'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      ),
      suggestedCategorySlug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}suggested_category_slug'],
      ),
      categorySource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_source'],
      ),
      rawMerchant: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_merchant'],
      )!,
      rawDescription: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_description'],
      )!,
      upiPayerVpa: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}upi_payer_vpa'],
      ),
      upiPayeeVpa: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}upi_payee_vpa'],
      ),
      upiRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}upi_ref'],
      ),
      remarks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remarks'],
      ),
      externalRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_ref'],
      ),
      balanceAfterPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}balance_after_paise'],
      ),
      dedupeHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dedupe_hash'],
      )!,
      importId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}import_id'],
      ),
      isRecurringCandidate: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_recurring_candidate'],
      )!,
      recurringKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurring_kind'],
      ),
      accountKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_kind'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final int id;

  /// Always positive; direction separates debit/credit.
  final int amountPaise;
  final String currency;

  /// debit | credit
  final String direction;

  /// See [TransactionType] wire names.
  final String txnType;
  final DateTime bookedAt;
  final DateTime? valueDate;
  final String bankCode;
  final String? accountHint;
  final int? merchantId;
  final int? categoryId;

  /// LLM/rule suggestion before user confirms (slug from [Categories]).
  final String? suggestedCategorySlug;

  /// rule | llm | user — how [categoryId] was assigned.
  final String? categorySource;
  final String rawMerchant;
  final String rawDescription;
  final String? upiPayerVpa;
  final String? upiPayeeVpa;
  final String? upiRef;
  final String? remarks;
  final String? externalRef;
  final int? balanceAfterPaise;

  /// sha256(bank|date|amount|ref) — unique for idempotent imports.
  final String dedupeHash;
  final int? importId;
  final bool isRecurringCandidate;

  /// subscription | sip | enach | other | null
  final String? recurringKind;

  /// bank | card | null (unknown) — which kind of account the row is from.
  final String? accountKind;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Transaction({
    required this.id,
    required this.amountPaise,
    required this.currency,
    required this.direction,
    required this.txnType,
    required this.bookedAt,
    this.valueDate,
    required this.bankCode,
    this.accountHint,
    this.merchantId,
    this.categoryId,
    this.suggestedCategorySlug,
    this.categorySource,
    required this.rawMerchant,
    required this.rawDescription,
    this.upiPayerVpa,
    this.upiPayeeVpa,
    this.upiRef,
    this.remarks,
    this.externalRef,
    this.balanceAfterPaise,
    required this.dedupeHash,
    this.importId,
    required this.isRecurringCandidate,
    this.recurringKind,
    this.accountKind,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['amount_paise'] = Variable<int>(amountPaise);
    map['currency'] = Variable<String>(currency);
    map['direction'] = Variable<String>(direction);
    map['txn_type'] = Variable<String>(txnType);
    map['booked_at'] = Variable<DateTime>(bookedAt);
    if (!nullToAbsent || valueDate != null) {
      map['value_date'] = Variable<DateTime>(valueDate);
    }
    map['bank_code'] = Variable<String>(bankCode);
    if (!nullToAbsent || accountHint != null) {
      map['account_hint'] = Variable<String>(accountHint);
    }
    if (!nullToAbsent || merchantId != null) {
      map['merchant_id'] = Variable<int>(merchantId);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    if (!nullToAbsent || suggestedCategorySlug != null) {
      map['suggested_category_slug'] = Variable<String>(suggestedCategorySlug);
    }
    if (!nullToAbsent || categorySource != null) {
      map['category_source'] = Variable<String>(categorySource);
    }
    map['raw_merchant'] = Variable<String>(rawMerchant);
    map['raw_description'] = Variable<String>(rawDescription);
    if (!nullToAbsent || upiPayerVpa != null) {
      map['upi_payer_vpa'] = Variable<String>(upiPayerVpa);
    }
    if (!nullToAbsent || upiPayeeVpa != null) {
      map['upi_payee_vpa'] = Variable<String>(upiPayeeVpa);
    }
    if (!nullToAbsent || upiRef != null) {
      map['upi_ref'] = Variable<String>(upiRef);
    }
    if (!nullToAbsent || remarks != null) {
      map['remarks'] = Variable<String>(remarks);
    }
    if (!nullToAbsent || externalRef != null) {
      map['external_ref'] = Variable<String>(externalRef);
    }
    if (!nullToAbsent || balanceAfterPaise != null) {
      map['balance_after_paise'] = Variable<int>(balanceAfterPaise);
    }
    map['dedupe_hash'] = Variable<String>(dedupeHash);
    if (!nullToAbsent || importId != null) {
      map['import_id'] = Variable<int>(importId);
    }
    map['is_recurring_candidate'] = Variable<bool>(isRecurringCandidate);
    if (!nullToAbsent || recurringKind != null) {
      map['recurring_kind'] = Variable<String>(recurringKind);
    }
    if (!nullToAbsent || accountKind != null) {
      map['account_kind'] = Variable<String>(accountKind);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      amountPaise: Value(amountPaise),
      currency: Value(currency),
      direction: Value(direction),
      txnType: Value(txnType),
      bookedAt: Value(bookedAt),
      valueDate: valueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(valueDate),
      bankCode: Value(bankCode),
      accountHint: accountHint == null && nullToAbsent
          ? const Value.absent()
          : Value(accountHint),
      merchantId: merchantId == null && nullToAbsent
          ? const Value.absent()
          : Value(merchantId),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      suggestedCategorySlug: suggestedCategorySlug == null && nullToAbsent
          ? const Value.absent()
          : Value(suggestedCategorySlug),
      categorySource: categorySource == null && nullToAbsent
          ? const Value.absent()
          : Value(categorySource),
      rawMerchant: Value(rawMerchant),
      rawDescription: Value(rawDescription),
      upiPayerVpa: upiPayerVpa == null && nullToAbsent
          ? const Value.absent()
          : Value(upiPayerVpa),
      upiPayeeVpa: upiPayeeVpa == null && nullToAbsent
          ? const Value.absent()
          : Value(upiPayeeVpa),
      upiRef: upiRef == null && nullToAbsent
          ? const Value.absent()
          : Value(upiRef),
      remarks: remarks == null && nullToAbsent
          ? const Value.absent()
          : Value(remarks),
      externalRef: externalRef == null && nullToAbsent
          ? const Value.absent()
          : Value(externalRef),
      balanceAfterPaise: balanceAfterPaise == null && nullToAbsent
          ? const Value.absent()
          : Value(balanceAfterPaise),
      dedupeHash: Value(dedupeHash),
      importId: importId == null && nullToAbsent
          ? const Value.absent()
          : Value(importId),
      isRecurringCandidate: Value(isRecurringCandidate),
      recurringKind: recurringKind == null && nullToAbsent
          ? const Value.absent()
          : Value(recurringKind),
      accountKind: accountKind == null && nullToAbsent
          ? const Value.absent()
          : Value(accountKind),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Transaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<int>(json['id']),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
      currency: serializer.fromJson<String>(json['currency']),
      direction: serializer.fromJson<String>(json['direction']),
      txnType: serializer.fromJson<String>(json['txnType']),
      bookedAt: serializer.fromJson<DateTime>(json['bookedAt']),
      valueDate: serializer.fromJson<DateTime?>(json['valueDate']),
      bankCode: serializer.fromJson<String>(json['bankCode']),
      accountHint: serializer.fromJson<String?>(json['accountHint']),
      merchantId: serializer.fromJson<int?>(json['merchantId']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      suggestedCategorySlug: serializer.fromJson<String?>(
        json['suggestedCategorySlug'],
      ),
      categorySource: serializer.fromJson<String?>(json['categorySource']),
      rawMerchant: serializer.fromJson<String>(json['rawMerchant']),
      rawDescription: serializer.fromJson<String>(json['rawDescription']),
      upiPayerVpa: serializer.fromJson<String?>(json['upiPayerVpa']),
      upiPayeeVpa: serializer.fromJson<String?>(json['upiPayeeVpa']),
      upiRef: serializer.fromJson<String?>(json['upiRef']),
      remarks: serializer.fromJson<String?>(json['remarks']),
      externalRef: serializer.fromJson<String?>(json['externalRef']),
      balanceAfterPaise: serializer.fromJson<int?>(json['balanceAfterPaise']),
      dedupeHash: serializer.fromJson<String>(json['dedupeHash']),
      importId: serializer.fromJson<int?>(json['importId']),
      isRecurringCandidate: serializer.fromJson<bool>(
        json['isRecurringCandidate'],
      ),
      recurringKind: serializer.fromJson<String?>(json['recurringKind']),
      accountKind: serializer.fromJson<String?>(json['accountKind']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'amountPaise': serializer.toJson<int>(amountPaise),
      'currency': serializer.toJson<String>(currency),
      'direction': serializer.toJson<String>(direction),
      'txnType': serializer.toJson<String>(txnType),
      'bookedAt': serializer.toJson<DateTime>(bookedAt),
      'valueDate': serializer.toJson<DateTime?>(valueDate),
      'bankCode': serializer.toJson<String>(bankCode),
      'accountHint': serializer.toJson<String?>(accountHint),
      'merchantId': serializer.toJson<int?>(merchantId),
      'categoryId': serializer.toJson<int?>(categoryId),
      'suggestedCategorySlug': serializer.toJson<String?>(
        suggestedCategorySlug,
      ),
      'categorySource': serializer.toJson<String?>(categorySource),
      'rawMerchant': serializer.toJson<String>(rawMerchant),
      'rawDescription': serializer.toJson<String>(rawDescription),
      'upiPayerVpa': serializer.toJson<String?>(upiPayerVpa),
      'upiPayeeVpa': serializer.toJson<String?>(upiPayeeVpa),
      'upiRef': serializer.toJson<String?>(upiRef),
      'remarks': serializer.toJson<String?>(remarks),
      'externalRef': serializer.toJson<String?>(externalRef),
      'balanceAfterPaise': serializer.toJson<int?>(balanceAfterPaise),
      'dedupeHash': serializer.toJson<String>(dedupeHash),
      'importId': serializer.toJson<int?>(importId),
      'isRecurringCandidate': serializer.toJson<bool>(isRecurringCandidate),
      'recurringKind': serializer.toJson<String?>(recurringKind),
      'accountKind': serializer.toJson<String?>(accountKind),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Transaction copyWith({
    int? id,
    int? amountPaise,
    String? currency,
    String? direction,
    String? txnType,
    DateTime? bookedAt,
    Value<DateTime?> valueDate = const Value.absent(),
    String? bankCode,
    Value<String?> accountHint = const Value.absent(),
    Value<int?> merchantId = const Value.absent(),
    Value<int?> categoryId = const Value.absent(),
    Value<String?> suggestedCategorySlug = const Value.absent(),
    Value<String?> categorySource = const Value.absent(),
    String? rawMerchant,
    String? rawDescription,
    Value<String?> upiPayerVpa = const Value.absent(),
    Value<String?> upiPayeeVpa = const Value.absent(),
    Value<String?> upiRef = const Value.absent(),
    Value<String?> remarks = const Value.absent(),
    Value<String?> externalRef = const Value.absent(),
    Value<int?> balanceAfterPaise = const Value.absent(),
    String? dedupeHash,
    Value<int?> importId = const Value.absent(),
    bool? isRecurringCandidate,
    Value<String?> recurringKind = const Value.absent(),
    Value<String?> accountKind = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Transaction(
    id: id ?? this.id,
    amountPaise: amountPaise ?? this.amountPaise,
    currency: currency ?? this.currency,
    direction: direction ?? this.direction,
    txnType: txnType ?? this.txnType,
    bookedAt: bookedAt ?? this.bookedAt,
    valueDate: valueDate.present ? valueDate.value : this.valueDate,
    bankCode: bankCode ?? this.bankCode,
    accountHint: accountHint.present ? accountHint.value : this.accountHint,
    merchantId: merchantId.present ? merchantId.value : this.merchantId,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    suggestedCategorySlug: suggestedCategorySlug.present
        ? suggestedCategorySlug.value
        : this.suggestedCategorySlug,
    categorySource: categorySource.present
        ? categorySource.value
        : this.categorySource,
    rawMerchant: rawMerchant ?? this.rawMerchant,
    rawDescription: rawDescription ?? this.rawDescription,
    upiPayerVpa: upiPayerVpa.present ? upiPayerVpa.value : this.upiPayerVpa,
    upiPayeeVpa: upiPayeeVpa.present ? upiPayeeVpa.value : this.upiPayeeVpa,
    upiRef: upiRef.present ? upiRef.value : this.upiRef,
    remarks: remarks.present ? remarks.value : this.remarks,
    externalRef: externalRef.present ? externalRef.value : this.externalRef,
    balanceAfterPaise: balanceAfterPaise.present
        ? balanceAfterPaise.value
        : this.balanceAfterPaise,
    dedupeHash: dedupeHash ?? this.dedupeHash,
    importId: importId.present ? importId.value : this.importId,
    isRecurringCandidate: isRecurringCandidate ?? this.isRecurringCandidate,
    recurringKind: recurringKind.present
        ? recurringKind.value
        : this.recurringKind,
    accountKind: accountKind.present ? accountKind.value : this.accountKind,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
      currency: data.currency.present ? data.currency.value : this.currency,
      direction: data.direction.present ? data.direction.value : this.direction,
      txnType: data.txnType.present ? data.txnType.value : this.txnType,
      bookedAt: data.bookedAt.present ? data.bookedAt.value : this.bookedAt,
      valueDate: data.valueDate.present ? data.valueDate.value : this.valueDate,
      bankCode: data.bankCode.present ? data.bankCode.value : this.bankCode,
      accountHint: data.accountHint.present
          ? data.accountHint.value
          : this.accountHint,
      merchantId: data.merchantId.present
          ? data.merchantId.value
          : this.merchantId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      suggestedCategorySlug: data.suggestedCategorySlug.present
          ? data.suggestedCategorySlug.value
          : this.suggestedCategorySlug,
      categorySource: data.categorySource.present
          ? data.categorySource.value
          : this.categorySource,
      rawMerchant: data.rawMerchant.present
          ? data.rawMerchant.value
          : this.rawMerchant,
      rawDescription: data.rawDescription.present
          ? data.rawDescription.value
          : this.rawDescription,
      upiPayerVpa: data.upiPayerVpa.present
          ? data.upiPayerVpa.value
          : this.upiPayerVpa,
      upiPayeeVpa: data.upiPayeeVpa.present
          ? data.upiPayeeVpa.value
          : this.upiPayeeVpa,
      upiRef: data.upiRef.present ? data.upiRef.value : this.upiRef,
      remarks: data.remarks.present ? data.remarks.value : this.remarks,
      externalRef: data.externalRef.present
          ? data.externalRef.value
          : this.externalRef,
      balanceAfterPaise: data.balanceAfterPaise.present
          ? data.balanceAfterPaise.value
          : this.balanceAfterPaise,
      dedupeHash: data.dedupeHash.present
          ? data.dedupeHash.value
          : this.dedupeHash,
      importId: data.importId.present ? data.importId.value : this.importId,
      isRecurringCandidate: data.isRecurringCandidate.present
          ? data.isRecurringCandidate.value
          : this.isRecurringCandidate,
      recurringKind: data.recurringKind.present
          ? data.recurringKind.value
          : this.recurringKind,
      accountKind: data.accountKind.present
          ? data.accountKind.value
          : this.accountKind,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('currency: $currency, ')
          ..write('direction: $direction, ')
          ..write('txnType: $txnType, ')
          ..write('bookedAt: $bookedAt, ')
          ..write('valueDate: $valueDate, ')
          ..write('bankCode: $bankCode, ')
          ..write('accountHint: $accountHint, ')
          ..write('merchantId: $merchantId, ')
          ..write('categoryId: $categoryId, ')
          ..write('suggestedCategorySlug: $suggestedCategorySlug, ')
          ..write('categorySource: $categorySource, ')
          ..write('rawMerchant: $rawMerchant, ')
          ..write('rawDescription: $rawDescription, ')
          ..write('upiPayerVpa: $upiPayerVpa, ')
          ..write('upiPayeeVpa: $upiPayeeVpa, ')
          ..write('upiRef: $upiRef, ')
          ..write('remarks: $remarks, ')
          ..write('externalRef: $externalRef, ')
          ..write('balanceAfterPaise: $balanceAfterPaise, ')
          ..write('dedupeHash: $dedupeHash, ')
          ..write('importId: $importId, ')
          ..write('isRecurringCandidate: $isRecurringCandidate, ')
          ..write('recurringKind: $recurringKind, ')
          ..write('accountKind: $accountKind, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    amountPaise,
    currency,
    direction,
    txnType,
    bookedAt,
    valueDate,
    bankCode,
    accountHint,
    merchantId,
    categoryId,
    suggestedCategorySlug,
    categorySource,
    rawMerchant,
    rawDescription,
    upiPayerVpa,
    upiPayeeVpa,
    upiRef,
    remarks,
    externalRef,
    balanceAfterPaise,
    dedupeHash,
    importId,
    isRecurringCandidate,
    recurringKind,
    accountKind,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.amountPaise == this.amountPaise &&
          other.currency == this.currency &&
          other.direction == this.direction &&
          other.txnType == this.txnType &&
          other.bookedAt == this.bookedAt &&
          other.valueDate == this.valueDate &&
          other.bankCode == this.bankCode &&
          other.accountHint == this.accountHint &&
          other.merchantId == this.merchantId &&
          other.categoryId == this.categoryId &&
          other.suggestedCategorySlug == this.suggestedCategorySlug &&
          other.categorySource == this.categorySource &&
          other.rawMerchant == this.rawMerchant &&
          other.rawDescription == this.rawDescription &&
          other.upiPayerVpa == this.upiPayerVpa &&
          other.upiPayeeVpa == this.upiPayeeVpa &&
          other.upiRef == this.upiRef &&
          other.remarks == this.remarks &&
          other.externalRef == this.externalRef &&
          other.balanceAfterPaise == this.balanceAfterPaise &&
          other.dedupeHash == this.dedupeHash &&
          other.importId == this.importId &&
          other.isRecurringCandidate == this.isRecurringCandidate &&
          other.recurringKind == this.recurringKind &&
          other.accountKind == this.accountKind &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<int> id;
  final Value<int> amountPaise;
  final Value<String> currency;
  final Value<String> direction;
  final Value<String> txnType;
  final Value<DateTime> bookedAt;
  final Value<DateTime?> valueDate;
  final Value<String> bankCode;
  final Value<String?> accountHint;
  final Value<int?> merchantId;
  final Value<int?> categoryId;
  final Value<String?> suggestedCategorySlug;
  final Value<String?> categorySource;
  final Value<String> rawMerchant;
  final Value<String> rawDescription;
  final Value<String?> upiPayerVpa;
  final Value<String?> upiPayeeVpa;
  final Value<String?> upiRef;
  final Value<String?> remarks;
  final Value<String?> externalRef;
  final Value<int?> balanceAfterPaise;
  final Value<String> dedupeHash;
  final Value<int?> importId;
  final Value<bool> isRecurringCandidate;
  final Value<String?> recurringKind;
  final Value<String?> accountKind;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.currency = const Value.absent(),
    this.direction = const Value.absent(),
    this.txnType = const Value.absent(),
    this.bookedAt = const Value.absent(),
    this.valueDate = const Value.absent(),
    this.bankCode = const Value.absent(),
    this.accountHint = const Value.absent(),
    this.merchantId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.suggestedCategorySlug = const Value.absent(),
    this.categorySource = const Value.absent(),
    this.rawMerchant = const Value.absent(),
    this.rawDescription = const Value.absent(),
    this.upiPayerVpa = const Value.absent(),
    this.upiPayeeVpa = const Value.absent(),
    this.upiRef = const Value.absent(),
    this.remarks = const Value.absent(),
    this.externalRef = const Value.absent(),
    this.balanceAfterPaise = const Value.absent(),
    this.dedupeHash = const Value.absent(),
    this.importId = const Value.absent(),
    this.isRecurringCandidate = const Value.absent(),
    this.recurringKind = const Value.absent(),
    this.accountKind = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    required int amountPaise,
    this.currency = const Value.absent(),
    required String direction,
    required String txnType,
    required DateTime bookedAt,
    this.valueDate = const Value.absent(),
    required String bankCode,
    this.accountHint = const Value.absent(),
    this.merchantId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.suggestedCategorySlug = const Value.absent(),
    this.categorySource = const Value.absent(),
    required String rawMerchant,
    required String rawDescription,
    this.upiPayerVpa = const Value.absent(),
    this.upiPayeeVpa = const Value.absent(),
    this.upiRef = const Value.absent(),
    this.remarks = const Value.absent(),
    this.externalRef = const Value.absent(),
    this.balanceAfterPaise = const Value.absent(),
    required String dedupeHash,
    this.importId = const Value.absent(),
    this.isRecurringCandidate = const Value.absent(),
    this.recurringKind = const Value.absent(),
    this.accountKind = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : amountPaise = Value(amountPaise),
       direction = Value(direction),
       txnType = Value(txnType),
       bookedAt = Value(bookedAt),
       bankCode = Value(bankCode),
       rawMerchant = Value(rawMerchant),
       rawDescription = Value(rawDescription),
       dedupeHash = Value(dedupeHash);
  static Insertable<Transaction> custom({
    Expression<int>? id,
    Expression<int>? amountPaise,
    Expression<String>? currency,
    Expression<String>? direction,
    Expression<String>? txnType,
    Expression<DateTime>? bookedAt,
    Expression<DateTime>? valueDate,
    Expression<String>? bankCode,
    Expression<String>? accountHint,
    Expression<int>? merchantId,
    Expression<int>? categoryId,
    Expression<String>? suggestedCategorySlug,
    Expression<String>? categorySource,
    Expression<String>? rawMerchant,
    Expression<String>? rawDescription,
    Expression<String>? upiPayerVpa,
    Expression<String>? upiPayeeVpa,
    Expression<String>? upiRef,
    Expression<String>? remarks,
    Expression<String>? externalRef,
    Expression<int>? balanceAfterPaise,
    Expression<String>? dedupeHash,
    Expression<int>? importId,
    Expression<bool>? isRecurringCandidate,
    Expression<String>? recurringKind,
    Expression<String>? accountKind,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (currency != null) 'currency': currency,
      if (direction != null) 'direction': direction,
      if (txnType != null) 'txn_type': txnType,
      if (bookedAt != null) 'booked_at': bookedAt,
      if (valueDate != null) 'value_date': valueDate,
      if (bankCode != null) 'bank_code': bankCode,
      if (accountHint != null) 'account_hint': accountHint,
      if (merchantId != null) 'merchant_id': merchantId,
      if (categoryId != null) 'category_id': categoryId,
      if (suggestedCategorySlug != null)
        'suggested_category_slug': suggestedCategorySlug,
      if (categorySource != null) 'category_source': categorySource,
      if (rawMerchant != null) 'raw_merchant': rawMerchant,
      if (rawDescription != null) 'raw_description': rawDescription,
      if (upiPayerVpa != null) 'upi_payer_vpa': upiPayerVpa,
      if (upiPayeeVpa != null) 'upi_payee_vpa': upiPayeeVpa,
      if (upiRef != null) 'upi_ref': upiRef,
      if (remarks != null) 'remarks': remarks,
      if (externalRef != null) 'external_ref': externalRef,
      if (balanceAfterPaise != null) 'balance_after_paise': balanceAfterPaise,
      if (dedupeHash != null) 'dedupe_hash': dedupeHash,
      if (importId != null) 'import_id': importId,
      if (isRecurringCandidate != null)
        'is_recurring_candidate': isRecurringCandidate,
      if (recurringKind != null) 'recurring_kind': recurringKind,
      if (accountKind != null) 'account_kind': accountKind,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TransactionsCompanion copyWith({
    Value<int>? id,
    Value<int>? amountPaise,
    Value<String>? currency,
    Value<String>? direction,
    Value<String>? txnType,
    Value<DateTime>? bookedAt,
    Value<DateTime?>? valueDate,
    Value<String>? bankCode,
    Value<String?>? accountHint,
    Value<int?>? merchantId,
    Value<int?>? categoryId,
    Value<String?>? suggestedCategorySlug,
    Value<String?>? categorySource,
    Value<String>? rawMerchant,
    Value<String>? rawDescription,
    Value<String?>? upiPayerVpa,
    Value<String?>? upiPayeeVpa,
    Value<String?>? upiRef,
    Value<String?>? remarks,
    Value<String?>? externalRef,
    Value<int?>? balanceAfterPaise,
    Value<String>? dedupeHash,
    Value<int?>? importId,
    Value<bool>? isRecurringCandidate,
    Value<String?>? recurringKind,
    Value<String?>? accountKind,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      amountPaise: amountPaise ?? this.amountPaise,
      currency: currency ?? this.currency,
      direction: direction ?? this.direction,
      txnType: txnType ?? this.txnType,
      bookedAt: bookedAt ?? this.bookedAt,
      valueDate: valueDate ?? this.valueDate,
      bankCode: bankCode ?? this.bankCode,
      accountHint: accountHint ?? this.accountHint,
      merchantId: merchantId ?? this.merchantId,
      categoryId: categoryId ?? this.categoryId,
      suggestedCategorySlug:
          suggestedCategorySlug ?? this.suggestedCategorySlug,
      categorySource: categorySource ?? this.categorySource,
      rawMerchant: rawMerchant ?? this.rawMerchant,
      rawDescription: rawDescription ?? this.rawDescription,
      upiPayerVpa: upiPayerVpa ?? this.upiPayerVpa,
      upiPayeeVpa: upiPayeeVpa ?? this.upiPayeeVpa,
      upiRef: upiRef ?? this.upiRef,
      remarks: remarks ?? this.remarks,
      externalRef: externalRef ?? this.externalRef,
      balanceAfterPaise: balanceAfterPaise ?? this.balanceAfterPaise,
      dedupeHash: dedupeHash ?? this.dedupeHash,
      importId: importId ?? this.importId,
      isRecurringCandidate: isRecurringCandidate ?? this.isRecurringCandidate,
      recurringKind: recurringKind ?? this.recurringKind,
      accountKind: accountKind ?? this.accountKind,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (txnType.present) {
      map['txn_type'] = Variable<String>(txnType.value);
    }
    if (bookedAt.present) {
      map['booked_at'] = Variable<DateTime>(bookedAt.value);
    }
    if (valueDate.present) {
      map['value_date'] = Variable<DateTime>(valueDate.value);
    }
    if (bankCode.present) {
      map['bank_code'] = Variable<String>(bankCode.value);
    }
    if (accountHint.present) {
      map['account_hint'] = Variable<String>(accountHint.value);
    }
    if (merchantId.present) {
      map['merchant_id'] = Variable<int>(merchantId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (suggestedCategorySlug.present) {
      map['suggested_category_slug'] = Variable<String>(
        suggestedCategorySlug.value,
      );
    }
    if (categorySource.present) {
      map['category_source'] = Variable<String>(categorySource.value);
    }
    if (rawMerchant.present) {
      map['raw_merchant'] = Variable<String>(rawMerchant.value);
    }
    if (rawDescription.present) {
      map['raw_description'] = Variable<String>(rawDescription.value);
    }
    if (upiPayerVpa.present) {
      map['upi_payer_vpa'] = Variable<String>(upiPayerVpa.value);
    }
    if (upiPayeeVpa.present) {
      map['upi_payee_vpa'] = Variable<String>(upiPayeeVpa.value);
    }
    if (upiRef.present) {
      map['upi_ref'] = Variable<String>(upiRef.value);
    }
    if (remarks.present) {
      map['remarks'] = Variable<String>(remarks.value);
    }
    if (externalRef.present) {
      map['external_ref'] = Variable<String>(externalRef.value);
    }
    if (balanceAfterPaise.present) {
      map['balance_after_paise'] = Variable<int>(balanceAfterPaise.value);
    }
    if (dedupeHash.present) {
      map['dedupe_hash'] = Variable<String>(dedupeHash.value);
    }
    if (importId.present) {
      map['import_id'] = Variable<int>(importId.value);
    }
    if (isRecurringCandidate.present) {
      map['is_recurring_candidate'] = Variable<bool>(
        isRecurringCandidate.value,
      );
    }
    if (recurringKind.present) {
      map['recurring_kind'] = Variable<String>(recurringKind.value);
    }
    if (accountKind.present) {
      map['account_kind'] = Variable<String>(accountKind.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('currency: $currency, ')
          ..write('direction: $direction, ')
          ..write('txnType: $txnType, ')
          ..write('bookedAt: $bookedAt, ')
          ..write('valueDate: $valueDate, ')
          ..write('bankCode: $bankCode, ')
          ..write('accountHint: $accountHint, ')
          ..write('merchantId: $merchantId, ')
          ..write('categoryId: $categoryId, ')
          ..write('suggestedCategorySlug: $suggestedCategorySlug, ')
          ..write('categorySource: $categorySource, ')
          ..write('rawMerchant: $rawMerchant, ')
          ..write('rawDescription: $rawDescription, ')
          ..write('upiPayerVpa: $upiPayerVpa, ')
          ..write('upiPayeeVpa: $upiPayeeVpa, ')
          ..write('upiRef: $upiRef, ')
          ..write('remarks: $remarks, ')
          ..write('externalRef: $externalRef, ')
          ..write('balanceAfterPaise: $balanceAfterPaise, ')
          ..write('dedupeHash: $dedupeHash, ')
          ..write('importId: $importId, ')
          ..write('isRecurringCandidate: $isRecurringCandidate, ')
          ..write('recurringKind: $recurringKind, ')
          ..write('accountKind: $accountKind, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TransactionImportsTable extends TransactionImports
    with TableInfo<$TransactionImportsTable, TransactionImport> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionImportsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<int> transactionId = GeneratedColumn<int>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES transactions (id)',
    ),
  );
  static const VerificationMeta _importIdMeta = const VerificationMeta(
    'importId',
  );
  @override
  late final GeneratedColumn<int> importId = GeneratedColumn<int>(
    'import_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES imports (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, transactionId, importId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_imports';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionImport> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('import_id')) {
      context.handle(
        _importIdMeta,
        importId.isAcceptableOrUnknown(data['import_id']!, _importIdMeta),
      );
    } else if (isInserting) {
      context.missing(_importIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {transactionId, importId},
  ];
  @override
  TransactionImport map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionImport(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transaction_id'],
      )!,
      importId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}import_id'],
      )!,
    );
  }

  @override
  $TransactionImportsTable createAlias(String alias) {
    return $TransactionImportsTable(attachedDatabase, alias);
  }
}

class TransactionImport extends DataClass
    implements Insertable<TransactionImport> {
  final int id;
  final int transactionId;
  final int importId;
  const TransactionImport({
    required this.id,
    required this.transactionId,
    required this.importId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['transaction_id'] = Variable<int>(transactionId);
    map['import_id'] = Variable<int>(importId);
    return map;
  }

  TransactionImportsCompanion toCompanion(bool nullToAbsent) {
    return TransactionImportsCompanion(
      id: Value(id),
      transactionId: Value(transactionId),
      importId: Value(importId),
    );
  }

  factory TransactionImport.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionImport(
      id: serializer.fromJson<int>(json['id']),
      transactionId: serializer.fromJson<int>(json['transactionId']),
      importId: serializer.fromJson<int>(json['importId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'transactionId': serializer.toJson<int>(transactionId),
      'importId': serializer.toJson<int>(importId),
    };
  }

  TransactionImport copyWith({int? id, int? transactionId, int? importId}) =>
      TransactionImport(
        id: id ?? this.id,
        transactionId: transactionId ?? this.transactionId,
        importId: importId ?? this.importId,
      );
  TransactionImport copyWithCompanion(TransactionImportsCompanion data) {
    return TransactionImport(
      id: data.id.present ? data.id.value : this.id,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      importId: data.importId.present ? data.importId.value : this.importId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionImport(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('importId: $importId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, transactionId, importId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionImport &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.importId == this.importId);
}

class TransactionImportsCompanion extends UpdateCompanion<TransactionImport> {
  final Value<int> id;
  final Value<int> transactionId;
  final Value<int> importId;
  const TransactionImportsCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.importId = const Value.absent(),
  });
  TransactionImportsCompanion.insert({
    this.id = const Value.absent(),
    required int transactionId,
    required int importId,
  }) : transactionId = Value(transactionId),
       importId = Value(importId);
  static Insertable<TransactionImport> custom({
    Expression<int>? id,
    Expression<int>? transactionId,
    Expression<int>? importId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (importId != null) 'import_id': importId,
    });
  }

  TransactionImportsCompanion copyWith({
    Value<int>? id,
    Value<int>? transactionId,
    Value<int>? importId,
  }) {
    return TransactionImportsCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      importId: importId ?? this.importId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<int>(transactionId.value);
    }
    if (importId.present) {
      map['import_id'] = Variable<int>(importId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionImportsCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('importId: $importId')
          ..write(')'))
        .toString();
  }
}

class $UserCorrectionsTable extends UserCorrections
    with TableInfo<$UserCorrectionsTable, UserCorrection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserCorrectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<int> transactionId = GeneratedColumn<int>(
    'transaction_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES transactions (id)',
    ),
  );
  static const VerificationMeta _rawMerchantMeta = const VerificationMeta(
    'rawMerchant',
  );
  @override
  late final GeneratedColumn<String> rawMerchant = GeneratedColumn<String>(
    'raw_merchant',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fieldMeta = const VerificationMeta('field');
  @override
  late final GeneratedColumn<String> field = GeneratedColumn<String>(
    'field',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _oldValueMeta = const VerificationMeta(
    'oldValue',
  );
  @override
  late final GeneratedColumn<String> oldValue = GeneratedColumn<String>(
    'old_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _newValueMeta = const VerificationMeta(
    'newValue',
  );
  @override
  late final GeneratedColumn<String> newValue = GeneratedColumn<String>(
    'new_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    transactionId,
    rawMerchant,
    field,
    oldValue,
    newValue,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_corrections';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserCorrection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    }
    if (data.containsKey('raw_merchant')) {
      context.handle(
        _rawMerchantMeta,
        rawMerchant.isAcceptableOrUnknown(
          data['raw_merchant']!,
          _rawMerchantMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rawMerchantMeta);
    }
    if (data.containsKey('field')) {
      context.handle(
        _fieldMeta,
        field.isAcceptableOrUnknown(data['field']!, _fieldMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldMeta);
    }
    if (data.containsKey('old_value')) {
      context.handle(
        _oldValueMeta,
        oldValue.isAcceptableOrUnknown(data['old_value']!, _oldValueMeta),
      );
    }
    if (data.containsKey('new_value')) {
      context.handle(
        _newValueMeta,
        newValue.isAcceptableOrUnknown(data['new_value']!, _newValueMeta),
      );
    } else if (isInserting) {
      context.missing(_newValueMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserCorrection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserCorrection(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transaction_id'],
      ),
      rawMerchant: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_merchant'],
      )!,
      field: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field'],
      )!,
      oldValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}old_value'],
      ),
      newValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}new_value'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $UserCorrectionsTable createAlias(String alias) {
    return $UserCorrectionsTable(attachedDatabase, alias);
  }
}

class UserCorrection extends DataClass implements Insertable<UserCorrection> {
  final int id;
  final int? transactionId;
  final String rawMerchant;
  final String field;
  final String? oldValue;
  final String newValue;
  final DateTime createdAt;
  const UserCorrection({
    required this.id,
    this.transactionId,
    required this.rawMerchant,
    required this.field,
    this.oldValue,
    required this.newValue,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || transactionId != null) {
      map['transaction_id'] = Variable<int>(transactionId);
    }
    map['raw_merchant'] = Variable<String>(rawMerchant);
    map['field'] = Variable<String>(field);
    if (!nullToAbsent || oldValue != null) {
      map['old_value'] = Variable<String>(oldValue);
    }
    map['new_value'] = Variable<String>(newValue);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UserCorrectionsCompanion toCompanion(bool nullToAbsent) {
    return UserCorrectionsCompanion(
      id: Value(id),
      transactionId: transactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionId),
      rawMerchant: Value(rawMerchant),
      field: Value(field),
      oldValue: oldValue == null && nullToAbsent
          ? const Value.absent()
          : Value(oldValue),
      newValue: Value(newValue),
      createdAt: Value(createdAt),
    );
  }

  factory UserCorrection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserCorrection(
      id: serializer.fromJson<int>(json['id']),
      transactionId: serializer.fromJson<int?>(json['transactionId']),
      rawMerchant: serializer.fromJson<String>(json['rawMerchant']),
      field: serializer.fromJson<String>(json['field']),
      oldValue: serializer.fromJson<String?>(json['oldValue']),
      newValue: serializer.fromJson<String>(json['newValue']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'transactionId': serializer.toJson<int?>(transactionId),
      'rawMerchant': serializer.toJson<String>(rawMerchant),
      'field': serializer.toJson<String>(field),
      'oldValue': serializer.toJson<String?>(oldValue),
      'newValue': serializer.toJson<String>(newValue),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  UserCorrection copyWith({
    int? id,
    Value<int?> transactionId = const Value.absent(),
    String? rawMerchant,
    String? field,
    Value<String?> oldValue = const Value.absent(),
    String? newValue,
    DateTime? createdAt,
  }) => UserCorrection(
    id: id ?? this.id,
    transactionId: transactionId.present
        ? transactionId.value
        : this.transactionId,
    rawMerchant: rawMerchant ?? this.rawMerchant,
    field: field ?? this.field,
    oldValue: oldValue.present ? oldValue.value : this.oldValue,
    newValue: newValue ?? this.newValue,
    createdAt: createdAt ?? this.createdAt,
  );
  UserCorrection copyWithCompanion(UserCorrectionsCompanion data) {
    return UserCorrection(
      id: data.id.present ? data.id.value : this.id,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      rawMerchant: data.rawMerchant.present
          ? data.rawMerchant.value
          : this.rawMerchant,
      field: data.field.present ? data.field.value : this.field,
      oldValue: data.oldValue.present ? data.oldValue.value : this.oldValue,
      newValue: data.newValue.present ? data.newValue.value : this.newValue,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserCorrection(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('rawMerchant: $rawMerchant, ')
          ..write('field: $field, ')
          ..write('oldValue: $oldValue, ')
          ..write('newValue: $newValue, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    transactionId,
    rawMerchant,
    field,
    oldValue,
    newValue,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserCorrection &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.rawMerchant == this.rawMerchant &&
          other.field == this.field &&
          other.oldValue == this.oldValue &&
          other.newValue == this.newValue &&
          other.createdAt == this.createdAt);
}

class UserCorrectionsCompanion extends UpdateCompanion<UserCorrection> {
  final Value<int> id;
  final Value<int?> transactionId;
  final Value<String> rawMerchant;
  final Value<String> field;
  final Value<String?> oldValue;
  final Value<String> newValue;
  final Value<DateTime> createdAt;
  const UserCorrectionsCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.rawMerchant = const Value.absent(),
    this.field = const Value.absent(),
    this.oldValue = const Value.absent(),
    this.newValue = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  UserCorrectionsCompanion.insert({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    required String rawMerchant,
    required String field,
    this.oldValue = const Value.absent(),
    required String newValue,
    this.createdAt = const Value.absent(),
  }) : rawMerchant = Value(rawMerchant),
       field = Value(field),
       newValue = Value(newValue);
  static Insertable<UserCorrection> custom({
    Expression<int>? id,
    Expression<int>? transactionId,
    Expression<String>? rawMerchant,
    Expression<String>? field,
    Expression<String>? oldValue,
    Expression<String>? newValue,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (rawMerchant != null) 'raw_merchant': rawMerchant,
      if (field != null) 'field': field,
      if (oldValue != null) 'old_value': oldValue,
      if (newValue != null) 'new_value': newValue,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  UserCorrectionsCompanion copyWith({
    Value<int>? id,
    Value<int?>? transactionId,
    Value<String>? rawMerchant,
    Value<String>? field,
    Value<String?>? oldValue,
    Value<String>? newValue,
    Value<DateTime>? createdAt,
  }) {
    return UserCorrectionsCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      rawMerchant: rawMerchant ?? this.rawMerchant,
      field: field ?? this.field,
      oldValue: oldValue ?? this.oldValue,
      newValue: newValue ?? this.newValue,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<int>(transactionId.value);
    }
    if (rawMerchant.present) {
      map['raw_merchant'] = Variable<String>(rawMerchant.value);
    }
    if (field.present) {
      map['field'] = Variable<String>(field.value);
    }
    if (oldValue.present) {
      map['old_value'] = Variable<String>(oldValue.value);
    }
    if (newValue.present) {
      map['new_value'] = Variable<String>(newValue.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserCorrectionsCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('rawMerchant: $rawMerchant, ')
          ..write('field: $field, ')
          ..write('oldValue: $oldValue, ')
          ..write('newValue: $newValue, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $UnparsedSmsRowsTable extends UnparsedSmsRows
    with TableInfo<$UnparsedSmsRowsTable, UnparsedSmsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UnparsedSmsRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _rawBodyMeta = const VerificationMeta(
    'rawBody',
  );
  @override
  late final GeneratedColumn<String> rawBody = GeneratedColumn<String>(
    'raw_body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderMeta = const VerificationMeta('sender');
  @override
  late final GeneratedColumn<String> sender = GeneratedColumn<String>(
    'sender',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receivedAtMeta = const VerificationMeta(
    'receivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> receivedAt = GeneratedColumn<DateTime>(
    'received_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bankCodeMeta = const VerificationMeta(
    'bankCode',
  );
  @override
  late final GeneratedColumn<String> bankCode = GeneratedColumn<String>(
    'bank_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolvedMeta = const VerificationMeta(
    'resolved',
  );
  @override
  late final GeneratedColumn<bool> resolved = GeneratedColumn<bool>(
    'resolved',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("resolved" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    rawBody,
    sender,
    receivedAt,
    bankCode,
    reason,
    resolved,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'unparsed_sms_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<UnparsedSmsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('raw_body')) {
      context.handle(
        _rawBodyMeta,
        rawBody.isAcceptableOrUnknown(data['raw_body']!, _rawBodyMeta),
      );
    } else if (isInserting) {
      context.missing(_rawBodyMeta);
    }
    if (data.containsKey('sender')) {
      context.handle(
        _senderMeta,
        sender.isAcceptableOrUnknown(data['sender']!, _senderMeta),
      );
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    }
    if (data.containsKey('bank_code')) {
      context.handle(
        _bankCodeMeta,
        bankCode.isAcceptableOrUnknown(data['bank_code']!, _bankCodeMeta),
      );
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('resolved')) {
      context.handle(
        _resolvedMeta,
        resolved.isAcceptableOrUnknown(data['resolved']!, _resolvedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UnparsedSmsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UnparsedSmsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      rawBody: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_body'],
      )!,
      sender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender'],
      ),
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}received_at'],
      ),
      bankCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bank_code'],
      ),
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      resolved: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}resolved'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $UnparsedSmsRowsTable createAlias(String alias) {
    return $UnparsedSmsRowsTable(attachedDatabase, alias);
  }
}

class UnparsedSmsRow extends DataClass implements Insertable<UnparsedSmsRow> {
  final int id;
  final String rawBody;
  final String? sender;
  final DateTime? receivedAt;
  final String? bankCode;
  final String reason;
  final bool resolved;
  final DateTime createdAt;
  const UnparsedSmsRow({
    required this.id,
    required this.rawBody,
    this.sender,
    this.receivedAt,
    this.bankCode,
    required this.reason,
    required this.resolved,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['raw_body'] = Variable<String>(rawBody);
    if (!nullToAbsent || sender != null) {
      map['sender'] = Variable<String>(sender);
    }
    if (!nullToAbsent || receivedAt != null) {
      map['received_at'] = Variable<DateTime>(receivedAt);
    }
    if (!nullToAbsent || bankCode != null) {
      map['bank_code'] = Variable<String>(bankCode);
    }
    map['reason'] = Variable<String>(reason);
    map['resolved'] = Variable<bool>(resolved);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UnparsedSmsRowsCompanion toCompanion(bool nullToAbsent) {
    return UnparsedSmsRowsCompanion(
      id: Value(id),
      rawBody: Value(rawBody),
      sender: sender == null && nullToAbsent
          ? const Value.absent()
          : Value(sender),
      receivedAt: receivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(receivedAt),
      bankCode: bankCode == null && nullToAbsent
          ? const Value.absent()
          : Value(bankCode),
      reason: Value(reason),
      resolved: Value(resolved),
      createdAt: Value(createdAt),
    );
  }

  factory UnparsedSmsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UnparsedSmsRow(
      id: serializer.fromJson<int>(json['id']),
      rawBody: serializer.fromJson<String>(json['rawBody']),
      sender: serializer.fromJson<String?>(json['sender']),
      receivedAt: serializer.fromJson<DateTime?>(json['receivedAt']),
      bankCode: serializer.fromJson<String?>(json['bankCode']),
      reason: serializer.fromJson<String>(json['reason']),
      resolved: serializer.fromJson<bool>(json['resolved']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rawBody': serializer.toJson<String>(rawBody),
      'sender': serializer.toJson<String?>(sender),
      'receivedAt': serializer.toJson<DateTime?>(receivedAt),
      'bankCode': serializer.toJson<String?>(bankCode),
      'reason': serializer.toJson<String>(reason),
      'resolved': serializer.toJson<bool>(resolved),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  UnparsedSmsRow copyWith({
    int? id,
    String? rawBody,
    Value<String?> sender = const Value.absent(),
    Value<DateTime?> receivedAt = const Value.absent(),
    Value<String?> bankCode = const Value.absent(),
    String? reason,
    bool? resolved,
    DateTime? createdAt,
  }) => UnparsedSmsRow(
    id: id ?? this.id,
    rawBody: rawBody ?? this.rawBody,
    sender: sender.present ? sender.value : this.sender,
    receivedAt: receivedAt.present ? receivedAt.value : this.receivedAt,
    bankCode: bankCode.present ? bankCode.value : this.bankCode,
    reason: reason ?? this.reason,
    resolved: resolved ?? this.resolved,
    createdAt: createdAt ?? this.createdAt,
  );
  UnparsedSmsRow copyWithCompanion(UnparsedSmsRowsCompanion data) {
    return UnparsedSmsRow(
      id: data.id.present ? data.id.value : this.id,
      rawBody: data.rawBody.present ? data.rawBody.value : this.rawBody,
      sender: data.sender.present ? data.sender.value : this.sender,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
      bankCode: data.bankCode.present ? data.bankCode.value : this.bankCode,
      reason: data.reason.present ? data.reason.value : this.reason,
      resolved: data.resolved.present ? data.resolved.value : this.resolved,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UnparsedSmsRow(')
          ..write('id: $id, ')
          ..write('rawBody: $rawBody, ')
          ..write('sender: $sender, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('bankCode: $bankCode, ')
          ..write('reason: $reason, ')
          ..write('resolved: $resolved, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    rawBody,
    sender,
    receivedAt,
    bankCode,
    reason,
    resolved,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UnparsedSmsRow &&
          other.id == this.id &&
          other.rawBody == this.rawBody &&
          other.sender == this.sender &&
          other.receivedAt == this.receivedAt &&
          other.bankCode == this.bankCode &&
          other.reason == this.reason &&
          other.resolved == this.resolved &&
          other.createdAt == this.createdAt);
}

class UnparsedSmsRowsCompanion extends UpdateCompanion<UnparsedSmsRow> {
  final Value<int> id;
  final Value<String> rawBody;
  final Value<String?> sender;
  final Value<DateTime?> receivedAt;
  final Value<String?> bankCode;
  final Value<String> reason;
  final Value<bool> resolved;
  final Value<DateTime> createdAt;
  const UnparsedSmsRowsCompanion({
    this.id = const Value.absent(),
    this.rawBody = const Value.absent(),
    this.sender = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.bankCode = const Value.absent(),
    this.reason = const Value.absent(),
    this.resolved = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  UnparsedSmsRowsCompanion.insert({
    this.id = const Value.absent(),
    required String rawBody,
    this.sender = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.bankCode = const Value.absent(),
    required String reason,
    this.resolved = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : rawBody = Value(rawBody),
       reason = Value(reason);
  static Insertable<UnparsedSmsRow> custom({
    Expression<int>? id,
    Expression<String>? rawBody,
    Expression<String>? sender,
    Expression<DateTime>? receivedAt,
    Expression<String>? bankCode,
    Expression<String>? reason,
    Expression<bool>? resolved,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rawBody != null) 'raw_body': rawBody,
      if (sender != null) 'sender': sender,
      if (receivedAt != null) 'received_at': receivedAt,
      if (bankCode != null) 'bank_code': bankCode,
      if (reason != null) 'reason': reason,
      if (resolved != null) 'resolved': resolved,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  UnparsedSmsRowsCompanion copyWith({
    Value<int>? id,
    Value<String>? rawBody,
    Value<String?>? sender,
    Value<DateTime?>? receivedAt,
    Value<String?>? bankCode,
    Value<String>? reason,
    Value<bool>? resolved,
    Value<DateTime>? createdAt,
  }) {
    return UnparsedSmsRowsCompanion(
      id: id ?? this.id,
      rawBody: rawBody ?? this.rawBody,
      sender: sender ?? this.sender,
      receivedAt: receivedAt ?? this.receivedAt,
      bankCode: bankCode ?? this.bankCode,
      reason: reason ?? this.reason,
      resolved: resolved ?? this.resolved,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (rawBody.present) {
      map['raw_body'] = Variable<String>(rawBody.value);
    }
    if (sender.present) {
      map['sender'] = Variable<String>(sender.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<DateTime>(receivedAt.value);
    }
    if (bankCode.present) {
      map['bank_code'] = Variable<String>(bankCode.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (resolved.present) {
      map['resolved'] = Variable<bool>(resolved.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UnparsedSmsRowsCompanion(')
          ..write('id: $id, ')
          ..write('rawBody: $rawBody, ')
          ..write('sender: $sender, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('bankCode: $bankCode, ')
          ..write('reason: $reason, ')
          ..write('resolved: $resolved, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MandateNoticesTable extends MandateNotices
    with TableInfo<$MandateNoticesTable, MandateNotice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MandateNoticesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bankCodeMeta = const VerificationMeta(
    'bankCode',
  );
  @override
  late final GeneratedColumn<String> bankCode = GeneratedColumn<String>(
    'bank_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _merchantMeta = const VerificationMeta(
    'merchant',
  );
  @override
  late final GeneratedColumn<String> merchant = GeneratedColumn<String>(
    'merchant',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scheduledDateMeta = const VerificationMeta(
    'scheduledDate',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledDate =
      GeneratedColumn<DateTime>(
        'scheduled_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _accountHintMeta = const VerificationMeta(
    'accountHint',
  );
  @override
  late final GeneratedColumn<String> accountHint = GeneratedColumn<String>(
    'account_hint',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawBodyMeta = const VerificationMeta(
    'rawBody',
  );
  @override
  late final GeneratedColumn<String> rawBody = GeneratedColumn<String>(
    'raw_body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderMeta = const VerificationMeta('sender');
  @override
  late final GeneratedColumn<String> sender = GeneratedColumn<String>(
    'sender',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receivedAtMeta = const VerificationMeta(
    'receivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> receivedAt = GeneratedColumn<DateTime>(
    'received_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bankCode,
    amountPaise,
    merchant,
    scheduledDate,
    accountHint,
    rawBody,
    sender,
    receivedAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mandate_notices';
  @override
  VerificationContext validateIntegrity(
    Insertable<MandateNotice> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('bank_code')) {
      context.handle(
        _bankCodeMeta,
        bankCode.isAcceptableOrUnknown(data['bank_code']!, _bankCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_bankCodeMeta);
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    }
    if (data.containsKey('merchant')) {
      context.handle(
        _merchantMeta,
        merchant.isAcceptableOrUnknown(data['merchant']!, _merchantMeta),
      );
    }
    if (data.containsKey('scheduled_date')) {
      context.handle(
        _scheduledDateMeta,
        scheduledDate.isAcceptableOrUnknown(
          data['scheduled_date']!,
          _scheduledDateMeta,
        ),
      );
    }
    if (data.containsKey('account_hint')) {
      context.handle(
        _accountHintMeta,
        accountHint.isAcceptableOrUnknown(
          data['account_hint']!,
          _accountHintMeta,
        ),
      );
    }
    if (data.containsKey('raw_body')) {
      context.handle(
        _rawBodyMeta,
        rawBody.isAcceptableOrUnknown(data['raw_body']!, _rawBodyMeta),
      );
    } else if (isInserting) {
      context.missing(_rawBodyMeta);
    }
    if (data.containsKey('sender')) {
      context.handle(
        _senderMeta,
        sender.isAcceptableOrUnknown(data['sender']!, _senderMeta),
      );
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MandateNotice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MandateNotice(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bankCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bank_code'],
      )!,
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      ),
      merchant: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}merchant'],
      ),
      scheduledDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_date'],
      ),
      accountHint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_hint'],
      ),
      rawBody: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_body'],
      )!,
      sender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender'],
      ),
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}received_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MandateNoticesTable createAlias(String alias) {
    return $MandateNoticesTable(attachedDatabase, alias);
  }
}

class MandateNotice extends DataClass implements Insertable<MandateNotice> {
  final int id;
  final String bankCode;
  final int? amountPaise;
  final String? merchant;
  final DateTime? scheduledDate;
  final String? accountHint;
  final String rawBody;
  final String? sender;
  final DateTime? receivedAt;
  final DateTime createdAt;
  const MandateNotice({
    required this.id,
    required this.bankCode,
    this.amountPaise,
    this.merchant,
    this.scheduledDate,
    this.accountHint,
    required this.rawBody,
    this.sender,
    this.receivedAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['bank_code'] = Variable<String>(bankCode);
    if (!nullToAbsent || amountPaise != null) {
      map['amount_paise'] = Variable<int>(amountPaise);
    }
    if (!nullToAbsent || merchant != null) {
      map['merchant'] = Variable<String>(merchant);
    }
    if (!nullToAbsent || scheduledDate != null) {
      map['scheduled_date'] = Variable<DateTime>(scheduledDate);
    }
    if (!nullToAbsent || accountHint != null) {
      map['account_hint'] = Variable<String>(accountHint);
    }
    map['raw_body'] = Variable<String>(rawBody);
    if (!nullToAbsent || sender != null) {
      map['sender'] = Variable<String>(sender);
    }
    if (!nullToAbsent || receivedAt != null) {
      map['received_at'] = Variable<DateTime>(receivedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MandateNoticesCompanion toCompanion(bool nullToAbsent) {
    return MandateNoticesCompanion(
      id: Value(id),
      bankCode: Value(bankCode),
      amountPaise: amountPaise == null && nullToAbsent
          ? const Value.absent()
          : Value(amountPaise),
      merchant: merchant == null && nullToAbsent
          ? const Value.absent()
          : Value(merchant),
      scheduledDate: scheduledDate == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledDate),
      accountHint: accountHint == null && nullToAbsent
          ? const Value.absent()
          : Value(accountHint),
      rawBody: Value(rawBody),
      sender: sender == null && nullToAbsent
          ? const Value.absent()
          : Value(sender),
      receivedAt: receivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(receivedAt),
      createdAt: Value(createdAt),
    );
  }

  factory MandateNotice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MandateNotice(
      id: serializer.fromJson<int>(json['id']),
      bankCode: serializer.fromJson<String>(json['bankCode']),
      amountPaise: serializer.fromJson<int?>(json['amountPaise']),
      merchant: serializer.fromJson<String?>(json['merchant']),
      scheduledDate: serializer.fromJson<DateTime?>(json['scheduledDate']),
      accountHint: serializer.fromJson<String?>(json['accountHint']),
      rawBody: serializer.fromJson<String>(json['rawBody']),
      sender: serializer.fromJson<String?>(json['sender']),
      receivedAt: serializer.fromJson<DateTime?>(json['receivedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bankCode': serializer.toJson<String>(bankCode),
      'amountPaise': serializer.toJson<int?>(amountPaise),
      'merchant': serializer.toJson<String?>(merchant),
      'scheduledDate': serializer.toJson<DateTime?>(scheduledDate),
      'accountHint': serializer.toJson<String?>(accountHint),
      'rawBody': serializer.toJson<String>(rawBody),
      'sender': serializer.toJson<String?>(sender),
      'receivedAt': serializer.toJson<DateTime?>(receivedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MandateNotice copyWith({
    int? id,
    String? bankCode,
    Value<int?> amountPaise = const Value.absent(),
    Value<String?> merchant = const Value.absent(),
    Value<DateTime?> scheduledDate = const Value.absent(),
    Value<String?> accountHint = const Value.absent(),
    String? rawBody,
    Value<String?> sender = const Value.absent(),
    Value<DateTime?> receivedAt = const Value.absent(),
    DateTime? createdAt,
  }) => MandateNotice(
    id: id ?? this.id,
    bankCode: bankCode ?? this.bankCode,
    amountPaise: amountPaise.present ? amountPaise.value : this.amountPaise,
    merchant: merchant.present ? merchant.value : this.merchant,
    scheduledDate: scheduledDate.present
        ? scheduledDate.value
        : this.scheduledDate,
    accountHint: accountHint.present ? accountHint.value : this.accountHint,
    rawBody: rawBody ?? this.rawBody,
    sender: sender.present ? sender.value : this.sender,
    receivedAt: receivedAt.present ? receivedAt.value : this.receivedAt,
    createdAt: createdAt ?? this.createdAt,
  );
  MandateNotice copyWithCompanion(MandateNoticesCompanion data) {
    return MandateNotice(
      id: data.id.present ? data.id.value : this.id,
      bankCode: data.bankCode.present ? data.bankCode.value : this.bankCode,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
      merchant: data.merchant.present ? data.merchant.value : this.merchant,
      scheduledDate: data.scheduledDate.present
          ? data.scheduledDate.value
          : this.scheduledDate,
      accountHint: data.accountHint.present
          ? data.accountHint.value
          : this.accountHint,
      rawBody: data.rawBody.present ? data.rawBody.value : this.rawBody,
      sender: data.sender.present ? data.sender.value : this.sender,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MandateNotice(')
          ..write('id: $id, ')
          ..write('bankCode: $bankCode, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('merchant: $merchant, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('accountHint: $accountHint, ')
          ..write('rawBody: $rawBody, ')
          ..write('sender: $sender, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bankCode,
    amountPaise,
    merchant,
    scheduledDate,
    accountHint,
    rawBody,
    sender,
    receivedAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MandateNotice &&
          other.id == this.id &&
          other.bankCode == this.bankCode &&
          other.amountPaise == this.amountPaise &&
          other.merchant == this.merchant &&
          other.scheduledDate == this.scheduledDate &&
          other.accountHint == this.accountHint &&
          other.rawBody == this.rawBody &&
          other.sender == this.sender &&
          other.receivedAt == this.receivedAt &&
          other.createdAt == this.createdAt);
}

class MandateNoticesCompanion extends UpdateCompanion<MandateNotice> {
  final Value<int> id;
  final Value<String> bankCode;
  final Value<int?> amountPaise;
  final Value<String?> merchant;
  final Value<DateTime?> scheduledDate;
  final Value<String?> accountHint;
  final Value<String> rawBody;
  final Value<String?> sender;
  final Value<DateTime?> receivedAt;
  final Value<DateTime> createdAt;
  const MandateNoticesCompanion({
    this.id = const Value.absent(),
    this.bankCode = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.merchant = const Value.absent(),
    this.scheduledDate = const Value.absent(),
    this.accountHint = const Value.absent(),
    this.rawBody = const Value.absent(),
    this.sender = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MandateNoticesCompanion.insert({
    this.id = const Value.absent(),
    required String bankCode,
    this.amountPaise = const Value.absent(),
    this.merchant = const Value.absent(),
    this.scheduledDate = const Value.absent(),
    this.accountHint = const Value.absent(),
    required String rawBody,
    this.sender = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : bankCode = Value(bankCode),
       rawBody = Value(rawBody);
  static Insertable<MandateNotice> custom({
    Expression<int>? id,
    Expression<String>? bankCode,
    Expression<int>? amountPaise,
    Expression<String>? merchant,
    Expression<DateTime>? scheduledDate,
    Expression<String>? accountHint,
    Expression<String>? rawBody,
    Expression<String>? sender,
    Expression<DateTime>? receivedAt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bankCode != null) 'bank_code': bankCode,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (merchant != null) 'merchant': merchant,
      if (scheduledDate != null) 'scheduled_date': scheduledDate,
      if (accountHint != null) 'account_hint': accountHint,
      if (rawBody != null) 'raw_body': rawBody,
      if (sender != null) 'sender': sender,
      if (receivedAt != null) 'received_at': receivedAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MandateNoticesCompanion copyWith({
    Value<int>? id,
    Value<String>? bankCode,
    Value<int?>? amountPaise,
    Value<String?>? merchant,
    Value<DateTime?>? scheduledDate,
    Value<String?>? accountHint,
    Value<String>? rawBody,
    Value<String?>? sender,
    Value<DateTime?>? receivedAt,
    Value<DateTime>? createdAt,
  }) {
    return MandateNoticesCompanion(
      id: id ?? this.id,
      bankCode: bankCode ?? this.bankCode,
      amountPaise: amountPaise ?? this.amountPaise,
      merchant: merchant ?? this.merchant,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      accountHint: accountHint ?? this.accountHint,
      rawBody: rawBody ?? this.rawBody,
      sender: sender ?? this.sender,
      receivedAt: receivedAt ?? this.receivedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bankCode.present) {
      map['bank_code'] = Variable<String>(bankCode.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (merchant.present) {
      map['merchant'] = Variable<String>(merchant.value);
    }
    if (scheduledDate.present) {
      map['scheduled_date'] = Variable<DateTime>(scheduledDate.value);
    }
    if (accountHint.present) {
      map['account_hint'] = Variable<String>(accountHint.value);
    }
    if (rawBody.present) {
      map['raw_body'] = Variable<String>(rawBody.value);
    }
    if (sender.present) {
      map['sender'] = Variable<String>(sender.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<DateTime>(receivedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MandateNoticesCompanion(')
          ..write('id: $id, ')
          ..write('bankCode: $bankCode, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('merchant: $merchant, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('accountHint: $accountHint, ')
          ..write('rawBody: $rawBody, ')
          ..write('sender: $sender, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ModelInfoTable extends ModelInfo
    with TableInfo<$ModelInfoTable, ModelInfoData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ModelInfoTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _modelNameMeta = const VerificationMeta(
    'modelName',
  );
  @override
  late final GeneratedColumn<String> modelName = GeneratedColumn<String>(
    'model_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantMeta = const VerificationMeta('quant');
  @override
  late final GeneratedColumn<String> quant = GeneratedColumn<String>(
    'quant',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceUrlMeta = const VerificationMeta(
    'sourceUrl',
  );
  @override
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
    'source_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _downloadedAtMeta = const VerificationMeta(
    'downloadedAt',
  );
  @override
  late final GeneratedColumn<DateTime> downloadedAt = GeneratedColumn<DateTime>(
    'downloaded_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastLoadedAtMeta = const VerificationMeta(
    'lastLoadedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastLoadedAt = GeneratedColumn<DateTime>(
    'last_loaded_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    modelName,
    quant,
    sha256,
    sourceUrl,
    localPath,
    downloadedAt,
    lastLoadedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'model_info';
  @override
  VerificationContext validateIntegrity(
    Insertable<ModelInfoData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('model_name')) {
      context.handle(
        _modelNameMeta,
        modelName.isAcceptableOrUnknown(data['model_name']!, _modelNameMeta),
      );
    } else if (isInserting) {
      context.missing(_modelNameMeta);
    }
    if (data.containsKey('quant')) {
      context.handle(
        _quantMeta,
        quant.isAcceptableOrUnknown(data['quant']!, _quantMeta),
      );
    } else if (isInserting) {
      context.missing(_quantMeta);
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    } else if (isInserting) {
      context.missing(_sha256Meta);
    }
    if (data.containsKey('source_url')) {
      context.handle(
        _sourceUrlMeta,
        sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceUrlMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(
        _downloadedAtMeta,
        downloadedAt.isAcceptableOrUnknown(
          data['downloaded_at']!,
          _downloadedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_loaded_at')) {
      context.handle(
        _lastLoadedAtMeta,
        lastLoadedAt.isAcceptableOrUnknown(
          data['last_loaded_at']!,
          _lastLoadedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ModelInfoData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ModelInfoData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      modelName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_name'],
      )!,
      quant: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quant'],
      )!,
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      )!,
      sourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_url'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      ),
      downloadedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}downloaded_at'],
      ),
      lastLoadedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_loaded_at'],
      ),
    );
  }

  @override
  $ModelInfoTable createAlias(String alias) {
    return $ModelInfoTable(attachedDatabase, alias);
  }
}

class ModelInfoData extends DataClass implements Insertable<ModelInfoData> {
  final int id;
  final String modelName;
  final String quant;
  final String sha256;
  final String sourceUrl;
  final String? localPath;
  final DateTime? downloadedAt;
  final DateTime? lastLoadedAt;
  const ModelInfoData({
    required this.id,
    required this.modelName,
    required this.quant,
    required this.sha256,
    required this.sourceUrl,
    this.localPath,
    this.downloadedAt,
    this.lastLoadedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['model_name'] = Variable<String>(modelName);
    map['quant'] = Variable<String>(quant);
    map['sha256'] = Variable<String>(sha256);
    map['source_url'] = Variable<String>(sourceUrl);
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    if (!nullToAbsent || downloadedAt != null) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt);
    }
    if (!nullToAbsent || lastLoadedAt != null) {
      map['last_loaded_at'] = Variable<DateTime>(lastLoadedAt);
    }
    return map;
  }

  ModelInfoCompanion toCompanion(bool nullToAbsent) {
    return ModelInfoCompanion(
      id: Value(id),
      modelName: Value(modelName),
      quant: Value(quant),
      sha256: Value(sha256),
      sourceUrl: Value(sourceUrl),
      localPath: localPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPath),
      downloadedAt: downloadedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(downloadedAt),
      lastLoadedAt: lastLoadedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastLoadedAt),
    );
  }

  factory ModelInfoData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ModelInfoData(
      id: serializer.fromJson<int>(json['id']),
      modelName: serializer.fromJson<String>(json['modelName']),
      quant: serializer.fromJson<String>(json['quant']),
      sha256: serializer.fromJson<String>(json['sha256']),
      sourceUrl: serializer.fromJson<String>(json['sourceUrl']),
      localPath: serializer.fromJson<String?>(json['localPath']),
      downloadedAt: serializer.fromJson<DateTime?>(json['downloadedAt']),
      lastLoadedAt: serializer.fromJson<DateTime?>(json['lastLoadedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'modelName': serializer.toJson<String>(modelName),
      'quant': serializer.toJson<String>(quant),
      'sha256': serializer.toJson<String>(sha256),
      'sourceUrl': serializer.toJson<String>(sourceUrl),
      'localPath': serializer.toJson<String?>(localPath),
      'downloadedAt': serializer.toJson<DateTime?>(downloadedAt),
      'lastLoadedAt': serializer.toJson<DateTime?>(lastLoadedAt),
    };
  }

  ModelInfoData copyWith({
    int? id,
    String? modelName,
    String? quant,
    String? sha256,
    String? sourceUrl,
    Value<String?> localPath = const Value.absent(),
    Value<DateTime?> downloadedAt = const Value.absent(),
    Value<DateTime?> lastLoadedAt = const Value.absent(),
  }) => ModelInfoData(
    id: id ?? this.id,
    modelName: modelName ?? this.modelName,
    quant: quant ?? this.quant,
    sha256: sha256 ?? this.sha256,
    sourceUrl: sourceUrl ?? this.sourceUrl,
    localPath: localPath.present ? localPath.value : this.localPath,
    downloadedAt: downloadedAt.present ? downloadedAt.value : this.downloadedAt,
    lastLoadedAt: lastLoadedAt.present ? lastLoadedAt.value : this.lastLoadedAt,
  );
  ModelInfoData copyWithCompanion(ModelInfoCompanion data) {
    return ModelInfoData(
      id: data.id.present ? data.id.value : this.id,
      modelName: data.modelName.present ? data.modelName.value : this.modelName,
      quant: data.quant.present ? data.quant.value : this.quant,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      downloadedAt: data.downloadedAt.present
          ? data.downloadedAt.value
          : this.downloadedAt,
      lastLoadedAt: data.lastLoadedAt.present
          ? data.lastLoadedAt.value
          : this.lastLoadedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ModelInfoData(')
          ..write('id: $id, ')
          ..write('modelName: $modelName, ')
          ..write('quant: $quant, ')
          ..write('sha256: $sha256, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('localPath: $localPath, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('lastLoadedAt: $lastLoadedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    modelName,
    quant,
    sha256,
    sourceUrl,
    localPath,
    downloadedAt,
    lastLoadedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ModelInfoData &&
          other.id == this.id &&
          other.modelName == this.modelName &&
          other.quant == this.quant &&
          other.sha256 == this.sha256 &&
          other.sourceUrl == this.sourceUrl &&
          other.localPath == this.localPath &&
          other.downloadedAt == this.downloadedAt &&
          other.lastLoadedAt == this.lastLoadedAt);
}

class ModelInfoCompanion extends UpdateCompanion<ModelInfoData> {
  final Value<int> id;
  final Value<String> modelName;
  final Value<String> quant;
  final Value<String> sha256;
  final Value<String> sourceUrl;
  final Value<String?> localPath;
  final Value<DateTime?> downloadedAt;
  final Value<DateTime?> lastLoadedAt;
  const ModelInfoCompanion({
    this.id = const Value.absent(),
    this.modelName = const Value.absent(),
    this.quant = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.localPath = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.lastLoadedAt = const Value.absent(),
  });
  ModelInfoCompanion.insert({
    this.id = const Value.absent(),
    required String modelName,
    required String quant,
    required String sha256,
    required String sourceUrl,
    this.localPath = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.lastLoadedAt = const Value.absent(),
  }) : modelName = Value(modelName),
       quant = Value(quant),
       sha256 = Value(sha256),
       sourceUrl = Value(sourceUrl);
  static Insertable<ModelInfoData> custom({
    Expression<int>? id,
    Expression<String>? modelName,
    Expression<String>? quant,
    Expression<String>? sha256,
    Expression<String>? sourceUrl,
    Expression<String>? localPath,
    Expression<DateTime>? downloadedAt,
    Expression<DateTime>? lastLoadedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (modelName != null) 'model_name': modelName,
      if (quant != null) 'quant': quant,
      if (sha256 != null) 'sha256': sha256,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (localPath != null) 'local_path': localPath,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
      if (lastLoadedAt != null) 'last_loaded_at': lastLoadedAt,
    });
  }

  ModelInfoCompanion copyWith({
    Value<int>? id,
    Value<String>? modelName,
    Value<String>? quant,
    Value<String>? sha256,
    Value<String>? sourceUrl,
    Value<String?>? localPath,
    Value<DateTime?>? downloadedAt,
    Value<DateTime?>? lastLoadedAt,
  }) {
    return ModelInfoCompanion(
      id: id ?? this.id,
      modelName: modelName ?? this.modelName,
      quant: quant ?? this.quant,
      sha256: sha256 ?? this.sha256,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      localPath: localPath ?? this.localPath,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      lastLoadedAt: lastLoadedAt ?? this.lastLoadedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (modelName.present) {
      map['model_name'] = Variable<String>(modelName.value);
    }
    if (quant.present) {
      map['quant'] = Variable<String>(quant.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt.value);
    }
    if (lastLoadedAt.present) {
      map['last_loaded_at'] = Variable<DateTime>(lastLoadedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ModelInfoCompanion(')
          ..write('id: $id, ')
          ..write('modelName: $modelName, ')
          ..write('quant: $quant, ')
          ..write('sha256: $sha256, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('localPath: $localPath, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('lastLoadedAt: $lastLoadedAt')
          ..write(')'))
        .toString();
  }
}

class $UnparsedStatementRowsTable extends UnparsedStatementRows
    with TableInfo<$UnparsedStatementRowsTable, UnparsedStatementRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UnparsedStatementRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _importIdMeta = const VerificationMeta(
    'importId',
  );
  @override
  late final GeneratedColumn<int> importId = GeneratedColumn<int>(
    'import_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES imports (id)',
    ),
  );
  static const VerificationMeta _rowIndexMeta = const VerificationMeta(
    'rowIndex',
  );
  @override
  late final GeneratedColumn<int> rowIndex = GeneratedColumn<int>(
    'row_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawRowJsonMeta = const VerificationMeta(
    'rawRowJson',
  );
  @override
  late final GeneratedColumn<String> rawRowJson = GeneratedColumn<String>(
    'raw_row_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolvedMeta = const VerificationMeta(
    'resolved',
  );
  @override
  late final GeneratedColumn<bool> resolved = GeneratedColumn<bool>(
    'resolved',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("resolved" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    importId,
    rowIndex,
    rawRowJson,
    reason,
    resolved,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'unparsed_statement_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<UnparsedStatementRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('import_id')) {
      context.handle(
        _importIdMeta,
        importId.isAcceptableOrUnknown(data['import_id']!, _importIdMeta),
      );
    } else if (isInserting) {
      context.missing(_importIdMeta);
    }
    if (data.containsKey('row_index')) {
      context.handle(
        _rowIndexMeta,
        rowIndex.isAcceptableOrUnknown(data['row_index']!, _rowIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_rowIndexMeta);
    }
    if (data.containsKey('raw_row_json')) {
      context.handle(
        _rawRowJsonMeta,
        rawRowJson.isAcceptableOrUnknown(
          data['raw_row_json']!,
          _rawRowJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rawRowJsonMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('resolved')) {
      context.handle(
        _resolvedMeta,
        resolved.isAcceptableOrUnknown(data['resolved']!, _resolvedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UnparsedStatementRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UnparsedStatementRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      importId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}import_id'],
      )!,
      rowIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row_index'],
      )!,
      rawRowJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_row_json'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      resolved: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}resolved'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $UnparsedStatementRowsTable createAlias(String alias) {
    return $UnparsedStatementRowsTable(attachedDatabase, alias);
  }
}

class UnparsedStatementRow extends DataClass
    implements Insertable<UnparsedStatementRow> {
  final int id;
  final int importId;
  final int rowIndex;
  final String rawRowJson;
  final String reason;
  final bool resolved;
  final DateTime createdAt;
  const UnparsedStatementRow({
    required this.id,
    required this.importId,
    required this.rowIndex,
    required this.rawRowJson,
    required this.reason,
    required this.resolved,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['import_id'] = Variable<int>(importId);
    map['row_index'] = Variable<int>(rowIndex);
    map['raw_row_json'] = Variable<String>(rawRowJson);
    map['reason'] = Variable<String>(reason);
    map['resolved'] = Variable<bool>(resolved);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UnparsedStatementRowsCompanion toCompanion(bool nullToAbsent) {
    return UnparsedStatementRowsCompanion(
      id: Value(id),
      importId: Value(importId),
      rowIndex: Value(rowIndex),
      rawRowJson: Value(rawRowJson),
      reason: Value(reason),
      resolved: Value(resolved),
      createdAt: Value(createdAt),
    );
  }

  factory UnparsedStatementRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UnparsedStatementRow(
      id: serializer.fromJson<int>(json['id']),
      importId: serializer.fromJson<int>(json['importId']),
      rowIndex: serializer.fromJson<int>(json['rowIndex']),
      rawRowJson: serializer.fromJson<String>(json['rawRowJson']),
      reason: serializer.fromJson<String>(json['reason']),
      resolved: serializer.fromJson<bool>(json['resolved']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'importId': serializer.toJson<int>(importId),
      'rowIndex': serializer.toJson<int>(rowIndex),
      'rawRowJson': serializer.toJson<String>(rawRowJson),
      'reason': serializer.toJson<String>(reason),
      'resolved': serializer.toJson<bool>(resolved),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  UnparsedStatementRow copyWith({
    int? id,
    int? importId,
    int? rowIndex,
    String? rawRowJson,
    String? reason,
    bool? resolved,
    DateTime? createdAt,
  }) => UnparsedStatementRow(
    id: id ?? this.id,
    importId: importId ?? this.importId,
    rowIndex: rowIndex ?? this.rowIndex,
    rawRowJson: rawRowJson ?? this.rawRowJson,
    reason: reason ?? this.reason,
    resolved: resolved ?? this.resolved,
    createdAt: createdAt ?? this.createdAt,
  );
  UnparsedStatementRow copyWithCompanion(UnparsedStatementRowsCompanion data) {
    return UnparsedStatementRow(
      id: data.id.present ? data.id.value : this.id,
      importId: data.importId.present ? data.importId.value : this.importId,
      rowIndex: data.rowIndex.present ? data.rowIndex.value : this.rowIndex,
      rawRowJson: data.rawRowJson.present
          ? data.rawRowJson.value
          : this.rawRowJson,
      reason: data.reason.present ? data.reason.value : this.reason,
      resolved: data.resolved.present ? data.resolved.value : this.resolved,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UnparsedStatementRow(')
          ..write('id: $id, ')
          ..write('importId: $importId, ')
          ..write('rowIndex: $rowIndex, ')
          ..write('rawRowJson: $rawRowJson, ')
          ..write('reason: $reason, ')
          ..write('resolved: $resolved, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    importId,
    rowIndex,
    rawRowJson,
    reason,
    resolved,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UnparsedStatementRow &&
          other.id == this.id &&
          other.importId == this.importId &&
          other.rowIndex == this.rowIndex &&
          other.rawRowJson == this.rawRowJson &&
          other.reason == this.reason &&
          other.resolved == this.resolved &&
          other.createdAt == this.createdAt);
}

class UnparsedStatementRowsCompanion
    extends UpdateCompanion<UnparsedStatementRow> {
  final Value<int> id;
  final Value<int> importId;
  final Value<int> rowIndex;
  final Value<String> rawRowJson;
  final Value<String> reason;
  final Value<bool> resolved;
  final Value<DateTime> createdAt;
  const UnparsedStatementRowsCompanion({
    this.id = const Value.absent(),
    this.importId = const Value.absent(),
    this.rowIndex = const Value.absent(),
    this.rawRowJson = const Value.absent(),
    this.reason = const Value.absent(),
    this.resolved = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  UnparsedStatementRowsCompanion.insert({
    this.id = const Value.absent(),
    required int importId,
    required int rowIndex,
    required String rawRowJson,
    required String reason,
    this.resolved = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : importId = Value(importId),
       rowIndex = Value(rowIndex),
       rawRowJson = Value(rawRowJson),
       reason = Value(reason);
  static Insertable<UnparsedStatementRow> custom({
    Expression<int>? id,
    Expression<int>? importId,
    Expression<int>? rowIndex,
    Expression<String>? rawRowJson,
    Expression<String>? reason,
    Expression<bool>? resolved,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (importId != null) 'import_id': importId,
      if (rowIndex != null) 'row_index': rowIndex,
      if (rawRowJson != null) 'raw_row_json': rawRowJson,
      if (reason != null) 'reason': reason,
      if (resolved != null) 'resolved': resolved,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  UnparsedStatementRowsCompanion copyWith({
    Value<int>? id,
    Value<int>? importId,
    Value<int>? rowIndex,
    Value<String>? rawRowJson,
    Value<String>? reason,
    Value<bool>? resolved,
    Value<DateTime>? createdAt,
  }) {
    return UnparsedStatementRowsCompanion(
      id: id ?? this.id,
      importId: importId ?? this.importId,
      rowIndex: rowIndex ?? this.rowIndex,
      rawRowJson: rawRowJson ?? this.rawRowJson,
      reason: reason ?? this.reason,
      resolved: resolved ?? this.resolved,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (importId.present) {
      map['import_id'] = Variable<int>(importId.value);
    }
    if (rowIndex.present) {
      map['row_index'] = Variable<int>(rowIndex.value);
    }
    if (rawRowJson.present) {
      map['raw_row_json'] = Variable<String>(rawRowJson.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (resolved.present) {
      map['resolved'] = Variable<bool>(resolved.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UnparsedStatementRowsCompanion(')
          ..write('id: $id, ')
          ..write('importId: $importId, ')
          ..write('rowIndex: $rowIndex, ')
          ..write('rawRowJson: $rawRowJson, ')
          ..write('reason: $reason, ')
          ..write('resolved: $resolved, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $LlmJobsTable extends LlmJobs with TableInfo<$LlmJobsTable, LlmJob> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LlmJobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _jobTypeMeta = const VerificationMeta(
    'jobType',
  );
  @override
  late final GeneratedColumn<String> jobType = GeneratedColumn<String>(
    'job_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _resultJsonMeta = const VerificationMeta(
    'resultJson',
  );
  @override
  late final GeneratedColumn<String> resultJson = GeneratedColumn<String>(
    'result_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    jobType,
    payloadJson,
    status,
    attempts,
    resultJson,
    lastError,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'llm_jobs';
  @override
  VerificationContext validateIntegrity(
    Insertable<LlmJob> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('job_type')) {
      context.handle(
        _jobTypeMeta,
        jobType.isAcceptableOrUnknown(data['job_type']!, _jobTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_jobTypeMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('result_json')) {
      context.handle(
        _resultJsonMeta,
        resultJson.isAcceptableOrUnknown(data['result_json']!, _resultJsonMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LlmJob map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LlmJob(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      jobType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}job_type'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      resultJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result_json'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LlmJobsTable createAlias(String alias) {
    return $LlmJobsTable(attachedDatabase, alias);
  }
}

class LlmJob extends DataClass implements Insertable<LlmJob> {
  final int id;

  /// sms_extract | stmt_row_extract | merchant_normalize | categorize
  final String jobType;

  /// JSON payload (row ids, raw strings, txn id, etc.).
  final String payloadJson;

  /// pending | running | done | failed
  final String status;
  final int attempts;
  final String? resultJson;
  final String? lastError;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LlmJob({
    required this.id,
    required this.jobType,
    required this.payloadJson,
    required this.status,
    required this.attempts,
    this.resultJson,
    this.lastError,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['job_type'] = Variable<String>(jobType);
    map['payload_json'] = Variable<String>(payloadJson);
    map['status'] = Variable<String>(status);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || resultJson != null) {
      map['result_json'] = Variable<String>(resultJson);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LlmJobsCompanion toCompanion(bool nullToAbsent) {
    return LlmJobsCompanion(
      id: Value(id),
      jobType: Value(jobType),
      payloadJson: Value(payloadJson),
      status: Value(status),
      attempts: Value(attempts),
      resultJson: resultJson == null && nullToAbsent
          ? const Value.absent()
          : Value(resultJson),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LlmJob.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LlmJob(
      id: serializer.fromJson<int>(json['id']),
      jobType: serializer.fromJson<String>(json['jobType']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      status: serializer.fromJson<String>(json['status']),
      attempts: serializer.fromJson<int>(json['attempts']),
      resultJson: serializer.fromJson<String?>(json['resultJson']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'jobType': serializer.toJson<String>(jobType),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'status': serializer.toJson<String>(status),
      'attempts': serializer.toJson<int>(attempts),
      'resultJson': serializer.toJson<String?>(resultJson),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LlmJob copyWith({
    int? id,
    String? jobType,
    String? payloadJson,
    String? status,
    int? attempts,
    Value<String?> resultJson = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LlmJob(
    id: id ?? this.id,
    jobType: jobType ?? this.jobType,
    payloadJson: payloadJson ?? this.payloadJson,
    status: status ?? this.status,
    attempts: attempts ?? this.attempts,
    resultJson: resultJson.present ? resultJson.value : this.resultJson,
    lastError: lastError.present ? lastError.value : this.lastError,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LlmJob copyWithCompanion(LlmJobsCompanion data) {
    return LlmJob(
      id: data.id.present ? data.id.value : this.id,
      jobType: data.jobType.present ? data.jobType.value : this.jobType,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      status: data.status.present ? data.status.value : this.status,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      resultJson: data.resultJson.present
          ? data.resultJson.value
          : this.resultJson,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LlmJob(')
          ..write('id: $id, ')
          ..write('jobType: $jobType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('status: $status, ')
          ..write('attempts: $attempts, ')
          ..write('resultJson: $resultJson, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    jobType,
    payloadJson,
    status,
    attempts,
    resultJson,
    lastError,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LlmJob &&
          other.id == this.id &&
          other.jobType == this.jobType &&
          other.payloadJson == this.payloadJson &&
          other.status == this.status &&
          other.attempts == this.attempts &&
          other.resultJson == this.resultJson &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LlmJobsCompanion extends UpdateCompanion<LlmJob> {
  final Value<int> id;
  final Value<String> jobType;
  final Value<String> payloadJson;
  final Value<String> status;
  final Value<int> attempts;
  final Value<String?> resultJson;
  final Value<String?> lastError;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const LlmJobsCompanion({
    this.id = const Value.absent(),
    this.jobType = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.status = const Value.absent(),
    this.attempts = const Value.absent(),
    this.resultJson = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  LlmJobsCompanion.insert({
    this.id = const Value.absent(),
    required String jobType,
    required String payloadJson,
    this.status = const Value.absent(),
    this.attempts = const Value.absent(),
    this.resultJson = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : jobType = Value(jobType),
       payloadJson = Value(payloadJson);
  static Insertable<LlmJob> custom({
    Expression<int>? id,
    Expression<String>? jobType,
    Expression<String>? payloadJson,
    Expression<String>? status,
    Expression<int>? attempts,
    Expression<String>? resultJson,
    Expression<String>? lastError,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (jobType != null) 'job_type': jobType,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (status != null) 'status': status,
      if (attempts != null) 'attempts': attempts,
      if (resultJson != null) 'result_json': resultJson,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  LlmJobsCompanion copyWith({
    Value<int>? id,
    Value<String>? jobType,
    Value<String>? payloadJson,
    Value<String>? status,
    Value<int>? attempts,
    Value<String?>? resultJson,
    Value<String?>? lastError,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return LlmJobsCompanion(
      id: id ?? this.id,
      jobType: jobType ?? this.jobType,
      payloadJson: payloadJson ?? this.payloadJson,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      resultJson: resultJson ?? this.resultJson,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (jobType.present) {
      map['job_type'] = Variable<String>(jobType.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (resultJson.present) {
      map['result_json'] = Variable<String>(resultJson.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LlmJobsCompanion(')
          ..write('id: $id, ')
          ..write('jobType: $jobType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('status: $status, ')
          ..write('attempts: $attempts, ')
          ..write('resultJson: $resultJson, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $LlmReviewItemsTable extends LlmReviewItems
    with TableInfo<$LlmReviewItemsTable, LlmReviewItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LlmReviewItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _unparsedSmsIdMeta = const VerificationMeta(
    'unparsedSmsId',
  );
  @override
  late final GeneratedColumn<int> unparsedSmsId = GeneratedColumn<int>(
    'unparsed_sms_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES unparsed_sms_rows (id)',
    ),
  );
  static const VerificationMeta _unparsedStatementRowIdMeta =
      const VerificationMeta('unparsedStatementRowId');
  @override
  late final GeneratedColumn<int> unparsedStatementRowId = GeneratedColumn<int>(
    'unparsed_statement_row_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES unparsed_statement_rows (id)',
    ),
  );
  static const VerificationMeta _rawTextMeta = const VerificationMeta(
    'rawText',
  );
  @override
  late final GeneratedColumn<String> rawText = GeneratedColumn<String>(
    'raw_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _suggestedJsonMeta = const VerificationMeta(
    'suggestedJson',
  );
  @override
  late final GeneratedColumn<String> suggestedJson = GeneratedColumn<String>(
    'suggested_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _anchorReportJsonMeta = const VerificationMeta(
    'anchorReportJson',
  );
  @override
  late final GeneratedColumn<String> anchorReportJson = GeneratedColumn<String>(
    'anchor_report_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<int> transactionId = GeneratedColumn<int>(
    'transaction_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES transactions (id)',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    unparsedSmsId,
    unparsedStatementRowId,
    rawText,
    suggestedJson,
    anchorReportJson,
    status,
    transactionId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'llm_review_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<LlmReviewItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('unparsed_sms_id')) {
      context.handle(
        _unparsedSmsIdMeta,
        unparsedSmsId.isAcceptableOrUnknown(
          data['unparsed_sms_id']!,
          _unparsedSmsIdMeta,
        ),
      );
    }
    if (data.containsKey('unparsed_statement_row_id')) {
      context.handle(
        _unparsedStatementRowIdMeta,
        unparsedStatementRowId.isAcceptableOrUnknown(
          data['unparsed_statement_row_id']!,
          _unparsedStatementRowIdMeta,
        ),
      );
    }
    if (data.containsKey('raw_text')) {
      context.handle(
        _rawTextMeta,
        rawText.isAcceptableOrUnknown(data['raw_text']!, _rawTextMeta),
      );
    } else if (isInserting) {
      context.missing(_rawTextMeta);
    }
    if (data.containsKey('suggested_json')) {
      context.handle(
        _suggestedJsonMeta,
        suggestedJson.isAcceptableOrUnknown(
          data['suggested_json']!,
          _suggestedJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_suggestedJsonMeta);
    }
    if (data.containsKey('anchor_report_json')) {
      context.handle(
        _anchorReportJsonMeta,
        anchorReportJson.isAcceptableOrUnknown(
          data['anchor_report_json']!,
          _anchorReportJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_anchorReportJsonMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LlmReviewItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LlmReviewItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      unparsedSmsId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unparsed_sms_id'],
      ),
      unparsedStatementRowId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unparsed_statement_row_id'],
      ),
      rawText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_text'],
      )!,
      suggestedJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}suggested_json'],
      )!,
      anchorReportJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}anchor_report_json'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transaction_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LlmReviewItemsTable createAlias(String alias) {
    return $LlmReviewItemsTable(attachedDatabase, alias);
  }
}

class LlmReviewItem extends DataClass implements Insertable<LlmReviewItem> {
  final int id;
  final int? unparsedSmsId;
  final int? unparsedStatementRowId;
  final String rawText;
  final String suggestedJson;
  final String anchorReportJson;

  /// pending | confirmed | discarded | unresolvable_v1
  final String status;
  final int? transactionId;
  final DateTime createdAt;
  const LlmReviewItem({
    required this.id,
    this.unparsedSmsId,
    this.unparsedStatementRowId,
    required this.rawText,
    required this.suggestedJson,
    required this.anchorReportJson,
    required this.status,
    this.transactionId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || unparsedSmsId != null) {
      map['unparsed_sms_id'] = Variable<int>(unparsedSmsId);
    }
    if (!nullToAbsent || unparsedStatementRowId != null) {
      map['unparsed_statement_row_id'] = Variable<int>(unparsedStatementRowId);
    }
    map['raw_text'] = Variable<String>(rawText);
    map['suggested_json'] = Variable<String>(suggestedJson);
    map['anchor_report_json'] = Variable<String>(anchorReportJson);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || transactionId != null) {
      map['transaction_id'] = Variable<int>(transactionId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LlmReviewItemsCompanion toCompanion(bool nullToAbsent) {
    return LlmReviewItemsCompanion(
      id: Value(id),
      unparsedSmsId: unparsedSmsId == null && nullToAbsent
          ? const Value.absent()
          : Value(unparsedSmsId),
      unparsedStatementRowId: unparsedStatementRowId == null && nullToAbsent
          ? const Value.absent()
          : Value(unparsedStatementRowId),
      rawText: Value(rawText),
      suggestedJson: Value(suggestedJson),
      anchorReportJson: Value(anchorReportJson),
      status: Value(status),
      transactionId: transactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionId),
      createdAt: Value(createdAt),
    );
  }

  factory LlmReviewItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LlmReviewItem(
      id: serializer.fromJson<int>(json['id']),
      unparsedSmsId: serializer.fromJson<int?>(json['unparsedSmsId']),
      unparsedStatementRowId: serializer.fromJson<int?>(
        json['unparsedStatementRowId'],
      ),
      rawText: serializer.fromJson<String>(json['rawText']),
      suggestedJson: serializer.fromJson<String>(json['suggestedJson']),
      anchorReportJson: serializer.fromJson<String>(json['anchorReportJson']),
      status: serializer.fromJson<String>(json['status']),
      transactionId: serializer.fromJson<int?>(json['transactionId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'unparsedSmsId': serializer.toJson<int?>(unparsedSmsId),
      'unparsedStatementRowId': serializer.toJson<int?>(unparsedStatementRowId),
      'rawText': serializer.toJson<String>(rawText),
      'suggestedJson': serializer.toJson<String>(suggestedJson),
      'anchorReportJson': serializer.toJson<String>(anchorReportJson),
      'status': serializer.toJson<String>(status),
      'transactionId': serializer.toJson<int?>(transactionId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LlmReviewItem copyWith({
    int? id,
    Value<int?> unparsedSmsId = const Value.absent(),
    Value<int?> unparsedStatementRowId = const Value.absent(),
    String? rawText,
    String? suggestedJson,
    String? anchorReportJson,
    String? status,
    Value<int?> transactionId = const Value.absent(),
    DateTime? createdAt,
  }) => LlmReviewItem(
    id: id ?? this.id,
    unparsedSmsId: unparsedSmsId.present
        ? unparsedSmsId.value
        : this.unparsedSmsId,
    unparsedStatementRowId: unparsedStatementRowId.present
        ? unparsedStatementRowId.value
        : this.unparsedStatementRowId,
    rawText: rawText ?? this.rawText,
    suggestedJson: suggestedJson ?? this.suggestedJson,
    anchorReportJson: anchorReportJson ?? this.anchorReportJson,
    status: status ?? this.status,
    transactionId: transactionId.present
        ? transactionId.value
        : this.transactionId,
    createdAt: createdAt ?? this.createdAt,
  );
  LlmReviewItem copyWithCompanion(LlmReviewItemsCompanion data) {
    return LlmReviewItem(
      id: data.id.present ? data.id.value : this.id,
      unparsedSmsId: data.unparsedSmsId.present
          ? data.unparsedSmsId.value
          : this.unparsedSmsId,
      unparsedStatementRowId: data.unparsedStatementRowId.present
          ? data.unparsedStatementRowId.value
          : this.unparsedStatementRowId,
      rawText: data.rawText.present ? data.rawText.value : this.rawText,
      suggestedJson: data.suggestedJson.present
          ? data.suggestedJson.value
          : this.suggestedJson,
      anchorReportJson: data.anchorReportJson.present
          ? data.anchorReportJson.value
          : this.anchorReportJson,
      status: data.status.present ? data.status.value : this.status,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LlmReviewItem(')
          ..write('id: $id, ')
          ..write('unparsedSmsId: $unparsedSmsId, ')
          ..write('unparsedStatementRowId: $unparsedStatementRowId, ')
          ..write('rawText: $rawText, ')
          ..write('suggestedJson: $suggestedJson, ')
          ..write('anchorReportJson: $anchorReportJson, ')
          ..write('status: $status, ')
          ..write('transactionId: $transactionId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    unparsedSmsId,
    unparsedStatementRowId,
    rawText,
    suggestedJson,
    anchorReportJson,
    status,
    transactionId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LlmReviewItem &&
          other.id == this.id &&
          other.unparsedSmsId == this.unparsedSmsId &&
          other.unparsedStatementRowId == this.unparsedStatementRowId &&
          other.rawText == this.rawText &&
          other.suggestedJson == this.suggestedJson &&
          other.anchorReportJson == this.anchorReportJson &&
          other.status == this.status &&
          other.transactionId == this.transactionId &&
          other.createdAt == this.createdAt);
}

class LlmReviewItemsCompanion extends UpdateCompanion<LlmReviewItem> {
  final Value<int> id;
  final Value<int?> unparsedSmsId;
  final Value<int?> unparsedStatementRowId;
  final Value<String> rawText;
  final Value<String> suggestedJson;
  final Value<String> anchorReportJson;
  final Value<String> status;
  final Value<int?> transactionId;
  final Value<DateTime> createdAt;
  const LlmReviewItemsCompanion({
    this.id = const Value.absent(),
    this.unparsedSmsId = const Value.absent(),
    this.unparsedStatementRowId = const Value.absent(),
    this.rawText = const Value.absent(),
    this.suggestedJson = const Value.absent(),
    this.anchorReportJson = const Value.absent(),
    this.status = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  LlmReviewItemsCompanion.insert({
    this.id = const Value.absent(),
    this.unparsedSmsId = const Value.absent(),
    this.unparsedStatementRowId = const Value.absent(),
    required String rawText,
    required String suggestedJson,
    required String anchorReportJson,
    this.status = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : rawText = Value(rawText),
       suggestedJson = Value(suggestedJson),
       anchorReportJson = Value(anchorReportJson);
  static Insertable<LlmReviewItem> custom({
    Expression<int>? id,
    Expression<int>? unparsedSmsId,
    Expression<int>? unparsedStatementRowId,
    Expression<String>? rawText,
    Expression<String>? suggestedJson,
    Expression<String>? anchorReportJson,
    Expression<String>? status,
    Expression<int>? transactionId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (unparsedSmsId != null) 'unparsed_sms_id': unparsedSmsId,
      if (unparsedStatementRowId != null)
        'unparsed_statement_row_id': unparsedStatementRowId,
      if (rawText != null) 'raw_text': rawText,
      if (suggestedJson != null) 'suggested_json': suggestedJson,
      if (anchorReportJson != null) 'anchor_report_json': anchorReportJson,
      if (status != null) 'status': status,
      if (transactionId != null) 'transaction_id': transactionId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  LlmReviewItemsCompanion copyWith({
    Value<int>? id,
    Value<int?>? unparsedSmsId,
    Value<int?>? unparsedStatementRowId,
    Value<String>? rawText,
    Value<String>? suggestedJson,
    Value<String>? anchorReportJson,
    Value<String>? status,
    Value<int?>? transactionId,
    Value<DateTime>? createdAt,
  }) {
    return LlmReviewItemsCompanion(
      id: id ?? this.id,
      unparsedSmsId: unparsedSmsId ?? this.unparsedSmsId,
      unparsedStatementRowId:
          unparsedStatementRowId ?? this.unparsedStatementRowId,
      rawText: rawText ?? this.rawText,
      suggestedJson: suggestedJson ?? this.suggestedJson,
      anchorReportJson: anchorReportJson ?? this.anchorReportJson,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (unparsedSmsId.present) {
      map['unparsed_sms_id'] = Variable<int>(unparsedSmsId.value);
    }
    if (unparsedStatementRowId.present) {
      map['unparsed_statement_row_id'] = Variable<int>(
        unparsedStatementRowId.value,
      );
    }
    if (rawText.present) {
      map['raw_text'] = Variable<String>(rawText.value);
    }
    if (suggestedJson.present) {
      map['suggested_json'] = Variable<String>(suggestedJson.value);
    }
    if (anchorReportJson.present) {
      map['anchor_report_json'] = Variable<String>(anchorReportJson.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<int>(transactionId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LlmReviewItemsCompanion(')
          ..write('id: $id, ')
          ..write('unparsedSmsId: $unparsedSmsId, ')
          ..write('unparsedStatementRowId: $unparsedStatementRowId, ')
          ..write('rawText: $rawText, ')
          ..write('suggestedJson: $suggestedJson, ')
          ..write('anchorReportJson: $anchorReportJson, ')
          ..write('status: $status, ')
          ..write('transactionId: $transactionId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $BudgetsTable extends Budgets with TableInfo<$BudgetsTable, Budget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'UNIQUE REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _limitPaiseMeta = const VerificationMeta(
    'limitPaise',
  );
  @override
  late final GeneratedColumn<int> limitPaise = GeneratedColumn<int>(
    'limit_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rolloverMeta = const VerificationMeta(
    'rollover',
  );
  @override
  late final GeneratedColumn<bool> rollover = GeneratedColumn<bool>(
    'rollover',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("rollover" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _startMonthMeta = const VerificationMeta(
    'startMonth',
  );
  @override
  late final GeneratedColumn<String> startMonth = GeneratedColumn<String>(
    'start_month',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    categoryId,
    limitPaise,
    rollover,
    startMonth,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budgets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Budget> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('limit_paise')) {
      context.handle(
        _limitPaiseMeta,
        limitPaise.isAcceptableOrUnknown(data['limit_paise']!, _limitPaiseMeta),
      );
    } else if (isInserting) {
      context.missing(_limitPaiseMeta);
    }
    if (data.containsKey('rollover')) {
      context.handle(
        _rolloverMeta,
        rollover.isAcceptableOrUnknown(data['rollover']!, _rolloverMeta),
      );
    }
    if (data.containsKey('start_month')) {
      context.handle(
        _startMonthMeta,
        startMonth.isAcceptableOrUnknown(data['start_month']!, _startMonthMeta),
      );
    } else if (isInserting) {
      context.missing(_startMonthMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Budget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Budget(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
      limitPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}limit_paise'],
      )!,
      rollover: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}rollover'],
      )!,
      startMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_month'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $BudgetsTable createAlias(String alias) {
    return $BudgetsTable(attachedDatabase, alias);
  }
}

class Budget extends DataClass implements Insertable<Budget> {
  final int id;
  final int categoryId;
  final int limitPaise;

  /// Envelope mode: unspent / overspent amounts carry into the next month.
  final bool rollover;

  /// First month (yyyy-MM) the budget applies to.
  final String startMonth;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Budget({
    required this.id,
    required this.categoryId,
    required this.limitPaise,
    required this.rollover,
    required this.startMonth,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['category_id'] = Variable<int>(categoryId);
    map['limit_paise'] = Variable<int>(limitPaise);
    map['rollover'] = Variable<bool>(rollover);
    map['start_month'] = Variable<String>(startMonth);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  BudgetsCompanion toCompanion(bool nullToAbsent) {
    return BudgetsCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      limitPaise: Value(limitPaise),
      rollover: Value(rollover),
      startMonth: Value(startMonth),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Budget.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Budget(
      id: serializer.fromJson<int>(json['id']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      limitPaise: serializer.fromJson<int>(json['limitPaise']),
      rollover: serializer.fromJson<bool>(json['rollover']),
      startMonth: serializer.fromJson<String>(json['startMonth']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'categoryId': serializer.toJson<int>(categoryId),
      'limitPaise': serializer.toJson<int>(limitPaise),
      'rollover': serializer.toJson<bool>(rollover),
      'startMonth': serializer.toJson<String>(startMonth),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Budget copyWith({
    int? id,
    int? categoryId,
    int? limitPaise,
    bool? rollover,
    String? startMonth,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Budget(
    id: id ?? this.id,
    categoryId: categoryId ?? this.categoryId,
    limitPaise: limitPaise ?? this.limitPaise,
    rollover: rollover ?? this.rollover,
    startMonth: startMonth ?? this.startMonth,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Budget copyWithCompanion(BudgetsCompanion data) {
    return Budget(
      id: data.id.present ? data.id.value : this.id,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      limitPaise: data.limitPaise.present
          ? data.limitPaise.value
          : this.limitPaise,
      rollover: data.rollover.present ? data.rollover.value : this.rollover,
      startMonth: data.startMonth.present
          ? data.startMonth.value
          : this.startMonth,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Budget(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('limitPaise: $limitPaise, ')
          ..write('rollover: $rollover, ')
          ..write('startMonth: $startMonth, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    categoryId,
    limitPaise,
    rollover,
    startMonth,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Budget &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.limitPaise == this.limitPaise &&
          other.rollover == this.rollover &&
          other.startMonth == this.startMonth &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BudgetsCompanion extends UpdateCompanion<Budget> {
  final Value<int> id;
  final Value<int> categoryId;
  final Value<int> limitPaise;
  final Value<bool> rollover;
  final Value<String> startMonth;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const BudgetsCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.limitPaise = const Value.absent(),
    this.rollover = const Value.absent(),
    this.startMonth = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  BudgetsCompanion.insert({
    this.id = const Value.absent(),
    required int categoryId,
    required int limitPaise,
    this.rollover = const Value.absent(),
    required String startMonth,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : categoryId = Value(categoryId),
       limitPaise = Value(limitPaise),
       startMonth = Value(startMonth);
  static Insertable<Budget> custom({
    Expression<int>? id,
    Expression<int>? categoryId,
    Expression<int>? limitPaise,
    Expression<bool>? rollover,
    Expression<String>? startMonth,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (limitPaise != null) 'limit_paise': limitPaise,
      if (rollover != null) 'rollover': rollover,
      if (startMonth != null) 'start_month': startMonth,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  BudgetsCompanion copyWith({
    Value<int>? id,
    Value<int>? categoryId,
    Value<int>? limitPaise,
    Value<bool>? rollover,
    Value<String>? startMonth,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return BudgetsCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      limitPaise: limitPaise ?? this.limitPaise,
      rollover: rollover ?? this.rollover,
      startMonth: startMonth ?? this.startMonth,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (limitPaise.present) {
      map['limit_paise'] = Variable<int>(limitPaise.value);
    }
    if (rollover.present) {
      map['rollover'] = Variable<bool>(rollover.value);
    }
    if (startMonth.present) {
      map['start_month'] = Variable<String>(startMonth.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetsCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('limitPaise: $limitPaise, ')
          ..write('rollover: $rollover, ')
          ..write('startMonth: $startMonth, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $StatementSummariesTable extends StatementSummaries
    with TableInfo<$StatementSummariesTable, StatementSummaryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StatementSummariesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _importIdMeta = const VerificationMeta(
    'importId',
  );
  @override
  late final GeneratedColumn<int> importId = GeneratedColumn<int>(
    'import_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'UNIQUE REFERENCES imports (id)',
    ),
  );
  static const VerificationMeta _bankCodeMeta = const VerificationMeta(
    'bankCode',
  );
  @override
  late final GeneratedColumn<String> bankCode = GeneratedColumn<String>(
    'bank_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountKindMeta = const VerificationMeta(
    'accountKind',
  );
  @override
  late final GeneratedColumn<String> accountKind = GeneratedColumn<String>(
    'account_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _last4Meta = const VerificationMeta('last4');
  @override
  late final GeneratedColumn<String> last4 = GeneratedColumn<String>(
    'last4',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statementDateMeta = const VerificationMeta(
    'statementDate',
  );
  @override
  late final GeneratedColumn<DateTime> statementDate =
      GeneratedColumn<DateTime>(
        'statement_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalDuePaiseMeta = const VerificationMeta(
    'totalDuePaise',
  );
  @override
  late final GeneratedColumn<int> totalDuePaise = GeneratedColumn<int>(
    'total_due_paise',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _minDuePaiseMeta = const VerificationMeta(
    'minDuePaise',
  );
  @override
  late final GeneratedColumn<int> minDuePaise = GeneratedColumn<int>(
    'min_due_paise',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creditLimitPaiseMeta = const VerificationMeta(
    'creditLimitPaise',
  );
  @override
  late final GeneratedColumn<int> creditLimitPaise = GeneratedColumn<int>(
    'credit_limit_paise',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _periodEndMeta = const VerificationMeta(
    'periodEnd',
  );
  @override
  late final GeneratedColumn<DateTime> periodEnd = GeneratedColumn<DateTime>(
    'period_end',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    importId,
    bankCode,
    accountKind,
    last4,
    statementDate,
    dueDate,
    totalDuePaise,
    minDuePaise,
    creditLimitPaise,
    periodEnd,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'statement_summaries';
  @override
  VerificationContext validateIntegrity(
    Insertable<StatementSummaryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('import_id')) {
      context.handle(
        _importIdMeta,
        importId.isAcceptableOrUnknown(data['import_id']!, _importIdMeta),
      );
    } else if (isInserting) {
      context.missing(_importIdMeta);
    }
    if (data.containsKey('bank_code')) {
      context.handle(
        _bankCodeMeta,
        bankCode.isAcceptableOrUnknown(data['bank_code']!, _bankCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_bankCodeMeta);
    }
    if (data.containsKey('account_kind')) {
      context.handle(
        _accountKindMeta,
        accountKind.isAcceptableOrUnknown(
          data['account_kind']!,
          _accountKindMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accountKindMeta);
    }
    if (data.containsKey('last4')) {
      context.handle(
        _last4Meta,
        last4.isAcceptableOrUnknown(data['last4']!, _last4Meta),
      );
    }
    if (data.containsKey('statement_date')) {
      context.handle(
        _statementDateMeta,
        statementDate.isAcceptableOrUnknown(
          data['statement_date']!,
          _statementDateMeta,
        ),
      );
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('total_due_paise')) {
      context.handle(
        _totalDuePaiseMeta,
        totalDuePaise.isAcceptableOrUnknown(
          data['total_due_paise']!,
          _totalDuePaiseMeta,
        ),
      );
    }
    if (data.containsKey('min_due_paise')) {
      context.handle(
        _minDuePaiseMeta,
        minDuePaise.isAcceptableOrUnknown(
          data['min_due_paise']!,
          _minDuePaiseMeta,
        ),
      );
    }
    if (data.containsKey('credit_limit_paise')) {
      context.handle(
        _creditLimitPaiseMeta,
        creditLimitPaise.isAcceptableOrUnknown(
          data['credit_limit_paise']!,
          _creditLimitPaiseMeta,
        ),
      );
    }
    if (data.containsKey('period_end')) {
      context.handle(
        _periodEndMeta,
        periodEnd.isAcceptableOrUnknown(data['period_end']!, _periodEndMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StatementSummaryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StatementSummaryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      importId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}import_id'],
      )!,
      bankCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bank_code'],
      )!,
      accountKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_kind'],
      )!,
      last4: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last4'],
      ),
      statementDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}statement_date'],
      ),
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      totalDuePaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_due_paise'],
      ),
      minDuePaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_due_paise'],
      ),
      creditLimitPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}credit_limit_paise'],
      ),
      periodEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}period_end'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $StatementSummariesTable createAlias(String alias) {
    return $StatementSummariesTable(attachedDatabase, alias);
  }
}

class StatementSummaryRow extends DataClass
    implements Insertable<StatementSummaryRow> {
  final int id;
  final int importId;
  final String bankCode;

  /// bank | card
  final String accountKind;
  final String? last4;
  final DateTime? statementDate;
  final DateTime? dueDate;
  final int? totalDuePaise;
  final int? minDuePaise;
  final int? creditLimitPaise;

  /// Latest transaction date on the statement (fallback statement date).
  final DateTime? periodEnd;
  final DateTime createdAt;
  const StatementSummaryRow({
    required this.id,
    required this.importId,
    required this.bankCode,
    required this.accountKind,
    this.last4,
    this.statementDate,
    this.dueDate,
    this.totalDuePaise,
    this.minDuePaise,
    this.creditLimitPaise,
    this.periodEnd,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['import_id'] = Variable<int>(importId);
    map['bank_code'] = Variable<String>(bankCode);
    map['account_kind'] = Variable<String>(accountKind);
    if (!nullToAbsent || last4 != null) {
      map['last4'] = Variable<String>(last4);
    }
    if (!nullToAbsent || statementDate != null) {
      map['statement_date'] = Variable<DateTime>(statementDate);
    }
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || totalDuePaise != null) {
      map['total_due_paise'] = Variable<int>(totalDuePaise);
    }
    if (!nullToAbsent || minDuePaise != null) {
      map['min_due_paise'] = Variable<int>(minDuePaise);
    }
    if (!nullToAbsent || creditLimitPaise != null) {
      map['credit_limit_paise'] = Variable<int>(creditLimitPaise);
    }
    if (!nullToAbsent || periodEnd != null) {
      map['period_end'] = Variable<DateTime>(periodEnd);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  StatementSummariesCompanion toCompanion(bool nullToAbsent) {
    return StatementSummariesCompanion(
      id: Value(id),
      importId: Value(importId),
      bankCode: Value(bankCode),
      accountKind: Value(accountKind),
      last4: last4 == null && nullToAbsent
          ? const Value.absent()
          : Value(last4),
      statementDate: statementDate == null && nullToAbsent
          ? const Value.absent()
          : Value(statementDate),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      totalDuePaise: totalDuePaise == null && nullToAbsent
          ? const Value.absent()
          : Value(totalDuePaise),
      minDuePaise: minDuePaise == null && nullToAbsent
          ? const Value.absent()
          : Value(minDuePaise),
      creditLimitPaise: creditLimitPaise == null && nullToAbsent
          ? const Value.absent()
          : Value(creditLimitPaise),
      periodEnd: periodEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(periodEnd),
      createdAt: Value(createdAt),
    );
  }

  factory StatementSummaryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StatementSummaryRow(
      id: serializer.fromJson<int>(json['id']),
      importId: serializer.fromJson<int>(json['importId']),
      bankCode: serializer.fromJson<String>(json['bankCode']),
      accountKind: serializer.fromJson<String>(json['accountKind']),
      last4: serializer.fromJson<String?>(json['last4']),
      statementDate: serializer.fromJson<DateTime?>(json['statementDate']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      totalDuePaise: serializer.fromJson<int?>(json['totalDuePaise']),
      minDuePaise: serializer.fromJson<int?>(json['minDuePaise']),
      creditLimitPaise: serializer.fromJson<int?>(json['creditLimitPaise']),
      periodEnd: serializer.fromJson<DateTime?>(json['periodEnd']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'importId': serializer.toJson<int>(importId),
      'bankCode': serializer.toJson<String>(bankCode),
      'accountKind': serializer.toJson<String>(accountKind),
      'last4': serializer.toJson<String?>(last4),
      'statementDate': serializer.toJson<DateTime?>(statementDate),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'totalDuePaise': serializer.toJson<int?>(totalDuePaise),
      'minDuePaise': serializer.toJson<int?>(minDuePaise),
      'creditLimitPaise': serializer.toJson<int?>(creditLimitPaise),
      'periodEnd': serializer.toJson<DateTime?>(periodEnd),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  StatementSummaryRow copyWith({
    int? id,
    int? importId,
    String? bankCode,
    String? accountKind,
    Value<String?> last4 = const Value.absent(),
    Value<DateTime?> statementDate = const Value.absent(),
    Value<DateTime?> dueDate = const Value.absent(),
    Value<int?> totalDuePaise = const Value.absent(),
    Value<int?> minDuePaise = const Value.absent(),
    Value<int?> creditLimitPaise = const Value.absent(),
    Value<DateTime?> periodEnd = const Value.absent(),
    DateTime? createdAt,
  }) => StatementSummaryRow(
    id: id ?? this.id,
    importId: importId ?? this.importId,
    bankCode: bankCode ?? this.bankCode,
    accountKind: accountKind ?? this.accountKind,
    last4: last4.present ? last4.value : this.last4,
    statementDate: statementDate.present
        ? statementDate.value
        : this.statementDate,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    totalDuePaise: totalDuePaise.present
        ? totalDuePaise.value
        : this.totalDuePaise,
    minDuePaise: minDuePaise.present ? minDuePaise.value : this.minDuePaise,
    creditLimitPaise: creditLimitPaise.present
        ? creditLimitPaise.value
        : this.creditLimitPaise,
    periodEnd: periodEnd.present ? periodEnd.value : this.periodEnd,
    createdAt: createdAt ?? this.createdAt,
  );
  StatementSummaryRow copyWithCompanion(StatementSummariesCompanion data) {
    return StatementSummaryRow(
      id: data.id.present ? data.id.value : this.id,
      importId: data.importId.present ? data.importId.value : this.importId,
      bankCode: data.bankCode.present ? data.bankCode.value : this.bankCode,
      accountKind: data.accountKind.present
          ? data.accountKind.value
          : this.accountKind,
      last4: data.last4.present ? data.last4.value : this.last4,
      statementDate: data.statementDate.present
          ? data.statementDate.value
          : this.statementDate,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      totalDuePaise: data.totalDuePaise.present
          ? data.totalDuePaise.value
          : this.totalDuePaise,
      minDuePaise: data.minDuePaise.present
          ? data.minDuePaise.value
          : this.minDuePaise,
      creditLimitPaise: data.creditLimitPaise.present
          ? data.creditLimitPaise.value
          : this.creditLimitPaise,
      periodEnd: data.periodEnd.present ? data.periodEnd.value : this.periodEnd,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StatementSummaryRow(')
          ..write('id: $id, ')
          ..write('importId: $importId, ')
          ..write('bankCode: $bankCode, ')
          ..write('accountKind: $accountKind, ')
          ..write('last4: $last4, ')
          ..write('statementDate: $statementDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('totalDuePaise: $totalDuePaise, ')
          ..write('minDuePaise: $minDuePaise, ')
          ..write('creditLimitPaise: $creditLimitPaise, ')
          ..write('periodEnd: $periodEnd, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    importId,
    bankCode,
    accountKind,
    last4,
    statementDate,
    dueDate,
    totalDuePaise,
    minDuePaise,
    creditLimitPaise,
    periodEnd,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StatementSummaryRow &&
          other.id == this.id &&
          other.importId == this.importId &&
          other.bankCode == this.bankCode &&
          other.accountKind == this.accountKind &&
          other.last4 == this.last4 &&
          other.statementDate == this.statementDate &&
          other.dueDate == this.dueDate &&
          other.totalDuePaise == this.totalDuePaise &&
          other.minDuePaise == this.minDuePaise &&
          other.creditLimitPaise == this.creditLimitPaise &&
          other.periodEnd == this.periodEnd &&
          other.createdAt == this.createdAt);
}

class StatementSummariesCompanion extends UpdateCompanion<StatementSummaryRow> {
  final Value<int> id;
  final Value<int> importId;
  final Value<String> bankCode;
  final Value<String> accountKind;
  final Value<String?> last4;
  final Value<DateTime?> statementDate;
  final Value<DateTime?> dueDate;
  final Value<int?> totalDuePaise;
  final Value<int?> minDuePaise;
  final Value<int?> creditLimitPaise;
  final Value<DateTime?> periodEnd;
  final Value<DateTime> createdAt;
  const StatementSummariesCompanion({
    this.id = const Value.absent(),
    this.importId = const Value.absent(),
    this.bankCode = const Value.absent(),
    this.accountKind = const Value.absent(),
    this.last4 = const Value.absent(),
    this.statementDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.totalDuePaise = const Value.absent(),
    this.minDuePaise = const Value.absent(),
    this.creditLimitPaise = const Value.absent(),
    this.periodEnd = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  StatementSummariesCompanion.insert({
    this.id = const Value.absent(),
    required int importId,
    required String bankCode,
    required String accountKind,
    this.last4 = const Value.absent(),
    this.statementDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.totalDuePaise = const Value.absent(),
    this.minDuePaise = const Value.absent(),
    this.creditLimitPaise = const Value.absent(),
    this.periodEnd = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : importId = Value(importId),
       bankCode = Value(bankCode),
       accountKind = Value(accountKind);
  static Insertable<StatementSummaryRow> custom({
    Expression<int>? id,
    Expression<int>? importId,
    Expression<String>? bankCode,
    Expression<String>? accountKind,
    Expression<String>? last4,
    Expression<DateTime>? statementDate,
    Expression<DateTime>? dueDate,
    Expression<int>? totalDuePaise,
    Expression<int>? minDuePaise,
    Expression<int>? creditLimitPaise,
    Expression<DateTime>? periodEnd,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (importId != null) 'import_id': importId,
      if (bankCode != null) 'bank_code': bankCode,
      if (accountKind != null) 'account_kind': accountKind,
      if (last4 != null) 'last4': last4,
      if (statementDate != null) 'statement_date': statementDate,
      if (dueDate != null) 'due_date': dueDate,
      if (totalDuePaise != null) 'total_due_paise': totalDuePaise,
      if (minDuePaise != null) 'min_due_paise': minDuePaise,
      if (creditLimitPaise != null) 'credit_limit_paise': creditLimitPaise,
      if (periodEnd != null) 'period_end': periodEnd,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  StatementSummariesCompanion copyWith({
    Value<int>? id,
    Value<int>? importId,
    Value<String>? bankCode,
    Value<String>? accountKind,
    Value<String?>? last4,
    Value<DateTime?>? statementDate,
    Value<DateTime?>? dueDate,
    Value<int?>? totalDuePaise,
    Value<int?>? minDuePaise,
    Value<int?>? creditLimitPaise,
    Value<DateTime?>? periodEnd,
    Value<DateTime>? createdAt,
  }) {
    return StatementSummariesCompanion(
      id: id ?? this.id,
      importId: importId ?? this.importId,
      bankCode: bankCode ?? this.bankCode,
      accountKind: accountKind ?? this.accountKind,
      last4: last4 ?? this.last4,
      statementDate: statementDate ?? this.statementDate,
      dueDate: dueDate ?? this.dueDate,
      totalDuePaise: totalDuePaise ?? this.totalDuePaise,
      minDuePaise: minDuePaise ?? this.minDuePaise,
      creditLimitPaise: creditLimitPaise ?? this.creditLimitPaise,
      periodEnd: periodEnd ?? this.periodEnd,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (importId.present) {
      map['import_id'] = Variable<int>(importId.value);
    }
    if (bankCode.present) {
      map['bank_code'] = Variable<String>(bankCode.value);
    }
    if (accountKind.present) {
      map['account_kind'] = Variable<String>(accountKind.value);
    }
    if (last4.present) {
      map['last4'] = Variable<String>(last4.value);
    }
    if (statementDate.present) {
      map['statement_date'] = Variable<DateTime>(statementDate.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (totalDuePaise.present) {
      map['total_due_paise'] = Variable<int>(totalDuePaise.value);
    }
    if (minDuePaise.present) {
      map['min_due_paise'] = Variable<int>(minDuePaise.value);
    }
    if (creditLimitPaise.present) {
      map['credit_limit_paise'] = Variable<int>(creditLimitPaise.value);
    }
    if (periodEnd.present) {
      map['period_end'] = Variable<DateTime>(periodEnd.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StatementSummariesCompanion(')
          ..write('id: $id, ')
          ..write('importId: $importId, ')
          ..write('bankCode: $bankCode, ')
          ..write('accountKind: $accountKind, ')
          ..write('last4: $last4, ')
          ..write('statementDate: $statementDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('totalDuePaise: $totalDuePaise, ')
          ..write('minDuePaise: $minDuePaise, ')
          ..write('creditLimitPaise: $creditLimitPaise, ')
          ..write('periodEnd: $periodEnd, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CreditCardsTable extends CreditCards
    with TableInfo<$CreditCardsTable, CreditCard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CreditCardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bankCodeMeta = const VerificationMeta(
    'bankCode',
  );
  @override
  late final GeneratedColumn<String> bankCode = GeneratedColumn<String>(
    'bank_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _last4Meta = const VerificationMeta('last4');
  @override
  late final GeneratedColumn<String> last4 = GeneratedColumn<String>(
    'last4',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _creditLimitPaiseMeta = const VerificationMeta(
    'creditLimitPaise',
  );
  @override
  late final GeneratedColumn<int> creditLimitPaise = GeneratedColumn<int>(
    'credit_limit_paise',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statementDayMeta = const VerificationMeta(
    'statementDay',
  );
  @override
  late final GeneratedColumn<int> statementDay = GeneratedColumn<int>(
    'statement_day',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dueDayMeta = const VerificationMeta('dueDay');
  @override
  late final GeneratedColumn<int> dueDay = GeneratedColumn<int>(
    'due_day',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bankCode,
    last4,
    name,
    creditLimitPaise,
    statementDay,
    dueDay,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'credit_cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<CreditCard> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('bank_code')) {
      context.handle(
        _bankCodeMeta,
        bankCode.isAcceptableOrUnknown(data['bank_code']!, _bankCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_bankCodeMeta);
    }
    if (data.containsKey('last4')) {
      context.handle(
        _last4Meta,
        last4.isAcceptableOrUnknown(data['last4']!, _last4Meta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('credit_limit_paise')) {
      context.handle(
        _creditLimitPaiseMeta,
        creditLimitPaise.isAcceptableOrUnknown(
          data['credit_limit_paise']!,
          _creditLimitPaiseMeta,
        ),
      );
    }
    if (data.containsKey('statement_day')) {
      context.handle(
        _statementDayMeta,
        statementDay.isAcceptableOrUnknown(
          data['statement_day']!,
          _statementDayMeta,
        ),
      );
    }
    if (data.containsKey('due_day')) {
      context.handle(
        _dueDayMeta,
        dueDay.isAcceptableOrUnknown(data['due_day']!, _dueDayMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {bankCode, last4},
  ];
  @override
  CreditCard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CreditCard(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bankCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bank_code'],
      )!,
      last4: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last4'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      creditLimitPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}credit_limit_paise'],
      ),
      statementDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}statement_day'],
      ),
      dueDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}due_day'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CreditCardsTable createAlias(String alias) {
    return $CreditCardsTable(attachedDatabase, alias);
  }
}

class CreditCard extends DataClass implements Insertable<CreditCard> {
  final int id;
  final String bankCode;

  /// Last four digits; null matches the bank's card rows without a number.
  final String? last4;
  final String name;
  final int? creditLimitPaise;

  /// Day of month the statement is generated (1–31).
  final int? statementDay;

  /// Day of month payment is due (1–31).
  final int? dueDay;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CreditCard({
    required this.id,
    required this.bankCode,
    this.last4,
    required this.name,
    this.creditLimitPaise,
    this.statementDay,
    this.dueDay,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['bank_code'] = Variable<String>(bankCode);
    if (!nullToAbsent || last4 != null) {
      map['last4'] = Variable<String>(last4);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || creditLimitPaise != null) {
      map['credit_limit_paise'] = Variable<int>(creditLimitPaise);
    }
    if (!nullToAbsent || statementDay != null) {
      map['statement_day'] = Variable<int>(statementDay);
    }
    if (!nullToAbsent || dueDay != null) {
      map['due_day'] = Variable<int>(dueDay);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CreditCardsCompanion toCompanion(bool nullToAbsent) {
    return CreditCardsCompanion(
      id: Value(id),
      bankCode: Value(bankCode),
      last4: last4 == null && nullToAbsent
          ? const Value.absent()
          : Value(last4),
      name: Value(name),
      creditLimitPaise: creditLimitPaise == null && nullToAbsent
          ? const Value.absent()
          : Value(creditLimitPaise),
      statementDay: statementDay == null && nullToAbsent
          ? const Value.absent()
          : Value(statementDay),
      dueDay: dueDay == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDay),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CreditCard.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CreditCard(
      id: serializer.fromJson<int>(json['id']),
      bankCode: serializer.fromJson<String>(json['bankCode']),
      last4: serializer.fromJson<String?>(json['last4']),
      name: serializer.fromJson<String>(json['name']),
      creditLimitPaise: serializer.fromJson<int?>(json['creditLimitPaise']),
      statementDay: serializer.fromJson<int?>(json['statementDay']),
      dueDay: serializer.fromJson<int?>(json['dueDay']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bankCode': serializer.toJson<String>(bankCode),
      'last4': serializer.toJson<String?>(last4),
      'name': serializer.toJson<String>(name),
      'creditLimitPaise': serializer.toJson<int?>(creditLimitPaise),
      'statementDay': serializer.toJson<int?>(statementDay),
      'dueDay': serializer.toJson<int?>(dueDay),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CreditCard copyWith({
    int? id,
    String? bankCode,
    Value<String?> last4 = const Value.absent(),
    String? name,
    Value<int?> creditLimitPaise = const Value.absent(),
    Value<int?> statementDay = const Value.absent(),
    Value<int?> dueDay = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CreditCard(
    id: id ?? this.id,
    bankCode: bankCode ?? this.bankCode,
    last4: last4.present ? last4.value : this.last4,
    name: name ?? this.name,
    creditLimitPaise: creditLimitPaise.present
        ? creditLimitPaise.value
        : this.creditLimitPaise,
    statementDay: statementDay.present ? statementDay.value : this.statementDay,
    dueDay: dueDay.present ? dueDay.value : this.dueDay,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CreditCard copyWithCompanion(CreditCardsCompanion data) {
    return CreditCard(
      id: data.id.present ? data.id.value : this.id,
      bankCode: data.bankCode.present ? data.bankCode.value : this.bankCode,
      last4: data.last4.present ? data.last4.value : this.last4,
      name: data.name.present ? data.name.value : this.name,
      creditLimitPaise: data.creditLimitPaise.present
          ? data.creditLimitPaise.value
          : this.creditLimitPaise,
      statementDay: data.statementDay.present
          ? data.statementDay.value
          : this.statementDay,
      dueDay: data.dueDay.present ? data.dueDay.value : this.dueDay,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CreditCard(')
          ..write('id: $id, ')
          ..write('bankCode: $bankCode, ')
          ..write('last4: $last4, ')
          ..write('name: $name, ')
          ..write('creditLimitPaise: $creditLimitPaise, ')
          ..write('statementDay: $statementDay, ')
          ..write('dueDay: $dueDay, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bankCode,
    last4,
    name,
    creditLimitPaise,
    statementDay,
    dueDay,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CreditCard &&
          other.id == this.id &&
          other.bankCode == this.bankCode &&
          other.last4 == this.last4 &&
          other.name == this.name &&
          other.creditLimitPaise == this.creditLimitPaise &&
          other.statementDay == this.statementDay &&
          other.dueDay == this.dueDay &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CreditCardsCompanion extends UpdateCompanion<CreditCard> {
  final Value<int> id;
  final Value<String> bankCode;
  final Value<String?> last4;
  final Value<String> name;
  final Value<int?> creditLimitPaise;
  final Value<int?> statementDay;
  final Value<int?> dueDay;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const CreditCardsCompanion({
    this.id = const Value.absent(),
    this.bankCode = const Value.absent(),
    this.last4 = const Value.absent(),
    this.name = const Value.absent(),
    this.creditLimitPaise = const Value.absent(),
    this.statementDay = const Value.absent(),
    this.dueDay = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CreditCardsCompanion.insert({
    this.id = const Value.absent(),
    required String bankCode,
    this.last4 = const Value.absent(),
    required String name,
    this.creditLimitPaise = const Value.absent(),
    this.statementDay = const Value.absent(),
    this.dueDay = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : bankCode = Value(bankCode),
       name = Value(name);
  static Insertable<CreditCard> custom({
    Expression<int>? id,
    Expression<String>? bankCode,
    Expression<String>? last4,
    Expression<String>? name,
    Expression<int>? creditLimitPaise,
    Expression<int>? statementDay,
    Expression<int>? dueDay,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bankCode != null) 'bank_code': bankCode,
      if (last4 != null) 'last4': last4,
      if (name != null) 'name': name,
      if (creditLimitPaise != null) 'credit_limit_paise': creditLimitPaise,
      if (statementDay != null) 'statement_day': statementDay,
      if (dueDay != null) 'due_day': dueDay,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CreditCardsCompanion copyWith({
    Value<int>? id,
    Value<String>? bankCode,
    Value<String?>? last4,
    Value<String>? name,
    Value<int?>? creditLimitPaise,
    Value<int?>? statementDay,
    Value<int?>? dueDay,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return CreditCardsCompanion(
      id: id ?? this.id,
      bankCode: bankCode ?? this.bankCode,
      last4: last4 ?? this.last4,
      name: name ?? this.name,
      creditLimitPaise: creditLimitPaise ?? this.creditLimitPaise,
      statementDay: statementDay ?? this.statementDay,
      dueDay: dueDay ?? this.dueDay,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bankCode.present) {
      map['bank_code'] = Variable<String>(bankCode.value);
    }
    if (last4.present) {
      map['last4'] = Variable<String>(last4.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (creditLimitPaise.present) {
      map['credit_limit_paise'] = Variable<int>(creditLimitPaise.value);
    }
    if (statementDay.present) {
      map['statement_day'] = Variable<int>(statementDay.value);
    }
    if (dueDay.present) {
      map['due_day'] = Variable<int>(dueDay.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CreditCardsCompanion(')
          ..write('id: $id, ')
          ..write('bankCode: $bankCode, ')
          ..write('last4: $last4, ')
          ..write('name: $name, ')
          ..write('creditLimitPaise: $creditLimitPaise, ')
          ..write('statementDay: $statementDay, ')
          ..write('dueDay: $dueDay, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $GoalsTable extends Goals with TableInfo<$GoalsTable, Goal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetPaiseMeta = const VerificationMeta(
    'targetPaise',
  );
  @override
  late final GeneratedColumn<int> targetPaise = GeneratedColumn<int>(
    'target_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetDateMeta = const VerificationMeta(
    'targetDate',
  );
  @override
  late final GeneratedColumn<DateTime> targetDate = GeneratedColumn<DateTime>(
    'target_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startPaiseMeta = const VerificationMeta(
    'startPaise',
  );
  @override
  late final GeneratedColumn<int> startPaise = GeneratedColumn<int>(
    'start_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _annualReturnBpMeta = const VerificationMeta(
    'annualReturnBp',
  );
  @override
  late final GeneratedColumn<int> annualReturnBp = GeneratedColumn<int>(
    'annual_return_bp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _sourceRefMeta = const VerificationMeta(
    'sourceRef',
  );
  @override
  late final GeneratedColumn<String> sourceRef = GeneratedColumn<String>(
    'source_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    targetPaise,
    targetDate,
    startDate,
    startPaise,
    annualReturnBp,
    source,
    sourceRef,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<Goal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('target_paise')) {
      context.handle(
        _targetPaiseMeta,
        targetPaise.isAcceptableOrUnknown(
          data['target_paise']!,
          _targetPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetPaiseMeta);
    }
    if (data.containsKey('target_date')) {
      context.handle(
        _targetDateMeta,
        targetDate.isAcceptableOrUnknown(data['target_date']!, _targetDateMeta),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('start_paise')) {
      context.handle(
        _startPaiseMeta,
        startPaise.isAcceptableOrUnknown(data['start_paise']!, _startPaiseMeta),
      );
    }
    if (data.containsKey('annual_return_bp')) {
      context.handle(
        _annualReturnBpMeta,
        annualReturnBp.isAcceptableOrUnknown(
          data['annual_return_bp']!,
          _annualReturnBpMeta,
        ),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('source_ref')) {
      context.handle(
        _sourceRefMeta,
        sourceRef.isAcceptableOrUnknown(data['source_ref']!, _sourceRefMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Goal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Goal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      targetPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_paise'],
      )!,
      targetDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}target_date'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      startPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_paise'],
      )!,
      annualReturnBp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}annual_return_bp'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      sourceRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_ref'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $GoalsTable createAlias(String alias) {
    return $GoalsTable(attachedDatabase, alias);
  }
}

class Goal extends DataClass implements Insertable<Goal> {
  final int id;
  final String name;
  final int targetPaise;
  final DateTime? targetDate;
  final DateTime startDate;
  final int startPaise;

  /// Expected yearly return in basis points (700 = 7%).
  final int annualReturnBp;

  /// manual | account | category
  final String source;

  /// account: `BANK|last4`; category: slug.
  final String? sourceRef;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Goal({
    required this.id,
    required this.name,
    required this.targetPaise,
    this.targetDate,
    required this.startDate,
    required this.startPaise,
    required this.annualReturnBp,
    required this.source,
    this.sourceRef,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['target_paise'] = Variable<int>(targetPaise);
    if (!nullToAbsent || targetDate != null) {
      map['target_date'] = Variable<DateTime>(targetDate);
    }
    map['start_date'] = Variable<DateTime>(startDate);
    map['start_paise'] = Variable<int>(startPaise);
    map['annual_return_bp'] = Variable<int>(annualReturnBp);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || sourceRef != null) {
      map['source_ref'] = Variable<String>(sourceRef);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  GoalsCompanion toCompanion(bool nullToAbsent) {
    return GoalsCompanion(
      id: Value(id),
      name: Value(name),
      targetPaise: Value(targetPaise),
      targetDate: targetDate == null && nullToAbsent
          ? const Value.absent()
          : Value(targetDate),
      startDate: Value(startDate),
      startPaise: Value(startPaise),
      annualReturnBp: Value(annualReturnBp),
      source: Value(source),
      sourceRef: sourceRef == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceRef),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Goal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Goal(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      targetPaise: serializer.fromJson<int>(json['targetPaise']),
      targetDate: serializer.fromJson<DateTime?>(json['targetDate']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      startPaise: serializer.fromJson<int>(json['startPaise']),
      annualReturnBp: serializer.fromJson<int>(json['annualReturnBp']),
      source: serializer.fromJson<String>(json['source']),
      sourceRef: serializer.fromJson<String?>(json['sourceRef']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'targetPaise': serializer.toJson<int>(targetPaise),
      'targetDate': serializer.toJson<DateTime?>(targetDate),
      'startDate': serializer.toJson<DateTime>(startDate),
      'startPaise': serializer.toJson<int>(startPaise),
      'annualReturnBp': serializer.toJson<int>(annualReturnBp),
      'source': serializer.toJson<String>(source),
      'sourceRef': serializer.toJson<String?>(sourceRef),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Goal copyWith({
    int? id,
    String? name,
    int? targetPaise,
    Value<DateTime?> targetDate = const Value.absent(),
    DateTime? startDate,
    int? startPaise,
    int? annualReturnBp,
    String? source,
    Value<String?> sourceRef = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Goal(
    id: id ?? this.id,
    name: name ?? this.name,
    targetPaise: targetPaise ?? this.targetPaise,
    targetDate: targetDate.present ? targetDate.value : this.targetDate,
    startDate: startDate ?? this.startDate,
    startPaise: startPaise ?? this.startPaise,
    annualReturnBp: annualReturnBp ?? this.annualReturnBp,
    source: source ?? this.source,
    sourceRef: sourceRef.present ? sourceRef.value : this.sourceRef,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Goal copyWithCompanion(GoalsCompanion data) {
    return Goal(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      targetPaise: data.targetPaise.present
          ? data.targetPaise.value
          : this.targetPaise,
      targetDate: data.targetDate.present
          ? data.targetDate.value
          : this.targetDate,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      startPaise: data.startPaise.present
          ? data.startPaise.value
          : this.startPaise,
      annualReturnBp: data.annualReturnBp.present
          ? data.annualReturnBp.value
          : this.annualReturnBp,
      source: data.source.present ? data.source.value : this.source,
      sourceRef: data.sourceRef.present ? data.sourceRef.value : this.sourceRef,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Goal(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('targetPaise: $targetPaise, ')
          ..write('targetDate: $targetDate, ')
          ..write('startDate: $startDate, ')
          ..write('startPaise: $startPaise, ')
          ..write('annualReturnBp: $annualReturnBp, ')
          ..write('source: $source, ')
          ..write('sourceRef: $sourceRef, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    targetPaise,
    targetDate,
    startDate,
    startPaise,
    annualReturnBp,
    source,
    sourceRef,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Goal &&
          other.id == this.id &&
          other.name == this.name &&
          other.targetPaise == this.targetPaise &&
          other.targetDate == this.targetDate &&
          other.startDate == this.startDate &&
          other.startPaise == this.startPaise &&
          other.annualReturnBp == this.annualReturnBp &&
          other.source == this.source &&
          other.sourceRef == this.sourceRef &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class GoalsCompanion extends UpdateCompanion<Goal> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> targetPaise;
  final Value<DateTime?> targetDate;
  final Value<DateTime> startDate;
  final Value<int> startPaise;
  final Value<int> annualReturnBp;
  final Value<String> source;
  final Value<String?> sourceRef;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const GoalsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.targetPaise = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.startDate = const Value.absent(),
    this.startPaise = const Value.absent(),
    this.annualReturnBp = const Value.absent(),
    this.source = const Value.absent(),
    this.sourceRef = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  GoalsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int targetPaise,
    this.targetDate = const Value.absent(),
    required DateTime startDate,
    this.startPaise = const Value.absent(),
    this.annualReturnBp = const Value.absent(),
    this.source = const Value.absent(),
    this.sourceRef = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name),
       targetPaise = Value(targetPaise),
       startDate = Value(startDate);
  static Insertable<Goal> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? targetPaise,
    Expression<DateTime>? targetDate,
    Expression<DateTime>? startDate,
    Expression<int>? startPaise,
    Expression<int>? annualReturnBp,
    Expression<String>? source,
    Expression<String>? sourceRef,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (targetPaise != null) 'target_paise': targetPaise,
      if (targetDate != null) 'target_date': targetDate,
      if (startDate != null) 'start_date': startDate,
      if (startPaise != null) 'start_paise': startPaise,
      if (annualReturnBp != null) 'annual_return_bp': annualReturnBp,
      if (source != null) 'source': source,
      if (sourceRef != null) 'source_ref': sourceRef,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  GoalsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? targetPaise,
    Value<DateTime?>? targetDate,
    Value<DateTime>? startDate,
    Value<int>? startPaise,
    Value<int>? annualReturnBp,
    Value<String>? source,
    Value<String?>? sourceRef,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return GoalsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      targetPaise: targetPaise ?? this.targetPaise,
      targetDate: targetDate ?? this.targetDate,
      startDate: startDate ?? this.startDate,
      startPaise: startPaise ?? this.startPaise,
      annualReturnBp: annualReturnBp ?? this.annualReturnBp,
      source: source ?? this.source,
      sourceRef: sourceRef ?? this.sourceRef,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (targetPaise.present) {
      map['target_paise'] = Variable<int>(targetPaise.value);
    }
    if (targetDate.present) {
      map['target_date'] = Variable<DateTime>(targetDate.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (startPaise.present) {
      map['start_paise'] = Variable<int>(startPaise.value);
    }
    if (annualReturnBp.present) {
      map['annual_return_bp'] = Variable<int>(annualReturnBp.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (sourceRef.present) {
      map['source_ref'] = Variable<String>(sourceRef.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('targetPaise: $targetPaise, ')
          ..write('targetDate: $targetDate, ')
          ..write('startDate: $startDate, ')
          ..write('startPaise: $startPaise, ')
          ..write('annualReturnBp: $annualReturnBp, ')
          ..write('source: $source, ')
          ..write('sourceRef: $sourceRef, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $GoalContributionsTable extends GoalContributions
    with TableInfo<$GoalContributionsTable, GoalContribution> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalContributionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _goalIdMeta = const VerificationMeta('goalId');
  @override
  late final GeneratedColumn<int> goalId = GeneratedColumn<int>(
    'goal_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES goals (id)',
    ),
  );
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    goalId,
    amountPaise,
    date,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goal_contributions';
  @override
  VerificationContext validateIntegrity(
    Insertable<GoalContribution> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('goal_id')) {
      context.handle(
        _goalIdMeta,
        goalId.isAcceptableOrUnknown(data['goal_id']!, _goalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_goalIdMeta);
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPaiseMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GoalContribution map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalContribution(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      goalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}goal_id'],
      )!,
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $GoalContributionsTable createAlias(String alias) {
    return $GoalContributionsTable(attachedDatabase, alias);
  }
}

class GoalContribution extends DataClass
    implements Insertable<GoalContribution> {
  final int id;
  final int goalId;
  final int amountPaise;
  final DateTime date;
  final String? note;
  final DateTime createdAt;
  const GoalContribution({
    required this.id,
    required this.goalId,
    required this.amountPaise,
    required this.date,
    this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['goal_id'] = Variable<int>(goalId);
    map['amount_paise'] = Variable<int>(amountPaise);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  GoalContributionsCompanion toCompanion(bool nullToAbsent) {
    return GoalContributionsCompanion(
      id: Value(id),
      goalId: Value(goalId),
      amountPaise: Value(amountPaise),
      date: Value(date),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory GoalContribution.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalContribution(
      id: serializer.fromJson<int>(json['id']),
      goalId: serializer.fromJson<int>(json['goalId']),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
      date: serializer.fromJson<DateTime>(json['date']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'goalId': serializer.toJson<int>(goalId),
      'amountPaise': serializer.toJson<int>(amountPaise),
      'date': serializer.toJson<DateTime>(date),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  GoalContribution copyWith({
    int? id,
    int? goalId,
    int? amountPaise,
    DateTime? date,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
  }) => GoalContribution(
    id: id ?? this.id,
    goalId: goalId ?? this.goalId,
    amountPaise: amountPaise ?? this.amountPaise,
    date: date ?? this.date,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  GoalContribution copyWithCompanion(GoalContributionsCompanion data) {
    return GoalContribution(
      id: data.id.present ? data.id.value : this.id,
      goalId: data.goalId.present ? data.goalId.value : this.goalId,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
      date: data.date.present ? data.date.value : this.date,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoalContribution(')
          ..write('id: $id, ')
          ..write('goalId: $goalId, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, goalId, amountPaise, date, note, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalContribution &&
          other.id == this.id &&
          other.goalId == this.goalId &&
          other.amountPaise == this.amountPaise &&
          other.date == this.date &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class GoalContributionsCompanion extends UpdateCompanion<GoalContribution> {
  final Value<int> id;
  final Value<int> goalId;
  final Value<int> amountPaise;
  final Value<DateTime> date;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  const GoalContributionsCompanion({
    this.id = const Value.absent(),
    this.goalId = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.date = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  GoalContributionsCompanion.insert({
    this.id = const Value.absent(),
    required int goalId,
    required int amountPaise,
    required DateTime date,
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : goalId = Value(goalId),
       amountPaise = Value(amountPaise),
       date = Value(date);
  static Insertable<GoalContribution> custom({
    Expression<int>? id,
    Expression<int>? goalId,
    Expression<int>? amountPaise,
    Expression<DateTime>? date,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (goalId != null) 'goal_id': goalId,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (date != null) 'date': date,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  GoalContributionsCompanion copyWith({
    Value<int>? id,
    Value<int>? goalId,
    Value<int>? amountPaise,
    Value<DateTime>? date,
    Value<String?>? note,
    Value<DateTime>? createdAt,
  }) {
    return GoalContributionsCompanion(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      amountPaise: amountPaise ?? this.amountPaise,
      date: date ?? this.date,
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
    if (goalId.present) {
      map['goal_id'] = Variable<int>(goalId.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalContributionsCompanion(')
          ..write('id: $id, ')
          ..write('goalId: $goalId, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SecuritiesTable extends Securities
    with TableInfo<$SecuritiesTable, Security> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SecuritiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _isinMeta = const VerificationMeta('isin');
  @override
  late final GeneratedColumn<String> isin = GeneratedColumn<String>(
    'isin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amcMeta = const VerificationMeta('amc');
  @override
  late final GeneratedColumn<String> amc = GeneratedColumn<String>(
    'amc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _taxCategoryMeta = const VerificationMeta(
    'taxCategory',
  );
  @override
  late final GeneratedColumn<String> taxCategory = GeneratedColumn<String>(
    'tax_category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    isin,
    name,
    kind,
    amc,
    taxCategory,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'securities';
  @override
  VerificationContext validateIntegrity(
    Insertable<Security> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('isin')) {
      context.handle(
        _isinMeta,
        isin.isAcceptableOrUnknown(data['isin']!, _isinMeta),
      );
    } else if (isInserting) {
      context.missing(_isinMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('amc')) {
      context.handle(
        _amcMeta,
        amc.isAcceptableOrUnknown(data['amc']!, _amcMeta),
      );
    }
    if (data.containsKey('tax_category')) {
      context.handle(
        _taxCategoryMeta,
        taxCategory.isAcceptableOrUnknown(
          data['tax_category']!,
          _taxCategoryMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Security map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Security(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      isin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}isin'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      amc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}amc'],
      ),
      taxCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tax_category'],
      ),
    );
  }

  @override
  $SecuritiesTable createAlias(String alias) {
    return $SecuritiesTable(attachedDatabase, alias);
  }
}

class Security extends DataClass implements Insertable<Security> {
  final int id;
  final String isin;
  final String name;

  /// mf | equity | other
  final String kind;
  final String? amc;

  /// User override of the tax category: equity | debt | other (Phase 10.1).
  final String? taxCategory;
  const Security({
    required this.id,
    required this.isin,
    required this.name,
    required this.kind,
    this.amc,
    this.taxCategory,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['isin'] = Variable<String>(isin);
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || amc != null) {
      map['amc'] = Variable<String>(amc);
    }
    if (!nullToAbsent || taxCategory != null) {
      map['tax_category'] = Variable<String>(taxCategory);
    }
    return map;
  }

  SecuritiesCompanion toCompanion(bool nullToAbsent) {
    return SecuritiesCompanion(
      id: Value(id),
      isin: Value(isin),
      name: Value(name),
      kind: Value(kind),
      amc: amc == null && nullToAbsent ? const Value.absent() : Value(amc),
      taxCategory: taxCategory == null && nullToAbsent
          ? const Value.absent()
          : Value(taxCategory),
    );
  }

  factory Security.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Security(
      id: serializer.fromJson<int>(json['id']),
      isin: serializer.fromJson<String>(json['isin']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      amc: serializer.fromJson<String?>(json['amc']),
      taxCategory: serializer.fromJson<String?>(json['taxCategory']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'isin': serializer.toJson<String>(isin),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'amc': serializer.toJson<String?>(amc),
      'taxCategory': serializer.toJson<String?>(taxCategory),
    };
  }

  Security copyWith({
    int? id,
    String? isin,
    String? name,
    String? kind,
    Value<String?> amc = const Value.absent(),
    Value<String?> taxCategory = const Value.absent(),
  }) => Security(
    id: id ?? this.id,
    isin: isin ?? this.isin,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    amc: amc.present ? amc.value : this.amc,
    taxCategory: taxCategory.present ? taxCategory.value : this.taxCategory,
  );
  Security copyWithCompanion(SecuritiesCompanion data) {
    return Security(
      id: data.id.present ? data.id.value : this.id,
      isin: data.isin.present ? data.isin.value : this.isin,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      amc: data.amc.present ? data.amc.value : this.amc,
      taxCategory: data.taxCategory.present
          ? data.taxCategory.value
          : this.taxCategory,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Security(')
          ..write('id: $id, ')
          ..write('isin: $isin, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('amc: $amc, ')
          ..write('taxCategory: $taxCategory')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, isin, name, kind, amc, taxCategory);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Security &&
          other.id == this.id &&
          other.isin == this.isin &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.amc == this.amc &&
          other.taxCategory == this.taxCategory);
}

class SecuritiesCompanion extends UpdateCompanion<Security> {
  final Value<int> id;
  final Value<String> isin;
  final Value<String> name;
  final Value<String> kind;
  final Value<String?> amc;
  final Value<String?> taxCategory;
  const SecuritiesCompanion({
    this.id = const Value.absent(),
    this.isin = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.amc = const Value.absent(),
    this.taxCategory = const Value.absent(),
  });
  SecuritiesCompanion.insert({
    this.id = const Value.absent(),
    required String isin,
    required String name,
    required String kind,
    this.amc = const Value.absent(),
    this.taxCategory = const Value.absent(),
  }) : isin = Value(isin),
       name = Value(name),
       kind = Value(kind);
  static Insertable<Security> custom({
    Expression<int>? id,
    Expression<String>? isin,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<String>? amc,
    Expression<String>? taxCategory,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (isin != null) 'isin': isin,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (amc != null) 'amc': amc,
      if (taxCategory != null) 'tax_category': taxCategory,
    });
  }

  SecuritiesCompanion copyWith({
    Value<int>? id,
    Value<String>? isin,
    Value<String>? name,
    Value<String>? kind,
    Value<String?>? amc,
    Value<String?>? taxCategory,
  }) {
    return SecuritiesCompanion(
      id: id ?? this.id,
      isin: isin ?? this.isin,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      amc: amc ?? this.amc,
      taxCategory: taxCategory ?? this.taxCategory,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (isin.present) {
      map['isin'] = Variable<String>(isin.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (amc.present) {
      map['amc'] = Variable<String>(amc.value);
    }
    if (taxCategory.present) {
      map['tax_category'] = Variable<String>(taxCategory.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SecuritiesCompanion(')
          ..write('id: $id, ')
          ..write('isin: $isin, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('amc: $amc, ')
          ..write('taxCategory: $taxCategory')
          ..write(')'))
        .toString();
  }
}

class $InvestmentAccountsTable extends InvestmentAccounts
    with TableInfo<$InvestmentAccountsTable, InvestmentAccount> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvestmentAccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<String> number = GeneratedColumn<String>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amcMeta = const VerificationMeta('amc');
  @override
  late final GeneratedColumn<String> amc = GeneratedColumn<String>(
    'amc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, kind, number, provider, amc];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'investment_accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<InvestmentAccount> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    } else if (isInserting) {
      context.missing(_providerMeta);
    }
    if (data.containsKey('amc')) {
      context.handle(
        _amcMeta,
        amc.isAcceptableOrUnknown(data['amc']!, _amcMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {kind, number},
  ];
  @override
  InvestmentAccount map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InvestmentAccount(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}number'],
      )!,
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      )!,
      amc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}amc'],
      ),
    );
  }

  @override
  $InvestmentAccountsTable createAlias(String alias) {
    return $InvestmentAccountsTable(attachedDatabase, alias);
  }
}

class InvestmentAccount extends DataClass
    implements Insertable<InvestmentAccount> {
  final int id;

  /// folio | demat
  final String kind;

  /// Folio number or `DP ID/Client ID` / BO ID.
  final String number;

  /// CAMS | KFINTECH | NSDL | CDSL | UNKNOWN
  final String provider;
  final String? amc;
  const InvestmentAccount({
    required this.id,
    required this.kind,
    required this.number,
    required this.provider,
    this.amc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['kind'] = Variable<String>(kind);
    map['number'] = Variable<String>(number);
    map['provider'] = Variable<String>(provider);
    if (!nullToAbsent || amc != null) {
      map['amc'] = Variable<String>(amc);
    }
    return map;
  }

  InvestmentAccountsCompanion toCompanion(bool nullToAbsent) {
    return InvestmentAccountsCompanion(
      id: Value(id),
      kind: Value(kind),
      number: Value(number),
      provider: Value(provider),
      amc: amc == null && nullToAbsent ? const Value.absent() : Value(amc),
    );
  }

  factory InvestmentAccount.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InvestmentAccount(
      id: serializer.fromJson<int>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      number: serializer.fromJson<String>(json['number']),
      provider: serializer.fromJson<String>(json['provider']),
      amc: serializer.fromJson<String?>(json['amc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kind': serializer.toJson<String>(kind),
      'number': serializer.toJson<String>(number),
      'provider': serializer.toJson<String>(provider),
      'amc': serializer.toJson<String?>(amc),
    };
  }

  InvestmentAccount copyWith({
    int? id,
    String? kind,
    String? number,
    String? provider,
    Value<String?> amc = const Value.absent(),
  }) => InvestmentAccount(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    number: number ?? this.number,
    provider: provider ?? this.provider,
    amc: amc.present ? amc.value : this.amc,
  );
  InvestmentAccount copyWithCompanion(InvestmentAccountsCompanion data) {
    return InvestmentAccount(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      number: data.number.present ? data.number.value : this.number,
      provider: data.provider.present ? data.provider.value : this.provider,
      amc: data.amc.present ? data.amc.value : this.amc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InvestmentAccount(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('number: $number, ')
          ..write('provider: $provider, ')
          ..write('amc: $amc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, kind, number, provider, amc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvestmentAccount &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.number == this.number &&
          other.provider == this.provider &&
          other.amc == this.amc);
}

class InvestmentAccountsCompanion extends UpdateCompanion<InvestmentAccount> {
  final Value<int> id;
  final Value<String> kind;
  final Value<String> number;
  final Value<String> provider;
  final Value<String?> amc;
  const InvestmentAccountsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.number = const Value.absent(),
    this.provider = const Value.absent(),
    this.amc = const Value.absent(),
  });
  InvestmentAccountsCompanion.insert({
    this.id = const Value.absent(),
    required String kind,
    required String number,
    required String provider,
    this.amc = const Value.absent(),
  }) : kind = Value(kind),
       number = Value(number),
       provider = Value(provider);
  static Insertable<InvestmentAccount> custom({
    Expression<int>? id,
    Expression<String>? kind,
    Expression<String>? number,
    Expression<String>? provider,
    Expression<String>? amc,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (number != null) 'number': number,
      if (provider != null) 'provider': provider,
      if (amc != null) 'amc': amc,
    });
  }

  InvestmentAccountsCompanion copyWith({
    Value<int>? id,
    Value<String>? kind,
    Value<String>? number,
    Value<String>? provider,
    Value<String?>? amc,
  }) {
    return InvestmentAccountsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      number: number ?? this.number,
      provider: provider ?? this.provider,
      amc: amc ?? this.amc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (number.present) {
      map['number'] = Variable<String>(number.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (amc.present) {
      map['amc'] = Variable<String>(amc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvestmentAccountsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('number: $number, ')
          ..write('provider: $provider, ')
          ..write('amc: $amc')
          ..write(')'))
        .toString();
  }
}

class $InvestmentTxnsTable extends InvestmentTxns
    with TableInfo<$InvestmentTxnsTable, InvestmentTxn> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvestmentTxnsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES investment_accounts (id)',
    ),
  );
  static const VerificationMeta _securityIdMeta = const VerificationMeta(
    'securityId',
  );
  @override
  late final GeneratedColumn<int> securityId = GeneratedColumn<int>(
    'security_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES securities (id)',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitsE4Meta = const VerificationMeta(
    'unitsE4',
  );
  @override
  late final GeneratedColumn<int> unitsE4 = GeneratedColumn<int>(
    'units_e4',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _navE4Meta = const VerificationMeta('navE4');
  @override
  late final GeneratedColumn<int> navE4 = GeneratedColumn<int>(
    'nav_e4',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _balanceE4Meta = const VerificationMeta(
    'balanceE4',
  );
  @override
  late final GeneratedColumn<int> balanceE4 = GeneratedColumn<int>(
    'balance_e4',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _importIdMeta = const VerificationMeta(
    'importId',
  );
  @override
  late final GeneratedColumn<int> importId = GeneratedColumn<int>(
    'import_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES imports (id)',
    ),
  );
  static const VerificationMeta _dedupeHashMeta = const VerificationMeta(
    'dedupeHash',
  );
  @override
  late final GeneratedColumn<String> dedupeHash = GeneratedColumn<String>(
    'dedupe_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    accountId,
    securityId,
    date,
    type,
    description,
    amountPaise,
    unitsE4,
    navE4,
    balanceE4,
    importId,
    dedupeHash,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'investment_txns';
  @override
  VerificationContext validateIntegrity(
    Insertable<InvestmentTxn> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('security_id')) {
      context.handle(
        _securityIdMeta,
        securityId.isAcceptableOrUnknown(data['security_id']!, _securityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_securityIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    }
    if (data.containsKey('units_e4')) {
      context.handle(
        _unitsE4Meta,
        unitsE4.isAcceptableOrUnknown(data['units_e4']!, _unitsE4Meta),
      );
    }
    if (data.containsKey('nav_e4')) {
      context.handle(
        _navE4Meta,
        navE4.isAcceptableOrUnknown(data['nav_e4']!, _navE4Meta),
      );
    }
    if (data.containsKey('balance_e4')) {
      context.handle(
        _balanceE4Meta,
        balanceE4.isAcceptableOrUnknown(data['balance_e4']!, _balanceE4Meta),
      );
    }
    if (data.containsKey('import_id')) {
      context.handle(
        _importIdMeta,
        importId.isAcceptableOrUnknown(data['import_id']!, _importIdMeta),
      );
    }
    if (data.containsKey('dedupe_hash')) {
      context.handle(
        _dedupeHashMeta,
        dedupeHash.isAcceptableOrUnknown(data['dedupe_hash']!, _dedupeHashMeta),
      );
    } else if (isInserting) {
      context.missing(_dedupeHashMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InvestmentTxn map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InvestmentTxn(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}account_id'],
      )!,
      securityId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}security_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      ),
      unitsE4: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}units_e4'],
      ),
      navE4: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}nav_e4'],
      ),
      balanceE4: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}balance_e4'],
      ),
      importId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}import_id'],
      ),
      dedupeHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dedupe_hash'],
      )!,
    );
  }

  @override
  $InvestmentTxnsTable createAlias(String alias) {
    return $InvestmentTxnsTable(attachedDatabase, alias);
  }
}

class InvestmentTxn extends DataClass implements Insertable<InvestmentTxn> {
  final int id;
  final int accountId;
  final int securityId;
  final DateTime date;

  /// See `CasTxnType` names.
  final String type;
  final String description;
  final int? amountPaise;
  final int? unitsE4;
  final int? navE4;
  final int? balanceE4;
  final int? importId;
  final String dedupeHash;
  const InvestmentTxn({
    required this.id,
    required this.accountId,
    required this.securityId,
    required this.date,
    required this.type,
    required this.description,
    this.amountPaise,
    this.unitsE4,
    this.navE4,
    this.balanceE4,
    this.importId,
    required this.dedupeHash,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['account_id'] = Variable<int>(accountId);
    map['security_id'] = Variable<int>(securityId);
    map['date'] = Variable<DateTime>(date);
    map['type'] = Variable<String>(type);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || amountPaise != null) {
      map['amount_paise'] = Variable<int>(amountPaise);
    }
    if (!nullToAbsent || unitsE4 != null) {
      map['units_e4'] = Variable<int>(unitsE4);
    }
    if (!nullToAbsent || navE4 != null) {
      map['nav_e4'] = Variable<int>(navE4);
    }
    if (!nullToAbsent || balanceE4 != null) {
      map['balance_e4'] = Variable<int>(balanceE4);
    }
    if (!nullToAbsent || importId != null) {
      map['import_id'] = Variable<int>(importId);
    }
    map['dedupe_hash'] = Variable<String>(dedupeHash);
    return map;
  }

  InvestmentTxnsCompanion toCompanion(bool nullToAbsent) {
    return InvestmentTxnsCompanion(
      id: Value(id),
      accountId: Value(accountId),
      securityId: Value(securityId),
      date: Value(date),
      type: Value(type),
      description: Value(description),
      amountPaise: amountPaise == null && nullToAbsent
          ? const Value.absent()
          : Value(amountPaise),
      unitsE4: unitsE4 == null && nullToAbsent
          ? const Value.absent()
          : Value(unitsE4),
      navE4: navE4 == null && nullToAbsent
          ? const Value.absent()
          : Value(navE4),
      balanceE4: balanceE4 == null && nullToAbsent
          ? const Value.absent()
          : Value(balanceE4),
      importId: importId == null && nullToAbsent
          ? const Value.absent()
          : Value(importId),
      dedupeHash: Value(dedupeHash),
    );
  }

  factory InvestmentTxn.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InvestmentTxn(
      id: serializer.fromJson<int>(json['id']),
      accountId: serializer.fromJson<int>(json['accountId']),
      securityId: serializer.fromJson<int>(json['securityId']),
      date: serializer.fromJson<DateTime>(json['date']),
      type: serializer.fromJson<String>(json['type']),
      description: serializer.fromJson<String>(json['description']),
      amountPaise: serializer.fromJson<int?>(json['amountPaise']),
      unitsE4: serializer.fromJson<int?>(json['unitsE4']),
      navE4: serializer.fromJson<int?>(json['navE4']),
      balanceE4: serializer.fromJson<int?>(json['balanceE4']),
      importId: serializer.fromJson<int?>(json['importId']),
      dedupeHash: serializer.fromJson<String>(json['dedupeHash']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'accountId': serializer.toJson<int>(accountId),
      'securityId': serializer.toJson<int>(securityId),
      'date': serializer.toJson<DateTime>(date),
      'type': serializer.toJson<String>(type),
      'description': serializer.toJson<String>(description),
      'amountPaise': serializer.toJson<int?>(amountPaise),
      'unitsE4': serializer.toJson<int?>(unitsE4),
      'navE4': serializer.toJson<int?>(navE4),
      'balanceE4': serializer.toJson<int?>(balanceE4),
      'importId': serializer.toJson<int?>(importId),
      'dedupeHash': serializer.toJson<String>(dedupeHash),
    };
  }

  InvestmentTxn copyWith({
    int? id,
    int? accountId,
    int? securityId,
    DateTime? date,
    String? type,
    String? description,
    Value<int?> amountPaise = const Value.absent(),
    Value<int?> unitsE4 = const Value.absent(),
    Value<int?> navE4 = const Value.absent(),
    Value<int?> balanceE4 = const Value.absent(),
    Value<int?> importId = const Value.absent(),
    String? dedupeHash,
  }) => InvestmentTxn(
    id: id ?? this.id,
    accountId: accountId ?? this.accountId,
    securityId: securityId ?? this.securityId,
    date: date ?? this.date,
    type: type ?? this.type,
    description: description ?? this.description,
    amountPaise: amountPaise.present ? amountPaise.value : this.amountPaise,
    unitsE4: unitsE4.present ? unitsE4.value : this.unitsE4,
    navE4: navE4.present ? navE4.value : this.navE4,
    balanceE4: balanceE4.present ? balanceE4.value : this.balanceE4,
    importId: importId.present ? importId.value : this.importId,
    dedupeHash: dedupeHash ?? this.dedupeHash,
  );
  InvestmentTxn copyWithCompanion(InvestmentTxnsCompanion data) {
    return InvestmentTxn(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      securityId: data.securityId.present
          ? data.securityId.value
          : this.securityId,
      date: data.date.present ? data.date.value : this.date,
      type: data.type.present ? data.type.value : this.type,
      description: data.description.present
          ? data.description.value
          : this.description,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
      unitsE4: data.unitsE4.present ? data.unitsE4.value : this.unitsE4,
      navE4: data.navE4.present ? data.navE4.value : this.navE4,
      balanceE4: data.balanceE4.present ? data.balanceE4.value : this.balanceE4,
      importId: data.importId.present ? data.importId.value : this.importId,
      dedupeHash: data.dedupeHash.present
          ? data.dedupeHash.value
          : this.dedupeHash,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InvestmentTxn(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('securityId: $securityId, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('description: $description, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('unitsE4: $unitsE4, ')
          ..write('navE4: $navE4, ')
          ..write('balanceE4: $balanceE4, ')
          ..write('importId: $importId, ')
          ..write('dedupeHash: $dedupeHash')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    accountId,
    securityId,
    date,
    type,
    description,
    amountPaise,
    unitsE4,
    navE4,
    balanceE4,
    importId,
    dedupeHash,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvestmentTxn &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.securityId == this.securityId &&
          other.date == this.date &&
          other.type == this.type &&
          other.description == this.description &&
          other.amountPaise == this.amountPaise &&
          other.unitsE4 == this.unitsE4 &&
          other.navE4 == this.navE4 &&
          other.balanceE4 == this.balanceE4 &&
          other.importId == this.importId &&
          other.dedupeHash == this.dedupeHash);
}

class InvestmentTxnsCompanion extends UpdateCompanion<InvestmentTxn> {
  final Value<int> id;
  final Value<int> accountId;
  final Value<int> securityId;
  final Value<DateTime> date;
  final Value<String> type;
  final Value<String> description;
  final Value<int?> amountPaise;
  final Value<int?> unitsE4;
  final Value<int?> navE4;
  final Value<int?> balanceE4;
  final Value<int?> importId;
  final Value<String> dedupeHash;
  const InvestmentTxnsCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.securityId = const Value.absent(),
    this.date = const Value.absent(),
    this.type = const Value.absent(),
    this.description = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.unitsE4 = const Value.absent(),
    this.navE4 = const Value.absent(),
    this.balanceE4 = const Value.absent(),
    this.importId = const Value.absent(),
    this.dedupeHash = const Value.absent(),
  });
  InvestmentTxnsCompanion.insert({
    this.id = const Value.absent(),
    required int accountId,
    required int securityId,
    required DateTime date,
    required String type,
    required String description,
    this.amountPaise = const Value.absent(),
    this.unitsE4 = const Value.absent(),
    this.navE4 = const Value.absent(),
    this.balanceE4 = const Value.absent(),
    this.importId = const Value.absent(),
    required String dedupeHash,
  }) : accountId = Value(accountId),
       securityId = Value(securityId),
       date = Value(date),
       type = Value(type),
       description = Value(description),
       dedupeHash = Value(dedupeHash);
  static Insertable<InvestmentTxn> custom({
    Expression<int>? id,
    Expression<int>? accountId,
    Expression<int>? securityId,
    Expression<DateTime>? date,
    Expression<String>? type,
    Expression<String>? description,
    Expression<int>? amountPaise,
    Expression<int>? unitsE4,
    Expression<int>? navE4,
    Expression<int>? balanceE4,
    Expression<int>? importId,
    Expression<String>? dedupeHash,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (securityId != null) 'security_id': securityId,
      if (date != null) 'date': date,
      if (type != null) 'type': type,
      if (description != null) 'description': description,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (unitsE4 != null) 'units_e4': unitsE4,
      if (navE4 != null) 'nav_e4': navE4,
      if (balanceE4 != null) 'balance_e4': balanceE4,
      if (importId != null) 'import_id': importId,
      if (dedupeHash != null) 'dedupe_hash': dedupeHash,
    });
  }

  InvestmentTxnsCompanion copyWith({
    Value<int>? id,
    Value<int>? accountId,
    Value<int>? securityId,
    Value<DateTime>? date,
    Value<String>? type,
    Value<String>? description,
    Value<int?>? amountPaise,
    Value<int?>? unitsE4,
    Value<int?>? navE4,
    Value<int?>? balanceE4,
    Value<int?>? importId,
    Value<String>? dedupeHash,
  }) {
    return InvestmentTxnsCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      securityId: securityId ?? this.securityId,
      date: date ?? this.date,
      type: type ?? this.type,
      description: description ?? this.description,
      amountPaise: amountPaise ?? this.amountPaise,
      unitsE4: unitsE4 ?? this.unitsE4,
      navE4: navE4 ?? this.navE4,
      balanceE4: balanceE4 ?? this.balanceE4,
      importId: importId ?? this.importId,
      dedupeHash: dedupeHash ?? this.dedupeHash,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (securityId.present) {
      map['security_id'] = Variable<int>(securityId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (unitsE4.present) {
      map['units_e4'] = Variable<int>(unitsE4.value);
    }
    if (navE4.present) {
      map['nav_e4'] = Variable<int>(navE4.value);
    }
    if (balanceE4.present) {
      map['balance_e4'] = Variable<int>(balanceE4.value);
    }
    if (importId.present) {
      map['import_id'] = Variable<int>(importId.value);
    }
    if (dedupeHash.present) {
      map['dedupe_hash'] = Variable<String>(dedupeHash.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvestmentTxnsCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('securityId: $securityId, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('description: $description, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('unitsE4: $unitsE4, ')
          ..write('navE4: $navE4, ')
          ..write('balanceE4: $balanceE4, ')
          ..write('importId: $importId, ')
          ..write('dedupeHash: $dedupeHash')
          ..write(')'))
        .toString();
  }
}

class $HoldingSnapshotsTable extends HoldingSnapshots
    with TableInfo<$HoldingSnapshotsTable, HoldingSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HoldingSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES investment_accounts (id)',
    ),
  );
  static const VerificationMeta _securityIdMeta = const VerificationMeta(
    'securityId',
  );
  @override
  late final GeneratedColumn<int> securityId = GeneratedColumn<int>(
    'security_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES securities (id)',
    ),
  );
  static const VerificationMeta _asOfMeta = const VerificationMeta('asOf');
  @override
  late final GeneratedColumn<DateTime> asOf = GeneratedColumn<DateTime>(
    'as_of',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitsE4Meta = const VerificationMeta(
    'unitsE4',
  );
  @override
  late final GeneratedColumn<int> unitsE4 = GeneratedColumn<int>(
    'units_e4',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceE4Meta = const VerificationMeta(
    'priceE4',
  );
  @override
  late final GeneratedColumn<int> priceE4 = GeneratedColumn<int>(
    'price_e4',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valuePaiseMeta = const VerificationMeta(
    'valuePaise',
  );
  @override
  late final GeneratedColumn<int> valuePaise = GeneratedColumn<int>(
    'value_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costPaiseMeta = const VerificationMeta(
    'costPaise',
  );
  @override
  late final GeneratedColumn<int> costPaise = GeneratedColumn<int>(
    'cost_paise',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _importIdMeta = const VerificationMeta(
    'importId',
  );
  @override
  late final GeneratedColumn<int> importId = GeneratedColumn<int>(
    'import_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES imports (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    accountId,
    securityId,
    asOf,
    unitsE4,
    priceE4,
    valuePaise,
    costPaise,
    importId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'holding_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<HoldingSnapshot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('security_id')) {
      context.handle(
        _securityIdMeta,
        securityId.isAcceptableOrUnknown(data['security_id']!, _securityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_securityIdMeta);
    }
    if (data.containsKey('as_of')) {
      context.handle(
        _asOfMeta,
        asOf.isAcceptableOrUnknown(data['as_of']!, _asOfMeta),
      );
    } else if (isInserting) {
      context.missing(_asOfMeta);
    }
    if (data.containsKey('units_e4')) {
      context.handle(
        _unitsE4Meta,
        unitsE4.isAcceptableOrUnknown(data['units_e4']!, _unitsE4Meta),
      );
    } else if (isInserting) {
      context.missing(_unitsE4Meta);
    }
    if (data.containsKey('price_e4')) {
      context.handle(
        _priceE4Meta,
        priceE4.isAcceptableOrUnknown(data['price_e4']!, _priceE4Meta),
      );
    } else if (isInserting) {
      context.missing(_priceE4Meta);
    }
    if (data.containsKey('value_paise')) {
      context.handle(
        _valuePaiseMeta,
        valuePaise.isAcceptableOrUnknown(data['value_paise']!, _valuePaiseMeta),
      );
    } else if (isInserting) {
      context.missing(_valuePaiseMeta);
    }
    if (data.containsKey('cost_paise')) {
      context.handle(
        _costPaiseMeta,
        costPaise.isAcceptableOrUnknown(data['cost_paise']!, _costPaiseMeta),
      );
    }
    if (data.containsKey('import_id')) {
      context.handle(
        _importIdMeta,
        importId.isAcceptableOrUnknown(data['import_id']!, _importIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {accountId, securityId, asOf},
  ];
  @override
  HoldingSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HoldingSnapshot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}account_id'],
      )!,
      securityId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}security_id'],
      )!,
      asOf: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}as_of'],
      )!,
      unitsE4: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}units_e4'],
      )!,
      priceE4: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price_e4'],
      )!,
      valuePaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}value_paise'],
      )!,
      costPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cost_paise'],
      ),
      importId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}import_id'],
      ),
    );
  }

  @override
  $HoldingSnapshotsTable createAlias(String alias) {
    return $HoldingSnapshotsTable(attachedDatabase, alias);
  }
}

class HoldingSnapshot extends DataClass implements Insertable<HoldingSnapshot> {
  final int id;
  final int accountId;
  final int securityId;
  final DateTime asOf;
  final int unitsE4;
  final int priceE4;
  final int valuePaise;
  final int? costPaise;
  final int? importId;
  const HoldingSnapshot({
    required this.id,
    required this.accountId,
    required this.securityId,
    required this.asOf,
    required this.unitsE4,
    required this.priceE4,
    required this.valuePaise,
    this.costPaise,
    this.importId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['account_id'] = Variable<int>(accountId);
    map['security_id'] = Variable<int>(securityId);
    map['as_of'] = Variable<DateTime>(asOf);
    map['units_e4'] = Variable<int>(unitsE4);
    map['price_e4'] = Variable<int>(priceE4);
    map['value_paise'] = Variable<int>(valuePaise);
    if (!nullToAbsent || costPaise != null) {
      map['cost_paise'] = Variable<int>(costPaise);
    }
    if (!nullToAbsent || importId != null) {
      map['import_id'] = Variable<int>(importId);
    }
    return map;
  }

  HoldingSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return HoldingSnapshotsCompanion(
      id: Value(id),
      accountId: Value(accountId),
      securityId: Value(securityId),
      asOf: Value(asOf),
      unitsE4: Value(unitsE4),
      priceE4: Value(priceE4),
      valuePaise: Value(valuePaise),
      costPaise: costPaise == null && nullToAbsent
          ? const Value.absent()
          : Value(costPaise),
      importId: importId == null && nullToAbsent
          ? const Value.absent()
          : Value(importId),
    );
  }

  factory HoldingSnapshot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HoldingSnapshot(
      id: serializer.fromJson<int>(json['id']),
      accountId: serializer.fromJson<int>(json['accountId']),
      securityId: serializer.fromJson<int>(json['securityId']),
      asOf: serializer.fromJson<DateTime>(json['asOf']),
      unitsE4: serializer.fromJson<int>(json['unitsE4']),
      priceE4: serializer.fromJson<int>(json['priceE4']),
      valuePaise: serializer.fromJson<int>(json['valuePaise']),
      costPaise: serializer.fromJson<int?>(json['costPaise']),
      importId: serializer.fromJson<int?>(json['importId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'accountId': serializer.toJson<int>(accountId),
      'securityId': serializer.toJson<int>(securityId),
      'asOf': serializer.toJson<DateTime>(asOf),
      'unitsE4': serializer.toJson<int>(unitsE4),
      'priceE4': serializer.toJson<int>(priceE4),
      'valuePaise': serializer.toJson<int>(valuePaise),
      'costPaise': serializer.toJson<int?>(costPaise),
      'importId': serializer.toJson<int?>(importId),
    };
  }

  HoldingSnapshot copyWith({
    int? id,
    int? accountId,
    int? securityId,
    DateTime? asOf,
    int? unitsE4,
    int? priceE4,
    int? valuePaise,
    Value<int?> costPaise = const Value.absent(),
    Value<int?> importId = const Value.absent(),
  }) => HoldingSnapshot(
    id: id ?? this.id,
    accountId: accountId ?? this.accountId,
    securityId: securityId ?? this.securityId,
    asOf: asOf ?? this.asOf,
    unitsE4: unitsE4 ?? this.unitsE4,
    priceE4: priceE4 ?? this.priceE4,
    valuePaise: valuePaise ?? this.valuePaise,
    costPaise: costPaise.present ? costPaise.value : this.costPaise,
    importId: importId.present ? importId.value : this.importId,
  );
  HoldingSnapshot copyWithCompanion(HoldingSnapshotsCompanion data) {
    return HoldingSnapshot(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      securityId: data.securityId.present
          ? data.securityId.value
          : this.securityId,
      asOf: data.asOf.present ? data.asOf.value : this.asOf,
      unitsE4: data.unitsE4.present ? data.unitsE4.value : this.unitsE4,
      priceE4: data.priceE4.present ? data.priceE4.value : this.priceE4,
      valuePaise: data.valuePaise.present
          ? data.valuePaise.value
          : this.valuePaise,
      costPaise: data.costPaise.present ? data.costPaise.value : this.costPaise,
      importId: data.importId.present ? data.importId.value : this.importId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HoldingSnapshot(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('securityId: $securityId, ')
          ..write('asOf: $asOf, ')
          ..write('unitsE4: $unitsE4, ')
          ..write('priceE4: $priceE4, ')
          ..write('valuePaise: $valuePaise, ')
          ..write('costPaise: $costPaise, ')
          ..write('importId: $importId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    accountId,
    securityId,
    asOf,
    unitsE4,
    priceE4,
    valuePaise,
    costPaise,
    importId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HoldingSnapshot &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.securityId == this.securityId &&
          other.asOf == this.asOf &&
          other.unitsE4 == this.unitsE4 &&
          other.priceE4 == this.priceE4 &&
          other.valuePaise == this.valuePaise &&
          other.costPaise == this.costPaise &&
          other.importId == this.importId);
}

class HoldingSnapshotsCompanion extends UpdateCompanion<HoldingSnapshot> {
  final Value<int> id;
  final Value<int> accountId;
  final Value<int> securityId;
  final Value<DateTime> asOf;
  final Value<int> unitsE4;
  final Value<int> priceE4;
  final Value<int> valuePaise;
  final Value<int?> costPaise;
  final Value<int?> importId;
  const HoldingSnapshotsCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.securityId = const Value.absent(),
    this.asOf = const Value.absent(),
    this.unitsE4 = const Value.absent(),
    this.priceE4 = const Value.absent(),
    this.valuePaise = const Value.absent(),
    this.costPaise = const Value.absent(),
    this.importId = const Value.absent(),
  });
  HoldingSnapshotsCompanion.insert({
    this.id = const Value.absent(),
    required int accountId,
    required int securityId,
    required DateTime asOf,
    required int unitsE4,
    required int priceE4,
    required int valuePaise,
    this.costPaise = const Value.absent(),
    this.importId = const Value.absent(),
  }) : accountId = Value(accountId),
       securityId = Value(securityId),
       asOf = Value(asOf),
       unitsE4 = Value(unitsE4),
       priceE4 = Value(priceE4),
       valuePaise = Value(valuePaise);
  static Insertable<HoldingSnapshot> custom({
    Expression<int>? id,
    Expression<int>? accountId,
    Expression<int>? securityId,
    Expression<DateTime>? asOf,
    Expression<int>? unitsE4,
    Expression<int>? priceE4,
    Expression<int>? valuePaise,
    Expression<int>? costPaise,
    Expression<int>? importId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (securityId != null) 'security_id': securityId,
      if (asOf != null) 'as_of': asOf,
      if (unitsE4 != null) 'units_e4': unitsE4,
      if (priceE4 != null) 'price_e4': priceE4,
      if (valuePaise != null) 'value_paise': valuePaise,
      if (costPaise != null) 'cost_paise': costPaise,
      if (importId != null) 'import_id': importId,
    });
  }

  HoldingSnapshotsCompanion copyWith({
    Value<int>? id,
    Value<int>? accountId,
    Value<int>? securityId,
    Value<DateTime>? asOf,
    Value<int>? unitsE4,
    Value<int>? priceE4,
    Value<int>? valuePaise,
    Value<int?>? costPaise,
    Value<int?>? importId,
  }) {
    return HoldingSnapshotsCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      securityId: securityId ?? this.securityId,
      asOf: asOf ?? this.asOf,
      unitsE4: unitsE4 ?? this.unitsE4,
      priceE4: priceE4 ?? this.priceE4,
      valuePaise: valuePaise ?? this.valuePaise,
      costPaise: costPaise ?? this.costPaise,
      importId: importId ?? this.importId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (securityId.present) {
      map['security_id'] = Variable<int>(securityId.value);
    }
    if (asOf.present) {
      map['as_of'] = Variable<DateTime>(asOf.value);
    }
    if (unitsE4.present) {
      map['units_e4'] = Variable<int>(unitsE4.value);
    }
    if (priceE4.present) {
      map['price_e4'] = Variable<int>(priceE4.value);
    }
    if (valuePaise.present) {
      map['value_paise'] = Variable<int>(valuePaise.value);
    }
    if (costPaise.present) {
      map['cost_paise'] = Variable<int>(costPaise.value);
    }
    if (importId.present) {
      map['import_id'] = Variable<int>(importId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HoldingSnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('securityId: $securityId, ')
          ..write('asOf: $asOf, ')
          ..write('unitsE4: $unitsE4, ')
          ..write('priceE4: $priceE4, ')
          ..write('valuePaise: $valuePaise, ')
          ..write('costPaise: $costPaise, ')
          ..write('importId: $importId')
          ..write(')'))
        .toString();
  }
}

class $SecurityPricesTable extends SecurityPrices
    with TableInfo<$SecurityPricesTable, SecurityPrice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SecurityPricesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _securityIdMeta = const VerificationMeta(
    'securityId',
  );
  @override
  late final GeneratedColumn<int> securityId = GeneratedColumn<int>(
    'security_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES securities (id)',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceE4Meta = const VerificationMeta(
    'priceE4',
  );
  @override
  late final GeneratedColumn<int> priceE4 = GeneratedColumn<int>(
    'price_e4',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, securityId, date, priceE4, source];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'security_prices';
  @override
  VerificationContext validateIntegrity(
    Insertable<SecurityPrice> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('security_id')) {
      context.handle(
        _securityIdMeta,
        securityId.isAcceptableOrUnknown(data['security_id']!, _securityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_securityIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('price_e4')) {
      context.handle(
        _priceE4Meta,
        priceE4.isAcceptableOrUnknown(data['price_e4']!, _priceE4Meta),
      );
    } else if (isInserting) {
      context.missing(_priceE4Meta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {securityId, date},
  ];
  @override
  SecurityPrice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SecurityPrice(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      securityId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}security_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      priceE4: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price_e4'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
    );
  }

  @override
  $SecurityPricesTable createAlias(String alias) {
    return $SecurityPricesTable(attachedDatabase, alias);
  }
}

class SecurityPrice extends DataClass implements Insertable<SecurityPrice> {
  final int id;
  final int securityId;
  final DateTime date;
  final int priceE4;

  /// cas | amfi
  final String source;
  const SecurityPrice({
    required this.id,
    required this.securityId,
    required this.date,
    required this.priceE4,
    required this.source,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['security_id'] = Variable<int>(securityId);
    map['date'] = Variable<DateTime>(date);
    map['price_e4'] = Variable<int>(priceE4);
    map['source'] = Variable<String>(source);
    return map;
  }

  SecurityPricesCompanion toCompanion(bool nullToAbsent) {
    return SecurityPricesCompanion(
      id: Value(id),
      securityId: Value(securityId),
      date: Value(date),
      priceE4: Value(priceE4),
      source: Value(source),
    );
  }

  factory SecurityPrice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SecurityPrice(
      id: serializer.fromJson<int>(json['id']),
      securityId: serializer.fromJson<int>(json['securityId']),
      date: serializer.fromJson<DateTime>(json['date']),
      priceE4: serializer.fromJson<int>(json['priceE4']),
      source: serializer.fromJson<String>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'securityId': serializer.toJson<int>(securityId),
      'date': serializer.toJson<DateTime>(date),
      'priceE4': serializer.toJson<int>(priceE4),
      'source': serializer.toJson<String>(source),
    };
  }

  SecurityPrice copyWith({
    int? id,
    int? securityId,
    DateTime? date,
    int? priceE4,
    String? source,
  }) => SecurityPrice(
    id: id ?? this.id,
    securityId: securityId ?? this.securityId,
    date: date ?? this.date,
    priceE4: priceE4 ?? this.priceE4,
    source: source ?? this.source,
  );
  SecurityPrice copyWithCompanion(SecurityPricesCompanion data) {
    return SecurityPrice(
      id: data.id.present ? data.id.value : this.id,
      securityId: data.securityId.present
          ? data.securityId.value
          : this.securityId,
      date: data.date.present ? data.date.value : this.date,
      priceE4: data.priceE4.present ? data.priceE4.value : this.priceE4,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SecurityPrice(')
          ..write('id: $id, ')
          ..write('securityId: $securityId, ')
          ..write('date: $date, ')
          ..write('priceE4: $priceE4, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, securityId, date, priceE4, source);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SecurityPrice &&
          other.id == this.id &&
          other.securityId == this.securityId &&
          other.date == this.date &&
          other.priceE4 == this.priceE4 &&
          other.source == this.source);
}

class SecurityPricesCompanion extends UpdateCompanion<SecurityPrice> {
  final Value<int> id;
  final Value<int> securityId;
  final Value<DateTime> date;
  final Value<int> priceE4;
  final Value<String> source;
  const SecurityPricesCompanion({
    this.id = const Value.absent(),
    this.securityId = const Value.absent(),
    this.date = const Value.absent(),
    this.priceE4 = const Value.absent(),
    this.source = const Value.absent(),
  });
  SecurityPricesCompanion.insert({
    this.id = const Value.absent(),
    required int securityId,
    required DateTime date,
    required int priceE4,
    required String source,
  }) : securityId = Value(securityId),
       date = Value(date),
       priceE4 = Value(priceE4),
       source = Value(source);
  static Insertable<SecurityPrice> custom({
    Expression<int>? id,
    Expression<int>? securityId,
    Expression<DateTime>? date,
    Expression<int>? priceE4,
    Expression<String>? source,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (securityId != null) 'security_id': securityId,
      if (date != null) 'date': date,
      if (priceE4 != null) 'price_e4': priceE4,
      if (source != null) 'source': source,
    });
  }

  SecurityPricesCompanion copyWith({
    Value<int>? id,
    Value<int>? securityId,
    Value<DateTime>? date,
    Value<int>? priceE4,
    Value<String>? source,
  }) {
    return SecurityPricesCompanion(
      id: id ?? this.id,
      securityId: securityId ?? this.securityId,
      date: date ?? this.date,
      priceE4: priceE4 ?? this.priceE4,
      source: source ?? this.source,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (securityId.present) {
      map['security_id'] = Variable<int>(securityId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (priceE4.present) {
      map['price_e4'] = Variable<int>(priceE4.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SecurityPricesCompanion(')
          ..write('id: $id, ')
          ..write('securityId: $securityId, ')
          ..write('date: $date, ')
          ..write('priceE4: $priceE4, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }
}

class $ManualAssetsTable extends ManualAssets
    with TableInfo<$ManualAssetsTable, ManualAsset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ManualAssetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _interestBpMeta = const VerificationMeta(
    'interestBp',
  );
  @override
  late final GeneratedColumn<int> interestBp = GeneratedColumn<int>(
    'interest_bp',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maturityDateMeta = const VerificationMeta(
    'maturityDate',
  );
  @override
  late final GeneratedColumn<DateTime> maturityDate = GeneratedColumn<DateTime>(
    'maturity_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    kind,
    interestBp,
    startDate,
    maturityDate,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'manual_assets';
  @override
  VerificationContext validateIntegrity(
    Insertable<ManualAsset> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('interest_bp')) {
      context.handle(
        _interestBpMeta,
        interestBp.isAcceptableOrUnknown(data['interest_bp']!, _interestBpMeta),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('maturity_date')) {
      context.handle(
        _maturityDateMeta,
        maturityDate.isAcceptableOrUnknown(
          data['maturity_date']!,
          _maturityDateMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ManualAsset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ManualAsset(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      interestBp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interest_bp'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      ),
      maturityDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}maturity_date'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ManualAssetsTable createAlias(String alias) {
    return $ManualAssetsTable(attachedDatabase, alias);
  }
}

class ManualAsset extends DataClass implements Insertable<ManualAsset> {
  final int id;
  final String name;

  /// gold | fd | ppf | epf | nps | property | vehicle | cash | other |
  /// loan (liability)
  final String kind;

  /// FD only: yearly interest in basis points, compounded quarterly from
  /// [startDate] on the latest recorded value.
  final int? interestBp;
  final DateTime? startDate;
  final DateTime? maturityDate;
  final DateTime createdAt;
  const ManualAsset({
    required this.id,
    required this.name,
    required this.kind,
    this.interestBp,
    this.startDate,
    this.maturityDate,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || interestBp != null) {
      map['interest_bp'] = Variable<int>(interestBp);
    }
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || maturityDate != null) {
      map['maturity_date'] = Variable<DateTime>(maturityDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ManualAssetsCompanion toCompanion(bool nullToAbsent) {
    return ManualAssetsCompanion(
      id: Value(id),
      name: Value(name),
      kind: Value(kind),
      interestBp: interestBp == null && nullToAbsent
          ? const Value.absent()
          : Value(interestBp),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      maturityDate: maturityDate == null && nullToAbsent
          ? const Value.absent()
          : Value(maturityDate),
      createdAt: Value(createdAt),
    );
  }

  factory ManualAsset.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ManualAsset(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      interestBp: serializer.fromJson<int?>(json['interestBp']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      maturityDate: serializer.fromJson<DateTime?>(json['maturityDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'interestBp': serializer.toJson<int?>(interestBp),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'maturityDate': serializer.toJson<DateTime?>(maturityDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ManualAsset copyWith({
    int? id,
    String? name,
    String? kind,
    Value<int?> interestBp = const Value.absent(),
    Value<DateTime?> startDate = const Value.absent(),
    Value<DateTime?> maturityDate = const Value.absent(),
    DateTime? createdAt,
  }) => ManualAsset(
    id: id ?? this.id,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    interestBp: interestBp.present ? interestBp.value : this.interestBp,
    startDate: startDate.present ? startDate.value : this.startDate,
    maturityDate: maturityDate.present ? maturityDate.value : this.maturityDate,
    createdAt: createdAt ?? this.createdAt,
  );
  ManualAsset copyWithCompanion(ManualAssetsCompanion data) {
    return ManualAsset(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      interestBp: data.interestBp.present
          ? data.interestBp.value
          : this.interestBp,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      maturityDate: data.maturityDate.present
          ? data.maturityDate.value
          : this.maturityDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ManualAsset(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('interestBp: $interestBp, ')
          ..write('startDate: $startDate, ')
          ..write('maturityDate: $maturityDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    kind,
    interestBp,
    startDate,
    maturityDate,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ManualAsset &&
          other.id == this.id &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.interestBp == this.interestBp &&
          other.startDate == this.startDate &&
          other.maturityDate == this.maturityDate &&
          other.createdAt == this.createdAt);
}

class ManualAssetsCompanion extends UpdateCompanion<ManualAsset> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> kind;
  final Value<int?> interestBp;
  final Value<DateTime?> startDate;
  final Value<DateTime?> maturityDate;
  final Value<DateTime> createdAt;
  const ManualAssetsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.interestBp = const Value.absent(),
    this.startDate = const Value.absent(),
    this.maturityDate = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ManualAssetsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String kind,
    this.interestBp = const Value.absent(),
    this.startDate = const Value.absent(),
    this.maturityDate = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name),
       kind = Value(kind);
  static Insertable<ManualAsset> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<int>? interestBp,
    Expression<DateTime>? startDate,
    Expression<DateTime>? maturityDate,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (interestBp != null) 'interest_bp': interestBp,
      if (startDate != null) 'start_date': startDate,
      if (maturityDate != null) 'maturity_date': maturityDate,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ManualAssetsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? kind,
    Value<int?>? interestBp,
    Value<DateTime?>? startDate,
    Value<DateTime?>? maturityDate,
    Value<DateTime>? createdAt,
  }) {
    return ManualAssetsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      interestBp: interestBp ?? this.interestBp,
      startDate: startDate ?? this.startDate,
      maturityDate: maturityDate ?? this.maturityDate,
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
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (interestBp.present) {
      map['interest_bp'] = Variable<int>(interestBp.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (maturityDate.present) {
      map['maturity_date'] = Variable<DateTime>(maturityDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ManualAssetsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('interestBp: $interestBp, ')
          ..write('startDate: $startDate, ')
          ..write('maturityDate: $maturityDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ManualAssetValuesTable extends ManualAssetValues
    with TableInfo<$ManualAssetValuesTable, ManualAssetValue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ManualAssetValuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _assetIdMeta = const VerificationMeta(
    'assetId',
  );
  @override
  late final GeneratedColumn<int> assetId = GeneratedColumn<int>(
    'asset_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES manual_assets (id)',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valuePaiseMeta = const VerificationMeta(
    'valuePaise',
  );
  @override
  late final GeneratedColumn<int> valuePaise = GeneratedColumn<int>(
    'value_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, assetId, date, valuePaise];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'manual_asset_values';
  @override
  VerificationContext validateIntegrity(
    Insertable<ManualAssetValue> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('asset_id')) {
      context.handle(
        _assetIdMeta,
        assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_assetIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('value_paise')) {
      context.handle(
        _valuePaiseMeta,
        valuePaise.isAcceptableOrUnknown(data['value_paise']!, _valuePaiseMeta),
      );
    } else if (isInserting) {
      context.missing(_valuePaiseMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {assetId, date},
  ];
  @override
  ManualAssetValue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ManualAssetValue(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      assetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}asset_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      valuePaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}value_paise'],
      )!,
    );
  }

  @override
  $ManualAssetValuesTable createAlias(String alias) {
    return $ManualAssetValuesTable(attachedDatabase, alias);
  }
}

class ManualAssetValue extends DataClass
    implements Insertable<ManualAssetValue> {
  final int id;
  final int assetId;
  final DateTime date;

  /// Always positive; liabilities are subtracted by kind.
  final int valuePaise;
  const ManualAssetValue({
    required this.id,
    required this.assetId,
    required this.date,
    required this.valuePaise,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['asset_id'] = Variable<int>(assetId);
    map['date'] = Variable<DateTime>(date);
    map['value_paise'] = Variable<int>(valuePaise);
    return map;
  }

  ManualAssetValuesCompanion toCompanion(bool nullToAbsent) {
    return ManualAssetValuesCompanion(
      id: Value(id),
      assetId: Value(assetId),
      date: Value(date),
      valuePaise: Value(valuePaise),
    );
  }

  factory ManualAssetValue.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ManualAssetValue(
      id: serializer.fromJson<int>(json['id']),
      assetId: serializer.fromJson<int>(json['assetId']),
      date: serializer.fromJson<DateTime>(json['date']),
      valuePaise: serializer.fromJson<int>(json['valuePaise']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'assetId': serializer.toJson<int>(assetId),
      'date': serializer.toJson<DateTime>(date),
      'valuePaise': serializer.toJson<int>(valuePaise),
    };
  }

  ManualAssetValue copyWith({
    int? id,
    int? assetId,
    DateTime? date,
    int? valuePaise,
  }) => ManualAssetValue(
    id: id ?? this.id,
    assetId: assetId ?? this.assetId,
    date: date ?? this.date,
    valuePaise: valuePaise ?? this.valuePaise,
  );
  ManualAssetValue copyWithCompanion(ManualAssetValuesCompanion data) {
    return ManualAssetValue(
      id: data.id.present ? data.id.value : this.id,
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      date: data.date.present ? data.date.value : this.date,
      valuePaise: data.valuePaise.present
          ? data.valuePaise.value
          : this.valuePaise,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ManualAssetValue(')
          ..write('id: $id, ')
          ..write('assetId: $assetId, ')
          ..write('date: $date, ')
          ..write('valuePaise: $valuePaise')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, assetId, date, valuePaise);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ManualAssetValue &&
          other.id == this.id &&
          other.assetId == this.assetId &&
          other.date == this.date &&
          other.valuePaise == this.valuePaise);
}

class ManualAssetValuesCompanion extends UpdateCompanion<ManualAssetValue> {
  final Value<int> id;
  final Value<int> assetId;
  final Value<DateTime> date;
  final Value<int> valuePaise;
  const ManualAssetValuesCompanion({
    this.id = const Value.absent(),
    this.assetId = const Value.absent(),
    this.date = const Value.absent(),
    this.valuePaise = const Value.absent(),
  });
  ManualAssetValuesCompanion.insert({
    this.id = const Value.absent(),
    required int assetId,
    required DateTime date,
    required int valuePaise,
  }) : assetId = Value(assetId),
       date = Value(date),
       valuePaise = Value(valuePaise);
  static Insertable<ManualAssetValue> custom({
    Expression<int>? id,
    Expression<int>? assetId,
    Expression<DateTime>? date,
    Expression<int>? valuePaise,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (assetId != null) 'asset_id': assetId,
      if (date != null) 'date': date,
      if (valuePaise != null) 'value_paise': valuePaise,
    });
  }

  ManualAssetValuesCompanion copyWith({
    Value<int>? id,
    Value<int>? assetId,
    Value<DateTime>? date,
    Value<int>? valuePaise,
  }) {
    return ManualAssetValuesCompanion(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      date: date ?? this.date,
      valuePaise: valuePaise ?? this.valuePaise,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (assetId.present) {
      map['asset_id'] = Variable<int>(assetId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (valuePaise.present) {
      map['value_paise'] = Variable<int>(valuePaise.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ManualAssetValuesCompanion(')
          ..write('id: $id, ')
          ..write('assetId: $assetId, ')
          ..write('date: $date, ')
          ..write('valuePaise: $valuePaise')
          ..write(')'))
        .toString();
  }
}

abstract class _$ArthDatabase extends GeneratedDatabase {
  _$ArthDatabase(QueryExecutor e) : super(e);
  $ArthDatabaseManager get managers => $ArthDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $MerchantsTable merchants = $MerchantsTable(this);
  late final $MerchantAliasesTable merchantAliases = $MerchantAliasesTable(
    this,
  );
  late final $ImportsTable imports = $ImportsTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $TransactionImportsTable transactionImports =
      $TransactionImportsTable(this);
  late final $UserCorrectionsTable userCorrections = $UserCorrectionsTable(
    this,
  );
  late final $UnparsedSmsRowsTable unparsedSmsRows = $UnparsedSmsRowsTable(
    this,
  );
  late final $MandateNoticesTable mandateNotices = $MandateNoticesTable(this);
  late final $ModelInfoTable modelInfo = $ModelInfoTable(this);
  late final $UnparsedStatementRowsTable unparsedStatementRows =
      $UnparsedStatementRowsTable(this);
  late final $LlmJobsTable llmJobs = $LlmJobsTable(this);
  late final $LlmReviewItemsTable llmReviewItems = $LlmReviewItemsTable(this);
  late final $BudgetsTable budgets = $BudgetsTable(this);
  late final $StatementSummariesTable statementSummaries =
      $StatementSummariesTable(this);
  late final $CreditCardsTable creditCards = $CreditCardsTable(this);
  late final $GoalsTable goals = $GoalsTable(this);
  late final $GoalContributionsTable goalContributions =
      $GoalContributionsTable(this);
  late final $SecuritiesTable securities = $SecuritiesTable(this);
  late final $InvestmentAccountsTable investmentAccounts =
      $InvestmentAccountsTable(this);
  late final $InvestmentTxnsTable investmentTxns = $InvestmentTxnsTable(this);
  late final $HoldingSnapshotsTable holdingSnapshots = $HoldingSnapshotsTable(
    this,
  );
  late final $SecurityPricesTable securityPrices = $SecurityPricesTable(this);
  late final $ManualAssetsTable manualAssets = $ManualAssetsTable(this);
  late final $ManualAssetValuesTable manualAssetValues =
      $ManualAssetValuesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categories,
    merchants,
    merchantAliases,
    imports,
    transactions,
    transactionImports,
    userCorrections,
    unparsedSmsRows,
    mandateNotices,
    modelInfo,
    unparsedStatementRows,
    llmJobs,
    llmReviewItems,
    budgets,
    statementSummaries,
    creditCards,
    goals,
    goalContributions,
    securities,
    investmentAccounts,
    investmentTxns,
    holdingSnapshots,
    securityPrices,
    manualAssets,
    manualAssetValues,
  ];
}

typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      required String slug,
      required String name,
      Value<bool> isSystem,
      Value<int> sortOrder,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      Value<String> slug,
      Value<String> name,
      Value<bool> isSystem,
      Value<int> sortOrder,
    });

final class $$CategoriesTableReferences
    extends BaseReferences<_$ArthDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MerchantsTable, List<Merchant>>
  _merchantsRefsTable(_$ArthDatabase db) => MultiTypedResultKey.fromTable(
    db.merchants,
    aliasName: 'categories__id__merchants__default_category_id',
  );

  $$MerchantsTableProcessedTableManager get merchantsRefs {
    final manager = $$MerchantsTableTableManager(
      $_db,
      $_db.merchants,
    ).filter((f) => f.defaultCategoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_merchantsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TransactionsTable, List<Transaction>>
  _transactionsRefsTable(_$ArthDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: 'categories__id__transactions__category_id',
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BudgetsTable, List<Budget>> _budgetsRefsTable(
    _$ArthDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.budgets,
    aliasName: 'categories__id__budgets__category_id',
  );

  $$BudgetsTableProcessedTableManager get budgetsRefs {
    final manager = $$BudgetsTableTableManager(
      $_db,
      $_db.budgets,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_budgetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$ArthDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> merchantsRefs(
    Expression<bool> Function($$MerchantsTableFilterComposer f) f,
  ) {
    final $$MerchantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.merchants,
      getReferencedColumn: (t) => t.defaultCategoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MerchantsTableFilterComposer(
            $db: $db,
            $table: $db.merchants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> budgetsRefs(
    Expression<bool> Function($$BudgetsTableFilterComposer f) f,
  ) {
    final $$BudgetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.budgets,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetsTableFilterComposer(
            $db: $db,
            $table: $db.budgets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$ArthDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$ArthDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isSystem =>
      $composableBuilder(column: $table.isSystem, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> merchantsRefs<T extends Object>(
    Expression<T> Function($$MerchantsTableAnnotationComposer a) f,
  ) {
    final $$MerchantsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.merchants,
      getReferencedColumn: (t) => t.defaultCategoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MerchantsTableAnnotationComposer(
            $db: $db,
            $table: $db.merchants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> budgetsRefs<T extends Object>(
    Expression<T> Function($$BudgetsTableAnnotationComposer a) f,
  ) {
    final $$BudgetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.budgets,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetsTableAnnotationComposer(
            $db: $db,
            $table: $db.budgets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$ArthDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, $$CategoriesTableReferences),
          Category,
          PrefetchHooks Function({
            bool merchantsRefs,
            bool transactionsRefs,
            bool budgetsRefs,
          })
        > {
  $$CategoriesTableTableManager(_$ArthDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> slug = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                slug: slug,
                name: name,
                isSystem: isSystem,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String slug,
                required String name,
                Value<bool> isSystem = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                slug: slug,
                name: name,
                isSystem: isSystem,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                merchantsRefs = false,
                transactionsRefs = false,
                budgetsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (merchantsRefs) db.merchants,
                    if (transactionsRefs) db.transactions,
                    if (budgetsRefs) db.budgets,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (merchantsRefs)
                        await $_getPrefetchedData<
                          Category,
                          $CategoriesTable,
                          Merchant
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._merchantsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).merchantsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.defaultCategoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (transactionsRefs)
                        await $_getPrefetchedData<
                          Category,
                          $CategoriesTable,
                          Transaction
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._transactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (budgetsRefs)
                        await $_getPrefetchedData<
                          Category,
                          $CategoriesTable,
                          Budget
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._budgetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).budgetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$ArthDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, $$CategoriesTableReferences),
      Category,
      PrefetchHooks Function({
        bool merchantsRefs,
        bool transactionsRefs,
        bool budgetsRefs,
      })
    >;
typedef $$MerchantsTableCreateCompanionBuilder =
    MerchantsCompanion Function({
      Value<int> id,
      required String canonicalName,
      Value<int?> defaultCategoryId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$MerchantsTableUpdateCompanionBuilder =
    MerchantsCompanion Function({
      Value<int> id,
      Value<String> canonicalName,
      Value<int?> defaultCategoryId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$MerchantsTableReferences
    extends BaseReferences<_$ArthDatabase, $MerchantsTable, Merchant> {
  $$MerchantsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _defaultCategoryIdTable(_$ArthDatabase db) => db
      .categories
      .createAlias('merchants__default_category_id__categories__id');

  $$CategoriesTableProcessedTableManager? get defaultCategoryId {
    final $_column = $_itemColumn<int>('default_category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_defaultCategoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$MerchantAliasesTable, List<MerchantAliase>>
  _merchantAliasesRefsTable(_$ArthDatabase db) => MultiTypedResultKey.fromTable(
    db.merchantAliases,
    aliasName: 'merchants__id__merchant_aliases__merchant_id',
  );

  $$MerchantAliasesTableProcessedTableManager get merchantAliasesRefs {
    final manager = $$MerchantAliasesTableTableManager(
      $_db,
      $_db.merchantAliases,
    ).filter((f) => f.merchantId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _merchantAliasesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TransactionsTable, List<Transaction>>
  _transactionsRefsTable(_$ArthDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: 'merchants__id__transactions__merchant_id',
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.merchantId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MerchantsTableFilterComposer
    extends Composer<_$ArthDatabase, $MerchantsTable> {
  $$MerchantsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get canonicalName => $composableBuilder(
    column: $table.canonicalName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get defaultCategoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.defaultCategoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> merchantAliasesRefs(
    Expression<bool> Function($$MerchantAliasesTableFilterComposer f) f,
  ) {
    final $$MerchantAliasesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.merchantAliases,
      getReferencedColumn: (t) => t.merchantId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MerchantAliasesTableFilterComposer(
            $db: $db,
            $table: $db.merchantAliases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.merchantId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MerchantsTableOrderingComposer
    extends Composer<_$ArthDatabase, $MerchantsTable> {
  $$MerchantsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get canonicalName => $composableBuilder(
    column: $table.canonicalName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get defaultCategoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.defaultCategoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MerchantsTableAnnotationComposer
    extends Composer<_$ArthDatabase, $MerchantsTable> {
  $$MerchantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get canonicalName => $composableBuilder(
    column: $table.canonicalName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get defaultCategoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.defaultCategoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> merchantAliasesRefs<T extends Object>(
    Expression<T> Function($$MerchantAliasesTableAnnotationComposer a) f,
  ) {
    final $$MerchantAliasesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.merchantAliases,
      getReferencedColumn: (t) => t.merchantId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MerchantAliasesTableAnnotationComposer(
            $db: $db,
            $table: $db.merchantAliases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.merchantId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MerchantsTableTableManager
    extends
        RootTableManager<
          _$ArthDatabase,
          $MerchantsTable,
          Merchant,
          $$MerchantsTableFilterComposer,
          $$MerchantsTableOrderingComposer,
          $$MerchantsTableAnnotationComposer,
          $$MerchantsTableCreateCompanionBuilder,
          $$MerchantsTableUpdateCompanionBuilder,
          (Merchant, $$MerchantsTableReferences),
          Merchant,
          PrefetchHooks Function({
            bool defaultCategoryId,
            bool merchantAliasesRefs,
            bool transactionsRefs,
          })
        > {
  $$MerchantsTableTableManager(_$ArthDatabase db, $MerchantsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MerchantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MerchantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MerchantsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> canonicalName = const Value.absent(),
                Value<int?> defaultCategoryId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => MerchantsCompanion(
                id: id,
                canonicalName: canonicalName,
                defaultCategoryId: defaultCategoryId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String canonicalName,
                Value<int?> defaultCategoryId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => MerchantsCompanion.insert(
                id: id,
                canonicalName: canonicalName,
                defaultCategoryId: defaultCategoryId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MerchantsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                defaultCategoryId = false,
                merchantAliasesRefs = false,
                transactionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (merchantAliasesRefs) db.merchantAliases,
                    if (transactionsRefs) db.transactions,
                  ],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (defaultCategoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.defaultCategoryId,
                                    referencedTable: $$MerchantsTableReferences
                                        ._defaultCategoryIdTable(db),
                                    referencedColumn: $$MerchantsTableReferences
                                        ._defaultCategoryIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (merchantAliasesRefs)
                        await $_getPrefetchedData<
                          Merchant,
                          $MerchantsTable,
                          MerchantAliase
                        >(
                          currentTable: table,
                          referencedTable: $$MerchantsTableReferences
                              ._merchantAliasesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MerchantsTableReferences(
                                db,
                                table,
                                p0,
                              ).merchantAliasesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.merchantId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (transactionsRefs)
                        await $_getPrefetchedData<
                          Merchant,
                          $MerchantsTable,
                          Transaction
                        >(
                          currentTable: table,
                          referencedTable: $$MerchantsTableReferences
                              ._transactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MerchantsTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.merchantId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MerchantsTableProcessedTableManager =
    ProcessedTableManager<
      _$ArthDatabase,
      $MerchantsTable,
      Merchant,
      $$MerchantsTableFilterComposer,
      $$MerchantsTableOrderingComposer,
      $$MerchantsTableAnnotationComposer,
      $$MerchantsTableCreateCompanionBuilder,
      $$MerchantsTableUpdateCompanionBuilder,
      (Merchant, $$MerchantsTableReferences),
      Merchant,
      PrefetchHooks Function({
        bool defaultCategoryId,
        bool merchantAliasesRefs,
        bool transactionsRefs,
      })
    >;
typedef $$MerchantAliasesTableCreateCompanionBuilder =
    MerchantAliasesCompanion Function({
      Value<int> id,
      required String rawName,
      required int merchantId,
      required String source,
      Value<double?> confidence,
      Value<DateTime> createdAt,
    });
typedef $$MerchantAliasesTableUpdateCompanionBuilder =
    MerchantAliasesCompanion Function({
      Value<int> id,
      Value<String> rawName,
      Value<int> merchantId,
      Value<String> source,
      Value<double?> confidence,
      Value<DateTime> createdAt,
    });

final class $$MerchantAliasesTableReferences
    extends
        BaseReferences<_$ArthDatabase, $MerchantAliasesTable, MerchantAliase> {
  $$MerchantAliasesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MerchantsTable _merchantIdTable(_$ArthDatabase db) =>
      db.merchants.createAlias('merchant_aliases__merchant_id__merchants__id');

  $$MerchantsTableProcessedTableManager get merchantId {
    final $_column = $_itemColumn<int>('merchant_id')!;

    final manager = $$MerchantsTableTableManager(
      $_db,
      $_db.merchants,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_merchantIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MerchantAliasesTableFilterComposer
    extends Composer<_$ArthDatabase, $MerchantAliasesTable> {
  $$MerchantAliasesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawName => $composableBuilder(
    column: $table.rawName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MerchantsTableFilterComposer get merchantId {
    final $$MerchantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.merchantId,
      referencedTable: $db.merchants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MerchantsTableFilterComposer(
            $db: $db,
            $table: $db.merchants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MerchantAliasesTableOrderingComposer
    extends Composer<_$ArthDatabase, $MerchantAliasesTable> {
  $$MerchantAliasesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawName => $composableBuilder(
    column: $table.rawName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MerchantsTableOrderingComposer get merchantId {
    final $$MerchantsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.merchantId,
      referencedTable: $db.merchants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MerchantsTableOrderingComposer(
            $db: $db,
            $table: $db.merchants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MerchantAliasesTableAnnotationComposer
    extends Composer<_$ArthDatabase, $MerchantAliasesTable> {
  $$MerchantAliasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get rawName =>
      $composableBuilder(column: $table.rawName, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$MerchantsTableAnnotationComposer get merchantId {
    final $$MerchantsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.merchantId,
      referencedTable: $db.merchants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MerchantsTableAnnotationComposer(
            $db: $db,
            $table: $db.merchants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MerchantAliasesTableTableManager
    extends
        RootTableManager<
          _$ArthDatabase,
          $MerchantAliasesTable,
          MerchantAliase,
          $$MerchantAliasesTableFilterComposer,
          $$MerchantAliasesTableOrderingComposer,
          $$MerchantAliasesTableAnnotationComposer,
          $$MerchantAliasesTableCreateCompanionBuilder,
          $$MerchantAliasesTableUpdateCompanionBuilder,
          (MerchantAliase, $$MerchantAliasesTableReferences),
          MerchantAliase,
          PrefetchHooks Function({bool merchantId})
        > {
  $$MerchantAliasesTableTableManager(
    _$ArthDatabase db,
    $MerchantAliasesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MerchantAliasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MerchantAliasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MerchantAliasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> rawName = const Value.absent(),
                Value<int> merchantId = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MerchantAliasesCompanion(
                id: id,
                rawName: rawName,
                merchantId: merchantId,
                source: source,
                confidence: confidence,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String rawName,
                required int merchantId,
                required String source,
                Value<double?> confidence = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MerchantAliasesCompanion.insert(
                id: id,
                rawName: rawName,
                merchantId: merchantId,
                source: source,
                confidence: confidence,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MerchantAliasesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({merchantId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (merchantId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.merchantId,
                                referencedTable:
                                    $$MerchantAliasesTableReferences
                                        ._merchantIdTable(db),
                                referencedColumn:
                                    $$MerchantAliasesTableReferences
                                        ._merchantIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MerchantAliasesTableProcessedTableManager =
    ProcessedTableManager<
      _$ArthDatabase,
      $MerchantAliasesTable,
      MerchantAliase,
      $$MerchantAliasesTableFilterComposer,
      $$MerchantAliasesTableOrderingComposer,
      $$MerchantAliasesTableAnnotationComposer,
      $$MerchantAliasesTableCreateCompanionBuilder,
      $$MerchantAliasesTableUpdateCompanionBuilder,
      (MerchantAliase, $$MerchantAliasesTableReferences),
      MerchantAliase,
      PrefetchHooks Function({bool merchantId})
    >;
typedef $$ImportsTableCreateCompanionBuilder =
    ImportsCompanion Function({
      Value<int> id,
      required String sourceType,
      required String sourceLabel,
      required String contentHash,
      Value<DateTime> importedAt,
      Value<String> status,
      Value<int> rowCount,
      Value<int> parsedCount,
      Value<int> skippedCount,
      Value<int> duplicateCount,
      Value<String?> notes,
    });
typedef $$ImportsTableUpdateCompanionBuilder =
    ImportsCompanion Function({
      Value<int> id,
      Value<String> sourceType,
      Value<String> sourceLabel,
      Value<String> contentHash,
      Value<DateTime> importedAt,
      Value<String> status,
      Value<int> rowCount,
      Value<int> parsedCount,
      Value<int> skippedCount,
      Value<int> duplicateCount,
      Value<String?> notes,
    });

final class $$ImportsTableReferences
    extends BaseReferences<_$ArthDatabase, $ImportsTable, Import> {
  $$ImportsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TransactionsTable, List<Transaction>>
  _transactionsRefsTable(_$ArthDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: 'imports__id__transactions__import_id',
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.importId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TransactionImportsTable, List<TransactionImport>>
  _transactionImportsRefsTable(_$ArthDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.transactionImports,
        aliasName: 'imports__id__transaction_imports__import_id',
      );

  $$TransactionImportsTableProcessedTableManager get transactionImportsRefs {
    final manager = $$TransactionImportsTableTableManager(
      $_db,
      $_db.transactionImports,
    ).filter((f) => f.importId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _transactionImportsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $UnparsedStatementRowsTable,
    List<UnparsedStatementRow>
  >
  _unparsedStatementRowsRefsTable(_$ArthDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.unparsedStatementRows,
        aliasName: 'imports__id__unparsed_statement_rows__import_id',
      );

  $$UnparsedStatementRowsTableProcessedTableManager
  get unparsedStatementRowsRefs {
    final manager = $$UnparsedStatementRowsTableTableManager(
      $_db,
      $_db.unparsedStatementRows,
    ).filter((f) => f.importId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _unparsedStatementRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $StatementSummariesTable,
    List<StatementSummaryRow>
  >
  _statementSummariesRefsTable(_$ArthDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.statementSummaries,
        aliasName: 'imports__id__statement_summaries__import_id',
      );

  $$StatementSummariesTableProcessedTableManager get statementSummariesRefs {
    final manager = $$StatementSummariesTableTableManager(
      $_db,
      $_db.statementSummaries,
    ).filter((f) => f.importId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _statementSummariesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$InvestmentTxnsTable, List<InvestmentTxn>>
  _investmentTxnsRefsTable(_$ArthDatabase db) => MultiTypedResultKey.fromTable(
    db.investmentTxns,
    aliasName: 'imports__id__investment_txns__import_id',
  );

  $$InvestmentTxnsTableProcessedTableManager get investmentTxnsRefs {
    final manager = $$InvestmentTxnsTableTableManager(
      $_db,
      $_db.investmentTxns,
    ).filter((f) => f.importId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_investmentTxnsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$HoldingSnapshotsTable, List<HoldingSnapshot>>
  _holdingSnapshotsRefsTable(_$ArthDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.holdingSnapshots,
        aliasName: 'imports__id__holding_snapshots__import_id',
      );

  $$HoldingSnapshotsTableProcessedTableManager get holdingSnapshotsRefs {
    final manager = $$HoldingSnapshotsTableTableManager(
      $_db,
      $_db.holdingSnapshots,
    ).filter((f) => f.importId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _holdingSnapshotsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ImportsTableFilterComposer
    extends Composer<_$ArthDatabase, $ImportsTable> {
  $$ImportsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceLabel => $composableBuilder(
    column: $table.sourceLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rowCount => $composableBuilder(
    column: $table.rowCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get parsedCount => $composableBuilder(
    column: $table.parsedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get skippedCount => $composableBuilder(
    column: $table.skippedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duplicateCount => $composableBuilder(
    column: $table.duplicateCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.importId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> transactionImportsRefs(
    Expression<bool> Function($$TransactionImportsTableFilterComposer f) f,
  ) {
    final $$TransactionImportsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactionImports,
      getReferencedColumn: (t) => t.importId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionImportsTableFilterComposer(
            $db: $db,
            $table: $db.transactionImports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> unparsedStatementRowsRefs(
    Expression<bool> Function($$UnparsedStatementRowsTableFilterComposer f) f,
  ) {
    final $$UnparsedStatementRowsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.unparsedStatementRows,
          getReferencedColumn: (t) => t.importId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$UnparsedStatementRowsTableFilterComposer(
                $db: $db,
                $table: $db.unparsedStatementRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> statementSummariesRefs(
    Expression<bool> Function($$StatementSummariesTableFilterComposer f) f,
  ) {
    final $$StatementSummariesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.statementSummaries,
      getReferencedColumn: (t) => t.importId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StatementSummariesTableFilterComposer(
            $db: $db,
            $table: $db.statementSummaries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> investmentTxnsRefs(
    Expression<bool> Function($$InvestmentTxnsTableFilterComposer f) f,
  ) {
    final $$InvestmentTxnsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.investmentTxns,
      getReferencedColumn: (t) => t.importId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestmentTxnsTableFilterComposer(
            $db: $db,
            $table: $db.investmentTxns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> holdingSnapshotsRefs(
    Expression<bool> Function($$HoldingSnapshotsTableFilterComposer f) f,
  ) {
    final $$HoldingSnapshotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.holdingSnapshots,
      getReferencedColumn: (t) => t.importId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HoldingSnapshotsTableFilterComposer(
            $db: $db,
            $table: $db.holdingSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ImportsTableOrderingComposer
    extends Composer<_$ArthDatabase, $ImportsTable> {
  $$ImportsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceLabel => $composableBuilder(
    column: $table.sourceLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rowCount => $composableBuilder(
    column: $table.rowCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get parsedCount => $composableBuilder(
    column: $table.parsedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get skippedCount => $composableBuilder(
    column: $table.skippedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duplicateCount => $composableBuilder(
    column: $table.duplicateCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ImportsTableAnnotationComposer
    extends Composer<_$ArthDatabase, $ImportsTable> {
  $$ImportsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceLabel => $composableBuilder(
    column: $table.sourceLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get rowCount =>
      $composableBuilder(column: $table.rowCount, builder: (column) => column);

  GeneratedColumn<int> get parsedCount => $composableBuilder(
    column: $table.parsedCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get skippedCount => $composableBuilder(
    column: $table.skippedCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get duplicateCount => $composableBuilder(
    column: $table.duplicateCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.importId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> transactionImportsRefs<T extends Object>(
    Expression<T> Function($$TransactionImportsTableAnnotationComposer a) f,
  ) {
    final $$TransactionImportsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.transactionImports,
          getReferencedColumn: (t) => t.importId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TransactionImportsTableAnnotationComposer(
                $db: $db,
                $table: $db.transactionImports,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> unparsedStatementRowsRefs<T extends Object>(
    Expression<T> Function($$UnparsedStatementRowsTableAnnotationComposer a) f,
  ) {
    final $$UnparsedStatementRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.unparsedStatementRows,
          getReferencedColumn: (t) => t.importId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$UnparsedStatementRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.unparsedStatementRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> statementSummariesRefs<T extends Object>(
    Expression<T> Function($$StatementSummariesTableAnnotationComposer a) f,
  ) {
    final $$StatementSummariesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.statementSummaries,
          getReferencedColumn: (t) => t.importId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StatementSummariesTableAnnotationComposer(
                $db: $db,
                $table: $db.statementSummaries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> investmentTxnsRefs<T extends Object>(
    Expression<T> Function($$InvestmentTxnsTableAnnotationComposer a) f,
  ) {
    final $$InvestmentTxnsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.investmentTxns,
      getReferencedColumn: (t) => t.importId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestmentTxnsTableAnnotationComposer(
            $db: $db,
            $table: $db.investmentTxns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> holdingSnapshotsRefs<T extends Object>(
    Expression<T> Function($$HoldingSnapshotsTableAnnotationComposer a) f,
  ) {
    final $$HoldingSnapshotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.holdingSnapshots,
      getReferencedColumn: (t) => t.importId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HoldingSnapshotsTableAnnotationComposer(
            $db: $db,
            $table: $db.holdingSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ImportsTableTableManager
    extends
        RootTableManager<
          _$ArthDatabase,
          $ImportsTable,
          Import,
          $$ImportsTableFilterComposer,
          $$ImportsTableOrderingComposer,
          $$ImportsTableAnnotationComposer,
          $$ImportsTableCreateCompanionBuilder,
          $$ImportsTableUpdateCompanionBuilder,
          (Import, $$ImportsTableReferences),
          Import,
          PrefetchHooks Function({
            bool transactionsRefs,
            bool transactionImportsRefs,
            bool unparsedStatementRowsRefs,
            bool statementSummariesRefs,
            bool investmentTxnsRefs,
            bool holdingSnapshotsRefs,
          })
        > {
  $$ImportsTableTableManager(_$ArthDatabase db, $ImportsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImportsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImportsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> sourceType = const Value.absent(),
                Value<String> sourceLabel = const Value.absent(),
                Value<String> contentHash = const Value.absent(),
                Value<DateTime> importedAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowCount = const Value.absent(),
                Value<int> parsedCount = const Value.absent(),
                Value<int> skippedCount = const Value.absent(),
                Value<int> duplicateCount = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => ImportsCompanion(
                id: id,
                sourceType: sourceType,
                sourceLabel: sourceLabel,
                contentHash: contentHash,
                importedAt: importedAt,
                status: status,
                rowCount: rowCount,
                parsedCount: parsedCount,
                skippedCount: skippedCount,
                duplicateCount: duplicateCount,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String sourceType,
                required String sourceLabel,
                required String contentHash,
                Value<DateTime> importedAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowCount = const Value.absent(),
                Value<int> parsedCount = const Value.absent(),
                Value<int> skippedCount = const Value.absent(),
                Value<int> duplicateCount = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => ImportsCompanion.insert(
                id: id,
                sourceType: sourceType,
                sourceLabel: sourceLabel,
                contentHash: contentHash,
                importedAt: importedAt,
                status: status,
                rowCount: rowCount,
                parsedCount: parsedCount,
                skippedCount: skippedCount,
                duplicateCount: duplicateCount,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ImportsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                transactionsRefs = false,
                transactionImportsRefs = false,
                unparsedStatementRowsRefs = false,
                statementSummariesRefs = false,
                investmentTxnsRefs = false,
                holdingSnapshotsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transactionsRefs) db.transactions,
                    if (transactionImportsRefs) db.transactionImports,
                    if (unparsedStatementRowsRefs) db.unparsedStatementRows,
                    if (statementSummariesRefs) db.statementSummaries,
                    if (investmentTxnsRefs) db.investmentTxns,
                    if (holdingSnapshotsRefs) db.holdingSnapshots,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transactionsRefs)
                        await $_getPrefetchedData<
                          Import,
                          $ImportsTable,
                          Transaction
                        >(
                          currentTable: table,
                          referencedTable: $$ImportsTableReferences
                              ._transactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ImportsTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.importId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (transactionImportsRefs)
                        await $_getPrefetchedData<
                          Import,
                          $ImportsTable,
                          TransactionImport
                        >(
                          currentTable: table,
                          referencedTable: $$ImportsTableReferences
                              ._transactionImportsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ImportsTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionImportsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.importId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (unparsedStatementRowsRefs)
                        await $_getPrefetchedData<
                          Import,
                          $ImportsTable,
                          UnparsedStatementRow
                        >(
                          currentTable: table,
                          referencedTable: $$ImportsTableReferences
                              ._unparsedStatementRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ImportsTableReferences(
                                db,
                                table,
                                p0,
                              ).unparsedStatementRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.importId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (statementSummariesRefs)
                        await $_getPrefetchedData<
                          Import,
                          $ImportsTable,
                          StatementSummaryRow
                        >(
                          currentTable: table,
                          referencedTable: $$ImportsTableReferences
                              ._statementSummariesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ImportsTableReferences(
                                db,
                                table,
                                p0,
                              ).statementSummariesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.importId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (investmentTxnsRefs)
                        await $_getPrefetchedData<
                          Import,
                          $ImportsTable,
                          InvestmentTxn
                        >(
                          currentTable: table,
                          referencedTable: $$ImportsTableReferences
                              ._investmentTxnsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ImportsTableReferences(
                                db,
                                table,
                                p0,
                              ).investmentTxnsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.importId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (holdingSnapshotsRefs)
                        await $_getPrefetchedData<
                          Import,
                          $ImportsTable,
                          HoldingSnapshot
                        >(
                          currentTable: table,
                          referencedTable: $$ImportsTableReferences
                              ._holdingSnapshotsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ImportsTableReferences(
                                db,
                                table,
                                p0,
                              ).holdingSnapshotsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.importId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ImportsTableProcessedTableManager =
    ProcessedTableManager<
      _$ArthDatabase,
      $ImportsTable,
      Import,
      $$ImportsTableFilterComposer,
      $$ImportsTableOrderingComposer,
      $$ImportsTableAnnotationComposer,
      $$ImportsTableCreateCompanionBuilder,
      $$ImportsTableUpdateCompanionBuilder,
      (Import, $$ImportsTableReferences),
      Import,
      PrefetchHooks Function({
        bool transactionsRefs,
        bool transactionImportsRefs,
        bool unparsedStatementRowsRefs,
        bool statementSummariesRefs,
        bool investmentTxnsRefs,
        bool holdingSnapshotsRefs,
      })
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      required int amountPaise,
      Value<String> currency,
      required String direction,
      required String txnType,
      required DateTime bookedAt,
      Value<DateTime?> valueDate,
      required String bankCode,
      Value<String?> accountHint,
      Value<int?> merchantId,
      Value<int?> categoryId,
      Value<String?> suggestedCategorySlug,
      Value<String?> categorySource,
      required String rawMerchant,
      required String rawDescription,
      Value<String?> upiPayerVpa,
      Value<String?> upiPayeeVpa,
      Value<String?> upiRef,
      Value<String?> remarks,
      Value<String?> externalRef,
      Value<int?> balanceAfterPaise,
      required String dedupeHash,
      Value<int?> importId,
      Value<bool> isRecurringCandidate,
      Value<String?> recurringKind,
      Value<String?> accountKind,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      Value<int> amountPaise,
      Value<String> currency,
      Value<String> direction,
      Value<String> txnType,
      Value<DateTime> bookedAt,
      Value<DateTime?> valueDate,
      Value<String> bankCode,
      Value<String?> accountHint,
      Value<int?> merchantId,
      Value<int?> categoryId,
      Value<String?> suggestedCategorySlug,
      Value<String?> categorySource,
      Value<String> rawMerchant,
      Value<String> rawDescription,
      Value<String?> upiPayerVpa,
      Value<String?> upiPayeeVpa,
      Value<String?> upiRef,
      Value<String?> remarks,
      Value<String?> externalRef,
      Value<int?> balanceAfterPaise,
      Value<String> dedupeHash,
      Value<int?> importId,
      Value<bool> isRecurringCandidate,
      Value<String?> recurringKind,
      Value<String?> accountKind,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$TransactionsTableReferences
    extends BaseReferences<_$ArthDatabase, $TransactionsTable, Transaction> {
  $$TransactionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MerchantsTable _merchantIdTable(_$ArthDatabase db) =>
      db.merchants.createAlias('transactions__merchant_id__merchants__id');

  $$MerchantsTableProcessedTableManager? get merchantId {
    final $_column = $_itemColumn<int>('merchant_id');
    if ($_column == null) return null;
    final manager = $$MerchantsTableTableManager(
      $_db,
      $_db.merchants,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_merchantIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CategoriesTable _categoryIdTable(_$ArthDatabase db) =>
      db.categories.createAlias('transactions__category_id__categories__id');

  $$CategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<int>('category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ImportsTable _importIdTable(_$ArthDatabase db) =>
      db.imports.createAlias('transactions__import_id__imports__id');

  $$ImportsTableProcessedTableManager? get importId {
    final $_column = $_itemColumn<int>('import_id');
    if ($_column == null) return null;
    final manager = $$ImportsTableTableManager(
      $_db,
      $_db.imports,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_importIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TransactionImportsTable, List<TransactionImport>>
  _transactionImportsRefsTable(_$ArthDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.transactionImports,
        aliasName: 'transactions__id__transaction_imports__transaction_id',
      );

  $$TransactionImportsTableProcessedTableManager get transactionImportsRefs {
    final manager = $$TransactionImportsTableTableManager(
      $_db,
      $_db.transactionImports,
    ).filter((f) => f.transactionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _transactionImportsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$UserCorrectionsTable, List<UserCorrection>>
  _userCorrectionsRefsTable(_$ArthDatabase db) => MultiTypedResultKey.fromTable(
    db.userCorrections,
    aliasName: 'transactions__id__user_corrections__transaction_id',
  );

  $$UserCorrectionsTableProcessedTableManager get userCorrectionsRefs {
    final manager = $$UserCorrectionsTableTableManager(
      $_db,
      $_db.userCorrections,
    ).filter((f) => f.transactionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _userCorrectionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LlmReviewItemsTable, List<LlmReviewItem>>
  _llmReviewItemsRefsTable(_$ArthDatabase db) => MultiTypedResultKey.fromTable(
    db.llmReviewItems,
    aliasName: 'transactions__id__llm_review_items__transaction_id',
  );

  $$LlmReviewItemsTableProcessedTableManager get llmReviewItemsRefs {
    final manager = $$LlmReviewItemsTableTableManager(
      $_db,
      $_db.llmReviewItems,
    ).filter((f) => f.transactionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_llmReviewItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TransactionsTableFilterComposer
    extends Composer<_$ArthDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get txnType => $composableBuilder(
    column: $table.txnType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get bookedAt => $composableBuilder(
    column: $table.bookedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get valueDate => $composableBuilder(
    column: $table.valueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bankCode => $composableBuilder(
    column: $table.bankCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountHint => $composableBuilder(
    column: $table.accountHint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get suggestedCategorySlug => $composableBuilder(
    column: $table.suggestedCategorySlug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categorySource => $composableBuilder(
    column: $table.categorySource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawMerchant => $composableBuilder(
    column: $table.rawMerchant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawDescription => $composableBuilder(
    column: $table.rawDescription,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get upiPayerVpa => $composableBuilder(
    column: $table.upiPayerVpa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get upiPayeeVpa => $composableBuilder(
    column: $table.upiPayeeVpa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get upiRef => $composableBuilder(
    column: $table.upiRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalRef => $composableBuilder(
    column: $table.externalRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get balanceAfterPaise => $composableBuilder(
    column: $table.balanceAfterPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dedupeHash => $composableBuilder(
    column: $table.dedupeHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRecurringCandidate => $composableBuilder(
    column: $table.isRecurringCandidate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurringKind => $composableBuilder(
    column: $table.recurringKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountKind => $composableBuilder(
    column: $table.accountKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MerchantsTableFilterComposer get merchantId {
    final $$MerchantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.merchantId,
      referencedTable: $db.merchants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MerchantsTableFilterComposer(
            $db: $db,
            $table: $db.merchants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportsTableFilterComposer get importId {
    final $$ImportsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableFilterComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> transactionImportsRefs(
    Expression<bool> Function($$TransactionImportsTableFilterComposer f) f,
  ) {
    final $$TransactionImportsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactionImports,
      getReferencedColumn: (t) => t.transactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionImportsTableFilterComposer(
            $db: $db,
            $table: $db.transactionImports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> userCorrectionsRefs(
    Expression<bool> Function($$UserCorrectionsTableFilterComposer f) f,
  ) {
    final $$UserCorrectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userCorrections,
      getReferencedColumn: (t) => t.transactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserCorrectionsTableFilterComposer(
            $db: $db,
            $table: $db.userCorrections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> llmReviewItemsRefs(
    Expression<bool> Function($$LlmReviewItemsTableFilterComposer f) f,
  ) {
    final $$LlmReviewItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.llmReviewItems,
      getReferencedColumn: (t) => t.transactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LlmReviewItemsTableFilterComposer(
            $db: $db,
            $table: $db.llmReviewItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$ArthDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get txnType => $composableBuilder(
    column: $table.txnType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get bookedAt => $composableBuilder(
    column: $table.bookedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get valueDate => $composableBuilder(
    column: $table.valueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bankCode => $composableBuilder(
    column: $table.bankCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountHint => $composableBuilder(
    column: $table.accountHint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get suggestedCategorySlug => $composableBuilder(
    column: $table.suggestedCategorySlug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categorySource => $composableBuilder(
    column: $table.categorySource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawMerchant => $composableBuilder(
    column: $table.rawMerchant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawDescription => $composableBuilder(
    column: $table.rawDescription,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get upiPayerVpa => $composableBuilder(
    column: $table.upiPayerVpa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get upiPayeeVpa => $composableBuilder(
    column: $table.upiPayeeVpa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get upiRef => $composableBuilder(
    column: $table.upiRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalRef => $composableBuilder(
    column: $table.externalRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get balanceAfterPaise => $composableBuilder(
    column: $table.balanceAfterPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dedupeHash => $composableBuilder(
    column: $table.dedupeHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRecurringCandidate => $composableBuilder(
    column: $table.isRecurringCandidate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurringKind => $composableBuilder(
    column: $table.recurringKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountKind => $composableBuilder(
    column: $table.accountKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MerchantsTableOrderingComposer get merchantId {
    final $$MerchantsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.merchantId,
      referencedTable: $db.merchants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MerchantsTableOrderingComposer(
            $db: $db,
            $table: $db.merchants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportsTableOrderingComposer get importId {
    final $$ImportsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableOrderingComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$ArthDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<String> get txnType =>
      $composableBuilder(column: $table.txnType, builder: (column) => column);

  GeneratedColumn<DateTime> get bookedAt =>
      $composableBuilder(column: $table.bookedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get valueDate =>
      $composableBuilder(column: $table.valueDate, builder: (column) => column);

  GeneratedColumn<String> get bankCode =>
      $composableBuilder(column: $table.bankCode, builder: (column) => column);

  GeneratedColumn<String> get accountHint => $composableBuilder(
    column: $table.accountHint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get suggestedCategorySlug => $composableBuilder(
    column: $table.suggestedCategorySlug,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categorySource => $composableBuilder(
    column: $table.categorySource,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawMerchant => $composableBuilder(
    column: $table.rawMerchant,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawDescription => $composableBuilder(
    column: $table.rawDescription,
    builder: (column) => column,
  );

  GeneratedColumn<String> get upiPayerVpa => $composableBuilder(
    column: $table.upiPayerVpa,
    builder: (column) => column,
  );

  GeneratedColumn<String> get upiPayeeVpa => $composableBuilder(
    column: $table.upiPayeeVpa,
    builder: (column) => column,
  );

  GeneratedColumn<String> get upiRef =>
      $composableBuilder(column: $table.upiRef, builder: (column) => column);

  GeneratedColumn<String> get remarks =>
      $composableBuilder(column: $table.remarks, builder: (column) => column);

  GeneratedColumn<String> get externalRef => $composableBuilder(
    column: $table.externalRef,
    builder: (column) => column,
  );

  GeneratedColumn<int> get balanceAfterPaise => $composableBuilder(
    column: $table.balanceAfterPaise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dedupeHash => $composableBuilder(
    column: $table.dedupeHash,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isRecurringCandidate => $composableBuilder(
    column: $table.isRecurringCandidate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recurringKind => $composableBuilder(
    column: $table.recurringKind,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accountKind => $composableBuilder(
    column: $table.accountKind,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$MerchantsTableAnnotationComposer get merchantId {
    final $$MerchantsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.merchantId,
      referencedTable: $db.merchants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MerchantsTableAnnotationComposer(
            $db: $db,
            $table: $db.merchants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportsTableAnnotationComposer get importId {
    final $$ImportsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableAnnotationComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> transactionImportsRefs<T extends Object>(
    Expression<T> Function($$TransactionImportsTableAnnotationComposer a) f,
  ) {
    final $$TransactionImportsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.transactionImports,
          getReferencedColumn: (t) => t.transactionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TransactionImportsTableAnnotationComposer(
                $db: $db,
                $table: $db.transactionImports,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> userCorrectionsRefs<T extends Object>(
    Expression<T> Function($$UserCorrectionsTableAnnotationComposer a) f,
  ) {
    final $$UserCorrectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userCorrections,
      getReferencedColumn: (t) => t.transactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserCorrectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.userCorrections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> llmReviewItemsRefs<T extends Object>(
    Expression<T> Function($$LlmReviewItemsTableAnnotationComposer a) f,
  ) {
    final $$LlmReviewItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.llmReviewItems,
      getReferencedColumn: (t) => t.transactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LlmReviewItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.llmReviewItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$ArthDatabase,
          $TransactionsTable,
          Transaction,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (Transaction, $$TransactionsTableReferences),
          Transaction,
          PrefetchHooks Function({
            bool merchantId,
            bool categoryId,
            bool importId,
            bool transactionImportsRefs,
            bool userCorrectionsRefs,
            bool llmReviewItemsRefs,
          })
        > {
  $$TransactionsTableTableManager(_$ArthDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> direction = const Value.absent(),
                Value<String> txnType = const Value.absent(),
                Value<DateTime> bookedAt = const Value.absent(),
                Value<DateTime?> valueDate = const Value.absent(),
                Value<String> bankCode = const Value.absent(),
                Value<String?> accountHint = const Value.absent(),
                Value<int?> merchantId = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<String?> suggestedCategorySlug = const Value.absent(),
                Value<String?> categorySource = const Value.absent(),
                Value<String> rawMerchant = const Value.absent(),
                Value<String> rawDescription = const Value.absent(),
                Value<String?> upiPayerVpa = const Value.absent(),
                Value<String?> upiPayeeVpa = const Value.absent(),
                Value<String?> upiRef = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<String?> externalRef = const Value.absent(),
                Value<int?> balanceAfterPaise = const Value.absent(),
                Value<String> dedupeHash = const Value.absent(),
                Value<int?> importId = const Value.absent(),
                Value<bool> isRecurringCandidate = const Value.absent(),
                Value<String?> recurringKind = const Value.absent(),
                Value<String?> accountKind = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                amountPaise: amountPaise,
                currency: currency,
                direction: direction,
                txnType: txnType,
                bookedAt: bookedAt,
                valueDate: valueDate,
                bankCode: bankCode,
                accountHint: accountHint,
                merchantId: merchantId,
                categoryId: categoryId,
                suggestedCategorySlug: suggestedCategorySlug,
                categorySource: categorySource,
                rawMerchant: rawMerchant,
                rawDescription: rawDescription,
                upiPayerVpa: upiPayerVpa,
                upiPayeeVpa: upiPayeeVpa,
                upiRef: upiRef,
                remarks: remarks,
                externalRef: externalRef,
                balanceAfterPaise: balanceAfterPaise,
                dedupeHash: dedupeHash,
                importId: importId,
                isRecurringCandidate: isRecurringCandidate,
                recurringKind: recurringKind,
                accountKind: accountKind,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int amountPaise,
                Value<String> currency = const Value.absent(),
                required String direction,
                required String txnType,
                required DateTime bookedAt,
                Value<DateTime?> valueDate = const Value.absent(),
                required String bankCode,
                Value<String?> accountHint = const Value.absent(),
                Value<int?> merchantId = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<String?> suggestedCategorySlug = const Value.absent(),
                Value<String?> categorySource = const Value.absent(),
                required String rawMerchant,
                required String rawDescription,
                Value<String?> upiPayerVpa = const Value.absent(),
                Value<String?> upiPayeeVpa = const Value.absent(),
                Value<String?> upiRef = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<String?> externalRef = const Value.absent(),
                Value<int?> balanceAfterPaise = const Value.absent(),
                required String dedupeHash,
                Value<int?> importId = const Value.absent(),
                Value<bool> isRecurringCandidate = const Value.absent(),
                Value<String?> recurringKind = const Value.absent(),
                Value<String?> accountKind = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                amountPaise: amountPaise,
                currency: currency,
                direction: direction,
                txnType: txnType,
                bookedAt: bookedAt,
                valueDate: valueDate,
                bankCode: bankCode,
                accountHint: accountHint,
                merchantId: merchantId,
                categoryId: categoryId,
                suggestedCategorySlug: suggestedCategorySlug,
                categorySource: categorySource,
                rawMerchant: rawMerchant,
                rawDescription: rawDescription,
                upiPayerVpa: upiPayerVpa,
                upiPayeeVpa: upiPayeeVpa,
                upiRef: upiRef,
                remarks: remarks,
                externalRef: externalRef,
                balanceAfterPaise: balanceAfterPaise,
                dedupeHash: dedupeHash,
                importId: importId,
                isRecurringCandidate: isRecurringCandidate,
                recurringKind: recurringKind,
                accountKind: accountKind,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                merchantId = false,
                categoryId = false,
                importId = false,
                transactionImportsRefs = false,
                userCorrectionsRefs = false,
                llmReviewItemsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transactionImportsRefs) db.transactionImports,
                    if (userCorrectionsRefs) db.userCorrections,
                    if (llmReviewItemsRefs) db.llmReviewItems,
                  ],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (merchantId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.merchantId,
                                    referencedTable:
                                        $$TransactionsTableReferences
                                            ._merchantIdTable(db),
                                    referencedColumn:
                                        $$TransactionsTableReferences
                                            ._merchantIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (categoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categoryId,
                                    referencedTable:
                                        $$TransactionsTableReferences
                                            ._categoryIdTable(db),
                                    referencedColumn:
                                        $$TransactionsTableReferences
                                            ._categoryIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (importId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.importId,
                                    referencedTable:
                                        $$TransactionsTableReferences
                                            ._importIdTable(db),
                                    referencedColumn:
                                        $$TransactionsTableReferences
                                            ._importIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transactionImportsRefs)
                        await $_getPrefetchedData<
                          Transaction,
                          $TransactionsTable,
                          TransactionImport
                        >(
                          currentTable: table,
                          referencedTable: $$TransactionsTableReferences
                              ._transactionImportsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TransactionsTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionImportsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.transactionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (userCorrectionsRefs)
                        await $_getPrefetchedData<
                          Transaction,
                          $TransactionsTable,
                          UserCorrection
                        >(
                          currentTable: table,
                          referencedTable: $$TransactionsTableReferences
                              ._userCorrectionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TransactionsTableReferences(
                                db,
                                table,
                                p0,
                              ).userCorrectionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.transactionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (llmReviewItemsRefs)
                        await $_getPrefetchedData<
                          Transaction,
                          $TransactionsTable,
                          LlmReviewItem
                        >(
                          currentTable: table,
                          referencedTable: $$TransactionsTableReferences
                              ._llmReviewItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TransactionsTableReferences(
                                db,
                                table,
                                p0,
                              ).llmReviewItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.transactionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$ArthDatabase,
      $TransactionsTable,
      Transaction,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (Transaction, $$TransactionsTableReferences),
      Transaction,
      PrefetchHooks Function({
        bool merchantId,
        bool categoryId,
        bool importId,
        bool transactionImportsRefs,
        bool userCorrectionsRefs,
        bool llmReviewItemsRefs,
      })
    >;
typedef $$TransactionImportsTableCreateCompanionBuilder =
    TransactionImportsCompanion Function({
      Value<int> id,
      required int transactionId,
      required int importId,
    });
typedef $$TransactionImportsTableUpdateCompanionBuilder =
    TransactionImportsCompanion Function({
      Value<int> id,
      Value<int> transactionId,
      Value<int> importId,
    });

final class $$TransactionImportsTableReferences
    extends
        BaseReferences<
          _$ArthDatabase,
          $TransactionImportsTable,
          TransactionImport
        > {
  $$TransactionImportsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TransactionsTable _transactionIdTable(_$ArthDatabase db) => db
      .transactions
      .createAlias('transaction_imports__transaction_id__transactions__id');

  $$TransactionsTableProcessedTableManager get transactionId {
    final $_column = $_itemColumn<int>('transaction_id')!;

    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ImportsTable _importIdTable(_$ArthDatabase db) =>
      db.imports.createAlias('transaction_imports__import_id__imports__id');

  $$ImportsTableProcessedTableManager get importId {
    final $_column = $_itemColumn<int>('import_id')!;

    final manager = $$ImportsTableTableManager(
      $_db,
      $_db.imports,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_importIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TransactionImportsTableFilterComposer
    extends Composer<_$ArthDatabase, $TransactionImportsTable> {
  $$TransactionImportsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  $$TransactionsTableFilterComposer get transactionId {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportsTableFilterComposer get importId {
    final $$ImportsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableFilterComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionImportsTableOrderingComposer
    extends Composer<_$ArthDatabase, $TransactionImportsTable> {
  $$TransactionImportsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  $$TransactionsTableOrderingComposer get transactionId {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableOrderingComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportsTableOrderingComposer get importId {
    final $$ImportsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableOrderingComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionImportsTableAnnotationComposer
    extends Composer<_$ArthDatabase, $TransactionImportsTable> {
  $$TransactionImportsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  $$TransactionsTableAnnotationComposer get transactionId {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportsTableAnnotationComposer get importId {
    final $$ImportsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableAnnotationComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionImportsTableTableManager
    extends
        RootTableManager<
          _$ArthDatabase,
          $TransactionImportsTable,
          TransactionImport,
          $$TransactionImportsTableFilterComposer,
          $$TransactionImportsTableOrderingComposer,
          $$TransactionImportsTableAnnotationComposer,
          $$TransactionImportsTableCreateCompanionBuilder,
          $$TransactionImportsTableUpdateCompanionBuilder,
          (TransactionImport, $$TransactionImportsTableReferences),
          TransactionImport,
          PrefetchHooks Function({bool transactionId, bool importId})
        > {
  $$TransactionImportsTableTableManager(
    _$ArthDatabase db,
    $TransactionImportsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionImportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionImportsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionImportsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> transactionId = const Value.absent(),
                Value<int> importId = const Value.absent(),
              }) => TransactionImportsCompanion(
                id: id,
                transactionId: transactionId,
                importId: importId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int transactionId,
                required int importId,
              }) => TransactionImportsCompanion.insert(
                id: id,
                transactionId: transactionId,
                importId: importId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TransactionImportsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({transactionId = false, importId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (transactionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.transactionId,
                                referencedTable:
                                    $$TransactionImportsTableReferences
                                        ._transactionIdTable(db),
                                referencedColumn:
                                    $$TransactionImportsTableReferences
                                        ._transactionIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (importId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.importId,
                                referencedTable:
                                    $$TransactionImportsTableReferences
                                        ._importIdTable(db),
                                referencedColumn:
                                    $$TransactionImportsTableReferences
                                        ._importIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TransactionImportsTableProcessedTableManager =
    ProcessedTableManager<
      _$ArthDatabase,
      $TransactionImportsTable,
      TransactionImport,
      $$TransactionImportsTableFilterComposer,
      $$TransactionImportsTableOrderingComposer,
      $$TransactionImportsTableAnnotationComposer,
      $$TransactionImportsTableCreateCompanionBuilder,
      $$TransactionImportsTableUpdateCompanionBuilder,
      (TransactionImport, $$TransactionImportsTableReferences),
      TransactionImport,
      PrefetchHooks Function({bool transactionId, bool importId})
    >;
typedef $$UserCorrectionsTableCreateCompanionBuilder =
    UserCorrectionsCompanion Function({
      Value<int> id,
      Value<int?> transactionId,
      required String rawMerchant,
      required String field,
      Value<String?> oldValue,
      required String newValue,
      Value<DateTime> createdAt,
    });
typedef $$UserCorrectionsTableUpdateCompanionBuilder =
    UserCorrectionsCompanion Function({
      Value<int> id,
      Value<int?> transactionId,
      Value<String> rawMerchant,
      Value<String> field,
      Value<String?> oldValue,
      Value<String> newValue,
      Value<DateTime> createdAt,
    });

final class $$UserCorrectionsTableReferences
    extends
        BaseReferences<_$ArthDatabase, $UserCorrectionsTable, UserCorrection> {
  $$UserCorrectionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TransactionsTable _transactionIdTable(_$ArthDatabase db) => db
      .transactions
      .createAlias('user_corrections__transaction_id__transactions__id');

  $$TransactionsTableProcessedTableManager? get transactionId {
    final $_column = $_itemColumn<int>('transaction_id');
    if ($_column == null) return null;
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$UserCorrectionsTableFilterComposer
    extends Composer<_$ArthDatabase, $UserCorrectionsTable> {
  $$UserCorrectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawMerchant => $composableBuilder(
    column: $table.rawMerchant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get oldValue => $composableBuilder(
    column: $table.oldValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get newValue => $composableBuilder(
    column: $table.newValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TransactionsTableFilterComposer get transactionId {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserCorrectionsTableOrderingComposer
    extends Composer<_$ArthDatabase, $UserCorrectionsTable> {
  $$UserCorrectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawMerchant => $composableBuilder(
    column: $table.rawMerchant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get oldValue => $composableBuilder(
    column: $table.oldValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get newValue => $composableBuilder(
    column: $table.newValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TransactionsTableOrderingComposer get transactionId {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableOrderingComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserCorrectionsTableAnnotationComposer
    extends Composer<_$ArthDatabase, $UserCorrectionsTable> {
  $$UserCorrectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get rawMerchant => $composableBuilder(
    column: $table.rawMerchant,
    builder: (column) => column,
  );

  GeneratedColumn<String> get field =>
      $composableBuilder(column: $table.field, builder: (column) => column);

  GeneratedColumn<String> get oldValue =>
      $composableBuilder(column: $table.oldValue, builder: (column) => column);

  GeneratedColumn<String> get newValue =>
      $composableBuilder(column: $table.newValue, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$TransactionsTableAnnotationComposer get transactionId {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserCorrectionsTableTableManager
    extends
        RootTableManager<
          _$ArthDatabase,
          $UserCorrectionsTable,
          UserCorrection,
          $$UserCorrectionsTableFilterComposer,
          $$UserCorrectionsTableOrderingComposer,
          $$UserCorrectionsTableAnnotationComposer,
          $$UserCorrectionsTableCreateCompanionBuilder,
          $$UserCorrectionsTableUpdateCompanionBuilder,
          (UserCorrection, $$UserCorrectionsTableReferences),
          UserCorrection,
          PrefetchHooks Function({bool transactionId})
        > {
  $$UserCorrectionsTableTableManager(
    _$ArthDatabase db,
    $UserCorrectionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserCorrectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserCorrectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserCorrectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> transactionId = const Value.absent(),
                Value<String> rawMerchant = const Value.absent(),
                Value<String> field = const Value.absent(),
                Value<String?> oldValue = const Value.absent(),
                Value<String> newValue = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => UserCorrectionsCompanion(
                id: id,
                transactionId: transactionId,
                rawMerchant: rawMerchant,
                field: field,
                oldValue: oldValue,
                newValue: newValue,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> transactionId = const Value.absent(),
                required String rawMerchant,
                required String field,
                Value<String?> oldValue = const Value.absent(),
                required String newValue,
                Value<DateTime> createdAt = const Value.absent(),
              }) => UserCorrectionsCompanion.insert(
                id: id,
                transactionId: transactionId,
                rawMerchant: rawMerchant,
                field: field,
                oldValue: oldValue,
                newValue: newValue,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UserCorrectionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({transactionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (transactionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.transactionId,
                                referencedTable:
                                    $$UserCorrectionsTableReferences
                                        ._transactionIdTable(db),
                                referencedColumn:
                                    $$UserCorrectionsTableReferences
                                        ._transactionIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$UserCorrectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$ArthDatabase,
      $UserCorrectionsTable,
      UserCorrection,
      $$UserCorrectionsTableFilterComposer,
      $$UserCorrectionsTableOrderingComposer,
      $$UserCorrectionsTableAnnotationComposer,
      $$UserCorrectionsTableCreateCompanionBuilder,
      $$UserCorrectionsTableUpdateCompanionBuilder,
      (UserCorrection, $$UserCorrectionsTableReferences),
      UserCorrection,
      PrefetchHooks Function({bool transactionId})
    >;
typedef $$UnparsedSmsRowsTableCreateCompanionBuilder =
    UnparsedSmsRowsCompanion Function({
      Value<int> id,
      required String rawBody,
      Value<String?> sender,
      Value<DateTime?> receivedAt,
      Value<String?> bankCode,
      required String reason,
      Value<bool> resolved,
      Value<DateTime> createdAt,
    });
typedef $$UnparsedSmsRowsTableUpdateCompanionBuilder =
    UnparsedSmsRowsCompanion Function({
      Value<int> id,
      Value<String> rawBody,
      Value<String?> sender,
      Value<DateTime?> receivedAt,
      Value<String?> bankCode,
      Value<String> reason,
      Value<bool> resolved,
      Value<DateTime> createdAt,
    });

final class $$UnparsedSmsRowsTableReferences
    extends
        BaseReferences<_$ArthDatabase, $UnparsedSmsRowsTable, UnparsedSmsRow> {
  $$UnparsedSmsRowsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$LlmReviewItemsTable, List<LlmReviewItem>>
  _llmReviewItemsRefsTable(_$ArthDatabase db) => MultiTypedResultKey.fromTable(
    db.llmReviewItems,
    aliasName: 'unparsed_sms_rows__id__llm_review_items__unparsed_sms_id',
  );

  $$LlmReviewItemsTableProcessedTableManager get llmReviewItemsRefs {
    final manager = $$LlmReviewItemsTableTableManager(
      $_db,
      $_db.llmReviewItems,
    ).filter((f) => f.unparsedSmsId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_llmReviewItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UnparsedSmsRowsTableFilterComposer
    extends Composer<_$ArthDatabase, $UnparsedSmsRowsTable> {
  $$UnparsedSmsRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawBody => $composableBuilder(
    column: $table.rawBody,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sender => $composableBuilder(
    column: $table.sender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bankCode => $composableBuilder(
    column: $table.bankCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get resolved => $composableBuilder(
    column: $table.resolved,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> llmReviewItemsRefs(
    Expression<bool> Function($$LlmReviewItemsTableFilterComposer f) f,
  ) {
    final $$LlmReviewItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.llmReviewItems,
      getReferencedColumn: (t) => t.unparsedSmsId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LlmReviewItemsTableFilterComposer(
            $db: $db,
            $table: $db.llmReviewItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UnparsedSmsRowsTableOrderingComposer
    extends Composer<_$ArthDatabase, $UnparsedSmsRowsTable> {
  $$UnparsedSmsRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawBody => $composableBuilder(
    column: $table.rawBody,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sender => $composableBuilder(
    column: $table.sender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bankCode => $composableBuilder(
    column: $table.bankCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get resolved => $composableBuilder(
    column: $table.resolved,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UnparsedSmsRowsTableAnnotationComposer
    extends Composer<_$ArthDatabase, $UnparsedSmsRowsTable> {
  $$UnparsedSmsRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get rawBody =>
      $composableBuilder(column: $table.rawBody, builder: (column) => column);

  GeneratedColumn<String> get sender =>
      $composableBuilder(column: $table.sender, builder: (column) => column);

  GeneratedColumn<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bankCode =>
      $composableBuilder(column: $table.bankCode, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<bool> get resolved =>
      $composableBuilder(column: $table.resolved, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> llmReviewItemsRefs<T extends Object>(
    Expression<T> Function($$LlmReviewItemsTableAnnotationComposer a) f,
  ) {
    final $$LlmReviewItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.llmReviewItems,
      getReferencedColumn: (t) => t.unparsedSmsId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LlmReviewItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.llmReviewItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UnparsedSmsRowsTableTableManager
    extends
        RootTableManager<
          _$ArthDatabase,
          $UnparsedSmsRowsTable,
          UnparsedSmsRow,
          $$UnparsedSmsRowsTableFilterComposer,
          $$UnparsedSmsRowsTableOrderingComposer,
          $$UnparsedSmsRowsTableAnnotationComposer,
          $$UnparsedSmsRowsTableCreateCompanionBuilder,
          $$UnparsedSmsRowsTableUpdateCompanionBuilder,
          (UnparsedSmsRow, $$UnparsedSmsRowsTableReferences),
          UnparsedSmsRow,
          PrefetchHooks Function({bool llmReviewItemsRefs})
        > {
  $$UnparsedSmsRowsTableTableManager(
    _$ArthDatabase db,
    $UnparsedSmsRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UnparsedSmsRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UnparsedSmsRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UnparsedSmsRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> rawBody = const Value.absent(),
                Value<String?> sender = const Value.absent(),
                Value<DateTime?> receivedAt = const Value.absent(),
                Value<String?> bankCode = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<bool> resolved = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => UnparsedSmsRowsCompanion(
                id: id,
                rawBody: rawBody,
                sender: sender,
                receivedAt: receivedAt,
                bankCode: bankCode,
                reason: reason,
                resolved: resolved,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String rawBody,
                Value<String?> sender = const Value.absent(),
                Value<DateTime?> receivedAt = const Value.absent(),
                Value<String?> bankCode = const Value.absent(),
                required String reason,
                Value<bool> resolved = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => UnparsedSmsRowsCompanion.insert(
                id: id,
                rawBody: rawBody,
                sender: sender,
                receivedAt: receivedAt,
                bankCode: bankCode,
                reason: reason,
                resolved: resolved,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UnparsedSmsRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({llmReviewItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (llmReviewItemsRefs) db.llmReviewItems,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (llmReviewItemsRefs)
                    await $_getPrefetchedData<
                      UnparsedSmsRow,
                      $UnparsedSmsRowsTable,
                      LlmReviewItem
                    >(
                      currentTable: table,
                      referencedTable: $$UnparsedSmsRowsTableReferences
                          ._llmReviewItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$UnparsedSmsRowsTableReferences(
                            db,
                            table,
                            p0,
                          ).llmReviewItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.unparsedSmsId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$UnparsedSmsRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$ArthDatabase,
      $UnparsedSmsRowsTable,
      UnparsedSmsRow,
      $$UnparsedSmsRowsTableFilterComposer,
      $$UnparsedSmsRowsTableOrderingComposer,
      $$UnparsedSmsRowsTableAnnotationComposer,
      $$UnparsedSmsRowsTableCreateCompanionBuilder,
      $$UnparsedSmsRowsTableUpdateCompanionBuilder,
      (UnparsedSmsRow, $$UnparsedSmsRowsTableReferences),
      UnparsedSmsRow,
      PrefetchHooks Function({bool llmReviewItemsRefs})
    >;
typedef $$MandateNoticesTableCreateCompanionBuilder =
    MandateNoticesCompanion Function({
      Value<int> id,
      required String bankCode,
      Value<int?> amountPaise,
      Value<String?> merchant,
      Value<DateTime?> scheduledDate,
      Value<String?> accountHint,
      required String rawBody,
      Value<String?> sender,
      Value<DateTime?> receivedAt,
      Value<DateTime> createdAt,
    });
typedef $$MandateNoticesTableUpdateCompanionBuilder =
    MandateNoticesCompanion Function({
      Value<int> id,
      Value<String> bankCode,
      Value<int?> amountPaise,
      Value<String?> merchant,
      Value<DateTime?> scheduledDate,
      Value<String?> accountHint,
      Value<String> rawBody,
      Value<String?> sender,
      Value<DateTime?> receivedAt,
      Value<DateTime> createdAt,
    });

class $$MandateNoticesTableFilterComposer
    extends Composer<_$ArthDatabase, $MandateNoticesTable> {
  $$MandateNoticesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bankCode => $composableBuilder(
    column: $table.bankCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountHint => $composableBuilder(
    column: $table.accountHint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawBody => $composableBuilder(
    column: $table.rawBody,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sender => $composableBuilder(
    column: $table.sender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MandateNoticesTableOrderingComposer
    extends Composer<_$ArthDatabase, $MandateNoticesTable> {
  $$MandateNoticesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bankCode => $composableBuilder(
    column: $table.bankCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountHint => $composableBuilder(
    column: $table.accountHint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawBody => $composableBuilder(
    column: $table.rawBody,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sender => $composableBuilder(
    column: $table.sender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MandateNoticesTableAnnotationComposer
    extends Composer<_$ArthDatabase, $MandateNoticesTable> {
  $$MandateNoticesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bankCode =>
      $composableBuilder(column: $table.bankCode, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get merchant =>
      $composableBuilder(column: $table.merchant, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accountHint => $composableBuilder(
    column: $table.accountHint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawBody =>
      $composableBuilder(column: $table.rawBody, builder: (column) => column);

  GeneratedColumn<String> get sender =>
      $composableBuilder(column: $table.sender, builder: (column) => column);

  GeneratedColumn<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MandateNoticesTableTableManager
    extends
        RootTableManager<
          _$ArthDatabase,
          $MandateNoticesTable,
          MandateNotice,
          $$MandateNoticesTableFilterComposer,
          $$MandateNoticesTableOrderingComposer,
          $$MandateNoticesTableAnnotationComposer,
          $$MandateNoticesTableCreateCompanionBuilder,
          $$MandateNoticesTableUpdateCompanionBuilder,
          (
            MandateNotice,
            BaseReferences<_$ArthDatabase, $MandateNoticesTable, MandateNotice>,
          ),
          MandateNotice,
          PrefetchHooks Function()
        > {
  $$MandateNoticesTableTableManager(
    _$ArthDatabase db,
    $MandateNoticesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MandateNoticesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MandateNoticesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MandateNoticesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> bankCode = const Value.absent(),
                Value<int?> amountPaise = const Value.absent(),
                Value<String?> merchant = const Value.absent(),
                Value<DateTime?> scheduledDate = const Value.absent(),
                Value<String?> accountHint = const Value.absent(),
                Value<String> rawBody = const Value.absent(),
                Value<String?> sender = const Value.absent(),
                Value<DateTime?> receivedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MandateNoticesCompanion(
                id: id,
                bankCode: bankCode,
                amountPaise: amountPaise,
                merchant: merchant,
                scheduledDate: scheduledDate,
                accountHint: accountHint,
                rawBody: rawBody,
                sender: sender,
                receivedAt: receivedAt,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String bankCode,
                Value<int?> amountPaise = const Value.absent(),
                Value<String?> merchant = const Value.absent(),
                Value<DateTime?> scheduledDate = const Value.absent(),
                Value<String?> accountHint = const Value.absent(),
                required String rawBody,
                Value<String?> sender = const Value.absent(),
                Value<DateTime?> receivedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MandateNoticesCompanion.insert(
                id: id,
                bankCode: bankCode,
                amountPaise: amountPaise,
                merchant: merchant,
                scheduledDate: scheduledDate,
                accountHint: accountHint,
                rawBody: rawBody,
                sender: sender,
                receivedAt: receivedAt,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MandateNoticesTableProcessedTableManager =
    ProcessedTableManager<
      _$ArthDatabase,
      $MandateNoticesTable,
      MandateNotice,
      $$MandateNoticesTableFilterComposer,
      $$MandateNoticesTableOrderingComposer,
      $$MandateNoticesTableAnnotationComposer,
      $$MandateNoticesTableCreateCompanionBuilder,
      $$MandateNoticesTableUpdateCompanionBuilder,
      (
        MandateNotice,
        BaseReferences<_$ArthDatabase, $MandateNoticesTable, MandateNotice>,
      ),
      MandateNotice,
      PrefetchHooks Function()
    >;
typedef $$ModelInfoTableCreateCompanionBuilder =
    ModelInfoCompanion Function({
      Value<int> id,
      required String modelName,
      required String quant,
      required String sha256,
      required String sourceUrl,
      Value<String?> localPath,
      Value<DateTime?> downloadedAt,
      Value<DateTime?> lastLoadedAt,
    });
typedef $$ModelInfoTableUpdateCompanionBuilder =
    ModelInfoCompanion Function({
      Value<int> id,
      Value<String> modelName,
      Value<String> quant,
      Value<String> sha256,
      Value<String> sourceUrl,
      Value<String?> localPath,
      Value<DateTime?> downloadedAt,
      Value<DateTime?> lastLoadedAt,
    });

class $$ModelInfoTableFilterComposer
    extends Composer<_$ArthDatabase, $ModelInfoTable> {
  $$ModelInfoTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelName => $composableBuilder(
    column: $table.modelName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quant => $composableBuilder(
    column: $table.quant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastLoadedAt => $composableBuilder(
    column: $table.lastLoadedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ModelInfoTableOrderingComposer
    extends Composer<_$ArthDatabase, $ModelInfoTable> {
  $$ModelInfoTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelName => $composableBuilder(
    column: $table.modelName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quant => $composableBuilder(
    column: $table.quant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastLoadedAt => $composableBuilder(
    column: $table.lastLoadedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ModelInfoTableAnnotationComposer
    extends Composer<_$ArthDatabase, $ModelInfoTable> {
  $$ModelInfoTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get modelName =>
      $composableBuilder(column: $table.modelName, builder: (column) => column);

  GeneratedColumn<String> get quant =>
      $composableBuilder(column: $table.quant, builder: (column) => column);

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastLoadedAt => $composableBuilder(
    column: $table.lastLoadedAt,
    builder: (column) => column,
  );
}

class $$ModelInfoTableTableManager
    extends
        RootTableManager<
          _$ArthDatabase,
          $ModelInfoTable,
          ModelInfoData,
          $$ModelInfoTableFilterComposer,
          $$ModelInfoTableOrderingComposer,
          $$ModelInfoTableAnnotationComposer,
          $$ModelInfoTableCreateCompanionBuilder,
          $$ModelInfoTableUpdateCompanionBuilder,
          (
            ModelInfoData,
            BaseReferences<_$ArthDatabase, $ModelInfoTable, ModelInfoData>,
          ),
          ModelInfoData,
          PrefetchHooks Function()
        > {
  $$ModelInfoTableTableManager(_$ArthDatabase db, $ModelInfoTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ModelInfoTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ModelInfoTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ModelInfoTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> modelName = const Value.absent(),
                Value<String> quant = const Value.absent(),
                Value<String> sha256 = const Value.absent(),
                Value<String> sourceUrl = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<DateTime?> downloadedAt = const Value.absent(),
                Value<DateTime?> lastLoadedAt = const Value.absent(),
              }) => ModelInfoCompanion(
                id: id,
                modelName: modelName,
                quant: quant,
                sha256: sha256,
                sourceUrl: sourceUrl,
                localPath: localPath,
                downloadedAt: downloadedAt,
                lastLoadedAt: lastLoadedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String modelName,
                required String quant,
                required String sha256,
                required String sourceUrl,
                Value<String?> localPath = const Value.absent(),
                Value<DateTime?> downloadedAt = const Value.absent(),
                Value<DateTime?> lastLoadedAt = const Value.absent(),
              }) => ModelInfoCompanion.insert(
                id: id,
                modelName: modelName,
                quant: quant,
                sha256: sha256,
                sourceUrl: sourceUrl,
                localPath: localPath,
                downloadedAt: downloadedAt,
                lastLoadedAt: lastLoadedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ModelInfoTableProcessedTableManager =
    ProcessedTableManager<
      _$ArthDatabase,
      $ModelInfoTable,
      ModelInfoData,
      $$ModelInfoTableFilterComposer,
      $$ModelInfoTableOrderingComposer,
      $$ModelInfoTableAnnotationComposer,
      $$ModelInfoTableCreateCompanionBuilder,
      $$ModelInfoTableUpdateCompanionBuilder,
      (
        ModelInfoData,
        BaseReferences<_$ArthDatabase, $ModelInfoTable, ModelInfoData>,
      ),
      ModelInfoData,
      PrefetchHooks Function()
    >;
typedef $$UnparsedStatementRowsTableCreateCompanionBuilder =
    UnparsedStatementRowsCompanion Function({
      Value<int> id,
      required int importId,
      required int rowIndex,
      required String rawRowJson,
      required String reason,
      Value<bool> resolved,
      Value<DateTime> createdAt,
    });
typedef $$UnparsedStatementRowsTableUpdateCompanionBuilder =
    UnparsedStatementRowsCompanion Function({
      Value<int> id,
      Value<int> importId,
      Value<int> rowIndex,
      Value<String> rawRowJson,
      Value<String> reason,
      Value<bool> resolved,
      Value<DateTime> createdAt,
    });

final class $$UnparsedStatementRowsTableReferences
    extends
        BaseReferences<
          _$ArthDatabase,
          $UnparsedStatementRowsTable,
          UnparsedStatementRow
        > {
  $$UnparsedStatementRowsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ImportsTable _importIdTable(_$ArthDatabase db) =>
      db.imports.createAlias('unparsed_statement_rows__import_id__imports__id');

  $$ImportsTableProcessedTableManager get importId {
    final $_column = $_itemColumn<int>('import_id')!;

    final manager = $$ImportsTableTableManager(
      $_db,
      $_db.imports,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_importIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$LlmReviewItemsTable, List<LlmReviewItem>>
  _llmReviewItemsRefsTable(_$ArthDatabase db) => MultiTypedResultKey.fromTable(
    db.llmReviewItems,
    aliasName:
        'unparsed_statement_rows__id__llm_review_items__unparsed_statement_row_id',
  );

  $$LlmReviewItemsTableProcessedTableManager get llmReviewItemsRefs {
    final manager = $$LlmReviewItemsTableTableManager($_db, $_db.llmReviewItems)
        .filter(
          (f) =>
              f.unparsedStatementRowId.id.sqlEquals($_itemColumn<int>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(_llmReviewItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UnparsedStatementRowsTableFilterComposer
    extends Composer<_$ArthDatabase, $UnparsedStatementRowsTable> {
  $$UnparsedStatementRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rowIndex => $composableBuilder(
    column: $table.rowIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawRowJson => $composableBuilder(
    column: $table.rawRowJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get resolved => $composableBuilder(
    column: $table.resolved,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ImportsTableFilterComposer get importId {
    final $$ImportsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableFilterComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> llmReviewItemsRefs(
    Expression<bool> Function($$LlmReviewItemsTableFilterComposer f) f,
  ) {
    final $$LlmReviewItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.llmReviewItems,
      getReferencedColumn: (t) => t.unparsedStatementRowId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LlmReviewItemsTableFilterComposer(
            $db: $db,
            $table: $db.llmReviewItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UnparsedStatementRowsTableOrderingComposer
    extends Composer<_$ArthDatabase, $UnparsedStatementRowsTable> {
  $$UnparsedStatementRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rowIndex => $composableBuilder(
    column: $table.rowIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawRowJson => $composableBuilder(
    column: $table.rawRowJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get resolved => $composableBuilder(
    column: $table.resolved,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ImportsTableOrderingComposer get importId {
    final $$ImportsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableOrderingComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UnparsedStatementRowsTableAnnotationComposer
    extends Composer<_$ArthDatabase, $UnparsedStatementRowsTable> {
  $$UnparsedStatementRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get rowIndex =>
      $composableBuilder(column: $table.rowIndex, builder: (column) => column);

  GeneratedColumn<String> get rawRowJson => $composableBuilder(
    column: $table.rawRowJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<bool> get resolved =>
      $composableBuilder(column: $table.resolved, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ImportsTableAnnotationComposer get importId {
    final $$ImportsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableAnnotationComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> llmReviewItemsRefs<T extends Object>(
    Expression<T> Function($$LlmReviewItemsTableAnnotationComposer a) f,
  ) {
    final $$LlmReviewItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.llmReviewItems,
      getReferencedColumn: (t) => t.unparsedStatementRowId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LlmReviewItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.llmReviewItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UnparsedStatementRowsTableTableManager
    extends
        RootTableManager<
          _$ArthDatabase,
          $UnparsedStatementRowsTable,
          UnparsedStatementRow,
          $$UnparsedStatementRowsTableFilterComposer,
          $$UnparsedStatementRowsTableOrderingComposer,
          $$UnparsedStatementRowsTableAnnotationComposer,
          $$UnparsedStatementRowsTableCreateCompanionBuilder,
          $$UnparsedStatementRowsTableUpdateCompanionBuilder,
          (UnparsedStatementRow, $$UnparsedStatementRowsTableReferences),
          UnparsedStatementRow,
          PrefetchHooks Function({bool importId, bool llmReviewItemsRefs})
        > {
  $$UnparsedStatementRowsTableTableManager(
    _$ArthDatabase db,
    $UnparsedStatementRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UnparsedStatementRowsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$UnparsedStatementRowsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$UnparsedStatementRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> importId = const Value.absent(),
                Value<int> rowIndex = const Value.absent(),
                Value<String> rawRowJson = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<bool> resolved = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => UnparsedStatementRowsCompanion(
                id: id,
                importId: importId,
                rowIndex: rowIndex,
                rawRowJson: rawRowJson,
                reason: reason,
                resolved: resolved,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int importId,
                required int rowIndex,
                required String rawRowJson,
                required String reason,
                Value<bool> resolved = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => UnparsedStatementRowsCompanion.insert(
                id: id,
                importId: importId,
                rowIndex: rowIndex,
                rawRowJson: rawRowJson,
                reason: reason,
                resolved: resolved,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UnparsedStatementRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({importId = false, llmReviewItemsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (llmReviewItemsRefs) db.llmReviewItems,
                  ],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (importId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.importId,
                                    referencedTable:
                                        $$UnparsedStatementRowsTableReferences
                                            ._importIdTable(db),
                                    referencedColumn:
                                        $$UnparsedStatementRowsTableReferences
                                            ._importIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (llmReviewItemsRefs)
                        await $_getPrefetchedData<
                          UnparsedStatementRow,
                          $UnparsedStatementRowsTable,
                          LlmReviewItem
                        >(
                          currentTable: table,
                          referencedTable:
                              $$UnparsedStatementRowsTableReferences
                                  ._llmReviewItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UnparsedStatementRowsTableReferences(
                                db,
                                table,
                                p0,
                              ).llmReviewItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.unparsedStatementRowId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$UnparsedStatementRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$ArthDatabase,
      $UnparsedStatementRowsTable,
      UnparsedStatementRow,
      $$UnparsedStatementRowsTableFilterComposer,
      $$UnparsedStatementRowsTableOrderingComposer,
      $$UnparsedStatementRowsTableAnnotationComposer,
      $$UnparsedStatementRowsTableCreateCompanionBuilder,
      $$UnparsedStatementRowsTableUpdateCompanionBuilder,
      (UnparsedStatementRow, $$UnparsedStatementRowsTableReferences),
      UnparsedStatementRow,
      PrefetchHooks Function({bool importId, bool llmReviewItemsRefs})
    >;
typedef $$LlmJobsTableCreateCompanionBuilder =
    LlmJobsCompanion Function({
      Value<int> id,
      required String jobType,
      required String payloadJson,
      Value<String> status,
      Value<int> attempts,
      Value<String?> resultJson,
      Value<String?> lastError,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$LlmJobsTableUpdateCompanionBuilder =
    LlmJobsCompanion Function({
      Value<int> id,
      Value<String> jobType,
      Value<String> payloadJson,
      Value<String> status,
      Value<int> attempts,
      Value<String?> resultJson,
      Value<String?> lastError,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$LlmJobsTableFilterComposer
    extends Composer<_$ArthDatabase, $LlmJobsTable> {
  $$LlmJobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jobType => $composableBuilder(
    column: $table.jobType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resultJson => $composableBuilder(
    column: $table.resultJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LlmJobsTableOrderingComposer
    extends Composer<_$ArthDatabase, $LlmJobsTable> {
  $$LlmJobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jobType => $composableBuilder(
    column: $table.jobType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resultJson => $composableBuilder(
    column: $table.resultJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LlmJobsTableAnnotationComposer
    extends Composer<_$ArthDatabase, $LlmJobsTable> {
  $$LlmJobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get jobType =>
      $composableBuilder(column: $table.jobType, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get resultJson => $composableBuilder(
    column: $table.resultJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LlmJobsTableTableManager
    extends
        RootTableManager<
          _$ArthDatabase,
          $LlmJobsTable,
          LlmJob,
          $$LlmJobsTableFilterComposer,
          $$LlmJobsTableOrderingComposer,
          $$LlmJobsTableAnnotationComposer,
          $$LlmJobsTableCreateCompanionBuilder,
          $$LlmJobsTableUpdateCompanionBuilder,
          (LlmJob, BaseReferences<_$ArthDatabase, $LlmJobsTable, LlmJob>),
          LlmJob,
          PrefetchHooks Function()
        > {
  $$LlmJobsTableTableManager(_$ArthDatabase db, $LlmJobsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LlmJobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LlmJobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LlmJobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> jobType = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> resultJson = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => LlmJobsCompanion(
                id: id,
                jobType: jobType,
                payloadJson: payloadJson,
                status: status,
                attempts: attempts,
                resultJson: resultJson,
                lastError: lastError,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String jobType,
                required String payloadJson,
                Value<String> status = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> resultJson = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => LlmJobsCompanion.insert(
                id: id,
                jobType: jobType,
                payloadJson: payloadJson,
                status: status,
                attempts: attempts,
                resultJson: resultJson,
                lastError: lastError,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LlmJobsTableProcessedTableManager =
    ProcessedTableManager<
      _$ArthDatabase,
      $LlmJobsTable,
      LlmJob,
      $$LlmJobsTableFilterComposer,
      $$LlmJobsTableOrderingComposer,
      $$LlmJobsTableAnnotationComposer,
      $$LlmJobsTableCreateCompanionBuilder,
      $$LlmJobsTableUpdateCompanionBuilder,
      (LlmJob, BaseReferences<_$ArthDatabase, $LlmJobsTable, LlmJob>),
      LlmJob,
      PrefetchHooks Function()
    >;
typedef $$LlmReviewItemsTableCreateCompanionBuilder =
    LlmReviewItemsCompanion Function({
      Value<int> id,
      Value<int?> unparsedSmsId,
      Value<int?> unparsedStatementRowId,
      required String rawText,
      required String suggestedJson,
      required String anchorReportJson,
      Value<String> status,
      Value<int?> transactionId,
      Value<DateTime> createdAt,
    });
typedef $$LlmReviewItemsTableUpdateCompanionBuilder =
    LlmReviewItemsCompanion Function({
      Value<int> id,
      Value<int?> unparsedSmsId,
      Value<int?> unparsedStatementRowId,
      Value<String> rawText,
      Value<String> suggestedJson,
      Value<String> anchorReportJson,
      Value<String> status,
      Value<int?> transactionId,
      Value<DateTime> createdAt,
    });

final class $$LlmReviewItemsTableReferences
    extends
        BaseReferences<_$ArthDatabase, $LlmReviewItemsTable, LlmReviewItem> {
  $$LlmReviewItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $UnparsedSmsRowsTable _unparsedSmsIdTable(_$ArthDatabase db) => db
      .unparsedSmsRows
      .createAlias('llm_review_items__unparsed_sms_id__unparsed_sms_rows__id');

  $$UnparsedSmsRowsTableProcessedTableManager? get unparsedSmsId {
    final $_column = $_itemColumn<int>('unparsed_sms_id');
    if ($_column == null) return null;
    final manager = $$UnparsedSmsRowsTableTableManager(
      $_db,
      $_db.unparsedSmsRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_unparsedSmsIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UnparsedStatementRowsTable _unparsedStatementRowIdTable(
    _$ArthDatabase db,
  ) => db.unparsedStatementRows.createAlias(
    'llm_review_items__unparsed_statement_row_id__unparsed_statement_rows__id',
  );

  $$UnparsedStatementRowsTableProcessedTableManager?
  get unparsedStatementRowId {
    final $_column = $_itemColumn<int>('unparsed_statement_row_id');
    if ($_column == null) return null;
    final manager = $$UnparsedStatementRowsTableTableManager(
      $_db,
      $_db.unparsedStatementRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _unparsedStatementRowIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TransactionsTable _transactionIdTable(_$ArthDatabase db) => db
      .transactions
      .createAlias('llm_review_items__transaction_id__transactions__id');

  $$TransactionsTableProcessedTableManager? get transactionId {
    final $_column = $_itemColumn<int>('transaction_id');
    if ($_column == null) return null;
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LlmReviewItemsTableFilterComposer
    extends Composer<_$ArthDatabase, $LlmReviewItemsTable> {
  $$LlmReviewItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawText => $composableBuilder(
    column: $table.rawText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get suggestedJson => $composableBuilder(
    column: $table.suggestedJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get anchorReportJson => $composableBuilder(
    column: $table.anchorReportJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$UnparsedSmsRowsTableFilterComposer get unparsedSmsId {
    final $$UnparsedSmsRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.unparsedSmsId,
      referencedTable: $db.unparsedSmsRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnparsedSmsRowsTableFilterComposer(
            $db: $db,
            $table: $db.unparsedSmsRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UnparsedStatementRowsTableFilterComposer get unparsedStatementRowId {
    final $$UnparsedStatementRowsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.unparsedStatementRowId,
          referencedTable: $db.unparsedStatementRows,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$UnparsedStatementRowsTableFilterComposer(
                $db: $db,
                $table: $db.unparsedStatementRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$TransactionsTableFilterComposer get transactionId {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LlmReviewItemsTableOrderingComposer
    extends Composer<_$ArthDatabase, $LlmReviewItemsTable> {
  $$LlmReviewItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawText => $composableBuilder(
    column: $table.rawText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get suggestedJson => $composableBuilder(
    column: $table.suggestedJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get anchorReportJson => $composableBuilder(
    column: $table.anchorReportJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$UnparsedSmsRowsTableOrderingComposer get unparsedSmsId {
    final $$UnparsedSmsRowsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.unparsedSmsId,
      referencedTable: $db.unparsedSmsRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnparsedSmsRowsTableOrderingComposer(
            $db: $db,
            $table: $db.unparsedSmsRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UnparsedStatementRowsTableOrderingComposer get unparsedStatementRowId {
    final $$UnparsedStatementRowsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.unparsedStatementRowId,
          referencedTable: $db.unparsedStatementRows,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$UnparsedStatementRowsTableOrderingComposer(
                $db: $db,
                $table: $db.unparsedStatementRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$TransactionsTableOrderingComposer get transactionId {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableOrderingComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LlmReviewItemsTableAnnotationComposer
    extends Composer<_$ArthDatabase, $LlmReviewItemsTable> {
  $$LlmReviewItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get rawText =>
      $composableBuilder(column: $table.rawText, builder: (column) => column);

  GeneratedColumn<String> get suggestedJson => $composableBuilder(
    column: $table.suggestedJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get anchorReportJson => $composableBuilder(
    column: $table.anchorReportJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$UnparsedSmsRowsTableAnnotationComposer get unparsedSmsId {
    final $$UnparsedSmsRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.unparsedSmsId,
      referencedTable: $db.unparsedSmsRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnparsedSmsRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.unparsedSmsRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UnparsedStatementRowsTableAnnotationComposer get unparsedStatementRowId {
    final $$UnparsedStatementRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.unparsedStatementRowId,
          referencedTable: $db.unparsedStatementRows,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$UnparsedStatementRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.unparsedStatementRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$TransactionsTableAnnotationComposer get transactionId {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LlmReviewItemsTableTableManager
    extends
        RootTableManager<
          _$ArthDatabase,
          $LlmReviewItemsTable,
          LlmReviewItem,
          $$LlmReviewItemsTableFilterComposer,
          $$LlmReviewItemsTableOrderingComposer,
          $$LlmReviewItemsTableAnnotationComposer,
          $$LlmReviewItemsTableCreateCompanionBuilder,
          $$LlmReviewItemsTableUpdateCompanionBuilder,
          (LlmReviewItem, $$LlmReviewItemsTableReferences),
          LlmReviewItem,
          PrefetchHooks Function({
            bool unparsedSmsId,
            bool unparsedStatementRowId,
            bool transactionId,
          })
        > {
  $$LlmReviewItemsTableTableManager(
    _$ArthDatabase db,
    $LlmReviewItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LlmReviewItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LlmReviewItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LlmReviewItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> unparsedSmsId = const Value.absent(),
                Value<int?> unparsedStatementRowId = const Value.absent(),
                Value<String> rawText = const Value.absent(),
                Value<String> suggestedJson = const Value.absent(),
                Value<String> anchorReportJson = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> transactionId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => LlmReviewItemsCompanion(
                id: id,
                unparsedSmsId: unparsedSmsId,
                unparsedStatementRowId: unparsedStatementRowId,
                rawText: rawText,
                suggestedJson: suggestedJson,
                anchorReportJson: anchorReportJson,
                status: status,
                transactionId: transactionId,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> unparsedSmsId = const Value.absent(),
                Value<int?> unparsedStatementRowId = const Value.absent(),
                required String rawText,
                required String suggestedJson,
                required String anchorReportJson,
                Value<String> status = const Value.absent(),
                Value<int?> transactionId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => LlmReviewItemsCompanion.insert(
                id: id,
                unparsedSmsId: unparsedSmsId,
                unparsedStatementRowId: unparsedStatementRowId,
                rawText: rawText,
                suggestedJson: suggestedJson,
                anchorReportJson: anchorReportJson,
                status: status,
                transactionId: transactionId,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LlmReviewItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                unparsedSmsId = false,
                unparsedStatementRowId = false,
                transactionId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (unparsedSmsId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.unparsedSmsId,
                                    referencedTable:
                                        $$LlmReviewItemsTableReferences
                                            ._unparsedSmsIdTable(db),
                                    referencedColumn:
                                        $$LlmReviewItemsTableReferences
                                            ._unparsedSmsIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (unparsedStatementRowId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.unparsedStatementRowId,
                                    referencedTable:
                                        $$LlmReviewItemsTableReferences
                                            ._unparsedStatementRowIdTable(db),
                                    referencedColumn:
                                        $$LlmReviewItemsTableReferences
                                            ._unparsedStatementRowIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (transactionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.transactionId,
                                    referencedTable:
                                        $$LlmReviewItemsTableReferences
                                            ._transactionIdTable(db),
                                    referencedColumn:
                                        $$LlmReviewItemsTableReferences
                                            ._transactionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$LlmReviewItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$ArthDatabase,
      $LlmReviewItemsTable,
      LlmReviewItem,
      $$LlmReviewItemsTableFilterComposer,
      $$LlmReviewItemsTableOrderingComposer,
      $$LlmReviewItemsTableAnnotationComposer,
      $$LlmReviewItemsTableCreateCompanionBuilder,
      $$LlmReviewItemsTableUpdateCompanionBuilder,
      (LlmReviewItem, $$LlmReviewItemsTableReferences),
      LlmReviewItem,
      PrefetchHooks Function({
        bool unparsedSmsId,
        bool unparsedStatementRowId,
        bool transactionId,
      })
    >;
typedef $$BudgetsTableCreateCompanionBuilder =
    BudgetsCompanion Function({
      Value<int> id,
      required int categoryId,
      required int limitPaise,
      Value<bool> rollover,
      required String startMonth,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$BudgetsTableUpdateCompanionBuilder =
    BudgetsCompanion Function({
      Value<int> id,
      Value<int> categoryId,
      Value<int> limitPaise,
      Value<bool> rollover,
      Value<String> startMonth,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$BudgetsTableReferences
    extends BaseReferences<_$ArthDatabase, $BudgetsTable, Budget> {
  $$BudgetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$ArthDatabase db) =>
      db.categories.createAlias('budgets__category_id__categories__id');

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BudgetsTableFilterComposer
    extends Composer<_$ArthDatabase, $BudgetsTable> {
  $$BudgetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get limitPaise => $composableBuilder(
    column: $table.limitPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get rollover => $composableBuilder(
    column: $table.rollover,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startMonth => $composableBuilder(
    column: $table.startMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BudgetsTableOrderingComposer
    extends Composer<_$ArthDatabase, $BudgetsTable> {
  $$BudgetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get limitPaise => $composableBuilder(
    column: $table.limitPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get rollover => $composableBuilder(
    column: $table.rollover,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startMonth => $composableBuilder(
    column: $table.startMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BudgetsTableAnnotationComposer
    extends Composer<_$ArthDatabase, $BudgetsTable> {
  $$BudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get limitPaise => $composableBuilder(
    column: $table.limitPaise,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get rollover =>
      $composableBuilder(column: $table.rollover, builder: (column) => column);

  GeneratedColumn<String> get startMonth => $composableBuilder(
    column: $table.startMonth,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BudgetsTableTableManager
    extends
        RootTableManager<
          _$ArthDatabase,
          $BudgetsTable,
          Budget,
          $$BudgetsTableFilterComposer,
          $$BudgetsTableOrderingComposer,
          $$BudgetsTableAnnotationComposer,
          $$BudgetsTableCreateCompanionBuilder,
          $$BudgetsTableUpdateCompanionBuilder,
          (Budget, $$BudgetsTableReferences),
          Budget,
          PrefetchHooks Function({bool categoryId})
        > {
  $$BudgetsTableTableManager(_$ArthDatabase db, $BudgetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<int> limitPaise = const Value.absent(),
                Value<bool> rollover = const Value.absent(),
                Value<String> startMonth = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => BudgetsCompanion(
                id: id,
                categoryId: categoryId,
                limitPaise: limitPaise,
                rollover: rollover,
                startMonth: startMonth,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int categoryId,
                required int limitPaise,
                Value<bool> rollover = const Value.absent(),
                required String startMonth,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => BudgetsCompanion.insert(
                id: id,
                categoryId: categoryId,
                limitPaise: limitPaise,
                rollover: rollover,
                startMonth: startMonth,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BudgetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (categoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.categoryId,
                                referencedTable: $$BudgetsTableReferences
                                    ._categoryIdTable(db),
                                referencedColumn: $$BudgetsTableReferences
                                    ._categoryIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BudgetsTableProcessedTableManager =
    ProcessedTableManager<
      _$ArthDatabase,
      $BudgetsTable,
      Budget,
      $$BudgetsTableFilterComposer,
      $$BudgetsTableOrderingComposer,
      $$BudgetsTableAnnotationComposer,
      $$BudgetsTableCreateCompanionBuilder,
      $$BudgetsTableUpdateCompanionBuilder,
      (Budget, $$BudgetsTableReferences),
      Budget,
      PrefetchHooks Function({bool categoryId})
    >;
typedef $$StatementSummariesTableCreateCompanionBuilder =
    StatementSummariesCompanion Function({
      Value<int> id,
      required int importId,
      required String bankCode,
      required String accountKind,
      Value<String?> last4,
      Value<DateTime?> statementDate,
      Value<DateTime?> dueDate,
      Value<int?> totalDuePaise,
      Value<int?> minDuePaise,
      Value<int?> creditLimitPaise,
      Value<DateTime?> periodEnd,
      Value<DateTime> createdAt,
    });
typedef $$StatementSummariesTableUpdateCompanionBuilder =
    StatementSummariesCompanion Function({
      Value<int> id,
      Value<int> importId,
      Value<String> bankCode,
      Value<String> accountKind,
      Value<String?> last4,
      Value<DateTime?> statementDate,
      Value<DateTime?> dueDate,
      Value<int?> totalDuePaise,
      Value<int?> minDuePaise,
      Value<int?> creditLimitPaise,
      Value<DateTime?> periodEnd,
      Value<DateTime> createdAt,
    });

final class $$StatementSummariesTableReferences
    extends
        BaseReferences<
          _$ArthDatabase,
          $StatementSummariesTable,
          StatementSummaryRow
        > {
  $$StatementSummariesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ImportsTable _importIdTable(_$ArthDatabase db) =>
      db.imports.createAlias('statement_summaries__import_id__imports__id');

  $$ImportsTableProcessedTableManager get importId {
    final $_column = $_itemColumn<int>('import_id')!;

    final manager = $$ImportsTableTableManager(
      $_db,
      $_db.imports,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_importIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StatementSummariesTableFilterComposer
    extends Composer<_$ArthDatabase, $StatementSummariesTable> {
  $$StatementSummariesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bankCode => $composableBuilder(
    column: $table.bankCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountKind => $composableBuilder(
    column: $table.accountKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get last4 => $composableBuilder(
    column: $table.last4,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get statementDate => $composableBuilder(
    column: $table.statementDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalDuePaise => $composableBuilder(
    column: $table.totalDuePaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minDuePaise => $composableBuilder(
    column: $table.minDuePaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get creditLimitPaise => $composableBuilder(
    column: $table.creditLimitPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get periodEnd => $composableBuilder(
    column: $table.periodEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ImportsTableFilterComposer get importId {
    final $$ImportsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableFilterComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StatementSummariesTableOrderingComposer
    extends Composer<_$ArthDatabase, $StatementSummariesTable> {
  $$StatementSummariesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bankCode => $composableBuilder(
    column: $table.bankCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountKind => $composableBuilder(
    column: $table.accountKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get last4 => $composableBuilder(
    column: $table.last4,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get statementDate => $composableBuilder(
    column: $table.statementDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalDuePaise => $composableBuilder(
    column: $table.totalDuePaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minDuePaise => $composableBuilder(
    column: $table.minDuePaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get creditLimitPaise => $composableBuilder(
    column: $table.creditLimitPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get periodEnd => $composableBuilder(
    column: $table.periodEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ImportsTableOrderingComposer get importId {
    final $$ImportsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableOrderingComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StatementSummariesTableAnnotationComposer
    extends Composer<_$ArthDatabase, $StatementSummariesTable> {
  $$StatementSummariesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bankCode =>
      $composableBuilder(column: $table.bankCode, builder: (column) => column);

  GeneratedColumn<String> get accountKind => $composableBuilder(
    column: $table.accountKind,
    builder: (column) => column,
  );

  GeneratedColumn<String> get last4 =>
      $composableBuilder(column: $table.last4, builder: (column) => column);

  GeneratedColumn<DateTime> get statementDate => $composableBuilder(
    column: $table.statementDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<int> get totalDuePaise => $composableBuilder(
    column: $table.totalDuePaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get minDuePaise => $composableBuilder(
    column: $table.minDuePaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get creditLimitPaise => $composableBuilder(
    column: $table.creditLimitPaise,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get periodEnd =>
      $composableBuilder(column: $table.periodEnd, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ImportsTableAnnotationComposer get importId {
    final $$ImportsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableAnnotationComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StatementSummariesTableTableManager
    extends
        RootTableManager<
          _$ArthDatabase,
          $StatementSummariesTable,
          StatementSummaryRow,
          $$StatementSummariesTableFilterComposer,
          $$StatementSummariesTableOrderingComposer,
          $$StatementSummariesTableAnnotationComposer,
          $$StatementSummariesTableCreateCompanionBuilder,
          $$StatementSummariesTableUpdateCompanionBuilder,
          (StatementSummaryRow, $$StatementSummariesTableReferences),
          StatementSummaryRow,
          PrefetchHooks Function({bool importId})
        > {
  $$StatementSummariesTableTableManager(
    _$ArthDatabase db,
    $StatementSummariesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StatementSummariesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StatementSummariesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StatementSummariesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> importId = const Value.absent(),
                Value<String> bankCode = const Value.absent(),
                Value<String> accountKind = const Value.absent(),
                Value<String?> last4 = const Value.absent(),
                Value<DateTime?> statementDate = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<int?> totalDuePaise = const Value.absent(),
                Value<int?> minDuePaise = const Value.absent(),
                Value<int?> creditLimitPaise = const Value.absent(),
                Value<DateTime?> periodEnd = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => StatementSummariesCompanion(
                id: id,
                importId: importId,
                bankCode: bankCode,
                accountKind: accountKind,
                last4: last4,
                statementDate: statementDate,
                dueDate: dueDate,
                totalDuePaise: totalDuePaise,
                minDuePaise: minDuePaise,
                creditLimitPaise: creditLimitPaise,
                periodEnd: periodEnd,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int importId,
                required String bankCode,
                required String accountKind,
                Value<String?> last4 = const Value.absent(),
                Value<DateTime?> statementDate = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<int?> totalDuePaise = const Value.absent(),
                Value<int?> minDuePaise = const Value.absent(),
                Value<int?> creditLimitPaise = const Value.absent(),
                Value<DateTime?> periodEnd = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => StatementSummariesCompanion.insert(
                id: id,
                importId: importId,
                bankCode: bankCode,
                accountKind: accountKind,
                last4: last4,
                statementDate: statementDate,
                dueDate: dueDate,
                totalDuePaise: totalDuePaise,
                minDuePaise: minDuePaise,
                creditLimitPaise: creditLimitPaise,
                periodEnd: periodEnd,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StatementSummariesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({importId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (importId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.importId,
                                referencedTable:
                                    $$StatementSummariesTableReferences
                                        ._importIdTable(db),
                                referencedColumn:
                                    $$StatementSummariesTableReferences
                                        ._importIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$StatementSummariesTableProcessedTableManager =
    ProcessedTableManager<
      _$ArthDatabase,
      $StatementSummariesTable,
      StatementSummaryRow,
      $$StatementSummariesTableFilterComposer,
      $$StatementSummariesTableOrderingComposer,
      $$StatementSummariesTableAnnotationComposer,
      $$StatementSummariesTableCreateCompanionBuilder,
      $$StatementSummariesTableUpdateCompanionBuilder,
      (StatementSummaryRow, $$StatementSummariesTableReferences),
      StatementSummaryRow,
      PrefetchHooks Function({bool importId})
    >;
typedef $$CreditCardsTableCreateCompanionBuilder =
    CreditCardsCompanion Function({
      Value<int> id,
      required String bankCode,
      Value<String?> last4,
      required String name,
      Value<int?> creditLimitPaise,
      Value<int?> statementDay,
      Value<int?> dueDay,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$CreditCardsTableUpdateCompanionBuilder =
    CreditCardsCompanion Function({
      Value<int> id,
      Value<String> bankCode,
      Value<String?> last4,
      Value<String> name,
      Value<int?> creditLimitPaise,
      Value<int?> statementDay,
      Value<int?> dueDay,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$CreditCardsTableFilterComposer
    extends Composer<_$ArthDatabase, $CreditCardsTable> {
  $$CreditCardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bankCode => $composableBuilder(
    column: $table.bankCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get last4 => $composableBuilder(
    column: $table.last4,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get creditLimitPaise => $composableBuilder(
    column: $table.creditLimitPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get statementDay => $composableBuilder(
    column: $table.statementDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dueDay => $composableBuilder(
    column: $table.dueDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CreditCardsTableOrderingComposer
    extends Composer<_$ArthDatabase, $CreditCardsTable> {
  $$CreditCardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bankCode => $composableBuilder(
    column: $table.bankCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get last4 => $composableBuilder(
    column: $table.last4,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get creditLimitPaise => $composableBuilder(
    column: $table.creditLimitPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get statementDay => $composableBuilder(
    column: $table.statementDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dueDay => $composableBuilder(
    column: $table.dueDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CreditCardsTableAnnotationComposer
    extends Composer<_$ArthDatabase, $CreditCardsTable> {
  $$CreditCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bankCode =>
      $composableBuilder(column: $table.bankCode, builder: (column) => column);

  GeneratedColumn<String> get last4 =>
      $composableBuilder(column: $table.last4, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get creditLimitPaise => $composableBuilder(
    column: $table.creditLimitPaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get statementDay => $composableBuilder(
    column: $table.statementDay,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dueDay =>
      $composableBuilder(column: $table.dueDay, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CreditCardsTableTableManager
    extends
        RootTableManager<
          _$ArthDatabase,
          $CreditCardsTable,
          CreditCard,
          $$CreditCardsTableFilterComposer,
          $$CreditCardsTableOrderingComposer,
          $$CreditCardsTableAnnotationComposer,
          $$CreditCardsTableCreateCompanionBuilder,
          $$CreditCardsTableUpdateCompanionBuilder,
          (
            CreditCard,
            BaseReferences<_$ArthDatabase, $CreditCardsTable, CreditCard>,
          ),
          CreditCard,
          PrefetchHooks Function()
        > {
  $$CreditCardsTableTableManager(_$ArthDatabase db, $CreditCardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CreditCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CreditCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CreditCardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> bankCode = const Value.absent(),
                Value<String?> last4 = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> creditLimitPaise = const Value.absent(),
                Value<int?> statementDay = const Value.absent(),
                Value<int?> dueDay = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CreditCardsCompanion(
                id: id,
                bankCode: bankCode,
                last4: last4,
                name: name,
                creditLimitPaise: creditLimitPaise,
                statementDay: statementDay,
                dueDay: dueDay,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String bankCode,
                Value<String?> last4 = const Value.absent(),
                required String name,
                Value<int?> creditLimitPaise = const Value.absent(),
                Value<int?> statementDay = const Value.absent(),
                Value<int?> dueDay = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CreditCardsCompanion.insert(
                id: id,
                bankCode: bankCode,
                last4: last4,
                name: name,
                creditLimitPaise: creditLimitPaise,
                statementDay: statementDay,
                dueDay: dueDay,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CreditCardsTableProcessedTableManager =
    ProcessedTableManager<
      _$ArthDatabase,
      $CreditCardsTable,
      CreditCard,
      $$CreditCardsTableFilterComposer,
      $$CreditCardsTableOrderingComposer,
      $$CreditCardsTableAnnotationComposer,
      $$CreditCardsTableCreateCompanionBuilder,
      $$CreditCardsTableUpdateCompanionBuilder,
      (
        CreditCard,
        BaseReferences<_$ArthDatabase, $CreditCardsTable, CreditCard>,
      ),
      CreditCard,
      PrefetchHooks Function()
    >;
typedef $$GoalsTableCreateCompanionBuilder =
    GoalsCompanion Function({
      Value<int> id,
      required String name,
      required int targetPaise,
      Value<DateTime?> targetDate,
      required DateTime startDate,
      Value<int> startPaise,
      Value<int> annualReturnBp,
      Value<String> source,
      Value<String?> sourceRef,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$GoalsTableUpdateCompanionBuilder =
    GoalsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> targetPaise,
      Value<DateTime?> targetDate,
      Value<DateTime> startDate,
      Value<int> startPaise,
      Value<int> annualReturnBp,
      Value<String> source,
      Value<String?> sourceRef,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$GoalsTableReferences
    extends BaseReferences<_$ArthDatabase, $GoalsTable, Goal> {
  $$GoalsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GoalContributionsTable, List<GoalContribution>>
  _goalContributionsRefsTable(_$ArthDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.goalContributions,
        aliasName: 'goals__id__goal_contributions__goal_id',
      );

  $$GoalContributionsTableProcessedTableManager get goalContributionsRefs {
    final manager = $$GoalContributionsTableTableManager(
      $_db,
      $_db.goalContributions,
    ).filter((f) => f.goalId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _goalContributionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GoalsTableFilterComposer extends Composer<_$ArthDatabase, $GoalsTable> {
  $$GoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetPaise => $composableBuilder(
    column: $table.targetPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startPaise => $composableBuilder(
    column: $table.startPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get annualReturnBp => $composableBuilder(
    column: $table.annualReturnBp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceRef => $composableBuilder(
    column: $table.sourceRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> goalContributionsRefs(
    Expression<bool> Function($$GoalContributionsTableFilterComposer f) f,
  ) {
    final $$GoalContributionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.goalContributions,
      getReferencedColumn: (t) => t.goalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalContributionsTableFilterComposer(
            $db: $db,
            $table: $db.goalContributions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GoalsTableOrderingComposer
    extends Composer<_$ArthDatabase, $GoalsTable> {
  $$GoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetPaise => $composableBuilder(
    column: $table.targetPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startPaise => $composableBuilder(
    column: $table.startPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get annualReturnBp => $composableBuilder(
    column: $table.annualReturnBp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceRef => $composableBuilder(
    column: $table.sourceRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GoalsTableAnnotationComposer
    extends Composer<_$ArthDatabase, $GoalsTable> {
  $$GoalsTableAnnotationComposer({
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

  GeneratedColumn<int> get targetPaise => $composableBuilder(
    column: $table.targetPaise,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<int> get startPaise => $composableBuilder(
    column: $table.startPaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get annualReturnBp => $composableBuilder(
    column: $table.annualReturnBp,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get sourceRef =>
      $composableBuilder(column: $table.sourceRef, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> goalContributionsRefs<T extends Object>(
    Expression<T> Function($$GoalContributionsTableAnnotationComposer a) f,
  ) {
    final $$GoalContributionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.goalContributions,
          getReferencedColumn: (t) => t.goalId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GoalContributionsTableAnnotationComposer(
                $db: $db,
                $table: $db.goalContributions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$GoalsTableTableManager
    extends
        RootTableManager<
          _$ArthDatabase,
          $GoalsTable,
          Goal,
          $$GoalsTableFilterComposer,
          $$GoalsTableOrderingComposer,
          $$GoalsTableAnnotationComposer,
          $$GoalsTableCreateCompanionBuilder,
          $$GoalsTableUpdateCompanionBuilder,
          (Goal, $$GoalsTableReferences),
          Goal,
          PrefetchHooks Function({bool goalContributionsRefs})
        > {
  $$GoalsTableTableManager(_$ArthDatabase db, $GoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> targetPaise = const Value.absent(),
                Value<DateTime?> targetDate = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<int> startPaise = const Value.absent(),
                Value<int> annualReturnBp = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> sourceRef = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => GoalsCompanion(
                id: id,
                name: name,
                targetPaise: targetPaise,
                targetDate: targetDate,
                startDate: startDate,
                startPaise: startPaise,
                annualReturnBp: annualReturnBp,
                source: source,
                sourceRef: sourceRef,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int targetPaise,
                Value<DateTime?> targetDate = const Value.absent(),
                required DateTime startDate,
                Value<int> startPaise = const Value.absent(),
                Value<int> annualReturnBp = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> sourceRef = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => GoalsCompanion.insert(
                id: id,
                name: name,
                targetPaise: targetPaise,
                targetDate: targetDate,
                startDate: startDate,
                startPaise: startPaise,
                annualReturnBp: annualReturnBp,
                source: source,
                sourceRef: sourceRef,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$GoalsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({goalContributionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (goalContributionsRefs) db.goalContributions,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (goalContributionsRefs)
                    await $_getPrefetchedData<
                      Goal,
                      $GoalsTable,
                      GoalContribution
                    >(
                      currentTable: table,
                      referencedTable: $$GoalsTableReferences
                          ._goalContributionsRefsTable(db),
                      managerFromTypedResult: (p0) => $$GoalsTableReferences(
                        db,
                        table,
                        p0,
                      ).goalContributionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.goalId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$GoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$ArthDatabase,
      $GoalsTable,
      Goal,
      $$GoalsTableFilterComposer,
      $$GoalsTableOrderingComposer,
      $$GoalsTableAnnotationComposer,
      $$GoalsTableCreateCompanionBuilder,
      $$GoalsTableUpdateCompanionBuilder,
      (Goal, $$GoalsTableReferences),
      Goal,
      PrefetchHooks Function({bool goalContributionsRefs})
    >;
typedef $$GoalContributionsTableCreateCompanionBuilder =
    GoalContributionsCompanion Function({
      Value<int> id,
      required int goalId,
      required int amountPaise,
      required DateTime date,
      Value<String?> note,
      Value<DateTime> createdAt,
    });
typedef $$GoalContributionsTableUpdateCompanionBuilder =
    GoalContributionsCompanion Function({
      Value<int> id,
      Value<int> goalId,
      Value<int> amountPaise,
      Value<DateTime> date,
      Value<String?> note,
      Value<DateTime> createdAt,
    });

final class $$GoalContributionsTableReferences
    extends
        BaseReferences<
          _$ArthDatabase,
          $GoalContributionsTable,
          GoalContribution
        > {
  $$GoalContributionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $GoalsTable _goalIdTable(_$ArthDatabase db) =>
      db.goals.createAlias('goal_contributions__goal_id__goals__id');

  $$GoalsTableProcessedTableManager get goalId {
    final $_column = $_itemColumn<int>('goal_id')!;

    final manager = $$GoalsTableTableManager(
      $_db,
      $_db.goals,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_goalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GoalContributionsTableFilterComposer
    extends Composer<_$ArthDatabase, $GoalContributionsTable> {
  $$GoalContributionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GoalsTableFilterComposer get goalId {
    final $$GoalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalsTableFilterComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GoalContributionsTableOrderingComposer
    extends Composer<_$ArthDatabase, $GoalContributionsTable> {
  $$GoalContributionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GoalsTableOrderingComposer get goalId {
    final $$GoalsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalsTableOrderingComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GoalContributionsTableAnnotationComposer
    extends Composer<_$ArthDatabase, $GoalContributionsTable> {
  $$GoalContributionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$GoalsTableAnnotationComposer get goalId {
    final $$GoalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalsTableAnnotationComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GoalContributionsTableTableManager
    extends
        RootTableManager<
          _$ArthDatabase,
          $GoalContributionsTable,
          GoalContribution,
          $$GoalContributionsTableFilterComposer,
          $$GoalContributionsTableOrderingComposer,
          $$GoalContributionsTableAnnotationComposer,
          $$GoalContributionsTableCreateCompanionBuilder,
          $$GoalContributionsTableUpdateCompanionBuilder,
          (GoalContribution, $$GoalContributionsTableReferences),
          GoalContribution,
          PrefetchHooks Function({bool goalId})
        > {
  $$GoalContributionsTableTableManager(
    _$ArthDatabase db,
    $GoalContributionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalContributionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalContributionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalContributionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> goalId = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => GoalContributionsCompanion(
                id: id,
                goalId: goalId,
                amountPaise: amountPaise,
                date: date,
                note: note,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int goalId,
                required int amountPaise,
                required DateTime date,
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => GoalContributionsCompanion.insert(
                id: id,
                goalId: goalId,
                amountPaise: amountPaise,
                date: date,
                note: note,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GoalContributionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({goalId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (goalId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.goalId,
                                referencedTable:
                                    $$GoalContributionsTableReferences
                                        ._goalIdTable(db),
                                referencedColumn:
                                    $$GoalContributionsTableReferences
                                        ._goalIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GoalContributionsTableProcessedTableManager =
    ProcessedTableManager<
      _$ArthDatabase,
      $GoalContributionsTable,
      GoalContribution,
      $$GoalContributionsTableFilterComposer,
      $$GoalContributionsTableOrderingComposer,
      $$GoalContributionsTableAnnotationComposer,
      $$GoalContributionsTableCreateCompanionBuilder,
      $$GoalContributionsTableUpdateCompanionBuilder,
      (GoalContribution, $$GoalContributionsTableReferences),
      GoalContribution,
      PrefetchHooks Function({bool goalId})
    >;
typedef $$SecuritiesTableCreateCompanionBuilder =
    SecuritiesCompanion Function({
      Value<int> id,
      required String isin,
      required String name,
      required String kind,
      Value<String?> amc,
      Value<String?> taxCategory,
    });
typedef $$SecuritiesTableUpdateCompanionBuilder =
    SecuritiesCompanion Function({
      Value<int> id,
      Value<String> isin,
      Value<String> name,
      Value<String> kind,
      Value<String?> amc,
      Value<String?> taxCategory,
    });

final class $$SecuritiesTableReferences
    extends BaseReferences<_$ArthDatabase, $SecuritiesTable, Security> {
  $$SecuritiesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$InvestmentTxnsTable, List<InvestmentTxn>>
  _investmentTxnsRefsTable(_$ArthDatabase db) => MultiTypedResultKey.fromTable(
    db.investmentTxns,
    aliasName: 'securities__id__investment_txns__security_id',
  );

  $$InvestmentTxnsTableProcessedTableManager get investmentTxnsRefs {
    final manager = $$InvestmentTxnsTableTableManager(
      $_db,
      $_db.investmentTxns,
    ).filter((f) => f.securityId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_investmentTxnsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$HoldingSnapshotsTable, List<HoldingSnapshot>>
  _holdingSnapshotsRefsTable(_$ArthDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.holdingSnapshots,
        aliasName: 'securities__id__holding_snapshots__security_id',
      );

  $$HoldingSnapshotsTableProcessedTableManager get holdingSnapshotsRefs {
    final manager = $$HoldingSnapshotsTableTableManager(
      $_db,
      $_db.holdingSnapshots,
    ).filter((f) => f.securityId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _holdingSnapshotsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SecurityPricesTable, List<SecurityPrice>>
  _securityPricesRefsTable(_$ArthDatabase db) => MultiTypedResultKey.fromTable(
    db.securityPrices,
    aliasName: 'securities__id__security_prices__security_id',
  );

  $$SecurityPricesTableProcessedTableManager get securityPricesRefs {
    final manager = $$SecurityPricesTableTableManager(
      $_db,
      $_db.securityPrices,
    ).filter((f) => f.securityId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_securityPricesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SecuritiesTableFilterComposer
    extends Composer<_$ArthDatabase, $SecuritiesTable> {
  $$SecuritiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get isin => $composableBuilder(
    column: $table.isin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get amc => $composableBuilder(
    column: $table.amc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taxCategory => $composableBuilder(
    column: $table.taxCategory,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> investmentTxnsRefs(
    Expression<bool> Function($$InvestmentTxnsTableFilterComposer f) f,
  ) {
    final $$InvestmentTxnsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.investmentTxns,
      getReferencedColumn: (t) => t.securityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestmentTxnsTableFilterComposer(
            $db: $db,
            $table: $db.investmentTxns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> holdingSnapshotsRefs(
    Expression<bool> Function($$HoldingSnapshotsTableFilterComposer f) f,
  ) {
    final $$HoldingSnapshotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.holdingSnapshots,
      getReferencedColumn: (t) => t.securityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HoldingSnapshotsTableFilterComposer(
            $db: $db,
            $table: $db.holdingSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> securityPricesRefs(
    Expression<bool> Function($$SecurityPricesTableFilterComposer f) f,
  ) {
    final $$SecurityPricesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.securityPrices,
      getReferencedColumn: (t) => t.securityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SecurityPricesTableFilterComposer(
            $db: $db,
            $table: $db.securityPrices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SecuritiesTableOrderingComposer
    extends Composer<_$ArthDatabase, $SecuritiesTable> {
  $$SecuritiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get isin => $composableBuilder(
    column: $table.isin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amc => $composableBuilder(
    column: $table.amc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taxCategory => $composableBuilder(
    column: $table.taxCategory,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SecuritiesTableAnnotationComposer
    extends Composer<_$ArthDatabase, $SecuritiesTable> {
  $$SecuritiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get isin =>
      $composableBuilder(column: $table.isin, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get amc =>
      $composableBuilder(column: $table.amc, builder: (column) => column);

  GeneratedColumn<String> get taxCategory => $composableBuilder(
    column: $table.taxCategory,
    builder: (column) => column,
  );

  Expression<T> investmentTxnsRefs<T extends Object>(
    Expression<T> Function($$InvestmentTxnsTableAnnotationComposer a) f,
  ) {
    final $$InvestmentTxnsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.investmentTxns,
      getReferencedColumn: (t) => t.securityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestmentTxnsTableAnnotationComposer(
            $db: $db,
            $table: $db.investmentTxns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> holdingSnapshotsRefs<T extends Object>(
    Expression<T> Function($$HoldingSnapshotsTableAnnotationComposer a) f,
  ) {
    final $$HoldingSnapshotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.holdingSnapshots,
      getReferencedColumn: (t) => t.securityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HoldingSnapshotsTableAnnotationComposer(
            $db: $db,
            $table: $db.holdingSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> securityPricesRefs<T extends Object>(
    Expression<T> Function($$SecurityPricesTableAnnotationComposer a) f,
  ) {
    final $$SecurityPricesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.securityPrices,
      getReferencedColumn: (t) => t.securityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SecurityPricesTableAnnotationComposer(
            $db: $db,
            $table: $db.securityPrices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SecuritiesTableTableManager
    extends
        RootTableManager<
          _$ArthDatabase,
          $SecuritiesTable,
          Security,
          $$SecuritiesTableFilterComposer,
          $$SecuritiesTableOrderingComposer,
          $$SecuritiesTableAnnotationComposer,
          $$SecuritiesTableCreateCompanionBuilder,
          $$SecuritiesTableUpdateCompanionBuilder,
          (Security, $$SecuritiesTableReferences),
          Security,
          PrefetchHooks Function({
            bool investmentTxnsRefs,
            bool holdingSnapshotsRefs,
            bool securityPricesRefs,
          })
        > {
  $$SecuritiesTableTableManager(_$ArthDatabase db, $SecuritiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SecuritiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SecuritiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SecuritiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> isin = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> amc = const Value.absent(),
                Value<String?> taxCategory = const Value.absent(),
              }) => SecuritiesCompanion(
                id: id,
                isin: isin,
                name: name,
                kind: kind,
                amc: amc,
                taxCategory: taxCategory,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String isin,
                required String name,
                required String kind,
                Value<String?> amc = const Value.absent(),
                Value<String?> taxCategory = const Value.absent(),
              }) => SecuritiesCompanion.insert(
                id: id,
                isin: isin,
                name: name,
                kind: kind,
                amc: amc,
                taxCategory: taxCategory,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SecuritiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                investmentTxnsRefs = false,
                holdingSnapshotsRefs = false,
                securityPricesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (investmentTxnsRefs) db.investmentTxns,
                    if (holdingSnapshotsRefs) db.holdingSnapshots,
                    if (securityPricesRefs) db.securityPrices,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (investmentTxnsRefs)
                        await $_getPrefetchedData<
                          Security,
                          $SecuritiesTable,
                          InvestmentTxn
                        >(
                          currentTable: table,
                          referencedTable: $$SecuritiesTableReferences
                              ._investmentTxnsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SecuritiesTableReferences(
                                db,
                                table,
                                p0,
                              ).investmentTxnsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.securityId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (holdingSnapshotsRefs)
                        await $_getPrefetchedData<
                          Security,
                          $SecuritiesTable,
                          HoldingSnapshot
                        >(
                          currentTable: table,
                          referencedTable: $$SecuritiesTableReferences
                              ._holdingSnapshotsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SecuritiesTableReferences(
                                db,
                                table,
                                p0,
                              ).holdingSnapshotsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.securityId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (securityPricesRefs)
                        await $_getPrefetchedData<
                          Security,
                          $SecuritiesTable,
                          SecurityPrice
                        >(
                          currentTable: table,
                          referencedTable: $$SecuritiesTableReferences
                              ._securityPricesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SecuritiesTableReferences(
                                db,
                                table,
                                p0,
                              ).securityPricesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.securityId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SecuritiesTableProcessedTableManager =
    ProcessedTableManager<
      _$ArthDatabase,
      $SecuritiesTable,
      Security,
      $$SecuritiesTableFilterComposer,
      $$SecuritiesTableOrderingComposer,
      $$SecuritiesTableAnnotationComposer,
      $$SecuritiesTableCreateCompanionBuilder,
      $$SecuritiesTableUpdateCompanionBuilder,
      (Security, $$SecuritiesTableReferences),
      Security,
      PrefetchHooks Function({
        bool investmentTxnsRefs,
        bool holdingSnapshotsRefs,
        bool securityPricesRefs,
      })
    >;
typedef $$InvestmentAccountsTableCreateCompanionBuilder =
    InvestmentAccountsCompanion Function({
      Value<int> id,
      required String kind,
      required String number,
      required String provider,
      Value<String?> amc,
    });
typedef $$InvestmentAccountsTableUpdateCompanionBuilder =
    InvestmentAccountsCompanion Function({
      Value<int> id,
      Value<String> kind,
      Value<String> number,
      Value<String> provider,
      Value<String?> amc,
    });

final class $$InvestmentAccountsTableReferences
    extends
        BaseReferences<
          _$ArthDatabase,
          $InvestmentAccountsTable,
          InvestmentAccount
        > {
  $$InvestmentAccountsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$InvestmentTxnsTable, List<InvestmentTxn>>
  _investmentTxnsRefsTable(_$ArthDatabase db) => MultiTypedResultKey.fromTable(
    db.investmentTxns,
    aliasName: 'investment_accounts__id__investment_txns__account_id',
  );

  $$InvestmentTxnsTableProcessedTableManager get investmentTxnsRefs {
    final manager = $$InvestmentTxnsTableTableManager(
      $_db,
      $_db.investmentTxns,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_investmentTxnsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$HoldingSnapshotsTable, List<HoldingSnapshot>>
  _holdingSnapshotsRefsTable(_$ArthDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.holdingSnapshots,
        aliasName: 'investment_accounts__id__holding_snapshots__account_id',
      );

  $$HoldingSnapshotsTableProcessedTableManager get holdingSnapshotsRefs {
    final manager = $$HoldingSnapshotsTableTableManager(
      $_db,
      $_db.holdingSnapshots,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _holdingSnapshotsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$InvestmentAccountsTableFilterComposer
    extends Composer<_$ArthDatabase, $InvestmentAccountsTable> {
  $$InvestmentAccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get amc => $composableBuilder(
    column: $table.amc,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> investmentTxnsRefs(
    Expression<bool> Function($$InvestmentTxnsTableFilterComposer f) f,
  ) {
    final $$InvestmentTxnsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.investmentTxns,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestmentTxnsTableFilterComposer(
            $db: $db,
            $table: $db.investmentTxns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> holdingSnapshotsRefs(
    Expression<bool> Function($$HoldingSnapshotsTableFilterComposer f) f,
  ) {
    final $$HoldingSnapshotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.holdingSnapshots,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HoldingSnapshotsTableFilterComposer(
            $db: $db,
            $table: $db.holdingSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InvestmentAccountsTableOrderingComposer
    extends Composer<_$ArthDatabase, $InvestmentAccountsTable> {
  $$InvestmentAccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amc => $composableBuilder(
    column: $table.amc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InvestmentAccountsTableAnnotationComposer
    extends Composer<_$ArthDatabase, $InvestmentAccountsTable> {
  $$InvestmentAccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get amc =>
      $composableBuilder(column: $table.amc, builder: (column) => column);

  Expression<T> investmentTxnsRefs<T extends Object>(
    Expression<T> Function($$InvestmentTxnsTableAnnotationComposer a) f,
  ) {
    final $$InvestmentTxnsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.investmentTxns,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestmentTxnsTableAnnotationComposer(
            $db: $db,
            $table: $db.investmentTxns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> holdingSnapshotsRefs<T extends Object>(
    Expression<T> Function($$HoldingSnapshotsTableAnnotationComposer a) f,
  ) {
    final $$HoldingSnapshotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.holdingSnapshots,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HoldingSnapshotsTableAnnotationComposer(
            $db: $db,
            $table: $db.holdingSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InvestmentAccountsTableTableManager
    extends
        RootTableManager<
          _$ArthDatabase,
          $InvestmentAccountsTable,
          InvestmentAccount,
          $$InvestmentAccountsTableFilterComposer,
          $$InvestmentAccountsTableOrderingComposer,
          $$InvestmentAccountsTableAnnotationComposer,
          $$InvestmentAccountsTableCreateCompanionBuilder,
          $$InvestmentAccountsTableUpdateCompanionBuilder,
          (InvestmentAccount, $$InvestmentAccountsTableReferences),
          InvestmentAccount,
          PrefetchHooks Function({
            bool investmentTxnsRefs,
            bool holdingSnapshotsRefs,
          })
        > {
  $$InvestmentAccountsTableTableManager(
    _$ArthDatabase db,
    $InvestmentAccountsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvestmentAccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvestmentAccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvestmentAccountsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> number = const Value.absent(),
                Value<String> provider = const Value.absent(),
                Value<String?> amc = const Value.absent(),
              }) => InvestmentAccountsCompanion(
                id: id,
                kind: kind,
                number: number,
                provider: provider,
                amc: amc,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String kind,
                required String number,
                required String provider,
                Value<String?> amc = const Value.absent(),
              }) => InvestmentAccountsCompanion.insert(
                id: id,
                kind: kind,
                number: number,
                provider: provider,
                amc: amc,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InvestmentAccountsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({investmentTxnsRefs = false, holdingSnapshotsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (investmentTxnsRefs) db.investmentTxns,
                    if (holdingSnapshotsRefs) db.holdingSnapshots,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (investmentTxnsRefs)
                        await $_getPrefetchedData<
                          InvestmentAccount,
                          $InvestmentAccountsTable,
                          InvestmentTxn
                        >(
                          currentTable: table,
                          referencedTable: $$InvestmentAccountsTableReferences
                              ._investmentTxnsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InvestmentAccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).investmentTxnsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (holdingSnapshotsRefs)
                        await $_getPrefetchedData<
                          InvestmentAccount,
                          $InvestmentAccountsTable,
                          HoldingSnapshot
                        >(
                          currentTable: table,
                          referencedTable: $$InvestmentAccountsTableReferences
                              ._holdingSnapshotsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InvestmentAccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).holdingSnapshotsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$InvestmentAccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$ArthDatabase,
      $InvestmentAccountsTable,
      InvestmentAccount,
      $$InvestmentAccountsTableFilterComposer,
      $$InvestmentAccountsTableOrderingComposer,
      $$InvestmentAccountsTableAnnotationComposer,
      $$InvestmentAccountsTableCreateCompanionBuilder,
      $$InvestmentAccountsTableUpdateCompanionBuilder,
      (InvestmentAccount, $$InvestmentAccountsTableReferences),
      InvestmentAccount,
      PrefetchHooks Function({
        bool investmentTxnsRefs,
        bool holdingSnapshotsRefs,
      })
    >;
typedef $$InvestmentTxnsTableCreateCompanionBuilder =
    InvestmentTxnsCompanion Function({
      Value<int> id,
      required int accountId,
      required int securityId,
      required DateTime date,
      required String type,
      required String description,
      Value<int?> amountPaise,
      Value<int?> unitsE4,
      Value<int?> navE4,
      Value<int?> balanceE4,
      Value<int?> importId,
      required String dedupeHash,
    });
typedef $$InvestmentTxnsTableUpdateCompanionBuilder =
    InvestmentTxnsCompanion Function({
      Value<int> id,
      Value<int> accountId,
      Value<int> securityId,
      Value<DateTime> date,
      Value<String> type,
      Value<String> description,
      Value<int?> amountPaise,
      Value<int?> unitsE4,
      Value<int?> navE4,
      Value<int?> balanceE4,
      Value<int?> importId,
      Value<String> dedupeHash,
    });

final class $$InvestmentTxnsTableReferences
    extends
        BaseReferences<_$ArthDatabase, $InvestmentTxnsTable, InvestmentTxn> {
  $$InvestmentTxnsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $InvestmentAccountsTable _accountIdTable(_$ArthDatabase db) => db
      .investmentAccounts
      .createAlias('investment_txns__account_id__investment_accounts__id');

  $$InvestmentAccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<int>('account_id')!;

    final manager = $$InvestmentAccountsTableTableManager(
      $_db,
      $_db.investmentAccounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SecuritiesTable _securityIdTable(_$ArthDatabase db) =>
      db.securities.createAlias('investment_txns__security_id__securities__id');

  $$SecuritiesTableProcessedTableManager get securityId {
    final $_column = $_itemColumn<int>('security_id')!;

    final manager = $$SecuritiesTableTableManager(
      $_db,
      $_db.securities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_securityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ImportsTable _importIdTable(_$ArthDatabase db) =>
      db.imports.createAlias('investment_txns__import_id__imports__id');

  $$ImportsTableProcessedTableManager? get importId {
    final $_column = $_itemColumn<int>('import_id');
    if ($_column == null) return null;
    final manager = $$ImportsTableTableManager(
      $_db,
      $_db.imports,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_importIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$InvestmentTxnsTableFilterComposer
    extends Composer<_$ArthDatabase, $InvestmentTxnsTable> {
  $$InvestmentTxnsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitsE4 => $composableBuilder(
    column: $table.unitsE4,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get navE4 => $composableBuilder(
    column: $table.navE4,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get balanceE4 => $composableBuilder(
    column: $table.balanceE4,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dedupeHash => $composableBuilder(
    column: $table.dedupeHash,
    builder: (column) => ColumnFilters(column),
  );

  $$InvestmentAccountsTableFilterComposer get accountId {
    final $$InvestmentAccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.investmentAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestmentAccountsTableFilterComposer(
            $db: $db,
            $table: $db.investmentAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SecuritiesTableFilterComposer get securityId {
    final $$SecuritiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.securityId,
      referencedTable: $db.securities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SecuritiesTableFilterComposer(
            $db: $db,
            $table: $db.securities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportsTableFilterComposer get importId {
    final $$ImportsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableFilterComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvestmentTxnsTableOrderingComposer
    extends Composer<_$ArthDatabase, $InvestmentTxnsTable> {
  $$InvestmentTxnsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitsE4 => $composableBuilder(
    column: $table.unitsE4,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get navE4 => $composableBuilder(
    column: $table.navE4,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get balanceE4 => $composableBuilder(
    column: $table.balanceE4,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dedupeHash => $composableBuilder(
    column: $table.dedupeHash,
    builder: (column) => ColumnOrderings(column),
  );

  $$InvestmentAccountsTableOrderingComposer get accountId {
    final $$InvestmentAccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.investmentAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestmentAccountsTableOrderingComposer(
            $db: $db,
            $table: $db.investmentAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SecuritiesTableOrderingComposer get securityId {
    final $$SecuritiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.securityId,
      referencedTable: $db.securities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SecuritiesTableOrderingComposer(
            $db: $db,
            $table: $db.securities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportsTableOrderingComposer get importId {
    final $$ImportsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableOrderingComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvestmentTxnsTableAnnotationComposer
    extends Composer<_$ArthDatabase, $InvestmentTxnsTable> {
  $$InvestmentTxnsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unitsE4 =>
      $composableBuilder(column: $table.unitsE4, builder: (column) => column);

  GeneratedColumn<int> get navE4 =>
      $composableBuilder(column: $table.navE4, builder: (column) => column);

  GeneratedColumn<int> get balanceE4 =>
      $composableBuilder(column: $table.balanceE4, builder: (column) => column);

  GeneratedColumn<String> get dedupeHash => $composableBuilder(
    column: $table.dedupeHash,
    builder: (column) => column,
  );

  $$InvestmentAccountsTableAnnotationComposer get accountId {
    final $$InvestmentAccountsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.accountId,
          referencedTable: $db.investmentAccounts,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InvestmentAccountsTableAnnotationComposer(
                $db: $db,
                $table: $db.investmentAccounts,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$SecuritiesTableAnnotationComposer get securityId {
    final $$SecuritiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.securityId,
      referencedTable: $db.securities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SecuritiesTableAnnotationComposer(
            $db: $db,
            $table: $db.securities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportsTableAnnotationComposer get importId {
    final $$ImportsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableAnnotationComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvestmentTxnsTableTableManager
    extends
        RootTableManager<
          _$ArthDatabase,
          $InvestmentTxnsTable,
          InvestmentTxn,
          $$InvestmentTxnsTableFilterComposer,
          $$InvestmentTxnsTableOrderingComposer,
          $$InvestmentTxnsTableAnnotationComposer,
          $$InvestmentTxnsTableCreateCompanionBuilder,
          $$InvestmentTxnsTableUpdateCompanionBuilder,
          (InvestmentTxn, $$InvestmentTxnsTableReferences),
          InvestmentTxn,
          PrefetchHooks Function({
            bool accountId,
            bool securityId,
            bool importId,
          })
        > {
  $$InvestmentTxnsTableTableManager(
    _$ArthDatabase db,
    $InvestmentTxnsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvestmentTxnsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvestmentTxnsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvestmentTxnsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> accountId = const Value.absent(),
                Value<int> securityId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int?> amountPaise = const Value.absent(),
                Value<int?> unitsE4 = const Value.absent(),
                Value<int?> navE4 = const Value.absent(),
                Value<int?> balanceE4 = const Value.absent(),
                Value<int?> importId = const Value.absent(),
                Value<String> dedupeHash = const Value.absent(),
              }) => InvestmentTxnsCompanion(
                id: id,
                accountId: accountId,
                securityId: securityId,
                date: date,
                type: type,
                description: description,
                amountPaise: amountPaise,
                unitsE4: unitsE4,
                navE4: navE4,
                balanceE4: balanceE4,
                importId: importId,
                dedupeHash: dedupeHash,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int accountId,
                required int securityId,
                required DateTime date,
                required String type,
                required String description,
                Value<int?> amountPaise = const Value.absent(),
                Value<int?> unitsE4 = const Value.absent(),
                Value<int?> navE4 = const Value.absent(),
                Value<int?> balanceE4 = const Value.absent(),
                Value<int?> importId = const Value.absent(),
                required String dedupeHash,
              }) => InvestmentTxnsCompanion.insert(
                id: id,
                accountId: accountId,
                securityId: securityId,
                date: date,
                type: type,
                description: description,
                amountPaise: amountPaise,
                unitsE4: unitsE4,
                navE4: navE4,
                balanceE4: balanceE4,
                importId: importId,
                dedupeHash: dedupeHash,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InvestmentTxnsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({accountId = false, securityId = false, importId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (accountId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.accountId,
                                    referencedTable:
                                        $$InvestmentTxnsTableReferences
                                            ._accountIdTable(db),
                                    referencedColumn:
                                        $$InvestmentTxnsTableReferences
                                            ._accountIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (securityId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.securityId,
                                    referencedTable:
                                        $$InvestmentTxnsTableReferences
                                            ._securityIdTable(db),
                                    referencedColumn:
                                        $$InvestmentTxnsTableReferences
                                            ._securityIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (importId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.importId,
                                    referencedTable:
                                        $$InvestmentTxnsTableReferences
                                            ._importIdTable(db),
                                    referencedColumn:
                                        $$InvestmentTxnsTableReferences
                                            ._importIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$InvestmentTxnsTableProcessedTableManager =
    ProcessedTableManager<
      _$ArthDatabase,
      $InvestmentTxnsTable,
      InvestmentTxn,
      $$InvestmentTxnsTableFilterComposer,
      $$InvestmentTxnsTableOrderingComposer,
      $$InvestmentTxnsTableAnnotationComposer,
      $$InvestmentTxnsTableCreateCompanionBuilder,
      $$InvestmentTxnsTableUpdateCompanionBuilder,
      (InvestmentTxn, $$InvestmentTxnsTableReferences),
      InvestmentTxn,
      PrefetchHooks Function({bool accountId, bool securityId, bool importId})
    >;
typedef $$HoldingSnapshotsTableCreateCompanionBuilder =
    HoldingSnapshotsCompanion Function({
      Value<int> id,
      required int accountId,
      required int securityId,
      required DateTime asOf,
      required int unitsE4,
      required int priceE4,
      required int valuePaise,
      Value<int?> costPaise,
      Value<int?> importId,
    });
typedef $$HoldingSnapshotsTableUpdateCompanionBuilder =
    HoldingSnapshotsCompanion Function({
      Value<int> id,
      Value<int> accountId,
      Value<int> securityId,
      Value<DateTime> asOf,
      Value<int> unitsE4,
      Value<int> priceE4,
      Value<int> valuePaise,
      Value<int?> costPaise,
      Value<int?> importId,
    });

final class $$HoldingSnapshotsTableReferences
    extends
        BaseReferences<
          _$ArthDatabase,
          $HoldingSnapshotsTable,
          HoldingSnapshot
        > {
  $$HoldingSnapshotsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $InvestmentAccountsTable _accountIdTable(_$ArthDatabase db) => db
      .investmentAccounts
      .createAlias('holding_snapshots__account_id__investment_accounts__id');

  $$InvestmentAccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<int>('account_id')!;

    final manager = $$InvestmentAccountsTableTableManager(
      $_db,
      $_db.investmentAccounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SecuritiesTable _securityIdTable(_$ArthDatabase db) => db.securities
      .createAlias('holding_snapshots__security_id__securities__id');

  $$SecuritiesTableProcessedTableManager get securityId {
    final $_column = $_itemColumn<int>('security_id')!;

    final manager = $$SecuritiesTableTableManager(
      $_db,
      $_db.securities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_securityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ImportsTable _importIdTable(_$ArthDatabase db) =>
      db.imports.createAlias('holding_snapshots__import_id__imports__id');

  $$ImportsTableProcessedTableManager? get importId {
    final $_column = $_itemColumn<int>('import_id');
    if ($_column == null) return null;
    final manager = $$ImportsTableTableManager(
      $_db,
      $_db.imports,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_importIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HoldingSnapshotsTableFilterComposer
    extends Composer<_$ArthDatabase, $HoldingSnapshotsTable> {
  $$HoldingSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get asOf => $composableBuilder(
    column: $table.asOf,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitsE4 => $composableBuilder(
    column: $table.unitsE4,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priceE4 => $composableBuilder(
    column: $table.priceE4,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get valuePaise => $composableBuilder(
    column: $table.valuePaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get costPaise => $composableBuilder(
    column: $table.costPaise,
    builder: (column) => ColumnFilters(column),
  );

  $$InvestmentAccountsTableFilterComposer get accountId {
    final $$InvestmentAccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.investmentAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestmentAccountsTableFilterComposer(
            $db: $db,
            $table: $db.investmentAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SecuritiesTableFilterComposer get securityId {
    final $$SecuritiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.securityId,
      referencedTable: $db.securities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SecuritiesTableFilterComposer(
            $db: $db,
            $table: $db.securities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportsTableFilterComposer get importId {
    final $$ImportsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableFilterComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HoldingSnapshotsTableOrderingComposer
    extends Composer<_$ArthDatabase, $HoldingSnapshotsTable> {
  $$HoldingSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get asOf => $composableBuilder(
    column: $table.asOf,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitsE4 => $composableBuilder(
    column: $table.unitsE4,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priceE4 => $composableBuilder(
    column: $table.priceE4,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get valuePaise => $composableBuilder(
    column: $table.valuePaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get costPaise => $composableBuilder(
    column: $table.costPaise,
    builder: (column) => ColumnOrderings(column),
  );

  $$InvestmentAccountsTableOrderingComposer get accountId {
    final $$InvestmentAccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.investmentAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestmentAccountsTableOrderingComposer(
            $db: $db,
            $table: $db.investmentAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SecuritiesTableOrderingComposer get securityId {
    final $$SecuritiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.securityId,
      referencedTable: $db.securities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SecuritiesTableOrderingComposer(
            $db: $db,
            $table: $db.securities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportsTableOrderingComposer get importId {
    final $$ImportsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableOrderingComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HoldingSnapshotsTableAnnotationComposer
    extends Composer<_$ArthDatabase, $HoldingSnapshotsTable> {
  $$HoldingSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get asOf =>
      $composableBuilder(column: $table.asOf, builder: (column) => column);

  GeneratedColumn<int> get unitsE4 =>
      $composableBuilder(column: $table.unitsE4, builder: (column) => column);

  GeneratedColumn<int> get priceE4 =>
      $composableBuilder(column: $table.priceE4, builder: (column) => column);

  GeneratedColumn<int> get valuePaise => $composableBuilder(
    column: $table.valuePaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get costPaise =>
      $composableBuilder(column: $table.costPaise, builder: (column) => column);

  $$InvestmentAccountsTableAnnotationComposer get accountId {
    final $$InvestmentAccountsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.accountId,
          referencedTable: $db.investmentAccounts,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InvestmentAccountsTableAnnotationComposer(
                $db: $db,
                $table: $db.investmentAccounts,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$SecuritiesTableAnnotationComposer get securityId {
    final $$SecuritiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.securityId,
      referencedTable: $db.securities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SecuritiesTableAnnotationComposer(
            $db: $db,
            $table: $db.securities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportsTableAnnotationComposer get importId {
    final $$ImportsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableAnnotationComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HoldingSnapshotsTableTableManager
    extends
        RootTableManager<
          _$ArthDatabase,
          $HoldingSnapshotsTable,
          HoldingSnapshot,
          $$HoldingSnapshotsTableFilterComposer,
          $$HoldingSnapshotsTableOrderingComposer,
          $$HoldingSnapshotsTableAnnotationComposer,
          $$HoldingSnapshotsTableCreateCompanionBuilder,
          $$HoldingSnapshotsTableUpdateCompanionBuilder,
          (HoldingSnapshot, $$HoldingSnapshotsTableReferences),
          HoldingSnapshot,
          PrefetchHooks Function({
            bool accountId,
            bool securityId,
            bool importId,
          })
        > {
  $$HoldingSnapshotsTableTableManager(
    _$ArthDatabase db,
    $HoldingSnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HoldingSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HoldingSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HoldingSnapshotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> accountId = const Value.absent(),
                Value<int> securityId = const Value.absent(),
                Value<DateTime> asOf = const Value.absent(),
                Value<int> unitsE4 = const Value.absent(),
                Value<int> priceE4 = const Value.absent(),
                Value<int> valuePaise = const Value.absent(),
                Value<int?> costPaise = const Value.absent(),
                Value<int?> importId = const Value.absent(),
              }) => HoldingSnapshotsCompanion(
                id: id,
                accountId: accountId,
                securityId: securityId,
                asOf: asOf,
                unitsE4: unitsE4,
                priceE4: priceE4,
                valuePaise: valuePaise,
                costPaise: costPaise,
                importId: importId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int accountId,
                required int securityId,
                required DateTime asOf,
                required int unitsE4,
                required int priceE4,
                required int valuePaise,
                Value<int?> costPaise = const Value.absent(),
                Value<int?> importId = const Value.absent(),
              }) => HoldingSnapshotsCompanion.insert(
                id: id,
                accountId: accountId,
                securityId: securityId,
                asOf: asOf,
                unitsE4: unitsE4,
                priceE4: priceE4,
                valuePaise: valuePaise,
                costPaise: costPaise,
                importId: importId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HoldingSnapshotsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({accountId = false, securityId = false, importId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (accountId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.accountId,
                                    referencedTable:
                                        $$HoldingSnapshotsTableReferences
                                            ._accountIdTable(db),
                                    referencedColumn:
                                        $$HoldingSnapshotsTableReferences
                                            ._accountIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (securityId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.securityId,
                                    referencedTable:
                                        $$HoldingSnapshotsTableReferences
                                            ._securityIdTable(db),
                                    referencedColumn:
                                        $$HoldingSnapshotsTableReferences
                                            ._securityIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (importId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.importId,
                                    referencedTable:
                                        $$HoldingSnapshotsTableReferences
                                            ._importIdTable(db),
                                    referencedColumn:
                                        $$HoldingSnapshotsTableReferences
                                            ._importIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$HoldingSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$ArthDatabase,
      $HoldingSnapshotsTable,
      HoldingSnapshot,
      $$HoldingSnapshotsTableFilterComposer,
      $$HoldingSnapshotsTableOrderingComposer,
      $$HoldingSnapshotsTableAnnotationComposer,
      $$HoldingSnapshotsTableCreateCompanionBuilder,
      $$HoldingSnapshotsTableUpdateCompanionBuilder,
      (HoldingSnapshot, $$HoldingSnapshotsTableReferences),
      HoldingSnapshot,
      PrefetchHooks Function({bool accountId, bool securityId, bool importId})
    >;
typedef $$SecurityPricesTableCreateCompanionBuilder =
    SecurityPricesCompanion Function({
      Value<int> id,
      required int securityId,
      required DateTime date,
      required int priceE4,
      required String source,
    });
typedef $$SecurityPricesTableUpdateCompanionBuilder =
    SecurityPricesCompanion Function({
      Value<int> id,
      Value<int> securityId,
      Value<DateTime> date,
      Value<int> priceE4,
      Value<String> source,
    });

final class $$SecurityPricesTableReferences
    extends
        BaseReferences<_$ArthDatabase, $SecurityPricesTable, SecurityPrice> {
  $$SecurityPricesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SecuritiesTable _securityIdTable(_$ArthDatabase db) =>
      db.securities.createAlias('security_prices__security_id__securities__id');

  $$SecuritiesTableProcessedTableManager get securityId {
    final $_column = $_itemColumn<int>('security_id')!;

    final manager = $$SecuritiesTableTableManager(
      $_db,
      $_db.securities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_securityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SecurityPricesTableFilterComposer
    extends Composer<_$ArthDatabase, $SecurityPricesTable> {
  $$SecurityPricesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priceE4 => $composableBuilder(
    column: $table.priceE4,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  $$SecuritiesTableFilterComposer get securityId {
    final $$SecuritiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.securityId,
      referencedTable: $db.securities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SecuritiesTableFilterComposer(
            $db: $db,
            $table: $db.securities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SecurityPricesTableOrderingComposer
    extends Composer<_$ArthDatabase, $SecurityPricesTable> {
  $$SecurityPricesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priceE4 => $composableBuilder(
    column: $table.priceE4,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  $$SecuritiesTableOrderingComposer get securityId {
    final $$SecuritiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.securityId,
      referencedTable: $db.securities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SecuritiesTableOrderingComposer(
            $db: $db,
            $table: $db.securities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SecurityPricesTableAnnotationComposer
    extends Composer<_$ArthDatabase, $SecurityPricesTable> {
  $$SecurityPricesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get priceE4 =>
      $composableBuilder(column: $table.priceE4, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  $$SecuritiesTableAnnotationComposer get securityId {
    final $$SecuritiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.securityId,
      referencedTable: $db.securities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SecuritiesTableAnnotationComposer(
            $db: $db,
            $table: $db.securities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SecurityPricesTableTableManager
    extends
        RootTableManager<
          _$ArthDatabase,
          $SecurityPricesTable,
          SecurityPrice,
          $$SecurityPricesTableFilterComposer,
          $$SecurityPricesTableOrderingComposer,
          $$SecurityPricesTableAnnotationComposer,
          $$SecurityPricesTableCreateCompanionBuilder,
          $$SecurityPricesTableUpdateCompanionBuilder,
          (SecurityPrice, $$SecurityPricesTableReferences),
          SecurityPrice,
          PrefetchHooks Function({bool securityId})
        > {
  $$SecurityPricesTableTableManager(
    _$ArthDatabase db,
    $SecurityPricesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SecurityPricesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SecurityPricesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SecurityPricesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> securityId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> priceE4 = const Value.absent(),
                Value<String> source = const Value.absent(),
              }) => SecurityPricesCompanion(
                id: id,
                securityId: securityId,
                date: date,
                priceE4: priceE4,
                source: source,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int securityId,
                required DateTime date,
                required int priceE4,
                required String source,
              }) => SecurityPricesCompanion.insert(
                id: id,
                securityId: securityId,
                date: date,
                priceE4: priceE4,
                source: source,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SecurityPricesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({securityId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (securityId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.securityId,
                                referencedTable: $$SecurityPricesTableReferences
                                    ._securityIdTable(db),
                                referencedColumn:
                                    $$SecurityPricesTableReferences
                                        ._securityIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SecurityPricesTableProcessedTableManager =
    ProcessedTableManager<
      _$ArthDatabase,
      $SecurityPricesTable,
      SecurityPrice,
      $$SecurityPricesTableFilterComposer,
      $$SecurityPricesTableOrderingComposer,
      $$SecurityPricesTableAnnotationComposer,
      $$SecurityPricesTableCreateCompanionBuilder,
      $$SecurityPricesTableUpdateCompanionBuilder,
      (SecurityPrice, $$SecurityPricesTableReferences),
      SecurityPrice,
      PrefetchHooks Function({bool securityId})
    >;
typedef $$ManualAssetsTableCreateCompanionBuilder =
    ManualAssetsCompanion Function({
      Value<int> id,
      required String name,
      required String kind,
      Value<int?> interestBp,
      Value<DateTime?> startDate,
      Value<DateTime?> maturityDate,
      Value<DateTime> createdAt,
    });
typedef $$ManualAssetsTableUpdateCompanionBuilder =
    ManualAssetsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> kind,
      Value<int?> interestBp,
      Value<DateTime?> startDate,
      Value<DateTime?> maturityDate,
      Value<DateTime> createdAt,
    });

final class $$ManualAssetsTableReferences
    extends BaseReferences<_$ArthDatabase, $ManualAssetsTable, ManualAsset> {
  $$ManualAssetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ManualAssetValuesTable, List<ManualAssetValue>>
  _manualAssetValuesRefsTable(_$ArthDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.manualAssetValues,
        aliasName: 'manual_assets__id__manual_asset_values__asset_id',
      );

  $$ManualAssetValuesTableProcessedTableManager get manualAssetValuesRefs {
    final manager = $$ManualAssetValuesTableTableManager(
      $_db,
      $_db.manualAssetValues,
    ).filter((f) => f.assetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _manualAssetValuesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ManualAssetsTableFilterComposer
    extends Composer<_$ArthDatabase, $ManualAssetsTable> {
  $$ManualAssetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get interestBp => $composableBuilder(
    column: $table.interestBp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get maturityDate => $composableBuilder(
    column: $table.maturityDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> manualAssetValuesRefs(
    Expression<bool> Function($$ManualAssetValuesTableFilterComposer f) f,
  ) {
    final $$ManualAssetValuesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.manualAssetValues,
      getReferencedColumn: (t) => t.assetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ManualAssetValuesTableFilterComposer(
            $db: $db,
            $table: $db.manualAssetValues,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ManualAssetsTableOrderingComposer
    extends Composer<_$ArthDatabase, $ManualAssetsTable> {
  $$ManualAssetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get interestBp => $composableBuilder(
    column: $table.interestBp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get maturityDate => $composableBuilder(
    column: $table.maturityDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ManualAssetsTableAnnotationComposer
    extends Composer<_$ArthDatabase, $ManualAssetsTable> {
  $$ManualAssetsTableAnnotationComposer({
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

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get interestBp => $composableBuilder(
    column: $table.interestBp,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get maturityDate => $composableBuilder(
    column: $table.maturityDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> manualAssetValuesRefs<T extends Object>(
    Expression<T> Function($$ManualAssetValuesTableAnnotationComposer a) f,
  ) {
    final $$ManualAssetValuesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.manualAssetValues,
          getReferencedColumn: (t) => t.assetId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ManualAssetValuesTableAnnotationComposer(
                $db: $db,
                $table: $db.manualAssetValues,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ManualAssetsTableTableManager
    extends
        RootTableManager<
          _$ArthDatabase,
          $ManualAssetsTable,
          ManualAsset,
          $$ManualAssetsTableFilterComposer,
          $$ManualAssetsTableOrderingComposer,
          $$ManualAssetsTableAnnotationComposer,
          $$ManualAssetsTableCreateCompanionBuilder,
          $$ManualAssetsTableUpdateCompanionBuilder,
          (ManualAsset, $$ManualAssetsTableReferences),
          ManualAsset,
          PrefetchHooks Function({bool manualAssetValuesRefs})
        > {
  $$ManualAssetsTableTableManager(_$ArthDatabase db, $ManualAssetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ManualAssetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ManualAssetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ManualAssetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int?> interestBp = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> maturityDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ManualAssetsCompanion(
                id: id,
                name: name,
                kind: kind,
                interestBp: interestBp,
                startDate: startDate,
                maturityDate: maturityDate,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String kind,
                Value<int?> interestBp = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> maturityDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ManualAssetsCompanion.insert(
                id: id,
                name: name,
                kind: kind,
                interestBp: interestBp,
                startDate: startDate,
                maturityDate: maturityDate,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ManualAssetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({manualAssetValuesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (manualAssetValuesRefs) db.manualAssetValues,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (manualAssetValuesRefs)
                    await $_getPrefetchedData<
                      ManualAsset,
                      $ManualAssetsTable,
                      ManualAssetValue
                    >(
                      currentTable: table,
                      referencedTable: $$ManualAssetsTableReferences
                          ._manualAssetValuesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ManualAssetsTableReferences(
                            db,
                            table,
                            p0,
                          ).manualAssetValuesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.assetId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ManualAssetsTableProcessedTableManager =
    ProcessedTableManager<
      _$ArthDatabase,
      $ManualAssetsTable,
      ManualAsset,
      $$ManualAssetsTableFilterComposer,
      $$ManualAssetsTableOrderingComposer,
      $$ManualAssetsTableAnnotationComposer,
      $$ManualAssetsTableCreateCompanionBuilder,
      $$ManualAssetsTableUpdateCompanionBuilder,
      (ManualAsset, $$ManualAssetsTableReferences),
      ManualAsset,
      PrefetchHooks Function({bool manualAssetValuesRefs})
    >;
typedef $$ManualAssetValuesTableCreateCompanionBuilder =
    ManualAssetValuesCompanion Function({
      Value<int> id,
      required int assetId,
      required DateTime date,
      required int valuePaise,
    });
typedef $$ManualAssetValuesTableUpdateCompanionBuilder =
    ManualAssetValuesCompanion Function({
      Value<int> id,
      Value<int> assetId,
      Value<DateTime> date,
      Value<int> valuePaise,
    });

final class $$ManualAssetValuesTableReferences
    extends
        BaseReferences<
          _$ArthDatabase,
          $ManualAssetValuesTable,
          ManualAssetValue
        > {
  $$ManualAssetValuesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ManualAssetsTable _assetIdTable(_$ArthDatabase db) => db.manualAssets
      .createAlias('manual_asset_values__asset_id__manual_assets__id');

  $$ManualAssetsTableProcessedTableManager get assetId {
    final $_column = $_itemColumn<int>('asset_id')!;

    final manager = $$ManualAssetsTableTableManager(
      $_db,
      $_db.manualAssets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_assetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ManualAssetValuesTableFilterComposer
    extends Composer<_$ArthDatabase, $ManualAssetValuesTable> {
  $$ManualAssetValuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get valuePaise => $composableBuilder(
    column: $table.valuePaise,
    builder: (column) => ColumnFilters(column),
  );

  $$ManualAssetsTableFilterComposer get assetId {
    final $$ManualAssetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.manualAssets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ManualAssetsTableFilterComposer(
            $db: $db,
            $table: $db.manualAssets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ManualAssetValuesTableOrderingComposer
    extends Composer<_$ArthDatabase, $ManualAssetValuesTable> {
  $$ManualAssetValuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get valuePaise => $composableBuilder(
    column: $table.valuePaise,
    builder: (column) => ColumnOrderings(column),
  );

  $$ManualAssetsTableOrderingComposer get assetId {
    final $$ManualAssetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.manualAssets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ManualAssetsTableOrderingComposer(
            $db: $db,
            $table: $db.manualAssets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ManualAssetValuesTableAnnotationComposer
    extends Composer<_$ArthDatabase, $ManualAssetValuesTable> {
  $$ManualAssetValuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get valuePaise => $composableBuilder(
    column: $table.valuePaise,
    builder: (column) => column,
  );

  $$ManualAssetsTableAnnotationComposer get assetId {
    final $$ManualAssetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.manualAssets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ManualAssetsTableAnnotationComposer(
            $db: $db,
            $table: $db.manualAssets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ManualAssetValuesTableTableManager
    extends
        RootTableManager<
          _$ArthDatabase,
          $ManualAssetValuesTable,
          ManualAssetValue,
          $$ManualAssetValuesTableFilterComposer,
          $$ManualAssetValuesTableOrderingComposer,
          $$ManualAssetValuesTableAnnotationComposer,
          $$ManualAssetValuesTableCreateCompanionBuilder,
          $$ManualAssetValuesTableUpdateCompanionBuilder,
          (ManualAssetValue, $$ManualAssetValuesTableReferences),
          ManualAssetValue,
          PrefetchHooks Function({bool assetId})
        > {
  $$ManualAssetValuesTableTableManager(
    _$ArthDatabase db,
    $ManualAssetValuesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ManualAssetValuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ManualAssetValuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ManualAssetValuesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> assetId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> valuePaise = const Value.absent(),
              }) => ManualAssetValuesCompanion(
                id: id,
                assetId: assetId,
                date: date,
                valuePaise: valuePaise,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int assetId,
                required DateTime date,
                required int valuePaise,
              }) => ManualAssetValuesCompanion.insert(
                id: id,
                assetId: assetId,
                date: date,
                valuePaise: valuePaise,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ManualAssetValuesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({assetId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (assetId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.assetId,
                                referencedTable:
                                    $$ManualAssetValuesTableReferences
                                        ._assetIdTable(db),
                                referencedColumn:
                                    $$ManualAssetValuesTableReferences
                                        ._assetIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ManualAssetValuesTableProcessedTableManager =
    ProcessedTableManager<
      _$ArthDatabase,
      $ManualAssetValuesTable,
      ManualAssetValue,
      $$ManualAssetValuesTableFilterComposer,
      $$ManualAssetValuesTableOrderingComposer,
      $$ManualAssetValuesTableAnnotationComposer,
      $$ManualAssetValuesTableCreateCompanionBuilder,
      $$ManualAssetValuesTableUpdateCompanionBuilder,
      (ManualAssetValue, $$ManualAssetValuesTableReferences),
      ManualAssetValue,
      PrefetchHooks Function({bool assetId})
    >;

class $ArthDatabaseManager {
  final _$ArthDatabase _db;
  $ArthDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$MerchantsTableTableManager get merchants =>
      $$MerchantsTableTableManager(_db, _db.merchants);
  $$MerchantAliasesTableTableManager get merchantAliases =>
      $$MerchantAliasesTableTableManager(_db, _db.merchantAliases);
  $$ImportsTableTableManager get imports =>
      $$ImportsTableTableManager(_db, _db.imports);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$TransactionImportsTableTableManager get transactionImports =>
      $$TransactionImportsTableTableManager(_db, _db.transactionImports);
  $$UserCorrectionsTableTableManager get userCorrections =>
      $$UserCorrectionsTableTableManager(_db, _db.userCorrections);
  $$UnparsedSmsRowsTableTableManager get unparsedSmsRows =>
      $$UnparsedSmsRowsTableTableManager(_db, _db.unparsedSmsRows);
  $$MandateNoticesTableTableManager get mandateNotices =>
      $$MandateNoticesTableTableManager(_db, _db.mandateNotices);
  $$ModelInfoTableTableManager get modelInfo =>
      $$ModelInfoTableTableManager(_db, _db.modelInfo);
  $$UnparsedStatementRowsTableTableManager get unparsedStatementRows =>
      $$UnparsedStatementRowsTableTableManager(_db, _db.unparsedStatementRows);
  $$LlmJobsTableTableManager get llmJobs =>
      $$LlmJobsTableTableManager(_db, _db.llmJobs);
  $$LlmReviewItemsTableTableManager get llmReviewItems =>
      $$LlmReviewItemsTableTableManager(_db, _db.llmReviewItems);
  $$BudgetsTableTableManager get budgets =>
      $$BudgetsTableTableManager(_db, _db.budgets);
  $$StatementSummariesTableTableManager get statementSummaries =>
      $$StatementSummariesTableTableManager(_db, _db.statementSummaries);
  $$CreditCardsTableTableManager get creditCards =>
      $$CreditCardsTableTableManager(_db, _db.creditCards);
  $$GoalsTableTableManager get goals =>
      $$GoalsTableTableManager(_db, _db.goals);
  $$GoalContributionsTableTableManager get goalContributions =>
      $$GoalContributionsTableTableManager(_db, _db.goalContributions);
  $$SecuritiesTableTableManager get securities =>
      $$SecuritiesTableTableManager(_db, _db.securities);
  $$InvestmentAccountsTableTableManager get investmentAccounts =>
      $$InvestmentAccountsTableTableManager(_db, _db.investmentAccounts);
  $$InvestmentTxnsTableTableManager get investmentTxns =>
      $$InvestmentTxnsTableTableManager(_db, _db.investmentTxns);
  $$HoldingSnapshotsTableTableManager get holdingSnapshots =>
      $$HoldingSnapshotsTableTableManager(_db, _db.holdingSnapshots);
  $$SecurityPricesTableTableManager get securityPrices =>
      $$SecurityPricesTableTableManager(_db, _db.securityPrices);
  $$ManualAssetsTableTableManager get manualAssets =>
      $$ManualAssetsTableTableManager(_db, _db.manualAssets);
  $$ManualAssetValuesTableTableManager get manualAssetValues =>
      $$ManualAssetValuesTableTableManager(_db, _db.manualAssetValues);
}
