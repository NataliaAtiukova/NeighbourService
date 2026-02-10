import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app_providers.dart';
import 'features/auth/onboarding_flow.dart';
import 'features/feed/feed_screen.dart';
import 'features/listing_details/listing_details_screen.dart';
import 'features/post/post_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/splash/splash_screen.dart';
import 'shared/utils/app_flags.dart';
import 'shared/widgets/app_scaffold.dart';
import 'shared/utils/motion.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final profileStatus = ref.watch(profileStatusProvider);
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      if (authState.isLoading) return null;
      if (profileStatus == ProfileStatus.loading) return null;
      if (state.uri.path == '/splash') return null;
      if (kBypassSmsAuth) {
        // TEMP: SMS auth disabled, allow direct access to app shell.
        if (state.uri.path.startsWith('/onboarding')) {
          return '/home';
        }
        return null;
      }
      final user = authState.asData?.value;
      final isOnboardingRoute = state.uri.path.startsWith('/onboarding');
      if (user == null && !isOnboardingRoute) {
        return '/onboarding';
      }
      if (user != null && isOnboardingRoute) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        pageBuilder: (context, state) => _buildFadePage(
          state,
          const SplashScreen(),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        pageBuilder: (context, state) => _buildPage(
          state,
          const OnboardingFlow(),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                pageBuilder: (context, state) =>
                    _buildPage(state, const FeedScreen()),
                routes: [
                  GoRoute(
                    path: 'listing/:id',
                    name: 'listing',
                    pageBuilder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return _buildPage(
                        state,
                        ListingDetailsScreen(listingId: id),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/post',
                name: 'post',
                pageBuilder: (context, state) =>
                    _buildPage(state, const PostScreen()),
                routes: [
                  GoRoute(
                    path: 'edit/:id',
                    name: 'editListing',
                    pageBuilder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return _buildPage(
                        state,
                        PostScreen(listingId: id),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                pageBuilder: (context, state) =>
                    _buildPage(state, const ProfileScreen()),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

CustomTransitionPage<void> _buildPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: MotionDurations.medium,
    reverseTransitionDuration: MotionDurations.fast,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: MotionCurves.standard,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: kPageSlideOffset,
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

CustomTransitionPage<void> _buildFadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: MotionDurations.medium,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: MotionCurves.standard,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.02),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
