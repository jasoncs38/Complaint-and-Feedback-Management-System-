import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/config.dart';
import '../models/models.dart';
import '../providers/admin_provider.dart';

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
  final _response = TextEditingController();
  final _comment = TextEditingController();
  String? _status;
  String? _priority;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final d = await context.read<AdminProvider>().detail(widget.complaintId);
      setState(() {
        _data = d;
        _status = d['status'];
        _priority = d['priority'];
        _response.text = d['admin_response'] ?? '';
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    try {
      await context.read<AdminProvider>().updateStatus(
        widget.complaintId,
        status: _status!,
        response: _response.text.trim(),
        priority: _priority,
      );
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Updated')));
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _sendComment() async {
    if (_comment.text.trim().isEmpty) return;
    await context.read<AdminProvider>().addComment(widget.complaintId, _comment.text.trim());
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
              : _build(),
    );
  }

  Widget _build() {
    final d = _data!;
    final c = AdminComplaint.fromJson(d);
    final comments = (d['comments'] ?? []) as List;
    final df = DateFormat.yMMMd().add_jm();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(c.title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text('${c.userName ?? '#${c.userId}'} • ${df.format(c.createdAt.toLocal())}',
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 12),
        if (c.category != null) Text('Category: ${c.category!.name}'),
        if (c.location != null && c.location!.isNotEmpty) Text('Location: ${c.location}'),
        const SizedBox(height: 12),
        Text(c.description),
        if (c.attachment != null) ...[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network('${AppConfig.apiBaseUrl}/uploads/${c.attachment}',
              errorBuilder: (_, __, ___) => const SizedBox.shrink()),
          ),
        ],
        const Divider(height: 32),
        Text('Triage', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: const [
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
                DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                DropdownMenuItem(value: 'resolved', child: Text('Resolved')),
                DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
              ],
              onChanged: (v) => setState(() => _status = v),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _priority,
              decoration: const InputDecoration(labelText: 'Priority'),
              items: const [
                DropdownMenuItem(value: 'low', child: Text('Low')),
                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                DropdownMenuItem(value: 'high', child: Text('High')),
              ],
              onChanged: (v) => setState(() => _priority = v),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        TextField(
          controller: _response,
          minLines: 3,
          maxLines: 6,
          decoration: const InputDecoration(labelText: 'Official admin response'),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
              icon: const Icon(Icons.save), onPressed: _save, label: const Text('Save changes')),
        ),
        const Divider(height: 32),
        Text('Conversation', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (comments.isEmpty) const Text('No comments yet'),
        ...comments.map((e) {
          final created = DateTime.parse(e['created_at']);
          return Card(
            child: ListTile(
              title: Text(e['author_name'] ?? 'User'),
              subtitle: Text(e['message']),
              trailing: Text(DateFormat.MMMd().add_jm().format(created.toLocal()),
                  style: Theme.of(context).textTheme.bodySmall),
            ),
          );
        }),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: TextField(controller: _comment, decoration: const InputDecoration(hintText: 'Reply to user'))),
          IconButton(icon: const Icon(Icons.send), onPressed: _sendComment),
        ]),
      ],
    );
  }
}
