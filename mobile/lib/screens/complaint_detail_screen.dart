import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/config.dart';
import '../models/models.dart';
import '../providers/complaint_provider.dart';

class ComplaintDetailScreen extends StatefulWidget {
  final int complaintId;
  const ComplaintDetailScreen({super.key, required this.complaintId});
  @override
  State<ComplaintDetailScreen> createState() => _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState extends State<ComplaintDetailScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;
  final _comment = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final d = await context.read<ComplaintProvider>().detail(widget.complaintId);
      setState(() => _data = d);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendComment() async {
    if (_comment.text.trim().isEmpty) return;
    await context.read<ComplaintProvider>().addComment(widget.complaintId, _comment.text.trim());
    _comment.clear();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Complaint #${widget.complaintId}')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final d = _data!;
    final c = Complaint.fromJson(d);
    final comments = ((d['comments'] ?? []) as List)
        .map((e) => CommentModel.fromJson(e))
        .toList();
    final df = DateFormat.yMMMd().add_jm();
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(c.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Row(children: [
                _statusChip(c.status),
                const SizedBox(width: 6),
                Chip(label: Text(c.priority.toUpperCase()), padding: EdgeInsets.zero),
                const Spacer(),
                Text(df.format(c.createdAt.toLocal()),
                    style: Theme.of(context).textTheme.bodySmall),
              ]),
              const SizedBox(height: 12),
              if (c.category != null) Text('Category: ${c.category!.name}'),
              if (c.location != null && c.location!.isNotEmpty) Text('Location: ${c.location}'),
              const SizedBox(height: 12),
              Text(c.description),
              if (c.attachment != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    '${AppConfig.apiBaseUrl}/uploads/${c.attachment}',
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ],
              if (c.adminResponse != null && c.adminResponse!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Card(
                  color: Colors.amber.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Admin Response', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(c.adminResponse!),
                    ]),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Text('Conversation', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              if (comments.isEmpty) const Text('No comments yet'),
              ...comments.map((cm) => Card(
                child: ListTile(
                  title: Text(cm.authorName ?? 'User'),
                  subtitle: Text(cm.message),
                  trailing: Text(DateFormat.MMMd().add_jm().format(cm.createdAt.toLocal()),
                      style: Theme.of(context).textTheme.bodySmall),
                ),
              )),
            ],
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _comment,
                  decoration: const InputDecoration(hintText: 'Add a comment'),
                ),
              ),
              IconButton(icon: const Icon(Icons.send), onPressed: _sendComment),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _statusChip(String s) {
    final colors = {
      'pending': Colors.orange,
      'in_progress': Colors.blue,
      'resolved': Colors.green,
      'rejected': Colors.red,
    };
    return Chip(
      label: Text(s.replaceAll('_', ' ').toUpperCase()),
      backgroundColor: (colors[s] ?? Colors.grey).withOpacity(0.15),
      labelStyle: TextStyle(color: colors[s] ?? Colors.grey, fontWeight: FontWeight.w600),
      padding: EdgeInsets.zero,
    );
  }
}
