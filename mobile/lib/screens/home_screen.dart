import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/complaint_provider.dart';
import '../widgets/complaint_card.dart';
import 'submit_complaint_screen.dart';
import 'complaint_detail_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cp = context.read<ComplaintProvider>();
      cp.loadCategories();
      cp.refresh();
    });
  }

  Future<void> _refresh() => context.read<ComplaintProvider>().refresh(status: _statusFilter);

  @override
  Widget build(BuildContext context) {
    final cp = context.watch<ComplaintProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Complaints'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _chip('All', null),
                  _chip('Pending', 'pending'),
                  _chip('In Progress', 'in_progress'),
                  _chip('Resolved', 'resolved'),
                  _chip('Rejected', 'rejected'),
                ],
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: cp.loading && cp.items.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : cp.items.isEmpty
                      ? ListView(children: [
                          const SizedBox(height: 120),
                          Center(
                            child: Text(
                              'Hi ${auth.user?.fullName ?? ''}\nNo complaints yet. Tap + to create one.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          )
                        ])
                      : ListView.builder(
                          itemCount: cp.items.length,
                          itemBuilder: (_, i) {
                            final c = cp.items[i];
                            return ComplaintCard(
                              complaint: c,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ComplaintDetailScreen(complaintId: c.id),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('New'),
        onPressed: () async {
          final ok = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const SubmitComplaintScreen()),
          );
          if (ok == true) _refresh();
        },
      ),
    );
  }

  Widget _chip(String label, String? value) {
    final selected = _statusFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          setState(() => _statusFilter = value);
          context.read<ComplaintProvider>().refresh(status: value);
        },
      ),
    );
  }
}
