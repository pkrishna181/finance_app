import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'llm_debug_settings_screen.dart';
import '../../llm/llama_cpp_engine.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key}) : _engine = LlamaCppEngine();

  final LlamaCppEngine _engine;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arth'),
        actions: [
          if (kDebugMode)
            IconButton(
              tooltip: 'LLM debug',
              icon: const Icon(Icons.memory),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => LlmDebugSettingsScreen(engine: _engine),
                ),
              ),
            ),
        ],
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Arth',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12),
              Text(
                'Your money stays on your phone.\nImport a statement or enable SMS to begin.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
