import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pigpen_iot/apps/home_screen.dart';
import 'package:pigpen_iot/auth/auth_provider.dart';
import 'package:pigpen_iot/auth/login_screen.dart';
import 'package:pigpen_iot/splashscreen.dart';


final routerProvider = Provider<GoRouter>((ref) {
  final isLoggedIn = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      if (state.matchedLocation == '/login' && isLoggedIn) {
        return '/home';
      } else if (state.matchedLocation == '/home' && !isLoggedIn) {
        return '/login';
      }
      return null;
    },
    routes: [
     GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    ],
  );
});
