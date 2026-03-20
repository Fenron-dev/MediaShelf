import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database/app_database.dart';
import '../../providers/library_provider.dart';

class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dao = ref.watch(activityDaoProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Activity'),
      ),
      body: StreamBuilder<List<ActivityLogData>>(
        stream: dao.watchRecent(limit: 200),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data!;
          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No activity yet', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];
              return ListTile(
                leading: Icon(_iconForEvent(item.eventType)),
                title: Text(item.assetFilename),
                subtitle: Text(item.eventType),
                trailing: Text(
                  _formatDate(item.occurredAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _iconForEvent(String type) {
    switch (type) {
      case 'added':
        return Icons.add_circle_outline;
      case 'missing':
        return Icons.remove_circle_outline;
      case 'restored':
        return Icons.restore_outlined;
      default:
        return Icons.history;
    }
  }

  String _formatDate(int timestampMs) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
