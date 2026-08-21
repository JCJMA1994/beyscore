import 'package:fpdart/fpdart.dart';

import '../../error/failure.dart';
import '../../typedef/result.dart';
import '../../usecase/use_case.dart';
import '../battle_repository.dart';
import '../match.dart';

/// Stream use case: watch a match in real-time via Drift streams.
class WatchMatch extends StreamUseCase<Match, String> {
  const WatchMatch({required this.repository});
  final BattleRepository repository;

  @override
  ResultStream<Match> call(String matchId) {
    // Drift watches the match table and emits updates.
    // The API response never goes to the UI directly — it lands in Drift
    // and Drift notifies by stream. One data path, one place to debug.
    return repository
        .watchMatch(matchId)
        .map((match) => right<Failure, Match>(match));
  }
}
