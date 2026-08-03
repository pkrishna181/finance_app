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
  final DateTime createdAt;
  const MerchantAliase({
    required this.id,
    required this.rawName,
    required this.merchantId,
    required this.source,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['raw_name'] = Variable<String>(rawName);
    map['merchant_id'] = Variable<int>(merchantId);
    map['source'] = Variable<String>(source);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MerchantAliasesCompanion toCompanion(bool nullToAbsent) {
    return MerchantAliasesCompanion(
      id: Value(id),
      rawName: Value(rawName),
      merchantId: Value(merchantId),
      source: Value(source),
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
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MerchantAliase copyWith({
    int? id,
    String? rawName,
    int? merchantId,
    String? source,
    DateTime? createdAt,
  }) => MerchantAliase(
    id: id ?? this.id,
    rawName: rawName ?? this.rawName,
    merchantId: merchantId ?? this.merchantId,
    source: source ?? this.source,
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
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, rawName, merchantId, source, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MerchantAliase &&
          other.id == this.id &&
          other.rawName == this.rawName &&
          other.merchantId == this.merchantId &&
          other.source == this.source &&
          other.createdAt == this.createdAt);
}

class MerchantAliasesCompanion extends UpdateCompanion<MerchantAliase> {
  final Value<int> id;
  final Value<String> rawName;
  final Value<int> merchantId;
  final Value<String> source;
  final Value<DateTime> createdAt;
  const MerchantAliasesCompanion({
    this.id = const Value.absent(),
    this.rawName = const Value.absent(),
    this.merchantId = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MerchantAliasesCompanion.insert({
    this.id = const Value.absent(),
    required String rawName,
    required int merchantId,
    required String source,
    this.createdAt = const Value.absent(),
  }) : rawName = Value(rawName),
       merchantId = Value(merchantId),
       source = Value(source);
  static Insertable<MerchantAliase> custom({
    Expression<int>? id,
    Expression<String>? rawName,
    Expression<int>? merchantId,
    Expression<String>? source,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rawName != null) 'raw_name': rawName,
      if (merchantId != null) 'merchant_id': merchantId,
      if (source != null) 'source': source,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MerchantAliasesCompanion copyWith({
    Value<int>? id,
    Value<String>? rawName,
    Value<int>? merchantId,
    Value<String>? source,
    Value<DateTime>? createdAt,
  }) {
    return MerchantAliasesCompanion(
      id: id ?? this.id,
      rawName: rawName ?? this.rawName,
      merchantId: merchantId ?? this.merchantId,
      source: source ?? this.source,
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
          PrefetchHooks Function({bool merchantsRefs, bool transactionsRefs})
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
              ({merchantsRefs = false, transactionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (merchantsRefs) db.merchants,
                    if (transactionsRefs) db.transactions,
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
      PrefetchHooks Function({bool merchantsRefs, bool transactionsRefs})
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
      Value<DateTime> createdAt,
    });
typedef $$MerchantAliasesTableUpdateCompanionBuilder =
    MerchantAliasesCompanion Function({
      Value<int> id,
      Value<String> rawName,
      Value<int> merchantId,
      Value<String> source,
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
                Value<DateTime> createdAt = const Value.absent(),
              }) => MerchantAliasesCompanion(
                id: id,
                rawName: rawName,
                merchantId: merchantId,
                source: source,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String rawName,
                required int merchantId,
                required String source,
                Value<DateTime> createdAt = const Value.absent(),
              }) => MerchantAliasesCompanion.insert(
                id: id,
                rawName: rawName,
                merchantId: merchantId,
                source: source,
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
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transactionsRefs) db.transactions,
                    if (transactionImportsRefs) db.transactionImports,
                    if (unparsedStatementRowsRefs) db.unparsedStatementRows,
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
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transactionImportsRefs) db.transactionImports,
                    if (userCorrectionsRefs) db.userCorrections,
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
          (
            UnparsedSmsRow,
            BaseReferences<
              _$ArthDatabase,
              $UnparsedSmsRowsTable,
              UnparsedSmsRow
            >,
          ),
          UnparsedSmsRow,
          PrefetchHooks Function()
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
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
      (
        UnparsedSmsRow,
        BaseReferences<_$ArthDatabase, $UnparsedSmsRowsTable, UnparsedSmsRow>,
      ),
      UnparsedSmsRow,
      PrefetchHooks Function()
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
          PrefetchHooks Function({bool importId})
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
                return [];
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
      PrefetchHooks Function({bool importId})
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
}
