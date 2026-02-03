import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/feed/feed_screen.dart';
import 'features/listing_details/listing_details_screen.dart';
import 'features/post/post_screen.dart';
import 'features/profile/profile_screen.dart';
import 'shared/widgets/app_scaffold.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    routes: [
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
                builder: (context, state) => const FeedScreen(),
                routes: [
                  GoRoute(
                    path: 'listing/:id',
                    name: 'listing',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return ListingDetailsScreen(listingId: id);
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
                builder: (context, state) => const PostScreen(),
                routes: [
                  GoRoute(
                    path: 'edit/:id',
                    name: 'editListing',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return PostScreen(listingId: id);
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
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
