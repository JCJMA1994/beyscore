import 'combo.dart';

/// Abstract combo repository. No use cases for this feature.
abstract class ComboRepository {
  Stream<List<Combo>> watchAll();
  Future<void> save(Combo combo);
  Future<void> delete(String id);
}
