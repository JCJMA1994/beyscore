import 'player.dart';

abstract class ProfileRepository {
  Future<Player?> getCurrent();
  Future<void> save(Player player);
}
