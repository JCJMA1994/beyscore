import 'package:bey_catalog/bey_catalog.dart';
import 'package:bey_domain/bey_domain.dart';
import 'package:flutter_test/flutter_test.dart';

class MockCatalogRepository implements CatalogRepository {
  final List<Part> parts = [
    const Part(
      id: 'b-dransword',
      name: 'DranSword',
      type: PartType.blade,
      system: BeySystem.bx,
    ),
    const Part(
      id: 'b-hellsscythe',
      name: 'HellsScythe',
      type: PartType.blade,
      system: BeySystem.bx,
    ),
  ];

  @override
  Stream<List<Part>> watchByType(PartType type) {
    return Stream.value(parts.where((p) => p.type == type).toList());
  }

  @override
  Stream<List<Part>> search(String query, {PartType? type}) {
    return Stream.value(
      parts
          .where((p) =>
              (type == null || p.type == type) &&
              p.name.toLowerCase().contains(query.toLowerCase()))
          .toList(),
    );
  }

  @override
  Future<void> seedIfNeeded({required int currentVersion}) async {}
}

void main() {
  group('CatalogBloc Tests', () {
    late MockCatalogRepository repository;
    late CatalogBloc bloc;

    setUp(() {
      repository = MockCatalogRepository();
      bloc = CatalogBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is CatalogLoading', () {
      expect(bloc.state, isA<CatalogLoading>());
    });

    test('emits CatalogLoaded when CatalogStarted is added', () async {
      bloc.add(CatalogStarted(type: PartType.blade));

      await expectLater(
        bloc.stream,
        emits(isA<CatalogLoaded>().having(
          (s) => s.parts.length,
          'parts count',
          2,
        )),
      );
    });

    test('searches parts correctly when CatalogSearchChanged is added', () async {
      bloc
        ..add(CatalogStarted(type: PartType.blade))
        ..add(CatalogSearchChanged(query: 'Dran'));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<CatalogLoaded>().having((s) => s.parts.length, 'initial count', 2),
          isA<CatalogLoaded>().having((s) => s.parts.length, 'filtered count', 1),
        ]),
      );
    });
  });
}
