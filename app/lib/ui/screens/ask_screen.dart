import 'package:flutter/material.dart';

class AskScreen extends StatelessWidget {
  const AskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ask')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'On-device Q&A over your transactions.\n'
            'The local model is loaded on first use — nothing leaves the device.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
