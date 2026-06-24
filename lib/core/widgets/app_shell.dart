import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 하단 탭 4개를 감싸는 쉘. 각 탭은 독립 네비게이션 스택을 가진다.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: '홈'),
          NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined),
              selectedIcon: Icon(Icons.calendar_today),
              label: '기록'),
          NavigationDestination(
              icon: Icon(Icons.favorite_outline),
              selectedIcon: Icon(Icons.favorite),
              label: '우리'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: '마이'),
        ],
      ),
    );
  }
}
