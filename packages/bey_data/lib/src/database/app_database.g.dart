// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PartsTable extends Parts with TableInfo<$PartsTable, PartRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PartsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  @override
  late final GeneratedColumnWithTypeConverter<PartType, int> type =
      GeneratedColumn<int>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<PartType>($PartsTable.$convertertype);
  @override
  late final GeneratedColumnWithTypeConverter<BeySystem, int> system =
      GeneratedColumn<int>(
        'system',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<BeySystem>($PartsTable.$convertersystem);
  static const VerificationMeta _attackMeta = const VerificationMeta('attack');
  @override
  late final GeneratedColumn<int> attack = GeneratedColumn<int>(
    'attack',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defenseMeta = const VerificationMeta(
    'defense',
  );
  @override
  late final GeneratedColumn<int> defense = GeneratedColumn<int>(
    'defense',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _staminaMeta = const VerificationMeta(
    'stamina',
  );
  @override
  late final GeneratedColumn<int> stamina = GeneratedColumn<int>(
    'stamina',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightGMeta = const VerificationMeta(
    'weightG',
  );
  @override
  late final GeneratedColumn<double> weightG = GeneratedColumn<double>(
    'weight_g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightMinGMeta = const VerificationMeta(
    'weightMinG',
  );
  @override
  late final GeneratedColumn<double> weightMinG = GeneratedColumn<double>(
    'weight_min_g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightMaxGMeta = const VerificationMeta(
    'weightMaxG',
  );
  @override
  late final GeneratedColumn<double> weightMaxG = GeneratedColumn<double>(
    'weight_max_g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightNoteMeta = const VerificationMeta(
    'weightNote',
  );
  @override
  late final GeneratedColumn<String> weightNote = GeneratedColumn<String>(
    'weight_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightMmMeta = const VerificationMeta(
    'heightMm',
  );
  @override
  late final GeneratedColumn<double> heightMm = GeneratedColumn<double>(
    'height_mm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _widthMmMeta = const VerificationMeta(
    'widthMm',
  );
  @override
  late final GeneratedColumn<double> widthMm = GeneratedColumn<double>(
    'width_mm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<BeyType?, int> beyType =
      GeneratedColumn<int>(
        'bey_type',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<BeyType?>($PartsTable.$converterbeyTypen);
  @override
  late final GeneratedColumnWithTypeConverter<SpinDirection?, int>
  spinDirection = GeneratedColumn<int>(
    'spin_direction',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  ).withConverter<SpinDirection?>($PartsTable.$converterspinDirectionn);
  static const VerificationMeta _contactPointsMeta = const VerificationMeta(
    'contactPoints',
  );
  @override
  late final GeneratedColumn<int> contactPoints = GeneratedColumn<int>(
    'contact_points',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightDmmMeta = const VerificationMeta(
    'heightDmm',
  );
  @override
  late final GeneratedColumn<int> heightDmm = GeneratedColumn<int>(
    'height_dmm',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightDmmMaxMeta = const VerificationMeta(
    'heightDmmMax',
  );
  @override
  late final GeneratedColumn<int> heightDmmMax = GeneratedColumn<int>(
    'height_dmm_max',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightClassMeta = const VerificationMeta(
    'weightClass',
  );
  @override
  late final GeneratedColumn<String> weightClass = GeneratedColumn<String>(
    'weight_class',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tipShapeMeta = const VerificationMeta(
    'tipShape',
  );
  @override
  late final GeneratedColumn<String> tipShape = GeneratedColumn<String>(
    'tip_shape',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gearTeethMeta = const VerificationMeta(
    'gearTeeth',
  );
  @override
  late final GeneratedColumn<int> gearTeeth = GeneratedColumn<int>(
    'gear_teeth',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shaftWidthMeta = const VerificationMeta(
    'shaftWidth',
  );
  @override
  late final GeneratedColumn<int> shaftWidth = GeneratedColumn<int>(
    'shaft_width',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productCodeMeta = const VerificationMeta(
    'productCode',
  );
  @override
  late final GeneratedColumn<String> productCode = GeneratedColumn<String>(
    'product_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hasbroAliasMeta = const VerificationMeta(
    'hasbroAlias',
  );
  @override
  late final GeneratedColumn<String> hasbroAlias = GeneratedColumn<String>(
    'hasbro_alias',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _metaTierMeta = const VerificationMeta(
    'metaTier',
  );
  @override
  late final GeneratedColumn<String> metaTier = GeneratedColumn<String>(
    'meta_tier',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageLocalMeta = const VerificationMeta(
    'imageLocal',
  );
  @override
  late final GeneratedColumn<String> imageLocal = GeneratedColumn<String>(
    'image_local',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageRemoteMeta = const VerificationMeta(
    'imageRemote',
  );
  @override
  late final GeneratedColumn<String> imageRemote = GeneratedColumn<String>(
    'image_remote',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _catalogVersionMeta = const VerificationMeta(
    'catalogVersion',
  );
  @override
  late final GeneratedColumn<int> catalogVersion = GeneratedColumn<int>(
    'catalog_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    system,
    attack,
    defense,
    stamina,
    weightG,
    weightMinG,
    weightMaxG,
    weightNote,
    heightMm,
    widthMm,
    beyType,
    spinDirection,
    contactPoints,
    heightDmm,
    heightDmmMax,
    weightClass,
    code,
    tipShape,
    gearTeeth,
    shaftWidth,
    productCode,
    hasbroAlias,
    metaTier,
    imageLocal,
    imageRemote,
    catalogVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'parts';
  @override
  VerificationContext validateIntegrity(
    Insertable<PartRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('attack')) {
      context.handle(
        _attackMeta,
        attack.isAcceptableOrUnknown(data['attack']!, _attackMeta),
      );
    }
    if (data.containsKey('defense')) {
      context.handle(
        _defenseMeta,
        defense.isAcceptableOrUnknown(data['defense']!, _defenseMeta),
      );
    }
    if (data.containsKey('stamina')) {
      context.handle(
        _staminaMeta,
        stamina.isAcceptableOrUnknown(data['stamina']!, _staminaMeta),
      );
    }
    if (data.containsKey('weight_g')) {
      context.handle(
        _weightGMeta,
        weightG.isAcceptableOrUnknown(data['weight_g']!, _weightGMeta),
      );
    }
    if (data.containsKey('weight_min_g')) {
      context.handle(
        _weightMinGMeta,
        weightMinG.isAcceptableOrUnknown(
          data['weight_min_g']!,
          _weightMinGMeta,
        ),
      );
    }
    if (data.containsKey('weight_max_g')) {
      context.handle(
        _weightMaxGMeta,
        weightMaxG.isAcceptableOrUnknown(
          data['weight_max_g']!,
          _weightMaxGMeta,
        ),
      );
    }
    if (data.containsKey('weight_note')) {
      context.handle(
        _weightNoteMeta,
        weightNote.isAcceptableOrUnknown(data['weight_note']!, _weightNoteMeta),
      );
    }
    if (data.containsKey('height_mm')) {
      context.handle(
        _heightMmMeta,
        heightMm.isAcceptableOrUnknown(data['height_mm']!, _heightMmMeta),
      );
    }
    if (data.containsKey('width_mm')) {
      context.handle(
        _widthMmMeta,
        widthMm.isAcceptableOrUnknown(data['width_mm']!, _widthMmMeta),
      );
    }
    if (data.containsKey('contact_points')) {
      context.handle(
        _contactPointsMeta,
        contactPoints.isAcceptableOrUnknown(
          data['contact_points']!,
          _contactPointsMeta,
        ),
      );
    }
    if (data.containsKey('height_dmm')) {
      context.handle(
        _heightDmmMeta,
        heightDmm.isAcceptableOrUnknown(data['height_dmm']!, _heightDmmMeta),
      );
    }
    if (data.containsKey('height_dmm_max')) {
      context.handle(
        _heightDmmMaxMeta,
        heightDmmMax.isAcceptableOrUnknown(
          data['height_dmm_max']!,
          _heightDmmMaxMeta,
        ),
      );
    }
    if (data.containsKey('weight_class')) {
      context.handle(
        _weightClassMeta,
        weightClass.isAcceptableOrUnknown(
          data['weight_class']!,
          _weightClassMeta,
        ),
      );
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    }
    if (data.containsKey('tip_shape')) {
      context.handle(
        _tipShapeMeta,
        tipShape.isAcceptableOrUnknown(data['tip_shape']!, _tipShapeMeta),
      );
    }
    if (data.containsKey('gear_teeth')) {
      context.handle(
        _gearTeethMeta,
        gearTeeth.isAcceptableOrUnknown(data['gear_teeth']!, _gearTeethMeta),
      );
    }
    if (data.containsKey('shaft_width')) {
      context.handle(
        _shaftWidthMeta,
        shaftWidth.isAcceptableOrUnknown(data['shaft_width']!, _shaftWidthMeta),
      );
    }
    if (data.containsKey('product_code')) {
      context.handle(
        _productCodeMeta,
        productCode.isAcceptableOrUnknown(
          data['product_code']!,
          _productCodeMeta,
        ),
      );
    }
    if (data.containsKey('hasbro_alias')) {
      context.handle(
        _hasbroAliasMeta,
        hasbroAlias.isAcceptableOrUnknown(
          data['hasbro_alias']!,
          _hasbroAliasMeta,
        ),
      );
    }
    if (data.containsKey('meta_tier')) {
      context.handle(
        _metaTierMeta,
        metaTier.isAcceptableOrUnknown(data['meta_tier']!, _metaTierMeta),
      );
    }
    if (data.containsKey('image_local')) {
      context.handle(
        _imageLocalMeta,
        imageLocal.isAcceptableOrUnknown(data['image_local']!, _imageLocalMeta),
      );
    }
    if (data.containsKey('image_remote')) {
      context.handle(
        _imageRemoteMeta,
        imageRemote.isAcceptableOrUnknown(
          data['image_remote']!,
          _imageRemoteMeta,
        ),
      );
    }
    if (data.containsKey('catalog_version')) {
      context.handle(
        _catalogVersionMeta,
        catalogVersion.isAcceptableOrUnknown(
          data['catalog_version']!,
          _catalogVersionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PartRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PartRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: $PartsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}type'],
        )!,
      ),
      system: $PartsTable.$convertersystem.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}system'],
        )!,
      ),
      attack: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attack'],
      ),
      defense: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}defense'],
      ),
      stamina: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stamina'],
      ),
      weightG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_g'],
      ),
      weightMinG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_min_g'],
      ),
      weightMaxG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_max_g'],
      ),
      weightNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weight_note'],
      ),
      heightMm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height_mm'],
      ),
      widthMm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}width_mm'],
      ),
      beyType: $PartsTable.$converterbeyTypen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}bey_type'],
        ),
      ),
      spinDirection: $PartsTable.$converterspinDirectionn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}spin_direction'],
        ),
      ),
      contactPoints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}contact_points'],
      ),
      heightDmm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height_dmm'],
      ),
      heightDmmMax: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height_dmm_max'],
      ),
      weightClass: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weight_class'],
      ),
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      ),
      tipShape: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tip_shape'],
      ),
      gearTeeth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gear_teeth'],
      ),
      shaftWidth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}shaft_width'],
      ),
      productCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_code'],
      ),
      hasbroAlias: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hasbro_alias'],
      ),
      metaTier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meta_tier'],
      ),
      imageLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_local'],
      ),
      imageRemote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_remote'],
      ),
      catalogVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}catalog_version'],
      )!,
    );
  }

  @override
  $PartsTable createAlias(String alias) {
    return $PartsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PartType, int, int> $convertertype =
      const EnumIndexConverter<PartType>(PartType.values);
  static JsonTypeConverter2<BeySystem, int, int> $convertersystem =
      const EnumIndexConverter<BeySystem>(BeySystem.values);
  static JsonTypeConverter2<BeyType, int, int> $converterbeyType =
      const EnumIndexConverter<BeyType>(BeyType.values);
  static JsonTypeConverter2<BeyType?, int?, int?> $converterbeyTypen =
      JsonTypeConverter2.asNullable($converterbeyType);
  static JsonTypeConverter2<SpinDirection, int, int> $converterspinDirection =
      const EnumIndexConverter<SpinDirection>(SpinDirection.values);
  static JsonTypeConverter2<SpinDirection?, int?, int?>
  $converterspinDirectionn = JsonTypeConverter2.asNullable(
    $converterspinDirection,
  );
}

