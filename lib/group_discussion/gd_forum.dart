import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

// void main() => runApp(const GDArenaApp());

class Topic {
  final String id, title, category, difficulty;
  const Topic({
    required this.id,
    required this.title,
    required this.category,
    required this.difficulty,
  });
  factory Topic.fromJson(Map<String, dynamic> j) => Topic(
    id: j['id'] as String,
    title: j['title'] as String,
    category: j['category'] as String,
    difficulty: j['difficulty'] as String,
  );
}

class Participant {
  final String name, role, style, avatar;
  const Participant({
    required this.name,
    required this.role,
    required this.style,
    required this.avatar,
  });
  factory Participant.fromJson(Map<String, dynamic> j) => Participant(
    name: j['name'] as String,
    role: j['role'] as String,
    style: j['style'] as String,
    avatar: j['avatar'] as String,
  );
}

class GDMessage {
  final String speaker, text;
  final bool user;
  const GDMessage({
    required this.speaker,
    required this.text,
    this.user = false,
  });
}

class GDArenaApp extends StatelessWidget {
  const GDArenaApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'AI Group Discussion Arena',
    theme: ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF818CF8),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF090D16),
      cardTheme: CardThemeData(
        color: const Color(0xFF151C2B),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF090D16),
        centerTitle: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF151C2B),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF30394D)),
        ),
      ),
    ),
    home: const HomePage(),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<(List<Topic>, List<Participant>)> dataFuture;

  @override
  void initState() {
    super.initState();
    dataFuture = _loadData();
  }

  Future<(List<Topic>, List<Participant>)> _loadData() async {
    final topicsRaw = await rootBundle.loadString('assets/topics.json');
    final peopleRaw = await rootBundle.loadString('assets/participants.json');
    final topics = (jsonDecode(topicsRaw) as List)
        .map((e) => Topic.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    final people = (jsonDecode(peopleRaw) as List)
        .map((e) => Participant.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    if (topics.isEmpty || people.isEmpty)
      throw const FormatException('Topics and participants must not be empty.');
    return (topics, people);
  }

  @override
  Widget build(
    BuildContext context,
  ) => FutureBuilder<(List<Topic>, List<Participant>)>(
    future: dataFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (snapshot.hasError || !snapshot.hasData) {
        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Could not load JSON assets.\nCheck pubspec.yaml and assets/topics.json + assets/participants.json.\n\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }
      final topics = snapshot.data!.$1;
      final participants = snapshot.data!.$2;
      return Scaffold(
        appBar: AppBar(
          title: const Text('AI Group Discussion Arena'),
          leading: const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(Icons.groups_rounded),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Color(0xFF272B68), Color(0xFF40245F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.record_voice_over_rounded, size: 42),
                  SizedBox(height: 12),
                  Text(
                    'Practice. Speak. Lead.',
                    style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Practice a timed group discussion with simulated participants. Speak or type your response, listen to replies, and review your practice score.',
                  ),
                  SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text('Voice input')),
                      Chip(label: Text('Spoken replies')),
                      Chip(label: Text('3-minute session')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Choose a GD topic',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            ...topics.map(
              (t) => Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 7,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF343A78),
                    child: Text(
                      t.category.isEmpty ? '?' : t.category[0].toUpperCase(),
                    ),
                  ),
                  title: Text(
                    t.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('${t.category}  •  ${t.difficulty}'),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ArenaPage(topic: t, participants: participants),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class ArenaPage extends StatefulWidget {
  final Topic topic;
  final List<Participant> participants;
  const ArenaPage({super.key, required this.topic, required this.participants});
  @override
  State<ArenaPage> createState() => _ArenaPageState();
}

class _ArenaPageState extends State<ArenaPage> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final _messages = <GDMessage>[];
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  Timer? _timer;
  int _seconds = 180, _round = 0, _contributions = 0;
  bool _started = false,
      _finished = false,
      _sending = false,
      _speechReady = false,
      _listening = false,
      _voiceReplies = true;
  String _speechStatus = 'Voice input not initialized';

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _tts.setLanguage('en-US');
    _tts.setSpeechRate(0.48);
    _tts.setPitch(1.0);
    _tts.setCompletionHandler(() {
      if (mounted) setState(() {});
    });
  }

  Future<void> _initSpeech() async {
    try {
      final ready = await _speech.initialize(
        onStatus: (s) {
          if (mounted)
            setState(() {
              _listening = s == 'listening';
              _speechStatus = s;
            });
        },
        onError: (e) {
          if (mounted)
            setState(() {
              _listening = false;
              _speechStatus = e.errorMsg;
            });
        },
      );
      if (mounted)
        setState(() {
          _speechReady = ready;
          _speechStatus = ready
              ? 'Voice input ready'
              : 'Speech recognition unavailable';
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _speechReady = false;
          _speechStatus = 'Speech setup failed';
        });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _speech.stop();
    _tts.stop();
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _start() {
    setState(() {
      _started = true;
      _finished = false;
      _seconds = 180;
    });
    _messages.add(
      GDMessage(
        speaker: 'Moderator',
        text:
            'Welcome. Topic: ${widget.topic.title}. You have three minutes. Give clear points, examples, and respond respectfully.',
      ),
    );
    _aiOpening();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_seconds <= 1) {
        timer.cancel();
        _finish();
      } else {
        setState(() => _seconds--);
      }
    });
    _jump();
  }

  void _aiOpening() {
    Future.delayed(const Duration(milliseconds: 700), () async {
      if (!mounted || _finished || widget.participants.isEmpty) return;
      final p = widget.participants[_round % widget.participants.length];
      final reply = _openingFor(p);
      setState(() {
        _messages.add(GDMessage(speaker: p.name, text: reply));
        _round++;
      });
      _jump();
      if (_voiceReplies) await _speak(reply);
    });
  }

  String _openingFor(Participant p) {
    switch (p.style) {
      case 'analytical':
        return 'I would start by looking at evidence, measurable outcomes, and both short-term and long-term effects. We should distinguish assumptions from facts.';
      case 'empathetic':
        return 'We should consider how this issue affects different groups differently. A good solution should be inclusive and practical for people.';
      case 'challenging':
        return 'I want to challenge the obvious position. What sounds attractive in theory may create unexpected costs, risks, or trade-offs in practice.';
      default:
        return 'From a practical perspective, we should ask what can actually be implemented, what it costs, and how success can be measured.';
    }
  }

  Future<void> _listen() async {
    if (!_speechReady) {
      await _initSpeech();
      if (!_speechReady) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Speech recognition is unavailable. Check microphone permission and device speech services.',
              ),
            ),
          );
        return;
      }
    }
    if (_listening) {
      await _speech.stop();
      return;
    }
    if (_finished || !_started) return;
    await _speech.listen(
      listenFor: const Duration(seconds: 45),
      pauseFor: const Duration(seconds: 4),
      partialResults: true,
      onResult: (result) {
        if (!mounted) return;
        setState(() => _controller.text = result.recognizedWords);
      },
    );
  }

  Future<void> _speak(String text) async {
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _finished || !_started || _sending) return;
    if (_listening) await _speech.stop();
    _controller.clear();
    setState(() {
      _messages.add(GDMessage(speaker: 'You', text: text, user: true));
      _contributions++;
      _sending = true;
    });
    _jump();
    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted || _finished) return;
    final p = widget.participants[_round % widget.participants.length];
    final reply = _responseFor(p, text);
    setState(() {
      _messages.add(GDMessage(speaker: p.name, text: reply));
      _round++;
      _sending = false;
    });
    _jump();
    if (_voiceReplies) await _speak(reply);
  }

  String _responseFor(Participant p, String userText) {
    final lower = userText.toLowerCase();
    final mentionsExample =
        lower.contains('example') ||
        lower.contains('for instance') ||
        lower.contains('such as');
    final prefix = mentionsExample
        ? 'Your example helps make the point concrete. '
        : '';
    switch (p.style) {
      case 'challenging':
        return '${prefix}That is a useful point, but what happens when the same approach is applied at scale? We should also consider the counterargument.';
      case 'analytical':
        return '${prefix}Your point would be stronger with evidence or a measurable outcome. Implementation details will determine whether the idea succeeds.';
      case 'empathetic':
        return '${prefix}I agree that perspective matters. Different stakeholders may experience the same change very differently, so inclusion is important.';
      default:
        return '${prefix}That could work if execution is practical. We should define priorities, costs, responsibilities, and measurable outcomes.';
    }
  }

  void _finish() {
    if (_finished || !_started) return;
    _timer?.cancel();
    _speech.stop();
    _tts.stop();
    setState(() {
      _finished = true;
      _sending = false;
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ReportPage(
          topic: widget.topic,
          contributions: _contributions,
          secondsUsed: 180 - _seconds,
        ),
      ),
    );
  }

  void _jump() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients)
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_started) {
      return Scaffold(
        appBar: AppBar(title: const Text('GD Briefing')),
        body: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.topic.title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              Text(
                '${widget.topic.category} • ${widget.topic.difficulty} difficulty',
              ),
              const SizedBox(height: 26),
              const Text(
                'Your goals',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                '• Speak clearly and stay relevant\n• Build on other participants’ ideas\n• Use examples or evidence\n• Disagree respectfully\n• Keep contributions concise',
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _start,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start 3-minute GD'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.topic.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: _voiceReplies
                ? 'Mute spoken replies'
                : 'Enable spoken replies',
            onPressed: () => setState(() => _voiceReplies = !_voiceReplies),
            icon: Icon(
              _voiceReplies
                  ? Icons.volume_up_rounded
                  : Icons.volume_off_rounded,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: Text(
                '${_seconds ~/ 60}:${(_seconds % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(value: _seconds / 180, minHeight: 4),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(14),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _bubble(_messages[i]),
            ),
          ),
          if (_sending)
            const Padding(
              padding: EdgeInsets.all(6),
              child: Text('Participant is preparing a reply...'),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
            child: Row(
              children: [
                Icon(
                  _speechReady ? Icons.mic_none_rounded : Icons.mic_off_rounded,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _listening ? 'Listening… speak now' : _speechStatus,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: _listen,
                  child: Text(_listening ? 'Stop mic' : 'Speak'),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: !_finished,
                      maxLines: 3,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Type or use Speak…',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _send,
                    tooltip: 'Send contribution',
                    icon: const Icon(Icons.send_rounded),
                  ),
                  IconButton(
                    onPressed: _finish,
                    tooltip: 'Finish discussion',
                    icon: const Icon(Icons.flag_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(GDMessage m) => Align(
    alignment: m.user ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      constraints: const BoxConstraints(maxWidth: 650),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: m.user ? const Color(0xFF343A78) : const Color(0xFF171E2D),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            m.speaker,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFB9C0FF),
            ),
          ),
          const SizedBox(height: 5),
          Text(m.text),
          if (!m.user)
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: 'Read aloud',
                onPressed: () => _speak(m.text),
                icon: const Icon(Icons.volume_up_rounded, size: 18),
              ),
            ),
        ],
      ),
    ),
  );
}

