import 'package:fpdart/fpdart.dart';

import '../../typedef/result.dart';
import '../../usecase/use_case.dart';
import '../bracket.dart';
import '../bracket_generator.dart';

class GenerateBracketParams {
  const GenerateBracketParams({
    required this.tournamentId,
    required this.playerNames,
    required this.seed,
    this.method = BracketMethod.random,
  });

  final String tournamentId;
  final List<String> playerNames;
  final int seed;
  final BracketMethod method;
}

class GenerateBracket
    extends UseCase<List<BracketRound>, GenerateBracketParams> {
  const GenerateBracket({required this.bracketGenerator});
  final BracketGenerator bracketGenerator;

  @override
  AsyncResult<List<BracketRound>> call(GenerateBracketParams params) async {
    final rounds = bracketGenerator.generateBracketTree(
      playerNames: params.playerNames,
      seed: params.seed,
      method: params.method,
    );

    return right(rounds);
  }
}
