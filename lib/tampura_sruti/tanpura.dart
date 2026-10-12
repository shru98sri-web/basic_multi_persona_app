import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

const int sampleRate = 22050;

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   SystemChrome.setSystemUIOverlayStyle(
//     const SystemUiOverlayStyle(
//       statusBarColor: Colors.black,
//       systemNavigationBarColor: Colors.black,
//       statusBarIconBrightness: Brightness.light,
//       systemNavigationBarIconBrightness: Brightness.light,
//     ),
//   );
//
//   final prefs = await SharedPreferences.getInstance();
//
//   runApp(MaterialApp(home: TanpuraDroidApp(prefs: prefs)));
// }

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  final prefs = await SharedPreferences.getInstance();

  if (!getIt.isRegistered<SharedPreferences>()) {
    getIt.registerSingleton<SharedPreferences>(prefs);
  }
}

class TanpuraDroidApp extends StatelessWidget {
  final SharedPreferences prefs;

  const TanpuraDroidApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tanpura Droid',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        canvasColor: const Color(0xFF080808),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFB74D),
          secondary: Color(0xFFFFCC80),
          surface: Color(0xFF111111),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF111111),
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
        sliderTheme: const SliderThemeData(
          activeTrackColor: Color(0xFFFFB74D),
          inactiveTrackColor: Color(0xFF383838),
          thumbColor: Color(0xFFFFB74D),
          overlayColor: Color(0x22FFB74D),
        ),
      ),
      home: TanpuraPage(prefs: prefs),
    );
  }
}

// -----------------------------------------------------------------------------
// MUSICAL CONFIGURATION
// -----------------------------------------------------------------------------

const List<String> shrutiNames = [
  'C',
  'C♯',
  'D',
  'D♯',
  'E',
  'F',
  'F♯',
  'G',
  'G♯',
  'A',
  'A♯',
  'B',
];

const List<String> firstStringNames = ['Pa', 'Ma', 'Ni', 'Komal Ni', 'Sa'];

// Just-intonation ratios relative to Sa.
const List<double> firstStringRatios = [3 / 2, 4 / 3, 15 / 8, 9 / 5, 1];

// -----------------------------------------------------------------------------
// TANPURA AUDIO SYNTHESIS
// -----------------------------------------------------------------------------

