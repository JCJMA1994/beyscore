/// Pure Dart domain layer for BeyScore.
///
/// Contains entities, value objects, domain services, repository contracts,
/// and core use cases.
///
/// Pure Dart: ZERO dependencies on Flutter, Drift, or HTTP/Dio.
library;

// Core
export 'src/error/exceptions.dart';
export 'src/error/failure.dart';
export 'src/id/uuid_v7_generator.dart';
export 'src/typedef/result.dart';
export 'src/usecase/use_case.dart';

// Permissions & Identity
export 'src/identity/identity_repository.dart';
export 'src/identity/identity_service.dart';
export 'src/identity/user_profile.dart';
export 'src/permissions/capability.dart';
export 'src/permissions/device_role.dart';
export 'src/permissions/permission_result.dart';
export 'src/permissions/permission_service.dart';

// Battle
export 'src/battle/battle_finish.dart';
export 'src/battle/battle_repository.dart';
export 'src/battle/finish_type.dart';
export 'src/battle/match.dart';
export 'src/battle/match_outcome.dart';
export 'src/battle/match_rules.dart';
export 'src/battle/scoring_service.dart';
export 'src/battle/usecases/register_finish.dart';
export 'src/battle/usecases/start_match.dart';
export 'src/battle/usecases/undo_last_finish.dart';
export 'src/battle/usecases/watch_match.dart';

// Catalog
export 'src/catalog/catalog_repository.dart';
export 'src/catalog/part.dart';
export 'src/catalog/part_type.dart';

// Combo
export 'src/combo/combo.dart';
export 'src/combo/combo_repository.dart';
export 'src/combo/combo_stats_calculator.dart';

// Deck
export 'src/deck/deck.dart';
export 'src/deck/deck_repository.dart';
export 'src/deck/deck_validator.dart';

// Meta & Analytics
export 'src/meta/buildability_service.dart';
export 'src/meta/meta_advisor_service.dart';
export 'src/meta/meta_preset_service.dart';
export 'src/meta/meta_ranking_models.dart';
export 'src/meta/meta_repository.dart';
export 'src/meta/tier_entry.dart';
export 'src/analytics/meta_analytics_service.dart';
export 'src/analytics/rivalry_service.dart';
export 'src/analytics/spin_benchmark_service.dart';
export 'src/analytics/type_advantage_service.dart';

// Profile
export 'src/profile/player.dart';
export 'src/profile/profile_repository.dart';

// Stats
export 'src/stats/player_stats_snapshot.dart';
export 'src/stats/stats_repository.dart';

// Tournament
export 'src/tournament/arbitration_audit_service.dart';
export 'src/tournament/bracket.dart';
export 'src/tournament/bracket_generator.dart';
export 'src/tournament/swiss_bracket_generator.dart';
export 'src/tournament/seeded_shuffle.dart';
export 'src/tournament/tournament.dart';
export 'src/tournament/tournament_repository.dart';
export 'src/tournament/usecases/create_tournament.dart';
export 'src/tournament/usecases/generate_bracket.dart';
