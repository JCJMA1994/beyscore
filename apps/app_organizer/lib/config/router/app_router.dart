import 'package:bey_data/bey_data.dart';
import 'package:bey_domain/bey_domain.dart';
import 'package:bey_tournament/bey_tournament.dart';
import 'package:flutter/material.dart';
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
import '../../features/rankings/presentation/pages/rankings_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/stats/presentation/pages/stats_page.dart';
import '../../features/tournament/presentation/pages/tournament_organizer_hub_page.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    // Splash Screen
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),

    // Onboarding
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

    // Full screen Tournament Creation
    GoRoute(
      path: '/tournament/new',
      name: 'tournament-new',
      builder: (context, state) => const TournamentCreatePage(),
    ),

    // PhoneShell (5 main tabs: Inicio, Torneos, Beys, Stats, Perfil)
    ShellRoute(
      builder: (context, state, child) => PhoneShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomeDashboardPage(),
        ),
        GoRoute(
          path: '/tournament',
          name: 'tournament',
          builder: (context, state) => BlocProvider(
            create: (_) => TournamentBloc(repository: getIt<TournamentRepository>())..add(TournamentStarted()),
            child: TournamentPage(
              onRefresh: () => getIt<SyncEngine>().syncNow(),
              onOpenHub: (ctx, tournament) {
                Navigator.of(ctx).push<void>(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: ctx.read<TournamentBloc>(),
                      child: TournamentOrganizerHubPage(tournament: tournament),
                    ),
                  ),
                );
              },
            ),
          ),
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
          path: '/rankings',
          name: 'rankings',
          builder: (context, state) => const RankingsPage(),
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
