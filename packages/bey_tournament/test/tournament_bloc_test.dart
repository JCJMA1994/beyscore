import 'package:bey_domain/bey_domain.dart';
import 'package:bey_tournament/bey_tournament.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart/rxdart.dart';

class MockTournamentRepository implements TournamentRepository {
  final _subject = BehaviorSubject<List<Tournament>>.seeded([]);

  @override
  Stream<List<Tournament>> watchAll() => _subject.stream;

  @override
  Future<void> save(Tournament tournament) async {
    final list = List<Tournament>.from(_subject.value);
    final idx = list.indexWhere((t) => t.id == tournament.id);
    if (idx >= 0) {
      list[idx] = tournament;
    } else {
      list.add(tournament);
    }
    _subject.add(list);
  }

  @override
  Future<void> delete(String id) async {
    final list = List<Tournament>.from(_subject.value)..removeWhere((t) => t.id == id);
    _subject.add(list);
  }

  @override
  Stream<Tournament> watchById(String id) {
    return _subject.stream.map((list) => list.firstWhere((t) => t.id == id));
  }

  void dispose() {
    _subject.close();
  }
}

void main() {
  group('TournamentBloc Tests', () {
    late MockTournamentRepository repository;
    late TournamentBloc bloc;

    setUp(() {
      repository = MockTournamentRepository();
      bloc = TournamentBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
      repository.dispose();
    });

    test('initial state is TournamentLoading', () {
      expect(bloc.state, isA<TournamentLoading>());
    });

    test('loads empty list on TournamentStarted', () async {
      bloc.add(TournamentStarted());

      await expectLater(
        bloc.stream,
        emits(isA<TournamentLoaded>().having((s) => s.tournaments.length, 'count', 0)),
      );
    });

    test('creates and persists new tournament', () async {
      final tournament = Tournament(
        id: 'tour-1',
        name: 'Torneo Apertura 2026',
        organizerIds: const ['org-1'],
        tier: TournamentTier.g3,
        ageDivision: AgeDivision.open,
        status: TournamentStatus.inProgress,
        createdAt: DateTime.now(),
      );

      bloc
        ..add(TournamentStarted())
        ..add(TournamentCreated(tournament));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<TournamentLoaded>().having((s) => s.tournaments.length, 'count', 0),
          isA<TournamentLoaded>().having((s) => s.tournaments.length, 'count', 1),
        ]),
      );
    });

    test('advances bracket and sets champion on TournamentMatchReported', () async {
      const generator = BracketGenerator();
      final rounds = generator.generateBracketTree(
        playerNames: ['Tyson', 'Kai'],
        seed: 42,
      );

      final tournament = Tournament(
        id: 'tour-finals',
        name: 'Finalissima 2026',
        organizerIds: const ['org-1'],
        tier: TournamentTier.g2,
        ageDivision: AgeDivision.open,
        status: TournamentStatus.inProgress,
        participants: const ['Tyson', 'Kai'],
        rounds: rounds,
        createdAt: DateTime.now(),
      );

      await repository.save(tournament);
      bloc
        ..add(TournamentStarted())
        ..add(
          const TournamentMatchReported(
            tournamentId: 'tour-finals',
            roundIndex: 0,
            matchupIndex: 0,
            winnerName: 'Tyson',
            scoreA: 4,
            scoreB: 2,
          ),
        );

      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<TournamentLoaded>().having(
            (s) {
              final t = s.tournaments.firstWhere((item) => item.id == 'tour-finals');
              return t.status == TournamentStatus.completed && t.championName == 'Tyson';
            },
            'completed with champion Tyson',
            isTrue,
          ),
        ),
      );
    });
  });
}
