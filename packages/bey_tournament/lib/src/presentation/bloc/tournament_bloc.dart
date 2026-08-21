import 'package:bey_domain/bey_domain.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class TournamentEvent extends Equatable {
  const TournamentEvent();
  @override
  List<Object?> get props => [];
}

final class TournamentStarted extends TournamentEvent {}

final class TournamentCreated extends TournamentEvent {
  const TournamentCreated(this.tournament);
  final Tournament tournament;
  @override
  List<Object?> get props => [tournament.id];
}

final class TournamentMatchStarted extends TournamentEvent {
  const TournamentMatchStarted({
    required this.tournamentId,
    required this.roundIndex,
    required this.matchupIndex,
    this.tableNumber,
  });

  final String tournamentId;
  final int roundIndex;
  final int matchupIndex;
  final int? tableNumber;

  @override
  List<Object?> get props => [tournamentId, roundIndex, matchupIndex, tableNumber];
}

final class TournamentMatchWalkoverDeclared extends TournamentEvent {
  const TournamentMatchWalkoverDeclared({
    required this.tournamentId,
    required this.roundIndex,
    required this.matchupIndex,
    required this.winnerName,
  });

  final String tournamentId;
  final int roundIndex;
  final int matchupIndex;
  final String winnerName;

  @override
  List<Object?> get props => [tournamentId, roundIndex, matchupIndex, winnerName];
}

final class TournamentMatchReported extends TournamentEvent {
  const TournamentMatchReported({
    required this.tournamentId,
    required this.roundIndex,
    required this.matchupIndex,
    required this.winnerName,
    this.scoreA = 0,
    this.scoreB = 0,
  });

  final String tournamentId;
  final int roundIndex;
  final int matchupIndex;
  final String winnerName;
  final int scoreA;
  final int scoreB;

  @override
  List<Object?> get props => [tournamentId, roundIndex, matchupIndex, winnerName];
}

final class TournamentDeleted extends TournamentEvent {
  const TournamentDeleted(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

sealed class TournamentState extends Equatable {
  const TournamentState();
  @override
  List<Object?> get props => [];
}

final class TournamentLoading extends TournamentState {}

final class TournamentLoaded extends TournamentState {
  const TournamentLoaded({required this.tournaments});
  final List<Tournament> tournaments;

  @override
  List<Object?> get props => [tournaments];
}

class TournamentBloc extends Bloc<TournamentEvent, TournamentState> {
  TournamentBloc({
    required TournamentRepository repository,
    BracketGenerator bracketGenerator = const BracketGenerator(),
  })  : _repository = repository,
        _bracketGenerator = bracketGenerator,
        super(TournamentLoading()) {
    on<TournamentStarted>(_onStarted);
    on<TournamentCreated>(_onCreated);
    on<TournamentMatchStarted>(_onMatchStarted);
    on<TournamentMatchWalkoverDeclared>(_onMatchWalkover);
    on<TournamentMatchReported>(_onMatchReported);
    on<TournamentDeleted>(_onDeleted);
  }

  final TournamentRepository _repository;
  final BracketGenerator _bracketGenerator;

  Future<void> _onStarted(
    TournamentStarted event,
    Emitter<TournamentState> emit,
  ) async {
    await emit.forEach(
      _repository.watchAll(),
      onData: (tournaments) => TournamentLoaded(tournaments: tournaments),
    );
  }

  Future<void> _onCreated(
    TournamentCreated event,
    Emitter<TournamentState> emit,
  ) async {
    await _repository.save(event.tournament);
  }

  Future<void> _onMatchStarted(
    TournamentMatchStarted event,
    Emitter<TournamentState> emit,
  ) async {
    final state = this.state;
    if (state is! TournamentLoaded) return;

    final tournamentIndex = state.tournaments.indexWhere((t) => t.id == event.tournamentId);
    if (tournamentIndex < 0) return;

    final currentTournament = state.tournaments[tournamentIndex];
    if (currentTournament.rounds.isEmpty) return;

    final updatedRounds = _bracketGenerator.startMatchup(
      currentRounds: currentTournament.rounds,
      roundIndex: event.roundIndex,
      matchupIndex: event.matchupIndex,
      tableNumber: event.tableNumber,
    );

    final updatedTournament = currentTournament.copyWith(
      rounds: updatedRounds,
      status: TournamentStatus.inProgress,
    );

    await _repository.save(updatedTournament);
  }

  Future<void> _onMatchWalkover(
    TournamentMatchWalkoverDeclared event,
    Emitter<TournamentState> emit,
  ) async {
    final state = this.state;
    if (state is! TournamentLoaded) return;

    final tournamentIndex = state.tournaments.indexWhere((t) => t.id == event.tournamentId);
    if (tournamentIndex < 0) return;

    final currentTournament = state.tournaments[tournamentIndex];
    if (currentTournament.rounds.isEmpty) return;

    final updatedRounds = _bracketGenerator.declareWalkover(
      currentRounds: currentTournament.rounds,
      roundIndex: event.roundIndex,
      matchupIndex: event.matchupIndex,
      winnerName: event.winnerName,
    );

    final isFinalMatch = event.roundIndex == currentTournament.rounds.length - 1 && event.matchupIndex == 0;
    final champion = isFinalMatch ? event.winnerName : currentTournament.championName;
    final allDone = updatedRounds.every((r) => r.matchups.every((m) => m.isCompleted));
    final status = allDone ? TournamentStatus.completed : TournamentStatus.inProgress;

    final updatedTournament = currentTournament.copyWith(
      rounds: updatedRounds,
      championName: champion,
      status: status,
    );

    await _repository.save(updatedTournament);
  }

  Future<void> _onMatchReported(
    TournamentMatchReported event,
    Emitter<TournamentState> emit,
  ) async {
    final state = this.state;
    if (state is! TournamentLoaded) return;

    final tournamentIndex = state.tournaments.indexWhere((t) => t.id == event.tournamentId);
    if (tournamentIndex < 0) return;

    final currentTournament = state.tournaments[tournamentIndex];
    if (currentTournament.rounds.isEmpty) return;

    final updatedRounds = _bracketGenerator.advanceWinner(
      currentRounds: currentTournament.rounds,
      roundIndex: event.roundIndex,
      matchupIndex: event.matchupIndex,
      winnerName: event.winnerName,
      scoreA: event.scoreA,
      scoreB: event.scoreB,
    );

    // Check if the grand final match (index 0 of last round) was won
    final isFinalRound = event.roundIndex == currentTournament.rounds.length - 1;
    final isGrandFinal = isFinalRound && event.matchupIndex == 0;
    final champion = isGrandFinal ? event.winnerName : currentTournament.championName;
    final allDone = updatedRounds.every((r) => r.matchups.every((m) => m.isCompleted));
    final status = allDone ? TournamentStatus.completed : TournamentStatus.inProgress;

    final updatedTournament = currentTournament.copyWith(
      rounds: updatedRounds,
      championName: champion,
      status: status,
    );

    await _repository.save(updatedTournament);
  }

  Future<void> _onDeleted(
    TournamentDeleted event,
    Emitter<TournamentState> emit,
  ) async {
    await _repository.delete(event.id);
  }
}
