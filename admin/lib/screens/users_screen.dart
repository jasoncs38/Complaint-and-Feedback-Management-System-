import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/admin_provider.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});
  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<AdminProvider>().loadUsers());
  }

  @override
  Widget build(BuildContext context) {
    final ap = context.watch<AdminProvider>();
    return RefreshIndicator(
      onRefresh: () => context.read<AdminProvider>().loadUsers(),
      child: ListView.separated(
        itemBuilder: (_, i) {
          final u = ap.users[i];
          return ListTile(
            leading: CircleAvatar(child: Text(u.fullName.isNotEmpty ? u.fullName[0].toUpperCase() : '?')),
            title: Text(u.fullName),
            subtitle: Text(u.email),
            trailing: Chip(label: Text(u.role)),
          );
        },
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemCount: ap.users.length,
      ),
    );
  }
}
