import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/admin_provider.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});
  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _name = TextEditingController();
  final _desc = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<AdminProvider>().loadCategories());
  }

  Future<void> _add() async {
    if (_name.text.trim().isEmpty) return;
    try {
      await context.read<AdminProvider>().createCategory(_name.text.trim(),
          _desc.text.trim().isEmpty ? null : _desc.text.trim());
      _name.clear();
      _desc.clear();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ap = context.watch<AdminProvider>();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Expanded(child: TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name'))),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: _desc, decoration: const InputDecoration(labelText: 'Description'))),
              const SizedBox(width: 8),
              FilledButton.icon(icon: const Icon(Icons.add), onPressed: _add, label: const Text('Add')),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Card(
            child: ListView.separated(
              itemBuilder: (_, i) {
                final c = ap.categories[i];
                return ListTile(
                  title: Text(c.name),
                  subtitle: Text(c.description ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text('Delete ${c.name}?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                          ],
                        ),
                      );
                      if (ok == true) {
                        try { await context.read<AdminProvider>().deleteCategory(c.id); }
                        catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
                      }
                    },
                  ),
                );
              },
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemCount: ap.categories.length,
            ),
          ),
        ),
      ]),
    );
  }
}
