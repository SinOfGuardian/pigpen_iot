import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pigpen_iot/apps/home/home_screen.dart';
import 'package:pigpen_iot/apps/menu/menu_screen.dart';
import 'package:pigpen_iot/apps/notification/notif_screen.dart';
import 'package:pigpen_iot/apps/shop/shop_screen.dart';
import 'package:pigpen_iot/custom/app_bottom_navbar.dart';

class AppScreen extends ConsumerStatefulWidget {
  const AppScreen({super.key});
  @override
  ConsumerState<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends ConsumerState<AppScreen> {
  final _controller = PageController(initialPage: 0);
  int _pageIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    ShopScreen(),
    NotificationScreen(),
    MenuScreen(),
  ];

  @override
  void initState() {
    super.initState();
    if (FirebaseAuth.instance.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await FirebaseAuth.instance
            .signOut()
            .timeout(const Duration(seconds: 5));
        if (mounted) context.go('/signin');
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _ontTabChanged(int index) {
    setState(() => _pageIndex = index);
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutQuart,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _controller,
              children: _pages,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomGNavBar(
        index: _pageIndex,
        onTabChange: _ontTabChanged,
        role: 'user ',
      ),
    );
  }
}
