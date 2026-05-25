import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/admin_provider.dart';
import 'complaint_detail_screen.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});
  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  String? _status;
  String _search = '';
  final _searchCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadComplaints();
    });
  }

  Future<void> _refresh() => context.read<AdminProvider>().loadComplaints(status: _status, search: _search);

  @override
  Widget build(BuildContext context) {
    final ap = context.watch<AdminProvider>();
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: _searchCtl,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search title / description'),
              onSubmitted: (v) { _search = v; _refresh(); },
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<String?>(
            value: _status,
            hint: const Text('Status'),
            items: const [
              DropdownMenuItem(value: null, child: Text('All')),
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
              DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
              DropdownMenuItem(value: 'resolved', child: Text('Resolved')),
              DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
            ],
            onChanged: (v) { setState(() => _status = v); _refresh(); },
          ),
        ]),
      ),
      Expanded(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ap.loading
              ? const Center(child: CircularProgressIndicator())
              : ap.complaints.isEmpty
                  ? ListView(children: const [SizedBox(height: 120), Center(child: Text('No complaints'))])
                  : ListView.separated(
                      itemBuilder: (_, i) => _row(ap.complaints[i]),
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemCount: ap.complaints.length,
                    ),
        ),
      ),
    ]);
  }

  Widget _row(AdminComplaint c) {
    final df = DateFormat.MMMd().add_jm();
    return ListTile(
      title: Text(c.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('${c.userName ?? '#${c.userId}'} • ${c.category?.name ?? 'Uncategorized'} • ${df.format(c.createdAt.toLocal())}'),
      leading: CircleAvatar(
        backgroundColor: _statusColor(c.status).withOpacity(0.15),
        child: Icon(_statusIcon(c.status), color: _statusColor(c.status)),
      ),
      trailing: Chip(
        label: Text(c.priority.toUpperCase(), style: const TextStyle(fontSize: 10)),
        padding: EdgeInsets.zero,
      ),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ComplaintDetailScreen(complaintId: c.id))),
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'pending': return Colors.orange;
      case 'in_progress': return Colors.blue;
      case 'resolved': return Colors.green;
      case 'rejected': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _statusIcon(String s) {
    switch (s) {
      case 'pending': return Icons.hourglass_top;
      case 'in_progress': return Icons.autorenew;
      case 'resolved': return Icons.check_circle;
      case 'rejected': return Icons.cancel;
      default: return Icons.help_outline;
    }
  }
}
