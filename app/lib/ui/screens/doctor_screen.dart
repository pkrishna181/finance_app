import 'package:flutter/material.dart';

import '../../core/db/database.dart';
import '../../insights/insights.dart';
import 'credit_cards_screen.dart';
import 'search_screen.dart';

/// Data check-up: gaps, missing statements and other things that make the
/// numbers less trustworthy, each with a way to fix it.
class DoctorScreen extends StatefulWidget {
  const DoctorScreen({
    super.key,
    required this.database,
    this.onOpenImport,
    this.now,
  });

  final ArthDatabase database;

  /// Switches to the Import tab (closing this screen first).
  final VoidCallback? onOpenImport;
  final DateTime? now;

  @override
  State<DoctorScreen> createState() => _DoctorScreenState();
}

class _DoctorScreenState extends State<DoctorScreen> {
  List<DoctorFinding>? _findings;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final f = await runDataDoctor(widget.database, asOf: widget.now);
    if (mounted) setState(() => _findings = f);
  }

  Future<void> _act(DoctorFinding f) async {
    switch (f.action) {
      case DoctorAction.search:
        await Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => SearchScreen(
            database: widget.database,
            initialQuery: f.query,
          ),
        ));
        await _load();
      case DoctorAction.cards:
        await Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => CreditCardsScreen(database: widget.database),
        ));
        await _load();
      case DoctorAction.importData:
      case DoctorAction.resolveUnparsed:
        final open = widget.onOpenImport;
        if (open == null) return;
        Navigator.of(context).pop();
        open();
      case DoctorAction.none:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final f = _findings;
    final scheme = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Data check-up')),
      body: f == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  if (f.isEmpty)
                    ListTile(
                      leading: Icon(Icons.verified, color: scheme.primary),
                      title: const Text('Everything looks good'),
                      subtitle: const Text(
                        'Balances add up, no months are missing and most '
                        'spending is categorized.',
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Text(
                        '${f.length} thing${f.length == 1 ? '' : 's'} to look at',
                        style: t.titleMedium,
                      ),
                    ),
                  for (final x in f)
                    ListTile(
                      leading: Icon(
                        x.severity == DoctorSeverity.warning
                            ? Icons.warning_amber_rounded
                            : Icons.info_outline,
                        color: x.severity == DoctorSeverity.warning
                            ? scheme.error
                            : scheme.outline,
                      ),
                      title: Text(x.title),
                      subtitle: Text(x.detail),
                      isThreeLine: true,
                      trailing: x.action == DoctorAction.none ||
                              ((x.action == DoctorAction.importData ||
                                      x.action ==
                                          DoctorAction.resolveUnparsed) &&
                                  widget.onOpenImport == null)
                          ? null
                          : const Icon(Icons.chevron_right),
                      onTap: () => _act(x),
                    ),
                ],
              ),
            ),
    );
  }
}
