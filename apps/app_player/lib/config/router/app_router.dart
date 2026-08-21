import 'package:bey_domain/bey_domain.dart';
import 'package:bey_tournament/bey_tournament.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injector.dart';
import '../../features/battle/presentation/pages/live_battle_page.dart';
import '../../features/beys/presentation/pages/beys_hub_page.dart';
import '../../features/catalog/presentation/pages/catalog_page.dart';
import '../../features/combo/presentation/pages/combo_builder_page.dart';
import '../../features/combo/presentation/pages/combo_page.dart';
import '../../features/deck/presentation/pages/deck_builder_page.dart';
import '../../features/deck/presentation/pages/deck_page.dart';
import '../../features/home/presentation/pages/home_dashboard_page.dart';
import '../../features/home/presentation/pages/phone_shell.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/stats/presentation/pages/stats_page.dart';
import '../../features/tournament/presentation/pages/player_tournament_pass_page.dart';
import '../../features/tournament/presentation/pages/player_tournament_registration_page.dart';
import '../../features/tournament/presentation/pages/player_tournaments_page.dart';

/// App router for app_player.
final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    // Splash Screen
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),

    // Onboarding (Primer arranque, Apodo, Código de recuperación)
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),

    // Casual 1v1 Battle
    GoRoute(
      path: '/battle',
      name: 'battle',
      builder: (context, state) => const LiveBattlePage(),
    ),

    // Tournament routes outside shell
    GoRoute(
      path: '/tournaments/:id/register',
      name: 'tournament-register',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return PlayerTournamentRegistrationPage(tournamentId: id);
      },
    ),
    GoRoute(
      path: '/tournaments/:id/pass',
      name: 'tournament-pass',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return PlayerTournamentPassPage(tournamentId: id);
      },
    ),
    GoRoute(
      path: '/tournaments/:id/bracket',
      name: 'tournament-bracket',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return BlocProvider(
          create: (_) => TournamentBloc(repository: getIt<TournamentRepository>())..add(TournamentStarted()),
          child: TournamentBracketPage(tournamentId: id),
        );
      },
    ),

    // PhoneShell (Main navigation)
    ShellRoute(
      builder: (context, state, child) => PhoneShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomeDashboardPage(),
        ),
        GoRoute(
          path: '/tournaments',
          name: 'tournaments',
          builder: (context, state) => const PlayerTournamentsPage(),
        ),
        GoRoute(
          path: '/beys',
          name: 'beys',
          builder: (context, state) => const BeysHubPage(),
          routes: [
            GoRoute(
              path: 'combo/new',
              name: 'beys-combo-new',
              builder: (context, state) => const ComboBuilderPage(),
            ),
            GoRoute(
              path: 'deck/new',
              name: 'beys-deck-new',
              builder: (context, state) => const DeckBuilderPage(),
            ),
          ],
        ),
        GoRoute(
          path: '/catalog',
          name: 'catalog',
          builder: (context, state) => const CatalogPage(),
        ),
        GoRoute(
          path: '/combos',
          name: 'combos',
          builder: (context, state) => const ComboPage(),
          routes: [
            GoRoute(
              path: 'new',
              name: 'combo-new',
              builder: (context, state) => const ComboBuilderPage(),
            ),
          ],
        ),
        GoRoute(
          path: '/decks',
          name: 'decks',
          builder: (context, state) => const DeckPage(),
          routes: [
            GoRoute(
              path: 'new',
              name: 'deck-new',
              builder: (context, state) => const DeckBuilderPage(),
            ),
          ],
        ),
        GoRoute(
          path: '/stats',
          name: 'stats',
          builder: (context, state) => const StatsPage(),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfilePage(),
        ),
      ],
    ),
  ],
);
