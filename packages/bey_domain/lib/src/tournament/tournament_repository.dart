import 'tournament.dart';

abstract class TournamentRepository {
  Stream<List<Tournament>> watchAll();
  Future<void> save(Tournament tournament);
  Future<void> delete(String id);
  Stream<Tournament> watchById(String id);
}
