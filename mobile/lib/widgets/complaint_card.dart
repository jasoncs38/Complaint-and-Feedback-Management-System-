import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/models.dart';

class ComplaintCard extends StatelessWidget {
  final Complaint complaint;
  final VoidCallback onTap;
  const ComplaintCard({super.key, required this.complaint, required this.onTap});

  Color _statusColor(String s) {
    switch (s) {
      case 'pending': return Colors.orange;
      case 'in_progress': return Colors.blue;
      case 'resolved': return Colors.green;
      case 'rejected': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = complaint;
    final color = _statusColor(c.status);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Text(c.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  c.status.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 11),
                ),
              ),
            ]),
            const SizedBox(height: 4),
            Text(c.description,
                maxLines: 2, overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 6),
            Row(children: [
              if (c.category != null) ...[
                Icon(Icons.label_outline, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 2),
                Text(c.category!.name, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(width: 10),
              ],
              Icon(Icons.flag_outlined, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 2),
              Text(c.priority, style: Theme.of(context).textTheme.bodySmall),
              const Spacer(),
              Text(DateFormat.MMMd().format(c.createdAt.toLocal()),
                  style: Theme.of(context).textTheme.bodySmall),
            ]),
          ]),
        ),
      ),
    );
  }
}
