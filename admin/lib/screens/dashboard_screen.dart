import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/admin_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<AdminProvider>().loadStats());
  }

  @override
  Widget build(BuildContext context) {
    final ap = context.watch<AdminProvider>();
    final s = ap.stats;
    if (s == null) return const Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      onRefresh: () => context.read<AdminProvider>().loadStats(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          LayoutBuilder(builder: (context, c) {
            final cols = c.maxWidth > 900 ? 5 : c.maxWidth > 600 ? 3 : 2;
            return GridView.count(
              crossAxisCount: cols,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                _stat('Total', s.total, Colors.indigo, Icons.list_alt),
                _stat('Pending', s.pending, Colors.orange, Icons.hourglass_top),
                _stat('In Progress', s.inProgress, Colors.blue, Icons.autorenew),
                _stat('Resolved', s.resolved, Colors.green, Icons.check_circle),
                _stat('Users', s.users, Colors.purple, Icons.people),
              ],
            );
          }),
          const SizedBox(height: 24),
          Text('Complaints by Status', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SizedBox(height: 220, child: _statusChart(s.pending, s.inProgress, s.resolved, s.rejected)),
          const SizedBox(height: 24),
          Text('Complaints by Category', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...s.byCategory.entries.map((e) => ListTile(
                dense: true,
                leading: const Icon(Icons.label_outline),
                title: Text(e.key),
                trailing: Text('${e.value}'),
              )),
        ],
      ),
    );
  }

  Widget _stat(String label, int value, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [Icon(icon, color: color), const SizedBox(width: 6), Expanded(child: Text(label, overflow: TextOverflow.ellipsis))]),
          Text('$value', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
        ]),
      ),
    );
  }

  Widget _statusChart(int p, int ip, int r, int rj) {
    final data = [
      _Slice('Pending', p, Colors.orange),
      _Slice('In Progress', ip, Colors.blue),
      _Slice('Resolved', r, Colors.green),
      _Slice('Rejected', rj, Colors.red),
    ].where((s) => s.value > 0).toList();
    if (data.isEmpty) return const Center(child: Text('No data'));
    return PieChart(PieChartData(
      sectionsSpace: 2,
      centerSpaceRadius: 36,
      sections: data
          .map((d) => PieChartSectionData(
                value: d.value.toDouble(),
                color: d.color,
                title: '${d.label}\n${d.value}',
                radius: 70,
                titleStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ))
          .toList(),
    ));
  }
}

class _Slice {
  final String label;
  final int value;
  final Color color;
  _Slice(this.label, this.value, this.color);
}
