import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final u = context.watch<AuthProvider>().user;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: u == null
          ? const SizedBox.shrink()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
                const SizedBox(height: 16),
                Card(
                  child: Column(children: [
                    ListTile(title: const Text('Name'), subtitle: Text(u.fullName)),
                    ListTile(title: const Text('Email'), subtitle: Text(u.email)),
                    ListTile(title: const Text('Phone'), subtitle: Text(u.phone ?? '—')),
                    ListTile(title: const Text('Role'), subtitle: Text(u.role)),
                  ]),
                ),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: () => context.read<AuthProvider>().logout(),
                  child: const Text('Logout'),
                ),
              ],
            ),
    );
  }
}
