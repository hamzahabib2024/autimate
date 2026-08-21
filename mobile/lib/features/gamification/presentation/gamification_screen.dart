import 'package:flutter/material.dart';

class GamificationScreen extends StatelessWidget {
  const GamificationScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Stars and progress')),
    body: const Padding(
      padding: EdgeInsets.all(20),
      child: Card(
        child: ListTile(
          leading: Icon(Icons.stars),
          title: Text('Cooperative rewards'),
          subtitle: Text(
            'Stars, badges, streaks, and progress rings will be connected to completed activities.',
          ),
        ),
      ),
    ),
  );
}
