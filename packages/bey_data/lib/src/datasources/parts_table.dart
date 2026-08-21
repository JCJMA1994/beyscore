import 'package:bey_domain/bey_domain.dart';
import 'package:drift/drift.dart';

@DataClassName('PartRow')
class Parts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get type => intEnum<PartType>()();
  IntColumn get system => intEnum<BeySystem>()();

  // stats — nullable on purpose
  IntColumn get attack => integer().nullable()();
  IntColumn get defense => integer().nullable()();
  IntColumn get stamina => integer().nullable()();
  RealColumn get weightG => real().nullable()();
  RealColumn get weightMinG => real().nullable()();
  RealColumn get weightMaxG => real().nullable()();
  TextColumn get weightNote => text().nullable()();
  RealColumn get heightMm => real().nullable()();
  RealColumn get widthMm => real().nullable()();

  IntColumn get beyType => intEnum<BeyType>().nullable()();
  IntColumn get spinDirection => intEnum<SpinDirection>().nullable()();

  IntColumn get contactPoints => integer().nullable()();
  IntColumn get heightDmm => integer().nullable()();
  IntColumn get heightDmmMax => integer().nullable()();
  TextColumn get weightClass => text().nullable()();

  TextColumn get code => text().nullable()();
  TextColumn get tipShape => text().nullable()();
  IntColumn get gearTeeth => integer().nullable()();
  IntColumn get shaftWidth => integer().nullable()();

  TextColumn get productCode => text().nullable()();
  TextColumn get hasbroAlias => text().nullable()();
  TextColumn get metaTier => text().nullable()();

  TextColumn get imageLocal => text().nullable()();
  TextColumn get imageRemote => text().nullable()();

  IntColumn get catalogVersion =>
      integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}