Uint8List renderTanpura(Map<String, dynamic> parameters) {
  final double sa = parameters['sa'];
  final double ratio = parameters['ratio'];
  final double cycle = parameters['cycle'];
  final double jivari = parameters['jivari'];

  final int sampleCount = (cycle * sampleRate).round();

  /*
    Four Tanpura strings:

    String 1 = selected Pa / Ma / Ni / Sa
    String 2 = Sa
    String 3 = Sa
    String 4 = lower Sa
  */

  final List<double> frequencies = [sa * ratio, sa, sa * 1.0007, sa / 2];

  /*
    Pluck offsets create the traditional:
    first -> Sa -> Sa -> lower Sa
    pattern.
  */
  final List<int> offsets = [
    0,
    (sampleCount * 0.22).round(),
    (sampleCount * 0.44).round(),
    (sampleCount * 0.66).round(),
  ];

  final Float64List output = Float64List(sampleCount);

  final Random random = Random(7);

  final double tau = cycle / 3.2;

  // Jivari swell.
  final Float64List swell = Float64List(sampleCount);

  for (int i = 0; i < sampleCount; i++) {
    final double t = i / sampleRate;

    final double x = t / 0.6;

    swell[i] = x * exp(1 - x);
  }

  for (int stringIndex = 0; stringIndex < frequencies.length; stringIndex++) {
    final double f0 = frequencies[stringIndex];

    final int maximumHarmonics = min(36, (9500 / f0).floor());

    for (int harmonic = 1; harmonic <= maximumHarmonics; harmonic++) {
      final double angularFrequency =
          2 *
          pi *
          f0 *
          harmonic *
          (1 + 0.00005 * harmonic * harmonic) /
          sampleRate;

      final double harmonicAmplitude = 1 / pow(harmonic, 1.05);

      final double jivariBump = exp(-pow((harmonic - 9) / 5.0, 2));

      final double decay = exp(-(1 + 0.07 * harmonic) / (tau * sampleRate));

      final double phase = random.nextDouble() * 2 * pi;

      double envelope = 1;

      for (int i = 0; i < sampleCount; i++) {
        final double jivariAmount = 1 + jivari * 4 * swell[i] * jivariBump;

        final double amplitude = harmonicAmplitude * envelope * jivariAmount;

        final double attack = i < 66 ? i / 66.0 : 1.0;

        final int outputIndex = (offsets[stringIndex] + i) % sampleCount;

        output[outputIndex] +=
            amplitude * attack * sin(angularFrequency * i + phase);

        envelope *= decay;
      }
    }
  }

  // Normalize.
  double peak = 0;

  for (final value in output) {
    if (value.abs() > peak) {
      peak = value.abs();
    }
  }

  final double scale = peak == 0 ? 0 : 0.85 * 32767 / peak;

  // WAV header.
  final ByteData data = ByteData(44 + sampleCount * 2);

  void writeTag(int offset, String text) {
    for (int i = 0; i < text.length; i++) {
      data.setUint8(offset + i, text.codeUnitAt(i));
    }
  }

  writeTag(0, 'RIFF');

  data.setUint32(4, 36 + sampleCount * 2, Endian.little);

  writeTag(8, 'WAVE');
  writeTag(12, 'fmt ');

  data.setUint32(16, 16, Endian.little);

  // PCM.
  data.setUint16(20, 1, Endian.little);

  // Mono.
  data.setUint16(22, 1, Endian.little);

  data.setUint32(24, sampleRate, Endian.little);

  data.setUint32(28, sampleRate * 2, Endian.little);

  data.setUint16(32, 2, Endian.little);

  data.setUint16(34, 16, Endian.little);

  writeTag(36, 'data');

  data.setUint32(40, sampleCount * 2, Endian.little);

  for (int i = 0; i < sampleCount; i++) {
    data.setInt16(44 + i * 2, (output[i] * scale).round(), Endian.little);
  }

  return data.buffer.asUint8List();
}

// -----------------------------------------------------------------------------
// MAIN PAGE
// -----------------------------------------------------------------------------

class TanpuraPage extends StatefulWidget {
  final SharedPreferences prefs;

  const TanpuraPage({super.key, required this.prefs});

  @override
  State<TanpuraPage> createState() => _TanpuraPageState();
}

