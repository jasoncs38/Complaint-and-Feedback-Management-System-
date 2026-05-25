import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'dashboard_screen.dart';
import 'complaints_screen.dart';
import 'categories_screen.dart';
import 'users_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});
  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _index = 0;

  final _pages = const [
    DashboardScreen(),
    ComplaintsScreen(),
    CategoriesScreen(),
    UsersScreen(),
  ];

  final _titles = const ['Dashboard', 'Complaints', 'Categories', 'Users'];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 800;
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: isWide
          ? Row(children: [
              NavigationRail(
                selectedIndex: _index,
                onDestinationSelected: (i) => setState(() => _index = i),
                labelType: NavigationRailLabelType.all,
                destinations: const [
                  NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('Dashboard')),
                  NavigationRailDestination(icon: Icon(Icons.list_alt_outlined), selectedIcon: Icon(Icons.list_alt), label: Text('Complaints')),
                  NavigationRailDestination(icon: Icon(Icons.category_outlined), selectedIcon: Icon(Icons.category), label: Text('Categories')),
                  NavigationRailDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: Text('Users')),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(child: _pages[_index]),
            ])
          : _pages[_index],
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              destinations: const [
                NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Home'),
                NavigationDestination(icon: Icon(Icons.list_alt_outlined), label: 'Complaints'),
                NavigationDestination(icon: Icon(Icons.category_outlined), label: 'Categories'),
                NavigationDestination(icon: Icon(Icons.people_outline), label: 'Users'),
              ],
            ),
    );
  }
}
