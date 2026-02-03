import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_providers.dart';
import 'app_router.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: NeighbourServicesApp()));
}

class NeighbourServicesApp extends ConsumerWidget {
  const NeighbourServicesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final settings = ref.watch(settingsProvider);
    return MaterialApp.router(
      title: 'Neighbour Services',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode,
      routerConfig: router,
    );
  }
}
