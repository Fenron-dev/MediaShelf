import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/asset_grid.dart';
import '../widgets/bulk_toolbar.dart';
import '../widgets/drop_zone.dart';
import '../widgets/top_bar.dart';

class MobileShell extends ConsumerStatefulWidget {
  const MobileShell({super.key});

  @override
  ConsumerState<MobileShell> createState() => _MobileShellState();
}

class _MobileShellState extends ConsumerState<MobileShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: const TopBar(),
      ),
      body: DropZoneOverlay(
        child: Stack(
          children: [
            IndexedStack(
              index: _selectedIndex,
              children: const [
                AssetGrid(),
                Center(child: Text('Tags')),
                Center(child: Text('Collections')),
                Center(child: Text('Activity')),
              ],
            ),
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BulkToolbar(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.grid_view), label: 'Library'),
          NavigationDestination(icon: Icon(Icons.label_outline), label: 'Tags'),
          NavigationDestination(icon: Icon(Icons.folder_outlined), label: 'Collections'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Activity'),
        ],
      ),
    );
  }
}
