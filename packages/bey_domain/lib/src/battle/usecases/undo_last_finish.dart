import 'package:fpdart/fpdart.dart';

import '../../error/failure.dart';
import '../../id/uuid_v7_generator.dart';
import '../../typedef/result.dart';
import '../../usecase/use_case.dart';
import '../battle_finish.dart';
import '../battle_repository.dart';
import '../match.dart';

class UndoLastFinish extends UseCase<Match, String> {
  const UndoLastFinish({
    required this.repository,
    this.uuidGenerator = const UuidV7Generator(),
  });

  final BattleRepository repository;
  final UuidV7Generator uuidGenerator;

  @override
  AsyncResult<Match> call(String matchId) async {
    final match = await repository.getMatch(matchId);
    if (match == null) {
      return const Left(ValidationFailure(message: 'Match not found'));
    }

    if (match.finishes.isEmpty) {
      return right(match);
    }

    // Find the last non-void finish
    final voidedIds = match.finishes
        .where((f) => f.voidedTargetId != null)
        .map((f) => f.voidedTargetId!)
        .toSet();

    final activeFinishes = match.finishes
        .where((f) => !f.isVoid && !voidedIds.contains(f.id))
        .toList();

    if (activeFinishes.isEmpty) {
      return right(match);
    }

    final target = activeFinishes.last;

    // Undo is a NEW Finish entry referencing target ID (append-only bitácora)
    final voidFinish = BattleFinish(
      id: uuidGenerator.generate(),
      matchId: match.id,
      roundIndex: target.roundIndex,
      sequence: match.finishes.length + 1,
      type: target.type,
      scoringPlayerId: target.scoringPlayerId,
      createdAt: DateTime.now(),
      voidedTargetId: target.id,
    );

    final updated = match.copyWith(
      status: MatchStatus.inProgress,
      finishes: [...match.finishes, voidFinish],
    );

    await repository.saveMatch(updated);
    return right(updated);
  }
}
