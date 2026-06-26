import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:keeji/features/home/home_page.dart';
import 'package:keeji/features/import/import_page.dart';
import 'package:keeji/features/settings/settings_page.dart';
import 'package:keeji/widgets/adaptive_scaffold.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return AdaptiveScaffold(
            currentIndex: _calculateSelectedIndex(state.uri.path),
            onIndexChanged: (index) {
              switch (index) {
                case 0:
                  context.go('/');
                  break;
                case 1:
                  context.go('/settings');
                  break;
              }
            },
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomePage(),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsPage(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/import',
        builder: (context, state) => const ImportPage(),
      ),
    ],
  );
});

int _calculateSelectedIndex(String path) {
  if (path.startsWith('/settings')) return 1;
  return 0;
}
