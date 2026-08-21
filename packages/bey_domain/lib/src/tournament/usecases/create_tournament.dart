import 'package:fpdart/fpdart.dart';

import '../../id/uuid_v7_generator.dart';
import '../../typedef/result.dart';
import '../../usecase/use_case.dart';
import '../bracket.dart';
import '../tournament.dart';
import '../tournament_repository.dart';

class CreateTournamentParams {
  const CreateTournamentParams({
    required this.name,
    required this.organizerId,
    required this.tier,
    required this.ageDivision,
    this.status = TournamentStatus.draft,
    this.participants = const [],
    this.rounds = const [],
    this.seed,
  });

  final String name;
  final String organizerId;
  final TournamentTier tier;
  final AgeDivision ageDivision;
  final TournamentStatus status;
  final List<String> participants;
  final List<BracketRound> rounds;
  final int? seed;
}

class CreateTournament extends UseCase<Tournament, CreateTournamentParams> {
  const CreateTournament({
    required this.repository,
    this.uuidGenerator = const UuidV7Generator(),
  });

  final TournamentRepository repository;
  final UuidV7Generator uuidGenerator;

  @override
  AsyncResult<Tournament> call(CreateTournamentParams params) async {
    final tournament = Tournament(
      id: uuidGenerator.generate(),
      name: params.name,
      organizerIds: [params.organizerId],
      tier: params.tier,
      ageDivision: params.ageDivision,
      status: params.status,
      participants: List.unmodifiable(params.participants),
      rounds: params.rounds,
      seed: params.seed,
      createdAt: DateTime.now(),
    );

    await repository.save(tournament);
    return right(tournament);
  }
}
