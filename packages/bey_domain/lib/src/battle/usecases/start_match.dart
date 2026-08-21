import 'package:fpdart/fpdart.dart';

import '../../id/uuid_v7_generator.dart';
import '../../typedef/result.dart';
import '../../usecase/use_case.dart';
import '../battle_repository.dart';
import '../match.dart';
import '../match_rules.dart';

class StartMatchParams {
  const StartMatchParams({
    required this.playerAId,
    required this.playerBId,
    this.tournamentId,
    this.format = MatchFormat.singles,
    this.rules = const MatchRules(),
  });

  final String playerAId;
  final String playerBId;
  final String? tournamentId;
  final MatchFormat format;
  final MatchRules rules;
}

class StartMatch extends UseCase<Match, StartMatchParams> {
  const StartMatch({
    required this.repository,
    this.uuidGenerator = const UuidV7Generator(),
  });

  final BattleRepository repository;
  final UuidV7Generator uuidGenerator;

  @override
  AsyncResult<Match> call(StartMatchParams params) async {
    final match = Match(
      id: uuidGenerator.generate(),
      playerAId: params.playerAId,
      playerBId: params.playerBId,
      tournamentId: params.tournamentId,
      format: params.format,
      rules: params.rules,
      status: MatchStatus.inProgress,
      createdAt: DateTime.now(),
    );

    await repository.saveMatch(match);
    return right(match);
  }
}
