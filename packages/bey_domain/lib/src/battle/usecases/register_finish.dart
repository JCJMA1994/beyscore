import '../../typedef/result.dart';
import '../../usecase/use_case.dart';
import '../battle_finish.dart';
import '../battle_repository.dart';
import '../match.dart';
import '../scoring_service.dart';

class RegisterFinishParams {
  const RegisterFinishParams({
    required this.matchId,
    required this.finish,
  });

  final String matchId;
  final BattleFinish finish;
}

class RegisterFinish extends UseCase<Match, RegisterFinishParams> {
  const RegisterFinish({
    required this.repository,
    required this.scoringService,
  });

  final BattleRepository repository;
  final ScoringService scoringService;

  @override
  AsyncResult<Match> call(RegisterFinishParams params) async {
    final match = await repository.getMatch(params.matchId);
    if (match == null) {
      throw StateError('Match not found: ${params.matchId}');
    }

    final result = scoringService.applyFinish(match, params.finish);

    return result.map((updated) {
      repository.saveMatch(updated);
      return updated;
    });
  }
}
