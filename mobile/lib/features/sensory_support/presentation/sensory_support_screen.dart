import 'package:flutter/material.dart';

class SensorySupportScreen extends StatelessWidget {
  const SensorySupportScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sensory support')),
    body: const Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Card(
            child: ListTile(
              leading: Icon(Icons.air),
              title: Text('Guided breathing'),
              subtitle: Text('Calming activity placeholder'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.volume_down),
              title: Text('Sound and motion controls'),
              subtitle: Text('Global sensory mode is available in Settings'),
            ),
          ),
        ],
      ),
    ),
  );
}
