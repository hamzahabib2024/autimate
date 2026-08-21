// AutiMate — Urdu TTS probe.
//
// A throwaway app that answers one question: does THIS phone have a usable
// Urdu voice? Run it on the physical demo device, read the report on screen,
// then run it again with airplane mode ON.
//
// Nothing here is production code. It exists to retire a risk on Day 0.

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() => runApp(const ProbeApp());

class ProbeApp extends StatelessWidget {
  const ProbeApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Urdu TTS probe',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: const Color(0xFF0F766E)),
        home: const ProbePage(),
      );
}

class ProbePage extends StatefulWidget {
  const ProbePage({super.key});

  @override
  State<ProbePage> createState() => _ProbePageState();
}

class _ProbePageState extends State<ProbePage> {
  static const urduSentence = 'السلام علیکم، میں سیب چاہتا ہوں';
  static const englishSentence = 'I want an apple.';

  final FlutterTts _tts = FlutterTts();
  final List<String> _log = <String>[];
  bool _running = false;

  void _add(String line) => setState(() => _log.add(line));

  @override
  void initState() {
    super.initState();
    _probe();
  }

  Future<void> _probe() async {
    setState(() {
      _running = true;
      _log.clear();
    });

    _add('=== AutiMate Urdu TTS probe ===');

    // 1. Which engines are installed? (Android only — null elsewhere.)
    try {
      final engines = await _tts.getEngines;
      _add('');
      _add('ENGINES INSTALLED');
      if (engines == null || (engines as List).isEmpty) {
        _add('  none reported');
      } else {
        for (final e in engines) {
          _add('  $e');
        }
      }
      final defaultEngine = await _tts.getDefaultEngine;
      _add('  default engine: $defaultEngine');
    } catch (e) {
      _add('  getEngines failed: $e');
    }

    // 2. Every locale the CURRENT engine claims to know.
    List<dynamic> languages = <dynamic>[];
    try {
      languages = (await _tts.getLanguages) as List<dynamic>? ?? <dynamic>[];
    } catch (e) {
      _add('getLanguages failed: $e');
    }
    _add('');
    _add('LOCALES REPORTED: ${languages.length}');
    final urduLocales =
        languages.where((l) => l.toString().toLowerCase().startsWith('ur')).toList();
    if (urduLocales.isEmpty) {
      _add('  NO locale starting with "ur"  <-- this is the bad outcome');
    } else {
      for (final l in urduLocales) {
        _add('  URDU LOCALE FOUND: $l');
      }
    }

    // 3. Ask directly about the three tags the app will try, in order.
    _add('');
    _add('DIRECT AVAILABILITY CHECKS');
    for (final tag in const ['ur-PK', 'ur-IN', 'ur']) {
      try {
        final available = await _tts.isLanguageAvailable(tag);
        _add('  isLanguageAvailable("$tag") = $available');
      } catch (e) {
        _add('  isLanguageAvailable("$tag") threw $e');
      }
    }

    // 4. Named voices — a voice can be listed while its data is NOT downloaded.
    try {
      final voices = (await _tts.getVoices) as List<dynamic>? ?? <dynamic>[];
      final urduVoices = voices
          .where((v) => v.toString().toLowerCase().contains('ur-') ||
              v.toString().toLowerCase().contains('urdu'))
          .toList();
      _add('');
      _add('VOICES: ${voices.length} total, ${urduVoices.length} look Urdu');
      for (final v in urduVoices) {
        _add('  $v');
      }
    } catch (e) {
      _add('getVoices failed: $e');
    }

    _add('');
    _add('Now press the SPEAK buttons and LISTEN.');
    _add('A query answering true is encouraging. Hearing it is proof.');
    _add('Repeat the whole test with airplane mode ON.');

    setState(() => _running = false);
  }

  Future<void> _speak(String text, String locale) async {
    try {
      await _tts.stop();
      await _tts.setLanguage(locale);
      await _tts.setSpeechRate(0.45); // the Android default is too fast for a child
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);
      final result = await _tts.speak(text);
      _add('speak("$locale") returned $result  —  did you HEAR it?');
    } catch (e) {
      _add('speak("$locale") threw $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Urdu TTS probe'),
        actions: [
          IconButton(
            onPressed: _running ? null : _probe,
            icon: const Icon(Icons.refresh),
            tooltip: 'Run the probe again',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: () => _speak(englishSentence, 'en-US'),
                  child: const Text('Speak English'),
                ),
                FilledButton(
                  onPressed: () => _speak(urduSentence, 'ur-PK'),
                  child: const Text('Speak ur-PK'),
                ),
                FilledButton.tonal(
                  onPressed: () => _speak(urduSentence, 'ur-IN'),
                  child: const Text('Speak ur-IN'),
                ),
                FilledButton.tonal(
                  onPressed: () => _speak(urduSentence, 'ur'),
                  child: const Text('Speak ur'),
                ),
                OutlinedButton(
                  onPressed: () => _tts.stop(),
                  child: const Text('Stop'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _log.length,
              itemBuilder: (_, i) => Text(
                _log[i],
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
