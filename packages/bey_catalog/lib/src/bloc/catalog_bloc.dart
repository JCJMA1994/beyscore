import 'package:bey_domain/bey_domain.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

// -- Events --

sealed class CatalogEvent {}

final class CatalogStarted extends CatalogEvent {
  CatalogStarted({required this.type});
  final PartType type;
}

final class CatalogSearchChanged extends CatalogEvent {
  CatalogSearchChanged({required this.query});
  final String query;
}

// -- States --

sealed class CatalogState extends Equatable {
  const CatalogState();

  @override
  List<Object?> get props => [];
}

final class CatalogLoading extends CatalogState {}

final class CatalogLoaded extends CatalogState {
  const CatalogLoaded({required this.parts, this.query = ''});
  final List<Part> parts;
  final String query;

  @override
  List<Object?> get props => [parts.length, query];
}

final class CatalogError extends CatalogState {
  const CatalogError({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}

// -- BLoC --

/// Catalog BLoC with debounced search via RxDart.
///
/// Uses debounceTime — one of the four justified RxDart usages
/// (CLAUDE.md section 6). No use cases: calls repo directly.
class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  CatalogBloc({required CatalogRepository repository})
      : _repository = repository,
        super(CatalogLoading()) {
    on<CatalogStarted>(_onStarted);
    on<CatalogSearchChanged>(
      _onSearch,
      transformer: (events, mapper) =>
          events.debounceTime(const Duration(milliseconds: 300)).switchMap(mapper),
    );
  }

  final CatalogRepository _repository;
  PartType _currentType = PartType.blade;

  Future<void> _onStarted(
    CatalogStarted event,
    Emitter<CatalogState> emit,
  ) async {
    _currentType = event.type;
    await emit.forEach(
      _repository.watchByType(event.type),
      onData: (parts) => CatalogLoaded(parts: parts),
      onError: (error, _) => CatalogError(message: error.toString()),
    );
  }

  Future<void> _onSearch(
    CatalogSearchChanged event,
    Emitter<CatalogState> emit,
  ) async {
    if (event.query.isEmpty) {
      add(CatalogStarted(type: _currentType));
      return;
    }

    await emit.forEach(
      _repository.search(event.query, type: _currentType),
      onData: (parts) => CatalogLoaded(parts: parts, query: event.query),
      onError: (error, _) => CatalogError(message: error.toString()),
    );
  }
}