class PartRow extends DataClass implements Insertable<PartRow> {
  final String id;
  final String name;
  final PartType type;
  final BeySystem system;
  final int? attack;
  final int? defense;
  final int? stamina;
  final double? weightG;
  final double? weightMinG;
  final double? weightMaxG;
  final String? weightNote;
  final double? heightMm;
  final double? widthMm;
  final BeyType? beyType;
  final SpinDirection? spinDirection;
  final int? contactPoints;
  final int? heightDmm;
  final int? heightDmmMax;
  final String? weightClass;
  final String? code;
  final String? tipShape;
  final int? gearTeeth;
  final int? shaftWidth;
  final String? productCode;
  final String? hasbroAlias;
  final String? metaTier;
  final String? imageLocal;
  final String? imageRemote;
  final int catalogVersion;
  const PartRow({
    required this.id,
    required this.name,
    required this.type,
    required this.system,
    this.attack,
    this.defense,
    this.stamina,
    this.weightG,
    this.weightMinG,
    this.weightMaxG,
    this.weightNote,
    this.heightMm,
    this.widthMm,
    this.beyType,
    this.spinDirection,
    this.contactPoints,
    this.heightDmm,
    this.heightDmmMax,
    this.weightClass,
    this.code,
    this.tipShape,
    this.gearTeeth,
    this.shaftWidth,
    this.productCode,
    this.hasbroAlias,
    this.metaTier,
    this.imageLocal,
    this.imageRemote,
    required this.catalogVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    {
      map['type'] = Variable<int>($PartsTable.$convertertype.toSql(type));
    }
    {
      map['system'] = Variable<int>($PartsTable.$convertersystem.toSql(system));
    }
    if (!nullToAbsent || attack != null) {
      map['attack'] = Variable<int>(attack);
    }
    if (!nullToAbsent || defense != null) {
      map['defense'] = Variable<int>(defense);
    }
    if (!nullToAbsent || stamina != null) {
      map['stamina'] = Variable<int>(stamina);
    }
    if (!nullToAbsent || weightG != null) {
      map['weight_g'] = Variable<double>(weightG);
    }
    if (!nullToAbsent || weightMinG != null) {
      map['weight_min_g'] = Variable<double>(weightMinG);
    }
    if (!nullToAbsent || weightMaxG != null) {
      map['weight_max_g'] = Variable<double>(weightMaxG);
    }
    if (!nullToAbsent || weightNote != null) {
      map['weight_note'] = Variable<String>(weightNote);
    }
    if (!nullToAbsent || heightMm != null) {
      map['height_mm'] = Variable<double>(heightMm);
    }
    if (!nullToAbsent || widthMm != null) {
      map['width_mm'] = Variable<double>(widthMm);
    }
    if (!nullToAbsent || beyType != null) {
      map['bey_type'] = Variable<int>(
        $PartsTable.$converterbeyTypen.toSql(beyType),
      );
    }
    if (!nullToAbsent || spinDirection != null) {
      map['spin_direction'] = Variable<int>(
        $PartsTable.$converterspinDirectionn.toSql(spinDirection),
      );
    }
    if (!nullToAbsent || contactPoints != null) {
      map['contact_points'] = Variable<int>(contactPoints);
    }
    if (!nullToAbsent || heightDmm != null) {
      map['height_dmm'] = Variable<int>(heightDmm);
    }
    if (!nullToAbsent || heightDmmMax != null) {
      map['height_dmm_max'] = Variable<int>(heightDmmMax);
    }
    if (!nullToAbsent || weightClass != null) {
      map['weight_class'] = Variable<String>(weightClass);
    }
    if (!nullToAbsent || code != null) {
      map['code'] = Variable<String>(code);
    }
    if (!nullToAbsent || tipShape != null) {
      map['tip_shape'] = Variable<String>(tipShape);
    }
    if (!nullToAbsent || gearTeeth != null) {
      map['gear_teeth'] = Variable<int>(gearTeeth);
    }
    if (!nullToAbsent || shaftWidth != null) {
      map['shaft_width'] = Variable<int>(shaftWidth);
    }
    if (!nullToAbsent || productCode != null) {
      map['product_code'] = Variable<String>(productCode);
    }
    if (!nullToAbsent || hasbroAlias != null) {
      map['hasbro_alias'] = Variable<String>(hasbroAlias);
    }
    if (!nullToAbsent || metaTier != null) {
      map['meta_tier'] = Variable<String>(metaTier);
    }
    if (!nullToAbsent || imageLocal != null) {
      map['image_local'] = Variable<String>(imageLocal);
    }
    if (!nullToAbsent || imageRemote != null) {
      map['image_remote'] = Variable<String>(imageRemote);
    }
    map['catalog_version'] = Variable<int>(catalogVersion);
    return map;
  }

  PartsCompanion toCompanion(bool nullToAbsent) {
    return PartsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      system: Value(system),
      attack: attack == null && nullToAbsent
          ? const Value.absent()
          : Value(attack),
      defense: defense == null && nullToAbsent
          ? const Value.absent()
          : Value(defense),
      stamina: stamina == null && nullToAbsent
          ? const Value.absent()
          : Value(stamina),
      weightG: weightG == null && nullToAbsent
          ? const Value.absent()
          : Value(weightG),
      weightMinG: weightMinG == null && nullToAbsent
          ? const Value.absent()
          : Value(weightMinG),
      weightMaxG: weightMaxG == null && nullToAbsent
          ? const Value.absent()
          : Value(weightMaxG),
      weightNote: weightNote == null && nullToAbsent
          ? const Value.absent()
          : Value(weightNote),
      heightMm: heightMm == null && nullToAbsent
          ? const Value.absent()
          : Value(heightMm),
      widthMm: widthMm == null && nullToAbsent
          ? const Value.absent()
          : Value(widthMm),
      beyType: beyType == null && nullToAbsent
          ? const Value.absent()
          : Value(beyType),
      spinDirection: spinDirection == null && nullToAbsent
          ? const Value.absent()
          : Value(spinDirection),
      contactPoints: contactPoints == null && nullToAbsent
          ? const Value.absent()
          : Value(contactPoints),
      heightDmm: heightDmm == null && nullToAbsent
          ? const Value.absent()
          : Value(heightDmm),
      heightDmmMax: heightDmmMax == null && nullToAbsent
          ? const Value.absent()
          : Value(heightDmmMax),
      weightClass: weightClass == null && nullToAbsent
          ? const Value.absent()
          : Value(weightClass),
      code: code == null && nullToAbsent ? const Value.absent() : Value(code),
      tipShape: tipShape == null && nullToAbsent
          ? const Value.absent()
          : Value(tipShape),
      gearTeeth: gearTeeth == null && nullToAbsent
          ? const Value.absent()
          : Value(gearTeeth),
      shaftWidth: shaftWidth == null && nullToAbsent
          ? const Value.absent()
          : Value(shaftWidth),
      productCode: productCode == null && nullToAbsent
          ? const Value.absent()
          : Value(productCode),
      hasbroAlias: hasbroAlias == null && nullToAbsent
          ? const Value.absent()
          : Value(hasbroAlias),
      metaTier: metaTier == null && nullToAbsent
          ? const Value.absent()
          : Value(metaTier),
      imageLocal: imageLocal == null && nullToAbsent
          ? const Value.absent()
          : Value(imageLocal),
      imageRemote: imageRemote == null && nullToAbsent
          ? const Value.absent()
          : Value(imageRemote),
      catalogVersion: Value(catalogVersion),
    );
  }

  factory PartRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PartRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: $PartsTable.$convertertype.fromJson(
        serializer.fromJson<int>(json['type']),
      ),
      system: $PartsTable.$convertersystem.fromJson(
        serializer.fromJson<int>(json['system']),
      ),
      attack: serializer.fromJson<int?>(json['attack']),
      defense: serializer.fromJson<int?>(json['defense']),
      stamina: serializer.fromJson<int?>(json['stamina']),
      weightG: serializer.fromJson<double?>(json['weightG']),
      weightMinG: serializer.fromJson<double?>(json['weightMinG']),
      weightMaxG: serializer.fromJson<double?>(json['weightMaxG']),
      weightNote: serializer.fromJson<String?>(json['weightNote']),
      heightMm: serializer.fromJson<double?>(json['heightMm']),
      widthMm: serializer.fromJson<double?>(json['widthMm']),
      beyType: $PartsTable.$converterbeyTypen.fromJson(
        serializer.fromJson<int?>(json['beyType']),
      ),
      spinDirection: $PartsTable.$converterspinDirectionn.fromJson(
        serializer.fromJson<int?>(json['spinDirection']),
      ),
      contactPoints: serializer.fromJson<int?>(json['contactPoints']),
      heightDmm: serializer.fromJson<int?>(json['heightDmm']),
      heightDmmMax: serializer.fromJson<int?>(json['heightDmmMax']),
      weightClass: serializer.fromJson<String?>(json['weightClass']),
      code: serializer.fromJson<String?>(json['code']),
      tipShape: serializer.fromJson<String?>(json['tipShape']),
      gearTeeth: serializer.fromJson<int?>(json['gearTeeth']),
      shaftWidth: serializer.fromJson<int?>(json['shaftWidth']),
      productCode: serializer.fromJson<String?>(json['productCode']),
      hasbroAlias: serializer.fromJson<String?>(json['hasbroAlias']),
      metaTier: serializer.fromJson<String?>(json['metaTier']),
      imageLocal: serializer.fromJson<String?>(json['imageLocal']),
      imageRemote: serializer.fromJson<String?>(json['imageRemote']),
      catalogVersion: serializer.fromJson<int>(json['catalogVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<int>($PartsTable.$convertertype.toJson(type)),
      'system': serializer.toJson<int>(
        $PartsTable.$convertersystem.toJson(system),
      ),
      'attack': serializer.toJson<int?>(attack),
      'defense': serializer.toJson<int?>(defense),
      'stamina': serializer.toJson<int?>(stamina),
      'weightG': serializer.toJson<double?>(weightG),
      'weightMinG': serializer.toJson<double?>(weightMinG),
      'weightMaxG': serializer.toJson<double?>(weightMaxG),
      'weightNote': serializer.toJson<String?>(weightNote),
      'heightMm': serializer.toJson<double?>(heightMm),
      'widthMm': serializer.toJson<double?>(widthMm),
      'beyType': serializer.toJson<int?>(
        $PartsTable.$converterbeyTypen.toJson(beyType),
      ),
      'spinDirection': serializer.toJson<int?>(
        $PartsTable.$converterspinDirectionn.toJson(spinDirection),
      ),
      'contactPoints': serializer.toJson<int?>(contactPoints),
      'heightDmm': serializer.toJson<int?>(heightDmm),
      'heightDmmMax': serializer.toJson<int?>(heightDmmMax),
      'weightClass': serializer.toJson<String?>(weightClass),
      'code': serializer.toJson<String?>(code),
      'tipShape': serializer.toJson<String?>(tipShape),
      'gearTeeth': serializer.toJson<int?>(gearTeeth),
      'shaftWidth': serializer.toJson<int?>(shaftWidth),
      'productCode': serializer.toJson<String?>(productCode),
      'hasbroAlias': serializer.toJson<String?>(hasbroAlias),
      'metaTier': serializer.toJson<String?>(metaTier),
      'imageLocal': serializer.toJson<String?>(imageLocal),
      'imageRemote': serializer.toJson<String?>(imageRemote),
      'catalogVersion': serializer.toJson<int>(catalogVersion),
    };
  }

