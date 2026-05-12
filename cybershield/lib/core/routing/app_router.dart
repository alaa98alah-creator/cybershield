import 'package:cybershield/screens/analyzing_screen.dart';
import 'package:cybershield/screens/auth_screen.dart';
import 'package:cybershield/screens/file_scanner_screen.dart';
import 'package:cybershield/screens/history_screen.dart';
import 'package:cybershield/screens/home_screen.dart';
import 'package:cybershield/screens/link_scanner_screen.dart';
import 'package:cybershield/screens/register_screen.dart';
import 'package:cybershield/screens/security_report_screen.dart';
import 'package:cybershield/screens/splash_screen.dart';
import 'package:cybershield/services/token_storage.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  AppRouter._();

  static final _tokenStorage = TokenStorage();

  static final router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) async {
      final isLoggedIn = await _tokenStorage.hasToken();
      final isAuthRoute =
          state.matchedLocation == '/auth' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/splash';

      if (!isLoggedIn && !isAuthRoute) return '/auth';
      if (isLoggedIn && isAuthRoute && state.matchedLocation != '/splash') {
        return '/home';
      }
      if (isLoggedIn && state.matchedLocation == '/splash') return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/link-scanner',
        builder: (context, state) => const LinkScannerScreen(),
      ),
      GoRoute(
        path: '/file-scanner',
        builder: (context, state) => const FileScannerScreen(),
      ),
      GoRoute(
        path: '/analyzing',
        builder: (context, state) {
          final scanId = state.uri.queryParameters['scanId'] ?? '';
          return AnalyzingScreen(scanId: scanId);
        },
      ),
      GoRoute(
        path: '/report',
        builder: (context, state) {
          final scanId = state.uri.queryParameters['scanId'] ?? '';
          return SecurityReportScreen(scanId: scanId);
        },
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryScreen(),
      ),
    ],
  );
}
