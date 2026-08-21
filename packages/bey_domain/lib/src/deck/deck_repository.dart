import 'deck.dart';

abstract class DeckRepository {
  Stream<List<Deck>> watchAll();
  Future<void> save(Deck deck);
  Future<void> delete(String id);
}
