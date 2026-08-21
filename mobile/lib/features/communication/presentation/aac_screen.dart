import 'package:flutter/material.dart';

class AacScreen extends StatefulWidget {
  const AacScreen({super.key});

  @override
  State<AacScreen> createState() => _AacScreenState();
}

class _AacScreenState extends State<AacScreen> {
  final List<String> _strip = [];
  final cards = const [
    ('I want', 'میں چاہتا ہوں', Icons.touch_app),
    ('apple', 'سیب', Icons.apple),
    ('water', 'پانی', Icons.water_drop),
    ('happy', 'خوش', Icons.sentiment_satisfied),
    ('help', 'مدد', Icons.pan_tool_outlined),
    ('finished', 'ختم', Icons.check_circle_outline),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Communicate'),
        actions: [
          IconButton(
            tooltip: 'Speak sentence',
            onPressed: _strip.isEmpty ? null : () {},
            icon: const Icon(Icons.volume_up),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Semantics(
            header: true,
            child: Text(
              'Sentence',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _strip.isEmpty
                          ? 'Tap a card to build a sentence'
                          : _strip.join(' '),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (_strip.isNotEmpty)
                    IconButton(
                      tooltip: 'Clear sentence',
                      onPressed: () => setState(_strip.clear),
                      icon: const Icon(Icons.clear),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Core words', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 180,
              mainAxisExtent: 132,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              return Semantics(
                button: true,
                label: card.$1,
                child: Card(
                  child: InkWell(
                    onTap: () => setState(() => _strip.add(card.$1)),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(card.$3, size: 38),
                          const SizedBox(height: 8),
                          Text(
                            card.$1,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(card.$2, textDirection: TextDirection.rtl),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _strip.isEmpty ? null : () {},
            icon: const Icon(Icons.volume_up),
            label: const Text('Speak sentence'),
          ),
        ],
      ),
    );
  }
}