  PartRow copyWith({
    String? id,
    String? name,
    PartType? type,
    BeySystem? system,
    Value<int?> attack = const Value.absent(),
    Value<int?> defense = const Value.absent(),
    Value<int?> stamina = const Value.absent(),
    Value<double?> weightG = const Value.absent(),
    Value<double?> weightMinG = const Value.absent(),
    Value<double?> weightMaxG = const Value.absent(),
    Value<String?> weightNote = const Value.absent(),
    Value<double?> heightMm = const Value.absent(),
    Value<double?> widthMm = const Value.absent(),
    Value<BeyType?> beyType = const Value.absent(),
    Value<SpinDirection?> spinDirection = const Value.absent(),
    Value<int?> contactPoints = const Value.absent(),
    Value<int?> heightDmm = const Value.absent(),
    Value<int?> heightDmmMax = const Value.absent(),
    Value<String?> weightClass = const Value.absent(),
    Value<String?> code = const Value.absent(),
    Value<String?> tipShape = const Value.absent(),
    Value<int?> gearTeeth = const Value.absent(),
    Value<int?> shaftWidth = const Value.absent(),
    Value<String?> productCode = const Value.absent(),
    Value<String?> hasbroAlias = const Value.absent(),
    Value<String?> metaTier = const Value.absent(),
    Value<String?> imageLocal = const Value.absent(),
    Value<String?> imageRemote = const Value.absent(),
    int? catalogVersion,
  }) => PartRow(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    system: system ?? this.system,
    attack: attack.present ? attack.value : this.attack,
    defense: defense.present ? defense.value : this.defense,
    stamina: stamina.present ? stamina.value : this.stamina,
    weightG: weightG.present ? weightG.value : this.weightG,
    weightMinG: weightMinG.present ? weightMinG.value : this.weightMinG,
    weightMaxG: weightMaxG.present ? weightMaxG.value : this.weightMaxG,
    weightNote: weightNote.present ? weightNote.value : this.weightNote,
    heightMm: heightMm.present ? heightMm.value : this.heightMm,
    widthMm: widthMm.present ? widthMm.value : this.widthMm,
    beyType: beyType.present ? beyType.value : this.beyType,
    spinDirection: spinDirection.present
        ? spinDirection.value
        : this.spinDirection,
    contactPoints: contactPoints.present
        ? contactPoints.value
        : this.contactPoints,
    heightDmm: heightDmm.present ? heightDmm.value : this.heightDmm,
    heightDmmMax: heightDmmMax.present ? heightDmmMax.value : this.heightDmmMax,
    weightClass: weightClass.present ? weightClass.value : this.weightClass,
    code: code.present ? code.value : this.code,
    tipShape: tipShape.present ? tipShape.value : this.tipShape,
    gearTeeth: gearTeeth.present ? gearTeeth.value : this.gearTeeth,
    shaftWidth: shaftWidth.present ? shaftWidth.value : this.shaftWidth,
    productCode: productCode.present ? productCode.value : this.productCode,
    hasbroAlias: hasbroAlias.present ? hasbroAlias.value : this.hasbroAlias,
    metaTier: metaTier.present ? metaTier.value : this.metaTier,
    imageLocal: imageLocal.present ? imageLocal.value : this.imageLocal,
    imageRemote: imageRemote.present ? imageRemote.value : this.imageRemote,
    catalogVersion: catalogVersion ?? this.catalogVersion,
  );
  PartRow copyWithCompanion(PartsCompanion data) {
    return PartRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      system: data.system.present ? data.system.value : this.system,
      attack: data.attack.present ? data.attack.value : this.attack,
      defense: data.defense.present ? data.defense.value : this.defense,
      stamina: data.stamina.present ? data.stamina.value : this.stamina,
      weightG: data.weightG.present ? data.weightG.value : this.weightG,
      weightMinG: data.weightMinG.present
          ? data.weightMinG.value
          : this.weightMinG,
      weightMaxG: data.weightMaxG.present
          ? data.weightMaxG.value
          : this.weightMaxG,
      weightNote: data.weightNote.present
          ? data.weightNote.value
          : this.weightNote,
      heightMm: data.heightMm.present ? data.heightMm.value : this.heightMm,
      widthMm: data.widthMm.present ? data.widthMm.value : this.widthMm,
      beyType: data.beyType.present ? data.beyType.value : this.beyType,
      spinDirection: data.spinDirection.present
          ? data.spinDirection.value
          : this.spinDirection,
      contactPoints: data.contactPoints.present
          ? data.contactPoints.value
          : this.contactPoints,
      heightDmm: data.heightDmm.present ? data.heightDmm.value : this.heightDmm,
      heightDmmMax: data.heightDmmMax.present
          ? data.heightDmmMax.value
          : this.heightDmmMax,
      weightClass: data.weightClass.present
          ? data.weightClass.value
          : this.weightClass,
      code: data.code.present ? data.code.value : this.code,
      tipShape: data.tipShape.present ? data.tipShape.value : this.tipShape,
      gearTeeth: data.gearTeeth.present ? data.gearTeeth.value : this.gearTeeth,
      shaftWidth: data.shaftWidth.present
          ? data.shaftWidth.value
          : this.shaftWidth,
      productCode: data.productCode.present
          ? data.productCode.value
          : this.productCode,
      hasbroAlias: data.hasbroAlias.present
          ? data.hasbroAlias.value
          : this.hasbroAlias,
      metaTier: data.metaTier.present ? data.metaTier.value : this.metaTier,
      imageLocal: data.imageLocal.present
          ? data.imageLocal.value
          : this.imageLocal,
      imageRemote: data.imageRemote.present
          ? data.imageRemote.value
          : this.imageRemote,
      catalogVersion: data.catalogVersion.present
          ? data.catalogVersion.value
          : this.catalogVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PartRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('system: $system, ')
          ..write('attack: $attack, ')
          ..write('defense: $defense, ')
          ..write('stamina: $stamina, ')
          ..write('weightG: $weightG, ')
          ..write('weightMinG: $weightMinG, ')
          ..write('weightMaxG: $weightMaxG, ')
          ..write('weightNote: $weightNote, ')
          ..write('heightMm: $heightMm, ')
          ..write('widthMm: $widthMm, ')
          ..write('beyType: $beyType, ')
          ..write('spinDirection: $spinDirection, ')
          ..write('contactPoints: $contactPoints, ')
          ..write('heightDmm: $heightDmm, ')
          ..write('heightDmmMax: $heightDmmMax, ')
          ..write('weightClass: $weightClass, ')
          ..write('code: $code, ')
          ..write('tipShape: $tipShape, ')
          ..write('gearTeeth: $gearTeeth, ')
          ..write('shaftWidth: $shaftWidth, ')
          ..write('productCode: $productCode, ')
          ..write('hasbroAlias: $hasbroAlias, ')
          ..write('metaTier: $metaTier, ')
          ..write('imageLocal: $imageLocal, ')
          ..write('imageRemote: $imageRemote, ')
          ..write('catalogVersion: $catalogVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    name,
    type,
    system,
    attack,
    defense,
    stamina,
    weightG,
    weightMinG,
    weightMaxG,
    weightNote,
    heightMm,
    widthMm,
    beyType,
    spinDirection,
    contactPoints,
    heightDmm,
    heightDmmMax,
    weightClass,
    code,
    tipShape,
    gearTeeth,
    shaftWidth,
    productCode,
    hasbroAlias,
    metaTier,
    imageLocal,
    imageRemote,
    catalogVersion,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PartRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.system == this.system &&
          other.attack == this.attack &&
          other.defense == this.defense &&
          other.stamina == this.stamina &&
          other.weightG == this.weightG &&
          other.weightMinG == this.weightMinG &&
          other.weightMaxG == this.weightMaxG &&
          other.weightNote == this.weightNote &&
          other.heightMm == this.heightMm &&
          other.widthMm == this.widthMm &&
          other.beyType == this.beyType &&
          other.spinDirection == this.spinDirection &&
          other.contactPoints == this.contactPoints &&
          other.heightDmm == this.heightDmm &&
          other.heightDmmMax == this.heightDmmMax &&
          other.weightClass == this.weightClass &&
          other.code == this.code &&
          other.tipShape == this.tipShape &&
          other.gearTeeth == this.gearTeeth &&
          other.shaftWidth == this.shaftWidth &&
          other.productCode == this.productCode &&
          other.hasbroAlias == this.hasbroAlias &&
          other.metaTier == this.metaTier &&
          other.imageLocal == this.imageLocal &&
          other.imageRemote == this.imageRemote &&
          other.catalogVersion == this.catalogVersion);
}

class PartsCompanion extends UpdateCompanion<PartRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<PartType> type;
  final Value<BeySystem> system;
  final Value<int?> attack;
  final Value<int?> defense;
  final Value<int?> stamina;
  final Value<double?> weightG;
  final Value<double?> weightMinG;
  final Value<double?> weightMaxG;
  final Value<String?> weightNote;
  final Value<double?> heightMm;
  final Value<double?> widthMm;
  final Value<BeyType?> beyType;
  final Value<SpinDirection?> spinDirection;
  final Value<int?> contactPoints;
  final Value<int?> heightDmm;
  final Value<int?> heightDmmMax;
  final Value<String?> weightClass;
  final Value<String?> code;
  final Value<String?> tipShape;
  final Value<int?> gearTeeth;
  final Value<int?> shaftWidth;
  final Value<String?> productCode;
  final Value<String?> hasbroAlias;
  final Value<String?> metaTier;
  final Value<String?> imageLocal;
  final Value<String?> imageRemote;
  final Value<int> catalogVersion;
  final Value<int> rowid;
  const PartsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.system = const Value.absent(),
    this.attack = const Value.absent(),
    this.defense = const Value.absent(),
    this.stamina = const Value.absent(),
    this.weightG = const Value.absent(),
    this.weightMinG = const Value.absent(),
    this.weightMaxG = const Value.absent(),
    this.weightNote = const Value.absent(),
    this.heightMm = const Value.absent(),
    this.widthMm = const Value.absent(),
    this.beyType = const Value.absent(),
    this.spinDirection = const Value.absent(),
    this.contactPoints = const Value.absent(),
    this.heightDmm = const Value.absent(),
    this.heightDmmMax = const Value.absent(),
    this.weightClass = const Value.absent(),
    this.code = const Value.absent(),
    this.tipShape = const Value.absent(),
    this.gearTeeth = const Value.absent(),
    this.shaftWidth = const Value.absent(),
    this.productCode = const Value.absent(),
    this.hasbroAlias = const Value.absent(),
    this.metaTier = const Value.absent(),
    this.imageLocal = const Value.absent(),
    this.imageRemote = const Value.absent(),
    this.catalogVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PartsCompanion.insert({
    required String id,
    required String name,
    required PartType type,
    required BeySystem system,
    this.attack = const Value.absent(),
    this.defense = const Value.absent(),
    this.stamina = const Value.absent(),
    this.weightG = const Value.absent(),
    this.weightMinG = const Value.absent(),
    this.weightMaxG = const Value.absent(),
    this.weightNote = const Value.absent(),
    this.heightMm = const Value.absent(),
    this.widthMm = const Value.absent(),
    this.beyType = const Value.absent(),
    this.spinDirection = const Value.absent(),
    this.contactPoints = const Value.absent(),
    this.heightDmm = const Value.absent(),
    this.heightDmmMax = const Value.absent(),
    this.weightClass = const Value.absent(),
    this.code = const Value.absent(),
    this.tipShape = const Value.absent(),
    this.gearTeeth = const Value.absent(),
    this.shaftWidth = const Value.absent(),
    this.productCode = const Value.absent(),
    this.hasbroAlias = const Value.absent(),
    this.metaTier = const Value.absent(),
    this.imageLocal = const Value.absent(),
    this.imageRemote = const Value.absent(),
    this.catalogVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       type = Value(type),
       system = Value(system);
  static Insertable<PartRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? type,
    Expression<int>? system,
    Expression<int>? attack,
    Expression<int>? defense,
    Expression<int>? stamina,
    Expression<double>? weightG,
    Expression<double>? weightMinG,
    Expression<double>? weightMaxG,
    Expression<String>? weightNote,
    Expression<double>? heightMm,
    Expression<double>? widthMm,
    Expression<int>? beyType,
    Expression<int>? spinDirection,
    Expression<int>? contactPoints,
    Expression<int>? heightDmm,
    Expression<int>? heightDmmMax,
    Expression<String>? weightClass,
    Expression<String>? code,
    Expression<String>? tipShape,
    Expression<int>? gearTeeth,
    Expression<int>? shaftWidth,
    Expression<String>? productCode,
    Expression<String>? hasbroAlias,
    Expression<String>? metaTier,
    Expression<String>? imageLocal,
    Expression<String>? imageRemote,
    Expression<int>? catalogVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (system != null) 'system': system,
      if (attack != null) 'attack': attack,
      if (defense != null) 'defense': defense,
      if (stamina != null) 'stamina': stamina,
      if (weightG != null) 'weight_g': weightG,
      if (weightMinG != null) 'weight_min_g': weightMinG,
      if (weightMaxG != null) 'weight_max_g': weightMaxG,
      if (weightNote != null) 'weight_note': weightNote,
      if (heightMm != null) 'height_mm': heightMm,
      if (widthMm != null) 'width_mm': widthMm,
      if (beyType != null) 'bey_type': beyType,
      if (spinDirection != null) 'spin_direction': spinDirection,
      if (contactPoints != null) 'contact_points': contactPoints,
      if (heightDmm != null) 'height_dmm': heightDmm,
      if (heightDmmMax != null) 'height_dmm_max': heightDmmMax,
      if (weightClass != null) 'weight_class': weightClass,
      if (code != null) 'code': code,
      if (tipShape != null) 'tip_shape': tipShape,
      if (gearTeeth != null) 'gear_teeth': gearTeeth,
      if (shaftWidth != null) 'shaft_width': shaftWidth,
      if (productCode != null) 'product_code': productCode,
      if (hasbroAlias != null) 'hasbro_alias': hasbroAlias,
      if (metaTier != null) 'meta_tier': metaTier,
      if (imageLocal != null) 'image_local': imageLocal,
      if (imageRemote != null) 'image_remote': imageRemote,
      if (catalogVersion != null) 'catalog_version': catalogVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PartsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<PartType>? type,
    Value<BeySystem>? system,
    Value<int?>? attack,
    Value<int?>? defense,
    Value<int?>? stamina,
    Value<double?>? weightG,
    Value<double?>? weightMinG,
    Value<double?>? weightMaxG,
    Value<String?>? weightNote,
    Value<double?>? heightMm,
    Value<double?>? widthMm,
    Value<BeyType?>? beyType,
    Value<SpinDirection?>? spinDirection,
    Value<int?>? contactPoints,
    Value<int?>? heightDmm,
    Value<int?>? heightDmmMax,
    Value<String?>? weightClass,
    Value<String?>? code,
    Value<String?>? tipShape,
    Value<int?>? gearTeeth,
    Value<int?>? shaftWidth,
    Value<String?>? productCode,
    Value<String?>? hasbroAlias,
    Value<String?>? metaTier,
    Value<String?>? imageLocal,
    Value<String?>? imageRemote,
    Value<int>? catalogVersion,
    Value<int>? rowid,
  }) {
    return PartsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      system: system ?? this.system,
      attack: attack ?? this.attack,
      defense: defense ?? this.defense,
      stamina: stamina ?? this.stamina,
      weightG: weightG ?? this.weightG,
      weightMinG: weightMinG ?? this.weightMinG,
      weightMaxG: weightMaxG ?? this.weightMaxG,
      weightNote: weightNote ?? this.weightNote,
      heightMm: heightMm ?? this.heightMm,
      widthMm: widthMm ?? this.widthMm,
      beyType: beyType ?? this.beyType,
      spinDirection: spinDirection ?? this.spinDirection,
      contactPoints: contactPoints ?? this.contactPoints,
      heightDmm: heightDmm ?? this.heightDmm,
      heightDmmMax: heightDmmMax ?? this.heightDmmMax,
      weightClass: weightClass ?? this.weightClass,
      code: code ?? this.code,
      tipShape: tipShape ?? this.tipShape,
      gearTeeth: gearTeeth ?? this.gearTeeth,
      shaftWidth: shaftWidth ?? this.shaftWidth,
      productCode: productCode ?? this.productCode,
      hasbroAlias: hasbroAlias ?? this.hasbroAlias,
      metaTier: metaTier ?? this.metaTier,
      imageLocal: imageLocal ?? this.imageLocal,
      imageRemote: imageRemote ?? this.imageRemote,
      catalogVersion: catalogVersion ?? this.catalogVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<int>($PartsTable.$convertertype.toSql(type.value));
    }
    if (system.present) {
      map['system'] = Variable<int>(
        $PartsTable.$convertersystem.toSql(system.value),
      );
    }
    if (attack.present) {
      map['attack'] = Variable<int>(attack.value);
    }
    if (defense.present) {
      map['defense'] = Variable<int>(defense.value);
    }
    if (stamina.present) {
      map['stamina'] = Variable<int>(stamina.value);
    }
    if (weightG.present) {
      map['weight_g'] = Variable<double>(weightG.value);
    }
    if (weightMinG.present) {
      map['weight_min_g'] = Variable<double>(weightMinG.value);
    }
    if (weightMaxG.present) {
      map['weight_max_g'] = Variable<double>(weightMaxG.value);
    }
    if (weightNote.present) {
      map['weight_note'] = Variable<String>(weightNote.value);
    }
    if (heightMm.present) {
      map['height_mm'] = Variable<double>(heightMm.value);
    }
    if (widthMm.present) {
      map['width_mm'] = Variable<double>(widthMm.value);
    }
    if (beyType.present) {
      map['bey_type'] = Variable<int>(
        $PartsTable.$converterbeyTypen.toSql(beyType.value),
      );
    }
    if (spinDirection.present) {
      map['spin_direction'] = Variable<int>(
        $PartsTable.$converterspinDirectionn.toSql(spinDirection.value),
      );
    }
    if (contactPoints.present) {
      map['contact_points'] = Variable<int>(contactPoints.value);
    }
    if (heightDmm.present) {
      map['height_dmm'] = Variable<int>(heightDmm.value);
    }
    if (heightDmmMax.present) {
      map['height_dmm_max'] = Variable<int>(heightDmmMax.value);
    }
    if (weightClass.present) {
      map['weight_class'] = Variable<String>(weightClass.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (tipShape.present) {
      map['tip_shape'] = Variable<String>(tipShape.value);
    }
    if (gearTeeth.present) {
      map['gear_teeth'] = Variable<int>(gearTeeth.value);
    }
    if (shaftWidth.present) {
      map['shaft_width'] = Variable<int>(shaftWidth.value);
    }
    if (productCode.present) {
      map['product_code'] = Variable<String>(productCode.value);
    }
    if (hasbroAlias.present) {
      map['hasbro_alias'] = Variable<String>(hasbroAlias.value);
    }
    if (metaTier.present) {
      map['meta_tier'] = Variable<String>(metaTier.value);
    }
    if (imageLocal.present) {
      map['image_local'] = Variable<String>(imageLocal.value);
    }
    if (imageRemote.present) {
      map['image_remote'] = Variable<String>(imageRemote.value);
    }
    if (catalogVersion.present) {
      map['catalog_version'] = Variable<int>(catalogVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PartsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('system: $system, ')
          ..write('attack: $attack, ')
          ..write('defense: $defense, ')
          ..write('stamina: $stamina, ')
          ..write('weightG: $weightG, ')
          ..write('weightMinG: $weightMinG, ')
          ..write('weightMaxG: $weightMaxG, ')
          ..write('weightNote: $weightNote, ')
          ..write('heightMm: $heightMm, ')
          ..write('widthMm: $widthMm, ')
          ..write('beyType: $beyType, ')
          ..write('spinDirection: $spinDirection, ')
          ..write('contactPoints: $contactPoints, ')
          ..write('heightDmm: $heightDmm, ')
          ..write('heightDmmMax: $heightDmmMax, ')
          ..write('weightClass: $weightClass, ')
          ..write('code: $code, ')
          ..write('tipShape: $tipShape, ')
          ..write('gearTeeth: $gearTeeth, ')
          ..write('shaftWidth: $shaftWidth, ')
          ..write('productCode: $productCode, ')
          ..write('hasbroAlias: $hasbroAlias, ')
          ..write('metaTier: $metaTier, ')
          ..write('imageLocal: $imageLocal, ')
          ..write('imageRemote: $imageRemote, ')
          ..write('catalogVersion: $catalogVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CombosTable extends Combos with TableInfo<$CombosTable, ComboRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CombosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _bladeIdMeta = const VerificationMeta(
    'bladeId',
  );
  @override
  late final GeneratedColumn<String> bladeId = GeneratedColumn<String>(
    'blade_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ratchetIdMeta = const VerificationMeta(
    'ratchetId',
  );
  @override
  late final GeneratedColumn<String> ratchetId = GeneratedColumn<String>(
    'ratchet_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bitIdMeta = const VerificationMeta('bitId');
  @override
  late final GeneratedColumn<String> bitId = GeneratedColumn<String>(
    'bit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lockChipIdMeta = const VerificationMeta(
    'lockChipId',
  );
  @override
  late final GeneratedColumn<String> lockChipId = GeneratedColumn<String>(
    'lock_chip_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _assistBladeIdMeta = const VerificationMeta(
    'assistBladeId',
  );
  @override
  late final GeneratedColumn<String> assistBladeId = GeneratedColumn<String>(
    'assist_blade_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<BeySystem, int> system =
      GeneratedColumn<int>(
        'system',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<BeySystem>($CombosTable.$convertersystem);
  static const VerificationMeta _calculatedWeightMeta = const VerificationMeta(
    'calculatedWeight',
  );
  @override
  late final GeneratedColumn<double> calculatedWeight = GeneratedColumn<double>(
    'calculated_weight',
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
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    bladeId,
    ratchetId,
    bitId,
    lockChipId,
    assistBladeId,
    system,
    calculatedWeight,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'combos';
  @override
  VerificationContext validateIntegrity(
    Insertable<ComboRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('blade_id')) {
      context.handle(
        _bladeIdMeta,
        bladeId.isAcceptableOrUnknown(data['blade_id']!, _bladeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bladeIdMeta);
    }
    if (data.containsKey('ratchet_id')) {
      context.handle(
        _ratchetIdMeta,
        ratchetId.isAcceptableOrUnknown(data['ratchet_id']!, _ratchetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ratchetIdMeta);
    }
    if (data.containsKey('bit_id')) {
      context.handle(
        _bitIdMeta,
        bitId.isAcceptableOrUnknown(data['bit_id']!, _bitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bitIdMeta);
    }
    if (data.containsKey('lock_chip_id')) {
      context.handle(
        _lockChipIdMeta,
        lockChipId.isAcceptableOrUnknown(
          data['lock_chip_id']!,
          _lockChipIdMeta,
        ),
      );
    }
    if (data.containsKey('assist_blade_id')) {
      context.handle(
        _assistBladeIdMeta,
        assistBladeId.isAcceptableOrUnknown(
          data['assist_blade_id']!,
          _assistBladeIdMeta,
        ),
      );
    }
    if (data.containsKey('calculated_weight')) {
      context.handle(
        _calculatedWeightMeta,
        calculatedWeight.isAcceptableOrUnknown(
          data['calculated_weight']!,
          _calculatedWeightMeta,
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
  ComboRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ComboRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      bladeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}blade_id'],
      )!,
      ratchetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ratchet_id'],
      )!,
      bitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bit_id'],
      )!,
      lockChipId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lock_chip_id'],
      ),
      assistBladeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assist_blade_id'],
      ),
      system: $CombosTable.$convertersystem.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}system'],
        )!,
      ),
      calculatedWeight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calculated_weight'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $CombosTable createAlias(String alias) {
    return $CombosTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<BeySystem, int, int> $convertersystem =
      const EnumIndexConverter<BeySystem>(BeySystem.values);
}

class ComboRow extends DataClass implements Insertable<ComboRow> {
  final String id;
  final String name;
  final String bladeId;
  final String ratchetId;
  final String bitId;
  final String? lockChipId;
  final String? assistBladeId;
  final BeySystem system;
  final double? calculatedWeight;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const ComboRow({
    required this.id,
    required this.name,
    required this.bladeId,
    required this.ratchetId,
    required this.bitId,
    this.lockChipId,
    this.assistBladeId,
    required this.system,
    this.calculatedWeight,
    this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['blade_id'] = Variable<String>(bladeId);
    map['ratchet_id'] = Variable<String>(ratchetId);
    map['bit_id'] = Variable<String>(bitId);
    if (!nullToAbsent || lockChipId != null) {
      map['lock_chip_id'] = Variable<String>(lockChipId);
    }
    if (!nullToAbsent || assistBladeId != null) {
      map['assist_blade_id'] = Variable<String>(assistBladeId);
    }
    {
      map['system'] = Variable<int>(
        $CombosTable.$convertersystem.toSql(system),
      );
    }
    if (!nullToAbsent || calculatedWeight != null) {
      map['calculated_weight'] = Variable<double>(calculatedWeight);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  CombosCompanion toCompanion(bool nullToAbsent) {
    return CombosCompanion(
      id: Value(id),
      name: Value(name),
      bladeId: Value(bladeId),
      ratchetId: Value(ratchetId),
      bitId: Value(bitId),
      lockChipId: lockChipId == null && nullToAbsent
          ? const Value.absent()
          : Value(lockChipId),
      assistBladeId: assistBladeId == null && nullToAbsent
          ? const Value.absent()
          : Value(assistBladeId),
      system: Value(system),
      calculatedWeight: calculatedWeight == null && nullToAbsent
          ? const Value.absent()
          : Value(calculatedWeight),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory ComboRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ComboRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      bladeId: serializer.fromJson<String>(json['bladeId']),
      ratchetId: serializer.fromJson<String>(json['ratchetId']),
      bitId: serializer.fromJson<String>(json['bitId']),
      lockChipId: serializer.fromJson<String?>(json['lockChipId']),
      assistBladeId: serializer.fromJson<String?>(json['assistBladeId']),
      system: $CombosTable.$convertersystem.fromJson(
        serializer.fromJson<int>(json['system']),
      ),
      calculatedWeight: serializer.fromJson<double?>(json['calculatedWeight']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'bladeId': serializer.toJson<String>(bladeId),
      'ratchetId': serializer.toJson<String>(ratchetId),
      'bitId': serializer.toJson<String>(bitId),
      'lockChipId': serializer.toJson<String?>(lockChipId),
      'assistBladeId': serializer.toJson<String?>(assistBladeId),
      'system': serializer.toJson<int>(
        $CombosTable.$convertersystem.toJson(system),
      ),
      'calculatedWeight': serializer.toJson<double?>(calculatedWeight),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  ComboRow copyWith({
    String? id,
    String? name,
    String? bladeId,
    String? ratchetId,
    String? bitId,
    Value<String?> lockChipId = const Value.absent(),
    Value<String?> assistBladeId = const Value.absent(),
    BeySystem? system,
    Value<double?> calculatedWeight = const Value.absent(),
    Value<DateTime?> createdAt = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => ComboRow(
    id: id ?? this.id,
    name: name ?? this.name,
    bladeId: bladeId ?? this.bladeId,
    ratchetId: ratchetId ?? this.ratchetId,
    bitId: bitId ?? this.bitId,
    lockChipId: lockChipId.present ? lockChipId.value : this.lockChipId,
    assistBladeId: assistBladeId.present
        ? assistBladeId.value
        : this.assistBladeId,
    system: system ?? this.system,
    calculatedWeight: calculatedWeight.present
        ? calculatedWeight.value
        : this.calculatedWeight,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  ComboRow copyWithCompanion(CombosCompanion data) {
    return ComboRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      bladeId: data.bladeId.present ? data.bladeId.value : this.bladeId,
      ratchetId: data.ratchetId.present ? data.ratchetId.value : this.ratchetId,
      bitId: data.bitId.present ? data.bitId.value : this.bitId,
      lockChipId: data.lockChipId.present
          ? data.lockChipId.value
          : this.lockChipId,
      assistBladeId: data.assistBladeId.present
          ? data.assistBladeId.value
          : this.assistBladeId,
      system: data.system.present ? data.system.value : this.system,
      calculatedWeight: data.calculatedWeight.present
          ? data.calculatedWeight.value
          : this.calculatedWeight,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ComboRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('bladeId: $bladeId, ')
          ..write('ratchetId: $ratchetId, ')
          ..write('bitId: $bitId, ')
          ..write('lockChipId: $lockChipId, ')
          ..write('assistBladeId: $assistBladeId, ')
          ..write('system: $system, ')
          ..write('calculatedWeight: $calculatedWeight, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    bladeId,
    ratchetId,
    bitId,
    lockChipId,
    assistBladeId,
    system,
    calculatedWeight,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ComboRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.bladeId == this.bladeId &&
          other.ratchetId == this.ratchetId &&
          other.bitId == this.bitId &&
          other.lockChipId == this.lockChipId &&
          other.assistBladeId == this.assistBladeId &&
          other.system == this.system &&
          other.calculatedWeight == this.calculatedWeight &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CombosCompanion extends UpdateCompanion<ComboRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> bladeId;
  final Value<String> ratchetId;
  final Value<String> bitId;
  final Value<String?> lockChipId;
  final Value<String?> assistBladeId;
  final Value<BeySystem> system;
  final Value<double?> calculatedWeight;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const CombosCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.bladeId = const Value.absent(),
    this.ratchetId = const Value.absent(),
    this.bitId = const Value.absent(),
    this.lockChipId = const Value.absent(),
    this.assistBladeId = const Value.absent(),
    this.system = const Value.absent(),
    this.calculatedWeight = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CombosCompanion.insert({
    required String id,
    required String name,
    required String bladeId,
    required String ratchetId,
    required String bitId,
    this.lockChipId = const Value.absent(),
    this.assistBladeId = const Value.absent(),
    this.system = const Value.absent(),
    this.calculatedWeight = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       bladeId = Value(bladeId),
       ratchetId = Value(ratchetId),
       bitId = Value(bitId);
  static Insertable<ComboRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? bladeId,
    Expression<String>? ratchetId,
    Expression<String>? bitId,
    Expression<String>? lockChipId,
    Expression<String>? assistBladeId,
    Expression<int>? system,
    Expression<double>? calculatedWeight,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (bladeId != null) 'blade_id': bladeId,
      if (ratchetId != null) 'ratchet_id': ratchetId,
      if (bitId != null) 'bit_id': bitId,
      if (lockChipId != null) 'lock_chip_id': lockChipId,
      if (assistBladeId != null) 'assist_blade_id': assistBladeId,
      if (system != null) 'system': system,
      if (calculatedWeight != null) 'calculated_weight': calculatedWeight,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CombosCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? bladeId,
    Value<String>? ratchetId,
    Value<String>? bitId,
    Value<String?>? lockChipId,
    Value<String?>? assistBladeId,
    Value<BeySystem>? system,
    Value<double?>? calculatedWeight,
    Value<DateTime?>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return CombosCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      bladeId: bladeId ?? this.bladeId,
      ratchetId: ratchetId ?? this.ratchetId,
      bitId: bitId ?? this.bitId,
      lockChipId: lockChipId ?? this.lockChipId,
      assistBladeId: assistBladeId ?? this.assistBladeId,
      system: system ?? this.system,
      calculatedWeight: calculatedWeight ?? this.calculatedWeight,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (bladeId.present) {
      map['blade_id'] = Variable<String>(bladeId.value);
    }
    if (ratchetId.present) {
      map['ratchet_id'] = Variable<String>(ratchetId.value);
    }
    if (bitId.present) {
      map['bit_id'] = Variable<String>(bitId.value);
    }
    if (lockChipId.present) {
      map['lock_chip_id'] = Variable<String>(lockChipId.value);
    }
    if (assistBladeId.present) {
      map['assist_blade_id'] = Variable<String>(assistBladeId.value);
    }
    if (system.present) {
      map['system'] = Variable<int>(
        $CombosTable.$convertersystem.toSql(system.value),
      );
    }
    if (calculatedWeight.present) {
      map['calculated_weight'] = Variable<double>(calculatedWeight.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CombosCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('bladeId: $bladeId, ')
          ..write('ratchetId: $ratchetId, ')
          ..write('bitId: $bitId, ')
          ..write('lockChipId: $lockChipId, ')
          ..write('assistBladeId: $assistBladeId, ')
          ..write('system: $system, ')
          ..write('calculatedWeight: $calculatedWeight, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DecksTable extends Decks with TableInfo<$DecksTable, DeckRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DecksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _comboIdsJsonMeta = const VerificationMeta(
    'comboIdsJson',
  );
  @override
  late final GeneratedColumn<String> comboIdsJson = GeneratedColumn<String>(
    'combo_ids_json',
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
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    comboIdsJson,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'decks';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeckRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('combo_ids_json')) {
      context.handle(
        _comboIdsJsonMeta,
        comboIdsJson.isAcceptableOrUnknown(
          data['combo_ids_json']!,
          _comboIdsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_comboIdsJsonMeta);
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
  DeckRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeckRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      comboIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}combo_ids_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $DecksTable createAlias(String alias) {
    return $DecksTable(attachedDatabase, alias);
  }
}

class DeckRow extends DataClass implements Insertable<DeckRow> {
  final String id;
  final String name;
  final String comboIdsJson;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const DeckRow({
    required this.id,
    required this.name,
    required this.comboIdsJson,
    this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['combo_ids_json'] = Variable<String>(comboIdsJson);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  DecksCompanion toCompanion(bool nullToAbsent) {
    return DecksCompanion(
      id: Value(id),
      name: Value(name),
      comboIdsJson: Value(comboIdsJson),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory DeckRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeckRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      comboIdsJson: serializer.fromJson<String>(json['comboIdsJson']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'comboIdsJson': serializer.toJson<String>(comboIdsJson),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  DeckRow copyWith({
    String? id,
    String? name,
    String? comboIdsJson,
    Value<DateTime?> createdAt = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => DeckRow(
    id: id ?? this.id,
    name: name ?? this.name,
    comboIdsJson: comboIdsJson ?? this.comboIdsJson,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  DeckRow copyWithCompanion(DecksCompanion data) {
    return DeckRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      comboIdsJson: data.comboIdsJson.present
          ? data.comboIdsJson.value
          : this.comboIdsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeckRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('comboIdsJson: $comboIdsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, comboIdsJson, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeckRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.comboIdsJson == this.comboIdsJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DecksCompanion extends UpdateCompanion<DeckRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> comboIdsJson;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const DecksCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.comboIdsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DecksCompanion.insert({
    required String id,
    required String name,
    required String comboIdsJson,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       comboIdsJson = Value(comboIdsJson);
  static Insertable<DeckRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? comboIdsJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (comboIdsJson != null) 'combo_ids_json': comboIdsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DecksCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? comboIdsJson,
    Value<DateTime?>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return DecksCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      comboIdsJson: comboIdsJson ?? this.comboIdsJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (comboIdsJson.present) {
      map['combo_ids_json'] = Variable<String>(comboIdsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DecksCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('comboIdsJson: $comboIdsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MatchesTableTable extends MatchesTable
    with TableInfo<$MatchesTableTable, MatchRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MatchesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playerAIdMeta = const VerificationMeta(
    'playerAId',
  );
  @override
  late final GeneratedColumn<String> playerAId = GeneratedColumn<String>(
    'player_a_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playerBIdMeta = const VerificationMeta(
    'playerBId',
  );
  @override
  late final GeneratedColumn<String> playerBId = GeneratedColumn<String>(
    'player_b_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tournamentIdMeta = const VerificationMeta(
    'tournamentId',
  );
  @override
  late final GeneratedColumn<String> tournamentId = GeneratedColumn<String>(
    'tournament_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetPointsMeta = const VerificationMeta(
    'targetPoints',
  );
  @override
  late final GeneratedColumn<int> targetPoints = GeneratedColumn<int>(
    'target_points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(4),
  );
  @override
  late final GeneratedColumnWithTypeConverter<MatchFormat, int> format =
      GeneratedColumn<int>(
        'format',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<MatchFormat>($MatchesTableTable.$converterformat);
  @override
  late final GeneratedColumnWithTypeConverter<MatchStatus, int> status =
      GeneratedColumn<int>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<MatchStatus>($MatchesTableTable.$converterstatus);
  static const VerificationMeta _finishesJsonMeta = const VerificationMeta(
    'finishesJson',
  );
  @override
  late final GeneratedColumn<String> finishesJson = GeneratedColumn<String>(
    'finishes_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    playerAId,
    playerBId,
    tournamentId,
    targetPoints,
    format,
    status,
    finishesJson,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'matches_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<MatchRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('player_a_id')) {
      context.handle(
        _playerAIdMeta,
        playerAId.isAcceptableOrUnknown(data['player_a_id']!, _playerAIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playerAIdMeta);
    }
    if (data.containsKey('player_b_id')) {
      context.handle(
        _playerBIdMeta,
        playerBId.isAcceptableOrUnknown(data['player_b_id']!, _playerBIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playerBIdMeta);
    }
    if (data.containsKey('tournament_id')) {
      context.handle(
        _tournamentIdMeta,
        tournamentId.isAcceptableOrUnknown(
          data['tournament_id']!,
          _tournamentIdMeta,
        ),
      );
    }
    if (data.containsKey('target_points')) {
      context.handle(
        _targetPointsMeta,
        targetPoints.isAcceptableOrUnknown(
          data['target_points']!,
          _targetPointsMeta,
        ),
      );
    }
    if (data.containsKey('finishes_json')) {
      context.handle(
        _finishesJsonMeta,
        finishesJson.isAcceptableOrUnknown(
          data['finishes_json']!,
          _finishesJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MatchRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MatchRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      playerAId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}player_a_id'],
      )!,
      playerBId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}player_b_id'],
      )!,
      tournamentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tournament_id'],
      ),
      targetPoints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_points'],
      )!,
      format: $MatchesTableTable.$converterformat.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}format'],
        )!,
      ),
      status: $MatchesTableTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}status'],
        )!,
      ),
      finishesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}finishes_json'],
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
  $MatchesTableTable createAlias(String alias) {
    return $MatchesTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MatchFormat, int, int> $converterformat =
      const EnumIndexConverter<MatchFormat>(MatchFormat.values);
  static JsonTypeConverter2<MatchStatus, int, int> $converterstatus =
      const EnumIndexConverter<MatchStatus>(MatchStatus.values);
}

class MatchRow extends DataClass implements Insertable<MatchRow> {
  final String id;
  final String playerAId;
  final String playerBId;
  final String? tournamentId;
  final int targetPoints;
  final MatchFormat format;
  final MatchStatus status;
  final String finishesJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  const MatchRow({
    required this.id,
    required this.playerAId,
    required this.playerBId,
    this.tournamentId,
    required this.targetPoints,
    required this.format,
    required this.status,
    required this.finishesJson,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['player_a_id'] = Variable<String>(playerAId);
    map['player_b_id'] = Variable<String>(playerBId);
    if (!nullToAbsent || tournamentId != null) {
      map['tournament_id'] = Variable<String>(tournamentId);
    }
    map['target_points'] = Variable<int>(targetPoints);
    {
      map['format'] = Variable<int>(
        $MatchesTableTable.$converterformat.toSql(format),
      );
    }
    {
      map['status'] = Variable<int>(
        $MatchesTableTable.$converterstatus.toSql(status),
      );
    }
    map['finishes_json'] = Variable<String>(finishesJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MatchesTableCompanion toCompanion(bool nullToAbsent) {
    return MatchesTableCompanion(
      id: Value(id),
      playerAId: Value(playerAId),
      playerBId: Value(playerBId),
      tournamentId: tournamentId == null && nullToAbsent
          ? const Value.absent()
          : Value(tournamentId),
      targetPoints: Value(targetPoints),
      format: Value(format),
      status: Value(status),
      finishesJson: Value(finishesJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory MatchRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MatchRow(
      id: serializer.fromJson<String>(json['id']),
      playerAId: serializer.fromJson<String>(json['playerAId']),
      playerBId: serializer.fromJson<String>(json['playerBId']),
      tournamentId: serializer.fromJson<String?>(json['tournamentId']),
      targetPoints: serializer.fromJson<int>(json['targetPoints']),
      format: $MatchesTableTable.$converterformat.fromJson(
        serializer.fromJson<int>(json['format']),
      ),
      status: $MatchesTableTable.$converterstatus.fromJson(
        serializer.fromJson<int>(json['status']),
      ),
      finishesJson: serializer.fromJson<String>(json['finishesJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'playerAId': serializer.toJson<String>(playerAId),
      'playerBId': serializer.toJson<String>(playerBId),
      'tournamentId': serializer.toJson<String?>(tournamentId),
      'targetPoints': serializer.toJson<int>(targetPoints),
      'format': serializer.toJson<int>(
        $MatchesTableTable.$converterformat.toJson(format),
      ),
      'status': serializer.toJson<int>(
        $MatchesTableTable.$converterstatus.toJson(status),
      ),
      'finishesJson': serializer.toJson<String>(finishesJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MatchRow copyWith({
    String? id,
    String? playerAId,
    String? playerBId,
    Value<String?> tournamentId = const Value.absent(),
    int? targetPoints,
    MatchFormat? format,
    MatchStatus? status,
    String? finishesJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => MatchRow(
    id: id ?? this.id,
    playerAId: playerAId ?? this.playerAId,
    playerBId: playerBId ?? this.playerBId,
    tournamentId: tournamentId.present ? tournamentId.value : this.tournamentId,
    targetPoints: targetPoints ?? this.targetPoints,
    format: format ?? this.format,
    status: status ?? this.status,
    finishesJson: finishesJson ?? this.finishesJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MatchRow copyWithCompanion(MatchesTableCompanion data) {
    return MatchRow(
      id: data.id.present ? data.id.value : this.id,
      playerAId: data.playerAId.present ? data.playerAId.value : this.playerAId,
      playerBId: data.playerBId.present ? data.playerBId.value : this.playerBId,
      tournamentId: data.tournamentId.present
          ? data.tournamentId.value
          : this.tournamentId,
      targetPoints: data.targetPoints.present
          ? data.targetPoints.value
          : this.targetPoints,
      format: data.format.present ? data.format.value : this.format,
      status: data.status.present ? data.status.value : this.status,
      finishesJson: data.finishesJson.present
          ? data.finishesJson.value
          : this.finishesJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MatchRow(')
          ..write('id: $id, ')
          ..write('playerAId: $playerAId, ')
          ..write('playerBId: $playerBId, ')
          ..write('tournamentId: $tournamentId, ')
          ..write('targetPoints: $targetPoints, ')
          ..write('format: $format, ')
          ..write('status: $status, ')
          ..write('finishesJson: $finishesJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    playerAId,
    playerBId,
    tournamentId,
    targetPoints,
    format,
    status,
    finishesJson,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MatchRow &&
          other.id == this.id &&
          other.playerAId == this.playerAId &&
          other.playerBId == this.playerBId &&
          other.tournamentId == this.tournamentId &&
          other.targetPoints == this.targetPoints &&
          other.format == this.format &&
          other.status == this.status &&
          other.finishesJson == this.finishesJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MatchesTableCompanion extends UpdateCompanion<MatchRow> {
  final Value<String> id;
  final Value<String> playerAId;
  final Value<String> playerBId;
  final Value<String?> tournamentId;
  final Value<int> targetPoints;
  final Value<MatchFormat> format;
  final Value<MatchStatus> status;
  final Value<String> finishesJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MatchesTableCompanion({
    this.id = const Value.absent(),
    this.playerAId = const Value.absent(),
    this.playerBId = const Value.absent(),
    this.tournamentId = const Value.absent(),
    this.targetPoints = const Value.absent(),
    this.format = const Value.absent(),
    this.status = const Value.absent(),
    this.finishesJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MatchesTableCompanion.insert({
    required String id,
    required String playerAId,
    required String playerBId,
    this.tournamentId = const Value.absent(),
    this.targetPoints = const Value.absent(),
    this.format = const Value.absent(),
    this.status = const Value.absent(),
    this.finishesJson = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       playerAId = Value(playerAId),
       playerBId = Value(playerBId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<MatchRow> custom({
    Expression<String>? id,
    Expression<String>? playerAId,
    Expression<String>? playerBId,
    Expression<String>? tournamentId,
    Expression<int>? targetPoints,
    Expression<int>? format,
    Expression<int>? status,
    Expression<String>? finishesJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (playerAId != null) 'player_a_id': playerAId,
      if (playerBId != null) 'player_b_id': playerBId,
      if (tournamentId != null) 'tournament_id': tournamentId,
      if (targetPoints != null) 'target_points': targetPoints,
      if (format != null) 'format': format,
      if (status != null) 'status': status,
      if (finishesJson != null) 'finishes_json': finishesJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MatchesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? playerAId,
    Value<String>? playerBId,
    Value<String?>? tournamentId,
    Value<int>? targetPoints,
    Value<MatchFormat>? format,
    Value<MatchStatus>? status,
    Value<String>? finishesJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return MatchesTableCompanion(
      id: id ?? this.id,
      playerAId: playerAId ?? this.playerAId,
      playerBId: playerBId ?? this.playerBId,
      tournamentId: tournamentId ?? this.tournamentId,
      targetPoints: targetPoints ?? this.targetPoints,
      format: format ?? this.format,
      status: status ?? this.status,
      finishesJson: finishesJson ?? this.finishesJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (playerAId.present) {
      map['player_a_id'] = Variable<String>(playerAId.value);
    }
    if (playerBId.present) {
      map['player_b_id'] = Variable<String>(playerBId.value);
    }
    if (tournamentId.present) {
      map['tournament_id'] = Variable<String>(tournamentId.value);
    }
    if (targetPoints.present) {
      map['target_points'] = Variable<int>(targetPoints.value);
    }
    if (format.present) {
      map['format'] = Variable<int>(
        $MatchesTableTable.$converterformat.toSql(format.value),
      );
    }
    if (status.present) {
      map['status'] = Variable<int>(
        $MatchesTableTable.$converterstatus.toSql(status.value),
      );
    }
    if (finishesJson.present) {
      map['finishes_json'] = Variable<String>(finishesJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MatchesTableCompanion(')
          ..write('id: $id, ')
          ..write('playerAId: $playerAId, ')
          ..write('playerBId: $playerBId, ')
          ..write('tournamentId: $tournamentId, ')
          ..write('targetPoints: $targetPoints, ')
          ..write('format: $format, ')
          ..write('status: $status, ')
          ..write('finishesJson: $finishesJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TournamentsTableTable extends TournamentsTable
    with TableInfo<$TournamentsTableTable, TournamentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TournamentsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _organizerIdsJsonMeta = const VerificationMeta(
    'organizerIdsJson',
  );
  @override
  late final GeneratedColumn<String> organizerIdsJson = GeneratedColumn<String>(
    'organizer_ids_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<TournamentTier, int> tier =
      GeneratedColumn<int>(
        'tier',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<TournamentTier>($TournamentsTableTable.$convertertier);
  @override
  late final GeneratedColumnWithTypeConverter<AgeDivision, int> ageDivision =
      GeneratedColumn<int>(
        'age_division',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<AgeDivision>(
        $TournamentsTableTable.$converterageDivision,
      );
  @override
  late final GeneratedColumnWithTypeConverter<TournamentStatus, int> status =
      GeneratedColumn<int>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<TournamentStatus>(
        $TournamentsTableTable.$converterstatus,
      );
  static const VerificationMeta _participantsJsonMeta = const VerificationMeta(
    'participantsJson',
  );
  @override
  late final GeneratedColumn<String> participantsJson = GeneratedColumn<String>(
    'participants_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _roundsJsonMeta = const VerificationMeta(
    'roundsJson',
  );
  @override
  late final GeneratedColumn<String> roundsJson = GeneratedColumn<String>(
    'rounds_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _championNameMeta = const VerificationMeta(
    'championName',
  );
  @override
  late final GeneratedColumn<String> championName = GeneratedColumn<String>(
    'champion_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seedMeta = const VerificationMeta('seed');
  @override
  late final GeneratedColumn<int> seed = GeneratedColumn<int>(
    'seed',
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
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    organizerIdsJson,
    tier,
    ageDivision,
    status,
    participantsJson,
    roundsJson,
    championName,
    seed,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tournaments_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<TournamentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('organizer_ids_json')) {
      context.handle(
        _organizerIdsJsonMeta,
        organizerIdsJson.isAcceptableOrUnknown(
          data['organizer_ids_json']!,
          _organizerIdsJsonMeta,
        ),
      );
    }
    if (data.containsKey('participants_json')) {
      context.handle(
        _participantsJsonMeta,
        participantsJson.isAcceptableOrUnknown(
          data['participants_json']!,
          _participantsJsonMeta,
        ),
      );
    }
    if (data.containsKey('rounds_json')) {
      context.handle(
        _roundsJsonMeta,
        roundsJson.isAcceptableOrUnknown(data['rounds_json']!, _roundsJsonMeta),
      );
    }
    if (data.containsKey('champion_name')) {
      context.handle(
        _championNameMeta,
        championName.isAcceptableOrUnknown(
          data['champion_name']!,
          _championNameMeta,
        ),
      );
    }
    if (data.containsKey('seed')) {
      context.handle(
        _seedMeta,
        seed.isAcceptableOrUnknown(data['seed']!, _seedMeta),
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
  TournamentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TournamentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      organizerIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}organizer_ids_json'],
      )!,
      tier: $TournamentsTableTable.$convertertier.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}tier'],
        )!,
      ),
      ageDivision: $TournamentsTableTable.$converterageDivision.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}age_division'],
        )!,
      ),
      status: $TournamentsTableTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}status'],
        )!,
      ),
      participantsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}participants_json'],
      )!,
      roundsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rounds_json'],
      )!,
      championName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}champion_name'],
      ),
      seed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seed'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
    );
  }

  @override
  $TournamentsTableTable createAlias(String alias) {
    return $TournamentsTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TournamentTier, int, int> $convertertier =
      const EnumIndexConverter<TournamentTier>(TournamentTier.values);
  static JsonTypeConverter2<AgeDivision, int, int> $converterageDivision =
      const EnumIndexConverter<AgeDivision>(AgeDivision.values);
  static JsonTypeConverter2<TournamentStatus, int, int> $converterstatus =
      const EnumIndexConverter<TournamentStatus>(TournamentStatus.values);
}

class TournamentRow extends DataClass implements Insertable<TournamentRow> {
  final String id;
  final String name;
  final String organizerIdsJson;
  final TournamentTier tier;
  final AgeDivision ageDivision;
  final TournamentStatus status;
  final String participantsJson;
  final String roundsJson;
  final String? championName;
  final int? seed;
  final DateTime? createdAt;
  const TournamentRow({
    required this.id,
    required this.name,
    required this.organizerIdsJson,
    required this.tier,
    required this.ageDivision,
    required this.status,
    required this.participantsJson,
    required this.roundsJson,
    this.championName,
    this.seed,
    this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['organizer_ids_json'] = Variable<String>(organizerIdsJson);
    {
      map['tier'] = Variable<int>(
        $TournamentsTableTable.$convertertier.toSql(tier),
      );
    }
    {
      map['age_division'] = Variable<int>(
        $TournamentsTableTable.$converterageDivision.toSql(ageDivision),
      );
    }
    {
      map['status'] = Variable<int>(
        $TournamentsTableTable.$converterstatus.toSql(status),
      );
    }
    map['participants_json'] = Variable<String>(participantsJson);
    map['rounds_json'] = Variable<String>(roundsJson);
    if (!nullToAbsent || championName != null) {
      map['champion_name'] = Variable<String>(championName);
    }
    if (!nullToAbsent || seed != null) {
      map['seed'] = Variable<int>(seed);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    return map;
  }

  TournamentsTableCompanion toCompanion(bool nullToAbsent) {
    return TournamentsTableCompanion(
      id: Value(id),
      name: Value(name),
      organizerIdsJson: Value(organizerIdsJson),
      tier: Value(tier),
      ageDivision: Value(ageDivision),
      status: Value(status),
      participantsJson: Value(participantsJson),
      roundsJson: Value(roundsJson),
      championName: championName == null && nullToAbsent
          ? const Value.absent()
          : Value(championName),
      seed: seed == null && nullToAbsent ? const Value.absent() : Value(seed),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
    );
  }

  factory TournamentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TournamentRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      organizerIdsJson: serializer.fromJson<String>(json['organizerIdsJson']),
      tier: $TournamentsTableTable.$convertertier.fromJson(
        serializer.fromJson<int>(json['tier']),
      ),
      ageDivision: $TournamentsTableTable.$converterageDivision.fromJson(
        serializer.fromJson<int>(json['ageDivision']),
      ),
      status: $TournamentsTableTable.$converterstatus.fromJson(
        serializer.fromJson<int>(json['status']),
      ),
      participantsJson: serializer.fromJson<String>(json['participantsJson']),
      roundsJson: serializer.fromJson<String>(json['roundsJson']),
      championName: serializer.fromJson<String?>(json['championName']),
      seed: serializer.fromJson<int?>(json['seed']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'organizerIdsJson': serializer.toJson<String>(organizerIdsJson),
      'tier': serializer.toJson<int>(
        $TournamentsTableTable.$convertertier.toJson(tier),
      ),
      'ageDivision': serializer.toJson<int>(
        $TournamentsTableTable.$converterageDivision.toJson(ageDivision),
      ),
      'status': serializer.toJson<int>(
        $TournamentsTableTable.$converterstatus.toJson(status),
      ),
      'participantsJson': serializer.toJson<String>(participantsJson),
      'roundsJson': serializer.toJson<String>(roundsJson),
      'championName': serializer.toJson<String?>(championName),
      'seed': serializer.toJson<int?>(seed),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
    };
  }

  TournamentRow copyWith({
    String? id,
    String? name,
    String? organizerIdsJson,
    TournamentTier? tier,
    AgeDivision? ageDivision,
    TournamentStatus? status,
    String? participantsJson,
    String? roundsJson,
    Value<String?> championName = const Value.absent(),
    Value<int?> seed = const Value.absent(),
    Value<DateTime?> createdAt = const Value.absent(),
  }) => TournamentRow(
    id: id ?? this.id,
    name: name ?? this.name,
    organizerIdsJson: organizerIdsJson ?? this.organizerIdsJson,
    tier: tier ?? this.tier,
    ageDivision: ageDivision ?? this.ageDivision,
    status: status ?? this.status,
    participantsJson: participantsJson ?? this.participantsJson,
    roundsJson: roundsJson ?? this.roundsJson,
    championName: championName.present ? championName.value : this.championName,
    seed: seed.present ? seed.value : this.seed,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
  );
  TournamentRow copyWithCompanion(TournamentsTableCompanion data) {
    return TournamentRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      organizerIdsJson: data.organizerIdsJson.present
          ? data.organizerIdsJson.value
          : this.organizerIdsJson,
      tier: data.tier.present ? data.tier.value : this.tier,
      ageDivision: data.ageDivision.present
          ? data.ageDivision.value
          : this.ageDivision,
      status: data.status.present ? data.status.value : this.status,
      participantsJson: data.participantsJson.present
          ? data.participantsJson.value
          : this.participantsJson,
      roundsJson: data.roundsJson.present
          ? data.roundsJson.value
          : this.roundsJson,
      championName: data.championName.present
          ? data.championName.value
          : this.championName,
      seed: data.seed.present ? data.seed.value : this.seed,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TournamentRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('organizerIdsJson: $organizerIdsJson, ')
          ..write('tier: $tier, ')
          ..write('ageDivision: $ageDivision, ')
          ..write('status: $status, ')
          ..write('participantsJson: $participantsJson, ')
          ..write('roundsJson: $roundsJson, ')
          ..write('championName: $championName, ')
          ..write('seed: $seed, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    organizerIdsJson,
    tier,
    ageDivision,
    status,
    participantsJson,
    roundsJson,
    championName,
    seed,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TournamentRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.organizerIdsJson == this.organizerIdsJson &&
          other.tier == this.tier &&
          other.ageDivision == this.ageDivision &&
          other.status == this.status &&
          other.participantsJson == this.participantsJson &&
          other.roundsJson == this.roundsJson &&
          other.championName == this.championName &&
          other.seed == this.seed &&
          other.createdAt == this.createdAt);
}

class TournamentsTableCompanion extends UpdateCompanion<TournamentRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> organizerIdsJson;
  final Value<TournamentTier> tier;
  final Value<AgeDivision> ageDivision;
  final Value<TournamentStatus> status;
  final Value<String> participantsJson;
  final Value<String> roundsJson;
  final Value<String?> championName;
  final Value<int?> seed;
  final Value<DateTime?> createdAt;
  final Value<int> rowid;
  const TournamentsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.organizerIdsJson = const Value.absent(),
    this.tier = const Value.absent(),
    this.ageDivision = const Value.absent(),
    this.status = const Value.absent(),
    this.participantsJson = const Value.absent(),
    this.roundsJson = const Value.absent(),
    this.championName = const Value.absent(),
    this.seed = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TournamentsTableCompanion.insert({
    required String id,
    required String name,
    this.organizerIdsJson = const Value.absent(),
    this.tier = const Value.absent(),
    this.ageDivision = const Value.absent(),
    this.status = const Value.absent(),
    this.participantsJson = const Value.absent(),
    this.roundsJson = const Value.absent(),
    this.championName = const Value.absent(),
    this.seed = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<TournamentRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? organizerIdsJson,
    Expression<int>? tier,
    Expression<int>? ageDivision,
    Expression<int>? status,
    Expression<String>? participantsJson,
    Expression<String>? roundsJson,
    Expression<String>? championName,
    Expression<int>? seed,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (organizerIdsJson != null) 'organizer_ids_json': organizerIdsJson,
      if (tier != null) 'tier': tier,
      if (ageDivision != null) 'age_division': ageDivision,
      if (status != null) 'status': status,
      if (participantsJson != null) 'participants_json': participantsJson,
      if (roundsJson != null) 'rounds_json': roundsJson,
      if (championName != null) 'champion_name': championName,
      if (seed != null) 'seed': seed,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TournamentsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? organizerIdsJson,
    Value<TournamentTier>? tier,
    Value<AgeDivision>? ageDivision,
    Value<TournamentStatus>? status,
    Value<String>? participantsJson,
    Value<String>? roundsJson,
    Value<String?>? championName,
    Value<int?>? seed,
    Value<DateTime?>? createdAt,
    Value<int>? rowid,
  }) {
    return TournamentsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      organizerIdsJson: organizerIdsJson ?? this.organizerIdsJson,
      tier: tier ?? this.tier,
      ageDivision: ageDivision ?? this.ageDivision,
      status: status ?? this.status,
      participantsJson: participantsJson ?? this.participantsJson,
      roundsJson: roundsJson ?? this.roundsJson,
      championName: championName ?? this.championName,
      seed: seed ?? this.seed,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (organizerIdsJson.present) {
      map['organizer_ids_json'] = Variable<String>(organizerIdsJson.value);
    }
    if (tier.present) {
      map['tier'] = Variable<int>(
        $TournamentsTableTable.$convertertier.toSql(tier.value),
      );
    }
    if (ageDivision.present) {
      map['age_division'] = Variable<int>(
        $TournamentsTableTable.$converterageDivision.toSql(ageDivision.value),
      );
    }
    if (status.present) {
      map['status'] = Variable<int>(
        $TournamentsTableTable.$converterstatus.toSql(status.value),
      );
    }
    if (participantsJson.present) {
      map['participants_json'] = Variable<String>(participantsJson.value);
    }
    if (roundsJson.present) {
      map['rounds_json'] = Variable<String>(roundsJson.value);
    }
    if (championName.present) {
      map['champion_name'] = Variable<String>(championName.value);
    }
    if (seed.present) {
      map['seed'] = Variable<int>(seed.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TournamentsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('organizerIdsJson: $organizerIdsJson, ')
          ..write('tier: $tier, ')
          ..write('ageDivision: $ageDivision, ')
          ..write('status: $status, ')
          ..write('participantsJson: $participantsJson, ')
          ..write('roundsJson: $roundsJson, ')
          ..write('championName: $championName, ')
          ..write('seed: $seed, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PartsTable parts = $PartsTable(this);
  late final $CombosTable combos = $CombosTable(this);
  late final $DecksTable decks = $DecksTable(this);
  late final $MatchesTableTable matchesTable = $MatchesTableTable(this);
  late final $TournamentsTableTable tournamentsTable = $TournamentsTableTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    parts,
    combos,
    decks,
    matchesTable,
    tournamentsTable,
  ];
}

typedef $$PartsTableCreateCompanionBuilder =
    PartsCompanion Function({
      required String id,
      required String name,
      required PartType type,
      required BeySystem system,
      Value<int?> attack,
      Value<int?> defense,
      Value<int?> stamina,
      Value<double?> weightG,
      Value<double?> weightMinG,
      Value<double?> weightMaxG,
      Value<String?> weightNote,
      Value<double?> heightMm,
      Value<double?> widthMm,
      Value<BeyType?> beyType,
      Value<SpinDirection?> spinDirection,
      Value<int?> contactPoints,
      Value<int?> heightDmm,
      Value<int?> heightDmmMax,
      Value<String?> weightClass,
      Value<String?> code,
      Value<String?> tipShape,
      Value<int?> gearTeeth,
      Value<int?> shaftWidth,
      Value<String?> productCode,
      Value<String?> hasbroAlias,
      Value<String?> metaTier,
      Value<String?> imageLocal,
      Value<String?> imageRemote,
      Value<int> catalogVersion,
      Value<int> rowid,
    });
typedef $$PartsTableUpdateCompanionBuilder =
    PartsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<PartType> type,
      Value<BeySystem> system,
      Value<int?> attack,
      Value<int?> defense,
      Value<int?> stamina,
      Value<double?> weightG,
      Value<double?> weightMinG,
      Value<double?> weightMaxG,
      Value<String?> weightNote,
      Value<double?> heightMm,
      Value<double?> widthMm,
      Value<BeyType?> beyType,
      Value<SpinDirection?> spinDirection,
      Value<int?> contactPoints,
      Value<int?> heightDmm,
      Value<int?> heightDmmMax,
      Value<String?> weightClass,
      Value<String?> code,
      Value<String?> tipShape,
      Value<int?> gearTeeth,
      Value<int?> shaftWidth,
      Value<String?> productCode,
      Value<String?> hasbroAlias,
      Value<String?> metaTier,
      Value<String?> imageLocal,
      Value<String?> imageRemote,
      Value<int> catalogVersion,
      Value<int> rowid,
    });

class $$PartsTableFilterComposer extends Composer<_$AppDatabase, $PartsTable> {
  $$PartsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PartType, PartType, int> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<BeySystem, BeySystem, int> get system =>
      $composableBuilder(
        column: $table.system,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get attack => $composableBuilder(
    column: $table.attack,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defense => $composableBuilder(
    column: $table.defense,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stamina => $composableBuilder(
    column: $table.stamina,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightG => $composableBuilder(
    column: $table.weightG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightMinG => $composableBuilder(
    column: $table.weightMinG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightMaxG => $composableBuilder(
    column: $table.weightMaxG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weightNote => $composableBuilder(
    column: $table.weightNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heightMm => $composableBuilder(
    column: $table.heightMm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get widthMm => $composableBuilder(
    column: $table.widthMm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<BeyType?, BeyType, int> get beyType =>
      $composableBuilder(
        column: $table.beyType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<SpinDirection?, SpinDirection, int>
  get spinDirection => $composableBuilder(
    column: $table.spinDirection,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get contactPoints => $composableBuilder(
    column: $table.contactPoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get heightDmm => $composableBuilder(
    column: $table.heightDmm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get heightDmmMax => $composableBuilder(
    column: $table.heightDmmMax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weightClass => $composableBuilder(
    column: $table.weightClass,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipShape => $composableBuilder(
    column: $table.tipShape,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gearTeeth => $composableBuilder(
    column: $table.gearTeeth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get shaftWidth => $composableBuilder(
    column: $table.shaftWidth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productCode => $composableBuilder(
    column: $table.productCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hasbroAlias => $composableBuilder(
    column: $table.hasbroAlias,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metaTier => $composableBuilder(
    column: $table.metaTier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageLocal => $composableBuilder(
    column: $table.imageLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageRemote => $composableBuilder(
    column: $table.imageRemote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get catalogVersion => $composableBuilder(
    column: $table.catalogVersion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PartsTableOrderingComposer
    extends Composer<_$AppDatabase, $PartsTable> {
  $$PartsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get system => $composableBuilder(
    column: $table.system,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attack => $composableBuilder(
    column: $table.attack,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defense => $composableBuilder(
    column: $table.defense,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stamina => $composableBuilder(
    column: $table.stamina,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightG => $composableBuilder(
    column: $table.weightG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightMinG => $composableBuilder(
    column: $table.weightMinG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightMaxG => $composableBuilder(
    column: $table.weightMaxG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weightNote => $composableBuilder(
    column: $table.weightNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heightMm => $composableBuilder(
    column: $table.heightMm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get widthMm => $composableBuilder(
    column: $table.widthMm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get beyType => $composableBuilder(
    column: $table.beyType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get spinDirection => $composableBuilder(
    column: $table.spinDirection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get contactPoints => $composableBuilder(
    column: $table.contactPoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get heightDmm => $composableBuilder(
    column: $table.heightDmm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get heightDmmMax => $composableBuilder(
    column: $table.heightDmmMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weightClass => $composableBuilder(
    column: $table.weightClass,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipShape => $composableBuilder(
    column: $table.tipShape,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gearTeeth => $composableBuilder(
    column: $table.gearTeeth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get shaftWidth => $composableBuilder(
    column: $table.shaftWidth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productCode => $composableBuilder(
    column: $table.productCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hasbroAlias => $composableBuilder(
    column: $table.hasbroAlias,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metaTier => $composableBuilder(
    column: $table.metaTier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageLocal => $composableBuilder(
    column: $table.imageLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageRemote => $composableBuilder(
    column: $table.imageRemote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get catalogVersion => $composableBuilder(
    column: $table.catalogVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PartsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PartsTable> {
  $$PartsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PartType, int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumnWithTypeConverter<BeySystem, int> get system =>
      $composableBuilder(column: $table.system, builder: (column) => column);

  GeneratedColumn<int> get attack =>
      $composableBuilder(column: $table.attack, builder: (column) => column);

  GeneratedColumn<int> get defense =>
      $composableBuilder(column: $table.defense, builder: (column) => column);

  GeneratedColumn<int> get stamina =>
      $composableBuilder(column: $table.stamina, builder: (column) => column);

  GeneratedColumn<double> get weightG =>
      $composableBuilder(column: $table.weightG, builder: (column) => column);

  GeneratedColumn<double> get weightMinG => $composableBuilder(
    column: $table.weightMinG,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weightMaxG => $composableBuilder(
    column: $table.weightMaxG,
    builder: (column) => column,
  );

  GeneratedColumn<String> get weightNote => $composableBuilder(
    column: $table.weightNote,
    builder: (column) => column,
  );

  GeneratedColumn<double> get heightMm =>
      $composableBuilder(column: $table.heightMm, builder: (column) => column);

  GeneratedColumn<double> get widthMm =>
      $composableBuilder(column: $table.widthMm, builder: (column) => column);

  GeneratedColumnWithTypeConverter<BeyType?, int> get beyType =>
      $composableBuilder(column: $table.beyType, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SpinDirection?, int> get spinDirection =>
      $composableBuilder(
        column: $table.spinDirection,
        builder: (column) => column,
      );

  GeneratedColumn<int> get contactPoints => $composableBuilder(
    column: $table.contactPoints,
    builder: (column) => column,
  );

  GeneratedColumn<int> get heightDmm =>
      $composableBuilder(column: $table.heightDmm, builder: (column) => column);

  GeneratedColumn<int> get heightDmmMax => $composableBuilder(
    column: $table.heightDmmMax,
    builder: (column) => column,
  );

  GeneratedColumn<String> get weightClass => $composableBuilder(
    column: $table.weightClass,
    builder: (column) => column,
  );

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get tipShape =>
      $composableBuilder(column: $table.tipShape, builder: (column) => column);

  GeneratedColumn<int> get gearTeeth =>
      $composableBuilder(column: $table.gearTeeth, builder: (column) => column);

  GeneratedColumn<int> get shaftWidth => $composableBuilder(
    column: $table.shaftWidth,
    builder: (column) => column,
  );

  GeneratedColumn<String> get productCode => $composableBuilder(
    column: $table.productCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hasbroAlias => $composableBuilder(
    column: $table.hasbroAlias,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metaTier =>
      $composableBuilder(column: $table.metaTier, builder: (column) => column);

  GeneratedColumn<String> get imageLocal => $composableBuilder(
    column: $table.imageLocal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageRemote => $composableBuilder(
    column: $table.imageRemote,
    builder: (column) => column,
  );

  GeneratedColumn<int> get catalogVersion => $composableBuilder(
    column: $table.catalogVersion,
    builder: (column) => column,
  );
}

class $$PartsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PartsTable,
          PartRow,
          $$PartsTableFilterComposer,
          $$PartsTableOrderingComposer,
          $$PartsTableAnnotationComposer,
          $$PartsTableCreateCompanionBuilder,
          $$PartsTableUpdateCompanionBuilder,
          (PartRow, BaseReferences<_$AppDatabase, $PartsTable, PartRow>),
          PartRow,
          PrefetchHooks Function()
        > {
  $$PartsTableTableManager(_$AppDatabase db, $PartsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PartsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PartsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PartsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<PartType> type = const Value.absent(),
                Value<BeySystem> system = const Value.absent(),
                Value<int?> attack = const Value.absent(),
                Value<int?> defense = const Value.absent(),
                Value<int?> stamina = const Value.absent(),
                Value<double?> weightG = const Value.absent(),
                Value<double?> weightMinG = const Value.absent(),
                Value<double?> weightMaxG = const Value.absent(),
                Value<String?> weightNote = const Value.absent(),
                Value<double?> heightMm = const Value.absent(),
                Value<double?> widthMm = const Value.absent(),
                Value<BeyType?> beyType = const Value.absent(),
                Value<SpinDirection?> spinDirection = const Value.absent(),
                Value<int?> contactPoints = const Value.absent(),
                Value<int?> heightDmm = const Value.absent(),
                Value<int?> heightDmmMax = const Value.absent(),
                Value<String?> weightClass = const Value.absent(),
                Value<String?> code = const Value.absent(),
                Value<String?> tipShape = const Value.absent(),
                Value<int?> gearTeeth = const Value.absent(),
                Value<int?> shaftWidth = const Value.absent(),
                Value<String?> productCode = const Value.absent(),
                Value<String?> hasbroAlias = const Value.absent(),
                Value<String?> metaTier = const Value.absent(),
                Value<String?> imageLocal = const Value.absent(),
                Value<String?> imageRemote = const Value.absent(),
                Value<int> catalogVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PartsCompanion(
                id: id,
                name: name,
                type: type,
                system: system,
                attack: attack,
                defense: defense,
                stamina: stamina,
                weightG: weightG,
                weightMinG: weightMinG,
                weightMaxG: weightMaxG,
                weightNote: weightNote,
                heightMm: heightMm,
                widthMm: widthMm,
                beyType: beyType,
                spinDirection: spinDirection,
                contactPoints: contactPoints,
                heightDmm: heightDmm,
                heightDmmMax: heightDmmMax,
                weightClass: weightClass,
                code: code,
                tipShape: tipShape,
                gearTeeth: gearTeeth,
                shaftWidth: shaftWidth,
                productCode: productCode,
                hasbroAlias: hasbroAlias,
                metaTier: metaTier,
                imageLocal: imageLocal,
                imageRemote: imageRemote,
                catalogVersion: catalogVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required PartType type,
                required BeySystem system,
                Value<int?> attack = const Value.absent(),
                Value<int?> defense = const Value.absent(),
                Value<int?> stamina = const Value.absent(),
                Value<double?> weightG = const Value.absent(),
                Value<double?> weightMinG = const Value.absent(),
                Value<double?> weightMaxG = const Value.absent(),
                Value<String?> weightNote = const Value.absent(),
                Value<double?> heightMm = const Value.absent(),
                Value<double?> widthMm = const Value.absent(),
                Value<BeyType?> beyType = const Value.absent(),
                Value<SpinDirection?> spinDirection = const Value.absent(),
                Value<int?> contactPoints = const Value.absent(),
                Value<int?> heightDmm = const Value.absent(),
                Value<int?> heightDmmMax = const Value.absent(),
                Value<String?> weightClass = const Value.absent(),
                Value<String?> code = const Value.absent(),
                Value<String?> tipShape = const Value.absent(),
                Value<int?> gearTeeth = const Value.absent(),
                Value<int?> shaftWidth = const Value.absent(),
                Value<String?> productCode = const Value.absent(),
                Value<String?> hasbroAlias = const Value.absent(),
                Value<String?> metaTier = const Value.absent(),
                Value<String?> imageLocal = const Value.absent(),
                Value<String?> imageRemote = const Value.absent(),
                Value<int> catalogVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PartsCompanion.insert(
                id: id,
                name: name,
                type: type,
                system: system,
                attack: attack,
                defense: defense,
                stamina: stamina,
                weightG: weightG,
                weightMinG: weightMinG,
                weightMaxG: weightMaxG,
                weightNote: weightNote,
                heightMm: heightMm,
                widthMm: widthMm,
                beyType: beyType,
                spinDirection: spinDirection,
                contactPoints: contactPoints,
                heightDmm: heightDmm,
                heightDmmMax: heightDmmMax,
                weightClass: weightClass,
                code: code,
                tipShape: tipShape,
                gearTeeth: gearTeeth,
                shaftWidth: shaftWidth,
                productCode: productCode,
                hasbroAlias: hasbroAlias,
                metaTier: metaTier,
                imageLocal: imageLocal,
                imageRemote: imageRemote,
                catalogVersion: catalogVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PartsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PartsTable,
      PartRow,
      $$PartsTableFilterComposer,
      $$PartsTableOrderingComposer,
      $$PartsTableAnnotationComposer,
      $$PartsTableCreateCompanionBuilder,
      $$PartsTableUpdateCompanionBuilder,
      (PartRow, BaseReferences<_$AppDatabase, $PartsTable, PartRow>),
      PartRow,
      PrefetchHooks Function()
    >;
typedef $$CombosTableCreateCompanionBuilder =
    CombosCompanion Function({
      required String id,
      required String name,
      required String bladeId,
      required String ratchetId,
      required String bitId,
      Value<String?> lockChipId,
      Value<String?> assistBladeId,
      Value<BeySystem> system,
      Value<double?> calculatedWeight,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$CombosTableUpdateCompanionBuilder =
    CombosCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> bladeId,
      Value<String> ratchetId,
      Value<String> bitId,
      Value<String?> lockChipId,
      Value<String?> assistBladeId,
      Value<BeySystem> system,
      Value<double?> calculatedWeight,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

class $$CombosTableFilterComposer
    extends Composer<_$AppDatabase, $CombosTable> {
  $$CombosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bladeId => $composableBuilder(
    column: $table.bladeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ratchetId => $composableBuilder(
    column: $table.ratchetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bitId => $composableBuilder(
    column: $table.bitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lockChipId => $composableBuilder(
    column: $table.lockChipId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assistBladeId => $composableBuilder(
    column: $table.assistBladeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<BeySystem, BeySystem, int> get system =>
      $composableBuilder(
        column: $table.system,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get calculatedWeight => $composableBuilder(
    column: $table.calculatedWeight,
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

class $$CombosTableOrderingComposer
    extends Composer<_$AppDatabase, $CombosTable> {
  $$CombosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bladeId => $composableBuilder(
    column: $table.bladeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ratchetId => $composableBuilder(
    column: $table.ratchetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bitId => $composableBuilder(
    column: $table.bitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lockChipId => $composableBuilder(
    column: $table.lockChipId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assistBladeId => $composableBuilder(
    column: $table.assistBladeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get system => $composableBuilder(
    column: $table.system,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get calculatedWeight => $composableBuilder(
    column: $table.calculatedWeight,
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

class $$CombosTableAnnotationComposer
    extends Composer<_$AppDatabase, $CombosTable> {
  $$CombosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get bladeId =>
      $composableBuilder(column: $table.bladeId, builder: (column) => column);

  GeneratedColumn<String> get ratchetId =>
      $composableBuilder(column: $table.ratchetId, builder: (column) => column);

  GeneratedColumn<String> get bitId =>
      $composableBuilder(column: $table.bitId, builder: (column) => column);

  GeneratedColumn<String> get lockChipId => $composableBuilder(
    column: $table.lockChipId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get assistBladeId => $composableBuilder(
    column: $table.assistBladeId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<BeySystem, int> get system =>
      $composableBuilder(column: $table.system, builder: (column) => column);

  GeneratedColumn<double> get calculatedWeight => $composableBuilder(
    column: $table.calculatedWeight,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CombosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CombosTable,
          ComboRow,
          $$CombosTableFilterComposer,
          $$CombosTableOrderingComposer,
          $$CombosTableAnnotationComposer,
          $$CombosTableCreateCompanionBuilder,
          $$CombosTableUpdateCompanionBuilder,
          (ComboRow, BaseReferences<_$AppDatabase, $CombosTable, ComboRow>),
          ComboRow,
          PrefetchHooks Function()
        > {
  $$CombosTableTableManager(_$AppDatabase db, $CombosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CombosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CombosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CombosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> bladeId = const Value.absent(),
                Value<String> ratchetId = const Value.absent(),
                Value<String> bitId = const Value.absent(),
                Value<String?> lockChipId = const Value.absent(),
                Value<String?> assistBladeId = const Value.absent(),
                Value<BeySystem> system = const Value.absent(),
                Value<double?> calculatedWeight = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CombosCompanion(
                id: id,
                name: name,
                bladeId: bladeId,
                ratchetId: ratchetId,
                bitId: bitId,
                lockChipId: lockChipId,
                assistBladeId: assistBladeId,
                system: system,
                calculatedWeight: calculatedWeight,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String bladeId,
                required String ratchetId,
                required String bitId,
                Value<String?> lockChipId = const Value.absent(),
                Value<String?> assistBladeId = const Value.absent(),
                Value<BeySystem> system = const Value.absent(),
                Value<double?> calculatedWeight = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CombosCompanion.insert(
                id: id,
                name: name,
                bladeId: bladeId,
                ratchetId: ratchetId,
                bitId: bitId,
                lockChipId: lockChipId,
                assistBladeId: assistBladeId,
                system: system,
                calculatedWeight: calculatedWeight,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CombosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CombosTable,
      ComboRow,
      $$CombosTableFilterComposer,
      $$CombosTableOrderingComposer,
      $$CombosTableAnnotationComposer,
      $$CombosTableCreateCompanionBuilder,
      $$CombosTableUpdateCompanionBuilder,
      (ComboRow, BaseReferences<_$AppDatabase, $CombosTable, ComboRow>),
      ComboRow,
      PrefetchHooks Function()
    >;
typedef $$DecksTableCreateCompanionBuilder =
    DecksCompanion Function({
      required String id,
      required String name,
      required String comboIdsJson,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$DecksTableUpdateCompanionBuilder =
    DecksCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> comboIdsJson,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

class $$DecksTableFilterComposer extends Composer<_$AppDatabase, $DecksTable> {
  $$DecksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get comboIdsJson => $composableBuilder(
    column: $table.comboIdsJson,
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

class $$DecksTableOrderingComposer
    extends Composer<_$AppDatabase, $DecksTable> {
  $$DecksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comboIdsJson => $composableBuilder(
    column: $table.comboIdsJson,
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

class $$DecksTableAnnotationComposer
    extends Composer<_$AppDatabase, $DecksTable> {
  $$DecksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get comboIdsJson => $composableBuilder(
    column: $table.comboIdsJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DecksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DecksTable,
          DeckRow,
          $$DecksTableFilterComposer,
          $$DecksTableOrderingComposer,
          $$DecksTableAnnotationComposer,
          $$DecksTableCreateCompanionBuilder,
          $$DecksTableUpdateCompanionBuilder,
          (DeckRow, BaseReferences<_$AppDatabase, $DecksTable, DeckRow>),
          DeckRow,
          PrefetchHooks Function()
        > {
  $$DecksTableTableManager(_$AppDatabase db, $DecksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DecksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DecksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DecksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> comboIdsJson = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DecksCompanion(
                id: id,
                name: name,
                comboIdsJson: comboIdsJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String comboIdsJson,
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DecksCompanion.insert(
                id: id,
                name: name,
                comboIdsJson: comboIdsJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DecksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DecksTable,
      DeckRow,
      $$DecksTableFilterComposer,
      $$DecksTableOrderingComposer,
      $$DecksTableAnnotationComposer,
      $$DecksTableCreateCompanionBuilder,
      $$DecksTableUpdateCompanionBuilder,
      (DeckRow, BaseReferences<_$AppDatabase, $DecksTable, DeckRow>),
      DeckRow,
      PrefetchHooks Function()
    >;
typedef $$MatchesTableTableCreateCompanionBuilder =
    MatchesTableCompanion Function({
      required String id,
      required String playerAId,
      required String playerBId,
      Value<String?> tournamentId,
      Value<int> targetPoints,
      Value<MatchFormat> format,
      Value<MatchStatus> status,
      Value<String> finishesJson,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$MatchesTableTableUpdateCompanionBuilder =
    MatchesTableCompanion Function({
      Value<String> id,
      Value<String> playerAId,
      Value<String> playerBId,
      Value<String?> tournamentId,
      Value<int> targetPoints,
      Value<MatchFormat> format,
      Value<MatchStatus> status,
      Value<String> finishesJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$MatchesTableTableFilterComposer
    extends Composer<_$AppDatabase, $MatchesTableTable> {
  $$MatchesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get playerAId => $composableBuilder(
    column: $table.playerAId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get playerBId => $composableBuilder(
    column: $table.playerBId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tournamentId => $composableBuilder(
    column: $table.tournamentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetPoints => $composableBuilder(
    column: $table.targetPoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MatchFormat, MatchFormat, int> get format =>
      $composableBuilder(
        column: $table.format,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<MatchStatus, MatchStatus, int> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get finishesJson => $composableBuilder(
    column: $table.finishesJson,
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

class $$MatchesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MatchesTableTable> {
  $$MatchesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get playerAId => $composableBuilder(
    column: $table.playerAId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get playerBId => $composableBuilder(
    column: $table.playerBId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tournamentId => $composableBuilder(
    column: $table.tournamentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetPoints => $composableBuilder(
    column: $table.targetPoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get finishesJson => $composableBuilder(
    column: $table.finishesJson,
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

class $$MatchesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MatchesTableTable> {
  $$MatchesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get playerAId =>
      $composableBuilder(column: $table.playerAId, builder: (column) => column);

  GeneratedColumn<String> get playerBId =>
      $composableBuilder(column: $table.playerBId, builder: (column) => column);

  GeneratedColumn<String> get tournamentId => $composableBuilder(
    column: $table.tournamentId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetPoints => $composableBuilder(
    column: $table.targetPoints,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<MatchFormat, int> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MatchStatus, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get finishesJson => $composableBuilder(
    column: $table.finishesJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MatchesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MatchesTableTable,
          MatchRow,
          $$MatchesTableTableFilterComposer,
          $$MatchesTableTableOrderingComposer,
          $$MatchesTableTableAnnotationComposer,
          $$MatchesTableTableCreateCompanionBuilder,
          $$MatchesTableTableUpdateCompanionBuilder,
          (
            MatchRow,
            BaseReferences<_$AppDatabase, $MatchesTableTable, MatchRow>,
          ),
          MatchRow,
          PrefetchHooks Function()
        > {
  $$MatchesTableTableTableManager(_$AppDatabase db, $MatchesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MatchesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MatchesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MatchesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> playerAId = const Value.absent(),
                Value<String> playerBId = const Value.absent(),
                Value<String?> tournamentId = const Value.absent(),
                Value<int> targetPoints = const Value.absent(),
                Value<MatchFormat> format = const Value.absent(),
                Value<MatchStatus> status = const Value.absent(),
                Value<String> finishesJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MatchesTableCompanion(
                id: id,
                playerAId: playerAId,
                playerBId: playerBId,
                tournamentId: tournamentId,
                targetPoints: targetPoints,
                format: format,
                status: status,
                finishesJson: finishesJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String playerAId,
                required String playerBId,
                Value<String?> tournamentId = const Value.absent(),
                Value<int> targetPoints = const Value.absent(),
                Value<MatchFormat> format = const Value.absent(),
                Value<MatchStatus> status = const Value.absent(),
                Value<String> finishesJson = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => MatchesTableCompanion.insert(
                id: id,
                playerAId: playerAId,
                playerBId: playerBId,
                tournamentId: tournamentId,
                targetPoints: targetPoints,
                format: format,
                status: status,
                finishesJson: finishesJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MatchesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MatchesTableTable,
      MatchRow,
      $$MatchesTableTableFilterComposer,
      $$MatchesTableTableOrderingComposer,
      $$MatchesTableTableAnnotationComposer,
      $$MatchesTableTableCreateCompanionBuilder,
      $$MatchesTableTableUpdateCompanionBuilder,
      (MatchRow, BaseReferences<_$AppDatabase, $MatchesTableTable, MatchRow>),
      MatchRow,
      PrefetchHooks Function()
    >;
typedef $$TournamentsTableTableCreateCompanionBuilder =
    TournamentsTableCompanion Function({
      required String id,
      required String name,
      Value<String> organizerIdsJson,
      Value<TournamentTier> tier,
      Value<AgeDivision> ageDivision,
      Value<TournamentStatus> status,
      Value<String> participantsJson,
      Value<String> roundsJson,
      Value<String?> championName,
      Value<int?> seed,
      Value<DateTime?> createdAt,
      Value<int> rowid,
    });
typedef $$TournamentsTableTableUpdateCompanionBuilder =
    TournamentsTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> organizerIdsJson,
      Value<TournamentTier> tier,
      Value<AgeDivision> ageDivision,
      Value<TournamentStatus> status,
      Value<String> participantsJson,
      Value<String> roundsJson,
      Value<String?> championName,
      Value<int?> seed,
      Value<DateTime?> createdAt,
      Value<int> rowid,
    });

class $$TournamentsTableTableFilterComposer
    extends Composer<_$AppDatabase, $TournamentsTableTable> {
  $$TournamentsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get organizerIdsJson => $composableBuilder(
    column: $table.organizerIdsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TournamentTier, TournamentTier, int>
  get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<AgeDivision, AgeDivision, int>
  get ageDivision => $composableBuilder(
    column: $table.ageDivision,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<TournamentStatus, TournamentStatus, int>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get participantsJson => $composableBuilder(
    column: $table.participantsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roundsJson => $composableBuilder(
    column: $table.roundsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get championName => $composableBuilder(
    column: $table.championName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seed => $composableBuilder(
    column: $table.seed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TournamentsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TournamentsTableTable> {
  $$TournamentsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get organizerIdsJson => $composableBuilder(
    column: $table.organizerIdsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ageDivision => $composableBuilder(
    column: $table.ageDivision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get participantsJson => $composableBuilder(
    column: $table.participantsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roundsJson => $composableBuilder(
    column: $table.roundsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get championName => $composableBuilder(
    column: $table.championName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seed => $composableBuilder(
    column: $table.seed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TournamentsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TournamentsTableTable> {
  $$TournamentsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get organizerIdsJson => $composableBuilder(
    column: $table.organizerIdsJson,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<TournamentTier, int> get tier =>
      $composableBuilder(column: $table.tier, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AgeDivision, int> get ageDivision =>
      $composableBuilder(
        column: $table.ageDivision,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<TournamentStatus, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get participantsJson => $composableBuilder(
    column: $table.participantsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get roundsJson => $composableBuilder(
    column: $table.roundsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get championName => $composableBuilder(
    column: $table.championName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get seed =>
      $composableBuilder(column: $table.seed, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TournamentsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TournamentsTableTable,
          TournamentRow,
          $$TournamentsTableTableFilterComposer,
          $$TournamentsTableTableOrderingComposer,
          $$TournamentsTableTableAnnotationComposer,
          $$TournamentsTableTableCreateCompanionBuilder,
          $$TournamentsTableTableUpdateCompanionBuilder,
          (
            TournamentRow,
            BaseReferences<
              _$AppDatabase,
              $TournamentsTableTable,
              TournamentRow
            >,
          ),
          TournamentRow,
          PrefetchHooks Function()
        > {
  $$TournamentsTableTableTableManager(
    _$AppDatabase db,
    $TournamentsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TournamentsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TournamentsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TournamentsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> organizerIdsJson = const Value.absent(),
                Value<TournamentTier> tier = const Value.absent(),
                Value<AgeDivision> ageDivision = const Value.absent(),
                Value<TournamentStatus> status = const Value.absent(),
                Value<String> participantsJson = const Value.absent(),
                Value<String> roundsJson = const Value.absent(),
                Value<String?> championName = const Value.absent(),
                Value<int?> seed = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TournamentsTableCompanion(
                id: id,
                name: name,
                organizerIdsJson: organizerIdsJson,
                tier: tier,
                ageDivision: ageDivision,
                status: status,
                participantsJson: participantsJson,
                roundsJson: roundsJson,
                championName: championName,
                seed: seed,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> organizerIdsJson = const Value.absent(),
                Value<TournamentTier> tier = const Value.absent(),
                Value<AgeDivision> ageDivision = const Value.absent(),
                Value<TournamentStatus> status = const Value.absent(),
                Value<String> participantsJson = const Value.absent(),
                Value<String> roundsJson = const Value.absent(),
                Value<String?> championName = const Value.absent(),
                Value<int?> seed = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TournamentsTableCompanion.insert(
                id: id,
                name: name,
                organizerIdsJson: organizerIdsJson,
                tier: tier,
                ageDivision: ageDivision,
                status: status,
                participantsJson: participantsJson,
                roundsJson: roundsJson,
                championName: championName,
                seed: seed,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TournamentsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TournamentsTableTable,
      TournamentRow,
      $$TournamentsTableTableFilterComposer,
      $$TournamentsTableTableOrderingComposer,
      $$TournamentsTableTableAnnotationComposer,
      $$TournamentsTableTableCreateCompanionBuilder,
      $$TournamentsTableTableUpdateCompanionBuilder,
      (
        TournamentRow,
        BaseReferences<_$AppDatabase, $TournamentsTableTable, TournamentRow>,
      ),
      TournamentRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PartsTableTableManager get parts =>
      $$PartsTableTableManager(_db, _db.parts);
  $$CombosTableTableManager get combos =>
      $$CombosTableTableManager(_db, _db.combos);
  $$DecksTableTableManager get decks =>
      $$DecksTableTableManager(_db, _db.decks);
  $$MatchesTableTableTableManager get matchesTable =>
      $$MatchesTableTableTableManager(_db, _db.matchesTable);
  $$TournamentsTableTableTableManager get tournamentsTable =>
      $$TournamentsTableTableTableManager(_db, _db.tournamentsTable);
}
