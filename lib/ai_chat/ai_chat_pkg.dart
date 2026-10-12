import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

// ============================================================
// APP
// ============================================================

class LocalAIChatbotApp extends StatelessWidget {
  const LocalAIChatbotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Voice Tutor',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF07111F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      home: const ChatPage(),
    );
  }
}

// ============================================================
// MESSAGE MODEL
// ============================================================

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  ChatMessage({required this.text, required this.isUser, required this.time});
}

// ============================================================
// CHAT PAGE
// ============================================================

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  final stt.SpeechToText _speech = stt.SpeechToText();

  final FlutterTts _tts = FlutterTts();

  final List<ChatMessage> _messages = [];

  bool _speechAvailable = false;
  bool _isListening = false;
  bool _isSpeaking = false;

  // ==========================================================
  // INITIALIZATION
  // ==========================================================

  @override
  void initState() {
    super.initState();

    _initializeSpeech();
    _initializeTts();
  }

  Future<void> _initializeSpeech() async {
    final available = await _speech.initialize(
      onStatus: (status) {
        if (!mounted) return;

        setState(() {
          _isListening = status == 'listening';
        });
      },
      onError: (error) {
        if (!mounted) return;

        setState(() {
          _isListening = false;
        });
      },
    );

    if (!mounted) return;

    setState(() {
      _speechAvailable = available;
    });
  }

  Future<void> _initializeTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.48);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _tts.setStartHandler(() {
      if (!mounted) return;

      setState(() {
        _isSpeaking = true;
      });
    });

    _tts.setCompletionHandler(() {
      if (!mounted) return;

      setState(() {
        _isSpeaking = false;
      });
    });

    _tts.setCancelHandler(() {
      if (!mounted) return;

      setState(() {
        _isSpeaking = false;
      });
    });
  }

  // ==========================================================
  // SPEECH TO TEXT
  // ==========================================================

  Future<void> _toggleListening() async {
    if (!_speechAvailable) {
      await _initializeSpeech();
    }

    if (!_speechAvailable) {
      _showSnackBar('Speech recognition is not available.');
      return;
    }

    if (_isListening) {
      await _speech.stop();

      if (!mounted) return;

      setState(() {
        _isListening = false;
      });

      return;
    }

    await _speech.listen(
      onResult: _onSpeechResult,
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        listenMode: stt.ListenMode.dictation,
      ),
    );

    if (!mounted) return;

    setState(() {
      _isListening = true;
    });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (!mounted) return;

    setState(() {
      _textController.text = result.recognizedWords;

      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: _textController.text.length),
      );
    });
  }

  // ==========================================================
  // TEXT TO SPEECH
  // ==========================================================

  Future<void> _speak(String text) async {
    if (text.trim().isEmpty) return;

    await _tts.stop();

    if (!mounted) return;

    setState(() {
      _isSpeaking = true;
    });

    await _tts.speak(text);
  }

  Future<void> _stopSpeaking() async {
    await _tts.stop();

    if (!mounted) return;

    setState(() {
      _isSpeaking = false;
    });
  }

  // ==========================================================
  // SEND
  // ==========================================================

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();

    if (text.isEmpty) return;

    _textController.clear();

    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: true, time: DateTime.now()),
      );
    });

    _scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 500));

    final answer = _generateLocalAIResponse(text);

    setState(() {
      _messages.add(
        ChatMessage(text: answer, isUser: false, time: DateTime.now()),
      );
    });

    _scrollToBottom();
  }

  // ==========================================================
  // LOCAL AI ENGINE
  // ==========================================================

  String _generateLocalAIResponse(String input) {
    final text = input.toLowerCase().trim();

    // --------------------------------------------------------
    // GREETING
    // --------------------------------------------------------

    if (_containsAny(text, ['hello', 'hi', 'hey', 'namaste'])) {
      return '''
Hello! 👋

I am your local AI Tutor.

You can ask me about:
• Physics
• Photonics
• Astronomy
• Mathematics
• Flutter
• Dart
• Programming
• Science
• OMR questions

You can also speak to me using the microphone.
''';
    }

    // --------------------------------------------------------
    // FLUTTER
    // --------------------------------------------------------

    if (_containsAny(text, ['flutter', 'flutter code'])) {
      return '''
Flutter is Google's UI framework for building
applications from a single Dart codebase.

A basic Flutter application contains:

MaterialApp
    ↓
Scaffold
    ↓
AppBar
    ↓
Body
    ↓
Widgets

Example:

void main() {
  runApp(
    const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello Flutter'),
        ),
      ),
    ),
  );
}

Flutter uses widgets to construct the user interface.
''';
    }

    // --------------------------------------------------------
    // DART
    // --------------------------------------------------------

    if (_containsAny(text, ['dart', 'constructor', 'inheritance'])) {
      return '''
Dart is the programming language used by Flutter.

Example class:

class Animal {
  String name;

  Animal(this.name);

  void speak() {
    print('Animal speaks');
  }
}

A subclass can inherit from Animal:

class Dog extends Animal {
  Dog(String name) : super(name);

  @override
  void speak() {
    print('Dog barks');
  }
}
''';
    }

    // --------------------------------------------------------
    // PHYSICS
    // --------------------------------------------------------

    if (_containsAny(text, ['physics', 'force', 'newton', 'mechanics'])) {
      return '''
Newton's second law relates force, mass and acceleration:

F = ma

where:

F = force
m = mass
a = acceleration

The SI unit of force is the newton (N).
''';
    }

    // --------------------------------------------------------
    // PHOTONICS
    // --------------------------------------------------------

    if (_containsAny(text, [
      'photonics',
      'laser',
      'optics',
      'fiber',
      'fibre',
    ])) {
      return '''
Photonics is the science and technology of
generating, controlling and detecting photons.

Important topics include:

• Lasers
• Optical fibers
• Waveguides
• Photodetectors
• Interferometry
• Optical communications
• Quantum optics

For a laser, stimulated emission produces photons
that can contribute to coherent optical amplification.
''';
    }

    // --------------------------------------------------------
    // ASTRONOMY
    // --------------------------------------------------------

    if (_containsAny(text, [
      'astronomy',
      'galaxy',
      'galactic',
      'jeans equation',
      'dark matter',
    ])) {
      return '''
In galactic dynamics, the Jeans equations describe
the evolution of velocity moments of a collisionless
stellar system.

For an axisymmetric disk, the circular velocity is
related to the gravitational potential by:

Vc² = R ∂Φ/∂R

where:

Vc = circular velocity
R  = Galactocentric radius
Φ  = gravitational potential

Stellar velocity dispersion can cause the mean stellar
azimuthal velocity to differ from the circular velocity.
This effect is known as asymmetric drift.
''';
    }

    // --------------------------------------------------------
    // QUANTUM
    // --------------------------------------------------------

    if (_containsAny(text, [
      'quantum',
      'wavefunction',
      'schrodinger',
      'heisenberg',
    ])) {
      return '''
In quantum mechanics, a system is described by a
wavefunction ψ.

The probability density is:

|ψ(x)|²

The Heisenberg uncertainty principle states that
position and momentum cannot both be known with
arbitrarily small uncertainty.

A common expression is:

Δx Δp ≥ ℏ/2
''';
    }

    // --------------------------------------------------------
    // MATHEMATICS
    // --------------------------------------------------------

    if (_containsAny(text, [
      'math',
      'mathematics',
      'derivative',
      'integral',
      'calculus',
    ])) {
      return '''
Calculus studies change and accumulation.

For example:

d/dx (x²) = 2x

and

∫ 2x dx = x² + C

Derivatives describe rates of change,
while integrals describe accumulation.
''';
    }

    // --------------------------------------------------------
    // OMR
    // --------------------------------------------------------

    if (_containsAny(text, ['omr', 'exam', 'question', 'mcq'])) {
      return '''
An OMR examination can contain:

• Question number
• Four answer choices
• Selected answer
• Mark for review
• Question palette
• Automatic scoring
• Negative marking
• Answer review

For example:

Question:
Which quantity represents quantum probability density?

A. ψ
B. ψ²
C. |ψ|²
D. dψ/dx

Correct answer:

C. |ψ|²
''';
    }

    // --------------------------------------------------------
    // HELP
    // --------------------------------------------------------

    if (_containsAny(text, ['help', 'what can you do'])) {
      return '''
I can provide explanations for:

🔬 Science
⚛️ Quantum physics
🌌 Astronomy
💡 Photonics
📐 Mathematics
💻 Dart
📱 Flutter
📝 OMR examinations

Try asking:

"Explain the Jeans equation"

or

"Give me Flutter code for a chatbot."
''';
    }

    // --------------------------------------------------------
    // DEFAULT
    // --------------------------------------------------------

    return '''
I understood your question as:

"$input"

I am currently running without a backend or external AI
model, so my answers are generated by the local knowledge
rules built into this Flutter application.

You can ask me about:

• Physics
• Quantum physics
• Photonics
• Astronomy
• Jeans equations
• Dark matter
• Mathematics
• Dart
• Flutter
• OMR examinations

To make this a true generative AI tutor later, an
on-device language model can be connected without
requiring a conventional FastAPI backend.
''';
  }

  // ==========================================================
  // HELPER
  // ==========================================================

  bool _containsAny(String text, List<String> words) {
    for (final word in words) {
      if (text.contains(word)) {
        return true;
      }
    }

    return false;
  }

  // ==========================================================
  // SCROLL
  // ==========================================================

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // ==========================================================
  // CLEAR
  // ==========================================================

  void _clearChat() {
    setState(() {
      _messages.clear();
    });
  }

  // ==========================================================
  // SNACKBAR
  // ==========================================================

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ==========================================================
  // UI
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1728),
        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                ),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(Icons.smart_toy),
            ),

            const SizedBox(width: 12),

            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Tutor',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  'Local • Voice enabled',
                  style: TextStyle(fontSize: 11, color: Colors.white60),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Clear chat',
            onPressed: _clearChat,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? _welcome()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return _messageBubble(_messages[index]);
                      },
                    ),
            ),

            _inputArea(),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // WELCOME
  // ==========================================================

  Widget _welcome() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(Icons.auto_awesome, size: 46),
            ),

            const SizedBox(height: 24),

            const Text(
              'AI Voice Tutor',
              style: TextStyle(fontSize: 29, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            const Text(
              'Type or speak your question',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60, fontSize: 15),
            ),

            const SizedBox(height: 28),

            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                _suggestion('Explain quantum physics'),
                _suggestion('Explain photonics'),
                _suggestion('Explain Jeans equation'),
                _suggestion('Give Flutter code'),
                _suggestion('Create an OMR question'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _suggestion(String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () {
        _textController.text = text;
        _sendMessage();
      },
    );
  }

  // ==========================================================
  // MESSAGE BUBBLE
  // ==========================================================

  Widget _messageBubble(ChatMessage message) {
    final bool user = message.isUser;

    return Align(
      alignment: user ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 720),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: user ? Colors.blue : const Color(0xFF132238),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(user ? 18 : 4),
            bottomRight: Radius.circular(user ? 4 : 18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(user ? Icons.person : Icons.smart_toy, size: 18),

                const SizedBox(width: 8),

                Text(
                  user ? 'You' : 'AI Tutor',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 10),

            SelectableText(
              message.text,
              style: const TextStyle(fontSize: 15, height: 1.55),
            ),

            if (!user)
              Row(
                children: [
                  const Spacer(),

                  IconButton(
                    tooltip: 'Read answer',
                    onPressed: () {
                      _speak(message.text);
                    },
                    icon: const Icon(Icons.volume_up),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // INPUT
  // ==========================================================

  Widget _inputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      color: const Color(0xFF0B1728),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              minLines: 1,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Type or speak...',
                filled: true,
                fillColor: const Color(0xFF132238),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: IconButton(
                  tooltip: _isListening ? 'Stop' : 'Speak',
                  onPressed: _toggleListening,
                  icon: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: _isListening ? Colors.red : Colors.white70,
                  ),
                ),
                suffixIcon: _isSpeaking
                    ? IconButton(
                        tooltip: 'Stop speaking',
                        onPressed: _stopSpeaking,
                        icon: const Icon(
                          Icons.stop_circle,
                          color: Colors.orange,
                        ),
                      )
                    : null,
              ),
            ),
          ),

          const SizedBox(width: 8),

          SizedBox(
            width: 54,
            height: 54,
            child: FloatingActionButton(
              heroTag: 'send',
              onPressed: _sendMessage,
              backgroundColor: Colors.blue,
              child: const Icon(Icons.send),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _speech.stop();
    _tts.stop();
    super.dispose();
  }
}