class ReportPage extends StatelessWidget {
  final Topic topic;
  final int contributions, secondsUsed;
  const ReportPage({
    super.key,
    required this.topic,
    required this.contributions,
    required this.secondsUsed,
  });

  int get content => ((contributions * 13) + 45).clamp(0, 100);
  int get communication => ((contributions * 10) + 42).clamp(0, 100);
  int get relevance => ((contributions * 11) + 40).clamp(0, 100);
  int get teamwork => ((contributions * 9) + 48).clamp(0, 100);
  int get leadership => ((contributions * 8) + 38).clamp(0, 100);
  int get total =>
      ((content + communication + relevance + teamwork + leadership) / 5)
          .round();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Practice Report')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  size: 56,
                  color: Color(0xFFFBBF24),
                ),
                const SizedBox(height: 10),
                Text(
                  '$total / 100',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _grade(total),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '${topic.title}\n$secondsUsed seconds • $contributions contributions',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Skill breakdown',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        _score(context, 'Content Quality', content),
        _score(context, 'Communication', communication),
        _score(context, 'Relevance', relevance),
        _score(context, 'Teamwork & Listening', teamwork),
        _score(context, 'Leadership', leadership),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Practice feedback',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                Text(
                  total >= 75
                      ? 'Good practice effort. Keep arguments concise and support important claims with examples.'
                      : 'Keep practicing. Focus on structured points, responding directly to others, and contributing consistently.',
                ),
                const SizedBox(height: 10),
                const Text(
                  'Next targets:\n• Use Point → Reason → Example\n• Refer to another participant before countering\n• Avoid repeating an existing idea\n• End with a concise recommendation',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Practice another topic'),
        ),
        const SizedBox(height: 8),
        const Text(
          'Note: this is a rule-based practice estimate, not a validated AI assessment of spoken language.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.white60),
        ),
      ],
    ),
  );

  Widget _score(BuildContext context, String name, int value) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(name), Text('$value/100')],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(value: value / 100, minHeight: 8),
        ),
      ],
    ),
  );

  String _grade(int x) => x >= 90
      ? 'Outstanding'
      : x >= 75
      ? 'Strong'
      : x >= 60
      ? 'Good'
      : x >= 40
      ? 'Developing'
      : 'Needs Practice';
}
