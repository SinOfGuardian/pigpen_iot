import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pigpen_iot/apps/home_screen.dart';
import 'package:pigpen_iot/auth/auth_provider.dart';
import 'package:pigpen_iot/auth/login_screen.dart';
import 'package:pigpen_iot/auth/registration/registration_view.dart';
import 'package:pigpen_iot/splashscreen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final isLoggedIn = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // Redirect to home if logged in and trying to access login or registration
      if ((state.matchedLocation == '/login' || state.matchedLocation == '/registration') && isLoggedIn) {
        return '/home';
      }
      // Redirect to login if not logged in and trying to access home
      else if (state.matchedLocation == '/home' && !isLoggedIn) {
        return '/login';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/registration',
        builder: (context, state) => const RegistrationPage(),
      ),
    ],
  );
});