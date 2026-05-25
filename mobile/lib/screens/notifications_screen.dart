import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/api_client.dart';
import '../models/models.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationModel> _items = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final j = await ApiClient.instance.get('/notifications/') as List;
    setState(() {
      _items = j.map((e) => NotificationModel.fromJson(e)).toList();
      _loading = false;
    });
  }

  Future<void> _markAll() async {
    await ApiClient.instance.post('/notifications/read-all', {});
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(icon: const Icon(Icons.done_all), onPressed: _markAll),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _items.isEmpty
                  ? ListView(children: const [SizedBox(height: 120), Center(child: Text('No notifications'))])
                  : ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (_, i) {
                        final n = _items[i];
                        return ListTile(
                          leading: Icon(n.isRead ? Icons.notifications_none : Icons.notifications_active,
                              color: n.isRead ? null : Colors.blue),
                          title: Text(n.title),
                          subtitle: Text(n.body ?? ''),
                          trailing: Text(DateFormat.MMMd().add_jm().format(n.createdAt.toLocal()),
                              style: Theme.of(context).textTheme.bodySmall),
                        );
                      },
                    ),
            ),
    );
  }
}
