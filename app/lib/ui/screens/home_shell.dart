import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/db/database.dart';
import '../../llm/jobs/llm_batch_coordinator.dart';
import 'ask_screen.dart';
import 'home_screen.dart';
import 'import_screen.dart';
import 'insights_screen.dart';

/// Bottom-nav shell: Home / Insights / Import / Ask.
class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    this.coordinator,
    this.database,
  });

  final LlmBatchCoordinator? coordinator;
  final ArthDatabase? database;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with WidgetsBindingObserver {
  int _index = 0;
  int _insightsTick = 0;
  late final LlmBatchCoordinator _coordinator;
  ArthDatabase? _db;

  @override
  void initState() {
    super.initState();
    _coordinator = widget.coordinator ?? LlmBatchCoordinator();
    WidgetsBinding.instance.addObserver(this);
    _openDb();
  }

  Future<void> _openDb() async {
    if (widget.database != null) {
      setState(() => _db = widget.database);
      await _coordinator.onAppResumed(widget.database!);
      return;
    }
    try {
      final db = await ArthDatabase.openEncrypted();
      if (!mounted) return;
      setState(() => _db = db);
      await _coordinator.onAppResumed(db);
    } catch (_) {}
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (widget.coordinator == null) _coordinator.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final db = _db;
    if (db == null) return;
    if (state == AppLifecycleState.resumed) {
      unawaited(_coordinator.onAppResumed(db));
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = _db;
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(coordinator: _coordinator, database: db),
          InsightsScreen(database: db, reloadToken: _insightsTick),
          ImportScreen(
            database: db,
            coordinator: _coordinator,
          ),
          AskScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() {
          _index = i;
          if (i == 1) _insightsTick++;
        }),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(Icons.file_upload_outlined),
            selectedIcon: Icon(Icons.file_upload),
            label: 'Import',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Ask',
          ),
        ],
      ),
    );
  }
}