class _TanpuraPageState extends State<TanpuraPage>
    with SingleTickerProviderStateMixin {
  final AudioPlayer player = AudioPlayer();

  late final AnimationController animation;

  Timer? debounce;

  int shruti = 0;
  int firstString = 0;
  int octave = 0;

  double cents = 0;
  double cycle = 6;
  double jivari = 0.6;
  double volume = 0.8;
  double referenceA = 440;

  bool playing = false;
  bool rendering = false;

  int generation = 0;

  double get saFrequency {
    return (261.6256 *
            (referenceA / 440) *
            pow(2, shruti / 12) *
            pow(2, octave - 1) *
            pow(2, cents / 1200))
        .toDouble();
  }

  @override
  void initState() {
    super.initState();

    animation = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (cycle * 1000).round()),
    );

    loadSettings();
  }

  // ---------------------------------------------------------------------------
  // PERSISTENT SETTINGS
  // ---------------------------------------------------------------------------

  Future<void> loadSettings() async {
    setState(() {
      shruti = widget.prefs.getInt('tanpura_shruti') ?? 0;

      firstString = widget.prefs.getInt('tanpura_first') ?? 0;

      octave = widget.prefs.getInt('tanpura_octave') ?? 0;

      cents = widget.prefs.getDouble('tanpura_cents') ?? 0;

      cycle = widget.prefs.getDouble('tanpura_cycle') ?? 6;

      jivari = widget.prefs.getDouble('tanpura_jivari') ?? 0.6;

      volume = widget.prefs.getDouble('tanpura_volume') ?? 0.8;

      referenceA = widget.prefs.getDouble('tanpura_reference') ?? 440;

      animation.duration = Duration(milliseconds: (cycle * 1000).round());
    });
  }

  void saveSettings() {
    widget.prefs.setInt('tanpura_shruti', shruti);

    widget.prefs.setInt('tanpura_first', firstString);

    widget.prefs.setInt('tanpura_octave', octave);

    widget.prefs.setDouble('tanpura_cents', cents);

    widget.prefs.setDouble('tanpura_cycle', cycle);

    widget.prefs.setDouble('tanpura_jivari', jivari);

    widget.prefs.setDouble('tanpura_volume', volume);

    widget.prefs.setDouble('tanpura_reference', referenceA);
  }

  void configurationChanged() {
    saveSettings();

    if (!playing) return;

    debounce?.cancel();

    debounce = Timer(const Duration(milliseconds: 350), renderAudio);
  }

  // ---------------------------------------------------------------------------
  // AUDIO
  // ---------------------------------------------------------------------------

  Future<void> renderAudio() async {
    final int currentGeneration = ++generation;

    if (mounted) {
      setState(() {
        rendering = true;
      });
    }

    final Uint8List bytes = await compute(renderTanpura, {
      'sa': saFrequency,
      'ratio': firstStringRatios[firstString],
      'cycle': cycle,
      'jivari': jivari,
    });

    if (!mounted || currentGeneration != generation) {
      return;
    }

    await player.setReleaseMode(ReleaseMode.loop);

    await player.setVolume(volume);

    await player.play(BytesSource(bytes));

    animation.duration = Duration(milliseconds: (cycle * 1000).round());

    animation.repeat();

    if (mounted) {
      setState(() {
        rendering = false;
      });
    }
  }

  Future<void> togglePlayback() async {
    if (playing) {
      generation++;

      debounce?.cancel();

      await player.stop();

      animation.stop();

      if (mounted) {
        setState(() {
          playing = false;
          rendering = false;
        });
      }

      return;
    }

    setState(() {
      playing = true;
    });

    await renderAudio();
  }

  // ---------------------------------------------------------------------------
  // DISPOSE
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    debounce?.cancel();
    player.dispose();
    animation.dispose();

    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // UI HELPERS
  // ---------------------------------------------------------------------------

  Widget settingSlider({
    required String title,
    required double value,
    required double min,
    required double max,
    int? divisions,
    required ValueChanged<double> onChanged,
    bool rerender = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              value.toStringAsFixed(1),
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
          onChangeEnd: (_) {
            if (rerender) {
              configurationChanged();
            } else {
              saveSettings();
            }
          },
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final double sa = saFrequency;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        titleSpacing: 18,
        title: const Row(
          children: [
            Icon(Icons.music_note_rounded, color: Color(0xFFFFB74D)),
            SizedBox(width: 9),
            Text(
              'Tanpura Droid',
              style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: .2),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Reset',
            onPressed: () {
              setState(() {
                shruti = 0;
                firstString = 0;
                octave = 0;
                cents = 0;
                cycle = 6;
                jivari = .6;
                volume = .8;
                referenceA = 440;
              });

              saveSettings();

              if (playing) {
                renderAudio();
              }
            },
            icon: const Icon(Icons.restart_alt_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 5, 14, 30),
        children: [
          // -------------------------------------------------------------------
          // STATUS
          // -------------------------------------------------------------------
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: playing && !rendering
                          ? const Color(0xFFFFB74D)
                          : Colors.white24,
                      boxShadow: playing && !rendering
                          ? const [
                              BoxShadow(
                                color: Color(0x66FFB74D),
                                blurRadius: 12,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rendering
                              ? 'GENERATING SOUND'
                              : playing
                              ? 'PLAYING'
                              : 'READY',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${firstStringNames[firstString]} – Sa – Sa – Sa',
                          style: const TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.graphic_eq_rounded,
                    color: Color(0xFFFFB74D),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // -------------------------------------------------------------------
          // FOUR HORIZONTAL STRINGS
          // -------------------------------------------------------------------
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Text(
                        'Tanpura Strings',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Spacer(),
                      Text(
                        '4 STRING',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.white38,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 180,
                    child: AnimatedBuilder(
                      animation: animation,
                      builder: (_, __) {
                        return CustomPaint(
                          painter: TanpuraStringsPainter(
                            animation.value,
                            cycle,
                            playing && !rendering,
                            const Color(0xFFFFB74D),
                          ),
                          child: const SizedBox.expand(),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: stringLabel('1', firstStringNames[firstString]),
                      ),
                      Expanded(child: stringLabel('2', 'Sa')),
                      Expanded(child: stringLabel('3', 'Sa')),
                      Expanded(child: stringLabel('4', 'Sa ↓')),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // -------------------------------------------------------------------
          // START BUTTON
          // -------------------------------------------------------------------
          Center(
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: playing
                    ? const Color(0xFFB3261E)
                    : const Color(0xFFFFB74D),
                foregroundColor: playing ? Colors.white : Colors.black,
                minimumSize: const Size(210, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: togglePlayback,
              icon: rendering
                  ? const SizedBox(
                      width: 19,
                      height: 19,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : Icon(
                      playing ? Icons.stop_rounded : Icons.play_arrow_rounded,
                    ),
              label: Text(
                rendering
                    ? 'Generating...'
                    : playing
                    ? 'STOP TANPURA'
                    : 'START TANPURA',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // -------------------------------------------------------------------
          // CURRENT PITCH
          // -------------------------------------------------------------------
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.piano, color: Color(0xFFFFB74D)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Sa',
                          style: TextStyle(color: Colors.white54),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${sa.toStringAsFixed(2)} Hz',
                          style: const TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    shrutiNames[shruti],
                    style: const TextStyle(
                      color: Color(0xFFFFCC80),
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // -------------------------------------------------------------------
          // SHRUTI
          // -------------------------------------------------------------------
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SHRUTI / SA',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      for (int i = 0; i < shrutiNames.length; i++)
                        ChoiceChip(
                          label: Text(shrutiNames[i]),
                          selected: shruti == i,
                          selectedColor: const Color(0xFFFFB74D),
                          backgroundColor: const Color(0xFF1B1B1B),
                          labelStyle: TextStyle(
                            color: shruti == i ? Colors.black : Colors.white70,
                            fontWeight: FontWeight.w700,
                          ),
                          onSelected: (_) {
                            setState(() {
                              shruti = i;
                            });

                            configurationChanged();
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // -------------------------------------------------------------------
          // FIRST STRING
          // -------------------------------------------------------------------
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FIRST STRING',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      for (int i = 0; i < firstStringNames.length; i++)
                        ChoiceChip(
                          label: Text(firstStringNames[i]),
                          selected: firstString == i,
                          selectedColor: const Color(0xFFFFB74D),
                          backgroundColor: const Color(0xFF1B1B1B),
                          labelStyle: TextStyle(
                            color: firstString == i
                                ? Colors.black
                                : Colors.white70,
                            fontWeight: FontWeight.w700,
                          ),
                          onSelected: (_) {
                            setState(() {
                              firstString = i;
                            });

                            configurationChanged();
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // -------------------------------------------------------------------
          // PITCH
          // -------------------------------------------------------------------
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'PITCH',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: -1, label: Text('Mandra')),
                      ButtonSegment(value: 0, label: Text('Madhya')),
                      ButtonSegment(value: 1, label: Text('Taar')),
                    ],
                    selected: {octave},
                    onSelectionChanged: (selection) {
                      setState(() {
                        octave = selection.first;
                      });

                      configurationChanged();
                    },
                  ),
                  const SizedBox(height: 12),
                  settingSlider(
                    title: 'Fine Tune: ${cents.round()} cents',
                    value: cents,
                    min: -50,
                    max: 50,
                    divisions: 100,
                    onChanged: (value) {
                      setState(() {
                        cents = value;
                      });
                    },
                  ),
                  settingSlider(
                    title: 'Reference A4: ${referenceA.round()} Hz',
                    value: referenceA,
                    min: 430,
                    max: 450,
                    divisions: 20,
                    onChanged: (value) {
                      setState(() {
                        referenceA = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // -------------------------------------------------------------------
          // SOUND SETTINGS
          // -------------------------------------------------------------------
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'SOUND ENGINE',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  settingSlider(
                    title: 'Pluck Cycle: ${cycle.toStringAsFixed(1)} sec',
                    value: cycle,
                    min: 4,
                    max: 9,
                    divisions: 50,
                    onChanged: (value) {
                      setState(() {
                        cycle = value;
                      });

                      animation.duration = Duration(
                        milliseconds: (cycle * 1000).round(),
                      );
                    },
                  ),
                  settingSlider(
                    title: 'Jivari: ${(jivari * 100).round()}%',
                    value: jivari,
                    min: 0,
                    max: 1,
                    divisions: 20,
                    onChanged: (value) {
                      setState(() {
                        jivari = value;
                      });
                    },
                  ),
                  settingSlider(
                    title: 'Volume: ${(volume * 100).round()}%',
                    value: volume,
                    min: 0,
                    max: 1,
                    onChanged: (value) {
                      setState(() {
                        volume = value;
                      });

                      player.setVolume(value);
                    },
                    rerender: false,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          // -------------------------------------------------------------------
          // FOOTER
          // -------------------------------------------------------------------
          const Center(
            child: Text(
              'TANPURA DROID',
              style: TextStyle(
                color: Colors.white24,
                fontSize: 10,
                letterSpacing: 3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget stringLabel(String number, String note) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(color: Colors.white30, fontSize: 10),
        ),
        const SizedBox(height: 3),
        Text(
          note,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// STRING VISUALIZER
// -----------------------------------------------------------------------------

class TanpuraStringsPainter extends CustomPainter {
  final double animationValue;
  final double cycle;
  final bool active;
  final Color color;

  TanpuraStringsPainter(
    this.animationValue,
    this.cycle,
    this.active,
    this.color,
  );

  static const List<double> plucks = [0.00, 0.22, 0.44, 0.66];

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;

    for (int stringIndex = 0; stringIndex < 4; stringIndex++) {
      final double y = size.height * (stringIndex + 1) / 5;

      double amplitude = 0;

      if (active) {
        double delta = (animationValue - plucks[stringIndex]) % 1.0;

        amplitude = 15 * exp(-delta * 4.5);
      }

      final Paint paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = stringIndex == 3
            ? 3.5
            : stringIndex == 0
            ? 2.5
            : 1.8
        ..color = color.withOpacity(active ? 0.95 : 0.42);

      final Path path = Path();

      path.moveTo(0, y);

      for (double x = 0; x <= width; x += 3) {
        final double position = x / width;

        final double wave =
            amplitude *
            sin(pi * position) *
            sin(animationValue * cycle * 2 * pi * 9);

        path.lineTo(x, y + wave);
      }

      canvas.drawPath(path, paint);

      // Small bridge marker.
      final Paint bridge = Paint()
        ..color = color.withOpacity(active ? .8 : .25)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(8, y), 4, bridge);

      canvas.drawCircle(Offset(width - 8, y), 4, bridge);
    }
  }

  @override
  bool shouldRepaint(covariant TanpuraStringsPainter oldDelegate) {
    return true;
  }
}
