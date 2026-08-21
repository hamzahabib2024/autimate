import 'package:flutter/material.dart';

class RoutinesScreen extends StatelessWidget {
  const RoutinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = const [
      ('Breakfast', '08:00', Icons.restaurant),
      ('Get dressed', '08:30', Icons.checkroom),
      ('School time', '09:00', Icons.school),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Today\'s routine')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'One step at a time',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          ...steps.map(
            (step) => Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: CircleAvatar(child: Icon(step.$3)),
                title: Text(step.$1),
                subtitle: Text(step.$2),
                trailing: Checkbox(value: false, onChanged: (_) {}),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Reminders and transition warnings will connect to local notifications in the next implementation phase.',
          ),
        ],
      ),
    );
  }
}
