import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Ayaan\'s week',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(
                child: _Metric(label: 'Activities', value: '18'),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _Metric(label: 'Routine', value: '82%'),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _Metric(label: 'Stars', value: '12'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            child: SizedBox(
              height: 190,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Activity completion'),
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _Bar(height: 70, label: 'M'),
                        _Bar(height: 105, label: 'T'),
                        _Bar(height: 85, label: 'W'),
                        _Bar(height: 125, label: 'T'),
                        _Bar(height: 95, label: 'F'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Explainable progress'),
            subtitle: Text(
              'Charts are based on recorded activities and never make clinical claims.',
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

class _Bar extends StatelessWidget {
  const _Bar({required this.height, required this.label});
  final double height;
  final String label;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        width: 28,
        height: height,
        color: Theme.of(context).colorScheme.primary,
      ),
      const SizedBox(height: 4),
      Text(label),
    ],
  );
}
