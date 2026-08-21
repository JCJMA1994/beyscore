import 'tier_entry.dart';

abstract class MetaRepository {
  Stream<List<TierEntry>> watchTierList();
}
