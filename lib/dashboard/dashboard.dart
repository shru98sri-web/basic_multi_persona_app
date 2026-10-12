// Student Progress Dashboard: 150 students, neon-blue style, progress sliders,
// 3 pages (Dashboard, Students, AI Insights) with on-device ML (pure Dart).
// Single file, NO extra packages. Copy to lib/main.dart and run:
//   flutter run -d chrome

import 'dart:math' as math;

import 'package:flutter/material.dart';

// void main() => runApp(const StudentDashboardApp());

// ─────────────────────────────────────────────────────────────
// THEME
// ─────────────────────────────────────────────────────────────

const Color kBgTop = Color(0xFF050F3D);
const Color kBgBottom = Color(0xFF0B2C9A);
const Color kCard = Color(0xB30A1F6B);
const Color kBorder = Color(0xFF2F6BFF);
const Color kBlue = Color(0xFF3D7BFF);
const Color kCyan = Color(0xFF2DD4FF);
const Color kGreen = Color(0xFF35E0A1);
const Color kOrange = Color(0xFFFFB547);
const Color kRed = Color(0xFFFF5C7A);
const Color kPurple = Color(0xFFB28CFF);
const Color kMuted = Color(0xFF9DB4FF);

const List<Color> kPalette = [kBlue, kCyan, kGreen, kOrange, kPurple];

const TextStyle kMutedStyle = TextStyle(fontSize: 12, color: kMuted);
const TextStyle kTitleStyle = TextStyle(fontSize: 15, fontWeight: FontWeight.bold);

// ─────────────────────────────────────────────────────────────
// DEMO DATA: 150 students (deterministic)
// ─────────────────────────────────────────────────────────────

const List<String> kBatches = ['Batch A', 'Batch B', 'Batch C', 'Batch D', 'Batch E'];
const List<String> kStatuses = ['Completed', 'On track', 'Behind', 'At risk'];
const List<String> kStatusShort = ['Done', 'On track', 'Behind', 'At risk'];
const List<String> kSkills = ['Math', 'Science', 'English', 'Coding', 'Reasoning'];
const int kWeeks = 12;

Color statusColor(String status) {
  switch (status) {
    case 'Completed':
      return kGreen;
    case 'On track':
      return kBlue;
    case 'Behind':
      return kOrange;
    default:
      return kRed;
  }
}

double avg(Iterable<double> values) {
  if (values.isEmpty) return 0;
  return values.reduce((a, b) => a + b) / values.length;
}

class Student {
  final int id;
  final String name;
  final String batch;
  final List<double> weekly; // cumulative progress % for 12 weeks
  final double hours;
  final double score;
  final double attendance;
  final List<double> skills; // 5 skill levels

  Student({
    required this.id,
    required this.name,
    required this.batch,
    required this.weekly,
    required this.hours,
    required this.score,
    required this.attendance,
    required this.skills,
  });

  double get progress => weekly.last;

  String get status {
    if (progress >= 80) return 'Completed';
    if (progress >= 50) return 'On track';
    if (progress >= 25) return 'Behind';
    return 'At risk';
  }

  String get initials {
    final parts = name.split(' ');
    return '${parts.first[0]}${parts.last[0]}';
  }
}

List<Student> generateStudents() {
  final rnd = math.Random(2026);
  const first = [
    'Aarav', 'Vivaan', 'Aditya', 'Diya', 'Ananya', 'Ishaan', 'Kavya', 'Rohan',
    'Meera', 'Arjun', 'Sneha', 'Karthik', 'Priya', 'Rahul', 'Divya', 'Vikram',
    'Nisha', 'Suresh', 'Lakshmi', 'Manoj', 'Pooja', 'Naveen', 'Harini', 'Gokul',
    'Swathi',
  ];
  const last = [
    'Kumar', 'Sharma', 'Reddy', 'Iyer', 'Nair', 'Patel', 'Singh', 'Menon',
    'Das', 'Gupta', 'Rao', 'Pillai', 'Naidu',
  ];

  return List.generate(150, (i) {
    final pace = 1.5 + rnd.nextDouble() * 8.5;
    double current = 0;
    final weekly = <double>[];
    for (var w = 0; w < kWeeks; w++) {
      current += pace * (0.5 + rnd.nextDouble());
      if (current > 100) current = 100;
      weekly.add(current);
    }
    final progress = weekly.last;
    final hours = 20 + pace * 12 + rnd.nextDouble() * 40;
    final score =
    (35 + progress * 0.5 + rnd.nextDouble() * 15).clamp(0.0, 100.0).toDouble();
    final attendance =
    (60 + progress * 0.3 + rnd.nextDouble() * 10).clamp(0.0, 100.0).toDouble();
    final skills = List.generate(
      kSkills.length,
          (_) => (progress * 0.6 + 20 + rnd.nextDouble() * 20).clamp(0.0, 100.0).toDouble(),
    );
    return Student(
      id: i + 1,
      name: '${first[i % first.length]} ${last[(i * 2 + i ~/ first.length) % last.length]}',
      batch: kBatches[i % kBatches.length],
      weekly: weekly,
      hours: hours,
      score: score,
      attendance: attendance,
      skills: skills,
    );
  });
}

final List<Student> kStudents = generateStudents();

// ─────────────────────────────────────────────────────────────
// ML / AI ENGINE (pure Dart, trains on-device in milliseconds)
//  1. Linear regression   -> forecast each student's progress
//  2. Logistic regression -> probability of completing the course
//  3. K-means clustering  -> group students by behaviour
//  4. Rule-based coach    -> personalised recommendations
// ─────────────────────────────────────────────────────────────

const List<String> kClusterNames = [
  'Top performers',
  'Steady learners',
  'Slow starters',
  'Need support',
];
const List<String> kClusterShort = ['Top', 'Steady', 'Slow', 'Support'];
const List<String> kFeatureNames = [
  'Week-6 progress',
  'Early weekly pace',
  'Hours studied',
  'Test score',
];

final List<Color> kClusterColors = [
  statusColor('Completed'),
  statusColor('On track'),
  statusColor('Behind'),
  statusColor('At risk'),
];

double sigmoid(double z) => 1 / (1 + math.exp(-z));

class Forecast {
  final double slope;
  final double intercept;
  const Forecast(this.slope, this.intercept);

  double at(int week) => (intercept + slope * week).clamp(0.0, 100.0).toDouble();

  double? get etaWeek {
    if (slope < 0.05) return null;
    return (100 - intercept) / slope;
  }
}

Forecast fitLine(List<double> ys) {
  final n = ys.length;
  final mx = (n + 1) / 2;
  final my = avg(ys);
  var sxy = 0.0;
  var sxx = 0.0;
  for (var i = 0; i < n; i++) {
    final dx = (i + 1) - mx;
    sxy += dx * (ys[i] - my);
    sxx += dx * dx;
  }
  final slope = sxx == 0 ? 0.0 : sxy / sxx;
  return Forecast(slope, my - slope * mx);
}

/// Features use only the FIRST 6 WEEKS to predict who finishes (>= 80%).
List<double> mlFeatures(Student s) => [
  s.weekly[5],
  fitLine(s.weekly.sublist(0, 6)).slope,
  s.hours,
  s.score,
];

class TrainResult {
  final List<double> w;
  final double b;
  final List<double> mean;
  final List<double> std;
  final List<double> trainAcc;
  final List<double> testAcc;

  TrainResult(this.w, this.b, this.mean, this.std, this.trainAcc, this.testAcc);

  double predict(List<double> x) {
    var s = b;
    for (var j = 0; j < w.length; j++) {
      s += w[j] * (x[j] - mean[j]) / std[j];
    }
    return sigmoid(s);
  }
}

TrainResult trainLogistic(List<Student> students) {
  final xs = students.map(mlFeatures).toList();
  final ys = students.map((s) => s.progress >= 80 ? 1.0 : 0.0).toList();

  // 70% train / 30% test
  final trainIdx = <int>[];
  final testIdx = <int>[];
  for (var i = 0; i < students.length; i++) {
    if (i % 10 < 7) {
      trainIdx.add(i);
    } else {
      testIdx.add(i);
    }
  }

  final d = xs.first.length;
  final mean = List<double>.filled(d, 0);
  final std = List<double>.filled(d, 1);
  for (var j = 0; j < d; j++) {
    final col = trainIdx.map((i) => xs[i][j]).toList();
    final m = avg(col);
    final variance = avg(col.map((v) => (v - m) * (v - m)));
    mean[j] = m;
    std[j] = variance < 1e-9 ? 1.0 : math.sqrt(variance);
  }

  final z = xs
      .map((x) => List.generate(d, (j) => (x[j] - mean[j]) / std[j]))
      .toList();

  final w = List<double>.filled(d, 0);
  var b = 0.0;
  const lr = 0.4;
  const epochs = 400;

  double prob(int i) {
    var s = b;
    for (var j = 0; j < d; j++) {
      s += w[j] * z[i][j];
    }
    return sigmoid(s);
  }

  double accuracy(List<int> idx) {
    var ok = 0;
    for (final i in idx) {
      if ((prob(i) >= 0.5) == (ys[i] == 1.0)) ok++;
    }
    return 100 * ok / idx.length;
  }

  final trainAcc = <double>[];
  final testAcc = <double>[];
  for (var e = 1; e <= epochs; e++) {
    final gw = List<double>.filled(d, 0);
    var gb = 0.0;
    for (final i in trainIdx) {
      final err = prob(i) - ys[i];
      for (var j = 0; j < d; j++) {
        gw[j] += err * z[i][j];
      }
      gb += err;
    }
    for (var j = 0; j < d; j++) {
      w[j] -= lr * gw[j] / trainIdx.length;
    }
    b -= lr * gb / trainIdx.length;
    if (e % 20 == 0) {
      trainAcc.add(accuracy(trainIdx));
      testAcc.add(accuracy(testIdx));
    }
  }
  return TrainResult(w, b, mean, std, trainAcc, testAcc);
}

class ClusterResult {
  final List<int> assignment; // cluster rank per student (0 = best group)
  final List<int> sizes;
  final List<double> avgProgress;
  final List<double> avgScore;
  final List<double> avgHours;
  ClusterResult(this.assignment, this.sizes, this.avgProgress, this.avgScore, this.avgHours);
}

ClusterResult kMeans(List<Student> students, int k) {
  const d = 3;
  final raw = students.map((s) => <double>[s.progress, s.score, s.hours]).toList();

  final mean = List<double>.filled(d, 0);
  final std = List<double>.filled(d, 1);
  for (var j = 0; j < d; j++) {
    final col = raw.map((r) => r[j]).toList();
    final m = avg(col);
    final variance = avg(col.map((v) => (v - m) * (v - m)));
    mean[j] = m;
    std[j] = variance < 1e-9 ? 1.0 : math.sqrt(variance);
  }
  final z = raw
      .map((r) => List<double>.generate(d, (j) => (r[j] - mean[j]) / std[j]))
      .toList();

  final rnd = math.Random(7);
  final chosen = <int>[];
  while (chosen.length < k) {
    final i = rnd.nextInt(students.length);
    if (!chosen.contains(i)) chosen.add(i);
  }
  final cent = chosen.map((i) => List<double>.from(z[i])).toList();
  final assign = List<int>.filled(students.length, 0);

  for (var iter = 0; iter < 30; iter++) {
    for (var i = 0; i < students.length; i++) {
      var best = 0;
      var bestDist = double.infinity;
      for (var c = 0; c < k; c++) {
        var dist = 0.0;
        for (var j = 0; j < d; j++) {
          final diff = z[i][j] - cent[c][j];
          dist += diff * diff;
        }
        if (dist < bestDist) {
          bestDist = dist;
          best = c;
        }
      }
      assign[i] = best;
    }
    final sums = List.generate(k, (_) => List<double>.filled(d, 0));
    final counts = List<int>.filled(k, 0);
    for (var i = 0; i < students.length; i++) {
      counts[assign[i]]++;
      for (var j = 0; j < d; j++) {
        sums[assign[i]][j] += z[i][j];
      }
    }
    for (var c = 0; c < k; c++) {
      if (counts[c] > 0) {
        for (var j = 0; j < d; j++) {
          cent[c][j] = sums[c][j] / counts[c];
        }
      }
    }
  }

  // Rank clusters by average progress so rank 0 = strongest group
  final rawAvgProgress = List.generate(k, (c) {
    final members = [
      for (var i = 0; i < students.length; i++)
        if (assign[i] == c) students[i].progress
    ];
    return avg(members);
  });
  final order = List<int>.generate(k, (c) => c)
    ..sort((a, b) => rawAvgProgress[b].compareTo(rawAvgProgress[a]));
  final rankOf = List<int>.filled(k, 0);
  for (var r = 0; r < k; r++) {
    rankOf[order[r]] = r;
  }
  final ranked = assign.map((c) => rankOf[c]).toList();

  List<double> groupAvg(double Function(Student) pick) => List.generate(k, (r) {
    final members = [
      for (var i = 0; i < students.length; i++)
        if (ranked[i] == r) pick(students[i])
    ];
    return avg(members);
  });

  return ClusterResult(
    ranked,
    List.generate(k, (r) => ranked.where((x) => x == r).length),
    groupAvg((s) => s.progress),
    groupAvg((s) => s.score),
    groupAvg((s) => s.hours),
  );
}

class MlResult {
  final List<Forecast> forecasts; // index = student id - 1
  final List<double> completeProb;
  final TrainResult model;
  final ClusterResult clusters;
  MlResult(this.forecasts, this.completeProb, this.model, this.clusters);
}

MlResult runMl(List<Student> students) {
  final model = trainLogistic(students);
  return MlResult(
    students.map((s) => fitLine(s.weekly)).toList(),
    students.map((s) => model.predict(mlFeatures(s))).toList(),
    model,
    kMeans(students, 4),
  );
}

final MlResult kMl = runMl(kStudents);

List<String> coachTips(Student s) {
  final i = s.id - 1;
  final prob = kMl.completeProb[i];
  final f = kMl.forecasts[i];
  final tips = <String>[];

  if (s.progress < 80 && prob < 0.4) {
    tips.add(
        'High risk of not finishing (${((1 - prob) * 100).round()}%). Arrange a mentor check-in this week.');
  }
  if (s.progress < 80 && f.slope < 5) {
    tips.add(
        'Pace is ${f.slope.toStringAsFixed(1)}% per week. Add about 30 minutes of daily practice.');
  }
  var weakest = 0;
  for (var k = 1; k < kSkills.length; k++) {
    if (s.skills[k] < s.skills[weakest]) weakest = k;
  }
  if (s.skills[weakest] < 55) {
    tips.add(
        'Weakest subject is ${kSkills[weakest]} (${s.skills[weakest].toStringAsFixed(0)}). Give it extra practice.');
  }
  if (s.attendance < 70) {
    tips.add('Attendance is ${s.attendance.toStringAsFixed(0)}%. Follow up with the student.');
  }
  if (s.progress >= 80) {
    tips.add('Course nearly done. Suggest an advanced module or a peer-mentor role.');
  }
  if (tips.isEmpty) {
    tips.add('Healthy pace. Keep the current routine.');
  }
  return tips;
}

// ─────────────────────────────────────────────────────────────
// APP SHELL: sidebar, header, right gear rail
// ─────────────────────────────────────────────────────────────

class StudentDashboardApp extends StatelessWidget {
  const StudentDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Progress Dashboard',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorSchemeSeed: kBlue,
      ),
      home: const DashboardShell(),
    );
  }
}

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int page = 0;
  String batch = 'All';
  double riskThreshold = 0.4;

  static const titles = ['Student Progress Dashboard', 'Students', 'AI Insights'];

  List<Student> get scope =>
      batch == 'All' ? kStudents : kStudents.where((s) => s.batch == batch).toList();

  void openSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0A1F6B),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(
                'High-risk threshold: completion probability below ${(riskThreshold * 100).round()}%',
              ),
              Slider(
                value: riskThreshold,
                min: 0.2,
                max: 0.7,
                divisions: 10,
                onChanged: (v) {
                  setState(() => riskThreshold = v);
                  setSheet(() {});
                },
              ),
              const Text(
                'Students whose predicted chance of finishing is below this value are flagged high-risk on the AI Insights page.',
                style: kMutedStyle,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final students = scope;
    final pages = <Widget>[
      DashboardPage(students: students),
      StudentsPage(students: students),
      AiPage(students: students, riskThreshold: riskThreshold),
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kBgTop, kBgBottom],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(builder: (context, c) {
            final extended = c.maxWidth >= 1000;
            final showRail = c.maxWidth >= 700;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Sidebar(
                  extended: extended,
                  selected: page,
                  onSelect: (i) => setState(() => page = i),
                  onSettings: openSettings,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(titles[page],
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 20, fontWeight: FontWeight.bold)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: kBorder),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text('${students.length} students', style: kMutedStyle),
                                ),
                                const SizedBox(width: 10),
                                const CircleAvatar(
                                  radius: 16,
                                  backgroundColor: kBlue,
                                  child: Icon(Icons.person, size: 18),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 40,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  for (final b in ['All', ...kBatches])
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: ChoiceChip(
                                        label: Text(b),
                                        selected: batch == b,
                                        onSelected: (_) => setState(() => batch = b),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(child: pages[page]),
                    ],
                  ),
                ),
                if (showRail) GearRail(onTap: openSettings),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class Sidebar extends StatelessWidget {
  final bool extended;
  final int selected;
  final ValueChanged<int> onSelect;
  final VoidCallback onSettings;
  const Sidebar({
    super.key,
    required this.extended,
    required this.selected,
    required this.onSelect,
    required this.onSettings,
  });

  static const icons = [Icons.dashboard_rounded, Icons.groups_rounded, Icons.psychology_rounded];
  static const labels = ['Dashboard', 'Students', 'AI Insights'];

  Widget item(IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: isSelected ? kBlue.withAlpha(70) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? kCyan : kBorder.withAlpha(120)),
          ),
          child: Row(
            mainAxisAlignment: extended ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: isSelected ? kCyan : kMuted),
              if (extended) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: Text(label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: extended ? 190 : 64,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kBorder, width: 1.2),
        boxShadow: [BoxShadow(color: kBorder.withAlpha(60), blurRadius: 14)],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: extended ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: [
                const Icon(Icons.school_rounded, color: kCyan, size: 26),
                if (extended) ...[
                  const SizedBox(width: 8),
                  const Text('EduPulse',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ],
            ),
          ),
          const Divider(color: Colors.white24),
          for (var i = 0; i < icons.length; i++)
            item(icons[i], labels[i], selected == i, () => onSelect(i)),
          const Spacer(),
          item(Icons.settings_rounded, 'Settings', false, onSettings),
        ],
      ),
    );
  }
}

class GearRail extends StatelessWidget {
  final VoidCallback onTap;
  const GearRail({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < 3; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: InkResponse(
                onTap: onTap,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kCard,
                    border: Border.all(color: kBorder, width: 1.4),
                    boxShadow: [BoxShadow(color: kBorder.withAlpha(90), blurRadius: 12)],
                  ),
                  child: const Icon(Icons.settings, color: kCyan, size: 24),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// REUSABLE WIDGETS
// ─────────────────────────────────────────────────────────────

class NeonCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const NeonCard({super.key, required this.child, this.padding = const EdgeInsets.all(14)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kBorder, width: 1.2),
        boxShadow: [BoxShadow(color: kBorder.withAlpha(50), blurRadius: 14)],
      ),
      child: child,
    );
  }
}

class ResponsiveWrap extends StatelessWidget {
  final double minWidth;
  final double gap;
  final List<Widget> children;
  const ResponsiveWrap({
    super.key,
    required this.minWidth,
    required this.children,
    this.gap = 16,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final cols = math.max(1, ((c.maxWidth + gap) / (minWidth + gap)).floor());
      final w = ((c.maxWidth - gap * (cols - 1)) / cols).floorToDouble();
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [for (final ch in children) SizedBox(width: w, child: ch)],
      );
    });
  }
}

class KpiTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const KpiTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      child: SizedBox(
        height: 64,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: kMutedStyle),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(value,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
            Icon(icon, color: color, size: 26),
          ],
        ),
      ),
    );
  }
}

class DonutTile extends StatelessWidget {
  final List<int> counts;
  final int total;
  const DonutTile({super.key, required this.counts, required this.total});

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      child: SizedBox(
        height: 64,
        child: Row(
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: CustomPaint(
                size: Size.infinite,
                painter: DonutPainter(
                  values: counts.map((c) => c.toDouble()).toList(),
                  colors: kStatuses.map(statusColor).toList(),
                  centerText: '$total',
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < kStatuses.length; i++)
                    Text('${kStatusShort[i]} ${counts[i]}',
                        style: TextStyle(
                            fontSize: 10.5,
                            height: 1.25,
                            color: statusColor(kStatuses[i]))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartPanel extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? footer;
  final double height;
  const ChartPanel({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.footer,
    this.height = 230,
  });

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: kTitleStyle),
          const SizedBox(height: 2),
          Text(subtitle, style: kMutedStyle),
          const SizedBox(height: 12),
          SizedBox(height: height, width: double.infinity, child: child),
          if (footer != null) ...[const SizedBox(height: 8), footer!],
        ],
      ),
    );
  }
}

class Legend extends StatelessWidget {
  final List<String> labels;
  final List<Color> colors;
  const Legend({super.key, required this.labels, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 4,
      children: [
        for (var i = 0; i < labels.length; i++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: colors[i], shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(labels[i], style: const TextStyle(fontSize: 12)),
            ],
          ),
      ],
    );
  }
}

/// The "progress slider indicator": a track, a gradient fill and a round handle.
class ProgressSlider extends StatelessWidget {
  final double value; // 0..100
  final Color color;
  const ProgressSlider({super.key, required this.value, this.color = kBlue});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 22,
      width: double.infinity,
      child: CustomPaint(
        painter: _SliderPainter((value / 100).clamp(0.0, 1.0).toDouble(), color),
      ),
    );
  }
}

class _SliderPainter extends CustomPainter {
  final double value;
  final Color color;
  _SliderPainter(this.value, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    const r = 7.0;
    final cy = size.height / 2;
    final track = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, cy - 3, size.width, 6),
      const Radius.circular(3),
    );
    canvas.drawRRect(track, Paint()..color = const Color(0x2EFFFFFF));

    final tx = r + (size.width - 2 * r) * value;
    final fillRect = Rect.fromLTWH(0, cy - 3, math.max(tx, 1), 6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(fillRect, const Radius.circular(3)),
      Paint()
        ..shader = LinearGradient(colors: [color.withAlpha(110), color]).createShader(fillRect),
    );

    canvas.drawCircle(Offset(tx, cy), r + 4, Paint()..color = color.withAlpha(60));
    canvas.drawCircle(Offset(tx, cy), r, Paint()..color = Colors.white);
    canvas.drawCircle(
      Offset(tx, cy),
      r,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final double labelWidth;
  const SliderRow({
    super.key,
    required this.label,
    required this.value,
    this.color = kBlue,
    this.labelWidth = 76,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(label, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(child: ProgressSlider(value: value, color: color)),
          const SizedBox(width: 8),
          SizedBox(
            width: 38,
            child: Text('${value.round()}%',
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PAGE 1: DASHBOARD
// ─────────────────────────────────────────────────────────────

class DashboardPage extends StatelessWidget {
  final List<Student> students;
  const DashboardPage({super.key, required this.students});

  @override
  Widget build(BuildContext context) {
    final n = students.length;
    final avgProgress = avg(students.map((s) => s.progress));
    final completed = students.where((s) => s.status == 'Completed').length;
    final atRisk = students.where((s) => s.status == 'At risk').length;
    final counts =
    kStatuses.map((st) => students.where((s) => s.status == st).length).toList();

    List<double> weeklyAvg(List<Student> g) =>
        List.generate(kWeeks, (w) => avg(g.map((s) => s.weekly[w])));

    final sorted = [...students]..sort((a, b) => b.progress.compareTo(a.progress));
    final groupSize = math.max(1, (n * 0.1).round());
    final top = sorted.take(groupSize).toList();
    final bottom = sorted.reversed.take(groupSize).toList();

    final batchAvg = kBatches
        .map((b) => avg(kStudents.where((s) => s.batch == b).map((s) => s.progress)))
        .toList();
    final skillAvg =
    List.generate(kSkills.length, (k) => avg(students.map((s) => s.skills[k])));
    final attendanceAvg = avg(students.map((s) => s.attendance));
    final scoreAvg = avg(students.map((s) => s.score));
    final weekLabels = List.generate(kWeeks, (w) => 'W${w + 1}');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ResponsiveWrap(
          minWidth: 170,
          children: [
            KpiTile(label: 'Students', value: '$n', icon: Icons.groups, color: kCyan),
            KpiTile(label: 'Avg progress', value: '${avgProgress.toStringAsFixed(1)}%', icon: Icons.trending_up, color: kGreen),
            KpiTile(label: 'Completed', value: '$completed', icon: Icons.verified, color: kBlue),
            KpiTile(label: 'At risk', value: '$atRisk', icon: Icons.warning_amber_rounded, color: kRed),
            DonutTile(counts: counts, total: n),
          ],
        ),
        const SizedBox(height: 16),
        ResponsiveWrap(
          minWidth: 400,
          children: [
            ChartPanel(
              title: 'Weekly progress trend',
              subtitle: 'Cumulative progress: all vs top 10% vs bottom 10%',
              child: CustomPaint(
                size: Size.infinite,
                painter: NeonLinePainter(
                  series: [
                    LineSeries(weeklyAvg(students), kBlue, fill: true),
                    LineSeries(weeklyAvg(top), kGreen),
                    LineSeries(weeklyAvg(bottom), kRed),
                  ],
                  xLabels: weekLabels,
                ),
              ),
              footer: const Legend(
                labels: ['All students', 'Top 10%', 'Bottom 10%'],
                colors: [kBlue, kGreen, kRed],
              ),
            ),
            ChartPanel(
              title: 'Average progress by batch',
              subtitle: 'All 150 students',
              child: CustomPaint(
                size: Size.infinite,
                painter: NeonBarPainter(
                  values: batchAvg,
                  labels: const ['A', 'B', 'C', 'D', 'E'],
                  maxY: 100,
                  colors: kPalette,
                  valueSuffix: '%',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ResponsiveWrap(
          minWidth: 300,
          children: [
            NeonCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Batch progress', style: kTitleStyle),
                  const Text('Average completion per batch', style: kMutedStyle),
                  const SizedBox(height: 8),
                  for (var i = 0; i < kBatches.length; i++)
                    SliderRow(label: kBatches[i], value: batchAvg[i], color: kPalette[i]),
                ],
              ),
            ),
            NeonCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Subject mastery', style: kTitleStyle),
                  const Text('Average skill level in this view', style: kMutedStyle),
                  const SizedBox(height: 8),
                  for (var k = 0; k < kSkills.length; k++)
                    SliderRow(label: kSkills[k], value: skillAvg[k], color: kPalette[k]),
                  SliderRow(label: 'Attendance', value: attendanceAvg, color: kCyan),
                  SliderRow(label: 'Avg score', value: scoreAvg, color: kGreen),
                ],
              ),
            ),
            NeonCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Top performers', style: kTitleStyle),
                  const Text('Highest progress right now', style: kMutedStyle),
                  const SizedBox(height: 8),
                  for (final s in sorted.take(6))
                    SliderRow(
                      label: s.name,
                      value: s.progress,
                      color: kGreen,
                      labelWidth: 100,
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PAGE 2: STUDENTS (search, filter, progress slider per student)
// ─────────────────────────────────────────────────────────────

class StudentsPage extends StatefulWidget {
  final List<Student> students;
  const StudentsPage({super.key, required this.students});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  String query = '';
  String status = 'All';

  @override
  Widget build(BuildContext context) {
    final list = widget.students
        .where((s) =>
    (status == 'All' || s.status == status) &&
        s.name.toLowerCase().contains(query.toLowerCase()))
        .toList()
      ..sort((a, b) => b.progress.compareTo(a.progress));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search student name…',
              filled: true,
              fillColor: kCard,
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: kBorder),
              ),
            ),
            onChanged: (v) => setState(() => query = v),
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              for (final s in ['All', ...kStatuses])
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: ChoiceChip(
                    label: Text(s),
                    selected: status == s,
                    onSelected: (_) => setState(() => status = s),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('${list.length} students · tap one for AI details', style: kMutedStyle),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, i) => StudentTile(student: list[i]),
          ),
        ),
      ],
    );
  }
}

class StudentTile extends StatelessWidget {
  final Student student;
  const StudentTile({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final color = statusColor(student.status);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => showStudentSheet(context, student),
        child: NeonCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: color.withAlpha(60),
                child: Text(student.initials, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text('#${student.id}  ${student.name}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Text(student.status,
                            style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Text('${student.batch} · attendance ${student.attendance.toStringAsFixed(0)}%',
                        style: kMutedStyle),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(child: ProgressSlider(value: student.progress, color: color)),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 38,
                          child: Text('${student.progress.round()}%',
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showStudentSheet(BuildContext context, Student s) {
  final i = s.id - 1;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF0A1F6B),
    builder: (_) => SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            '${s.batch} · ${s.status} · ${s.hours.toStringAsFixed(0)} h studied · score ${s.score.toStringAsFixed(1)} · attendance ${s.attendance.toStringAsFixed(0)}%',
            style: kMutedStyle,
          ),
          const SizedBox(height: 16),
          const Text('Weekly progress', style: kTitleStyle),
          const SizedBox(height: 8),
          SizedBox(
            height: 170,
            width: double.infinity,
            child: CustomPaint(
              size: Size.infinite,
              painter: NeonLinePainter(
                series: [LineSeries(s.weekly, statusColor(s.status), fill: true)],
                xLabels: List.generate(kWeeks, (w) => 'W${w + 1}'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Subjects', style: kTitleStyle),
          for (var k = 0; k < kSkills.length; k++)
            SliderRow(label: kSkills[k], value: s.skills[k], color: kPalette[k]),
          const SizedBox(height: 12),
          const Text('AI insights', style: kTitleStyle),
          const SizedBox(height: 6),
          Text(
            'Forecast at week 20: ${kMl.forecasts[i].at(20).toStringAsFixed(0)}%  ·  '
                'completion probability: ${(kMl.completeProb[i] * 100).toStringAsFixed(0)}%  ·  '
                'group: ${kClusterNames[kMl.clusters.assignment[i]]}',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 6),
          for (final tip in coachTips(s))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline, size: 16, color: kOrange),
                  const SizedBox(width: 8),
                  Expanded(child: Text(tip)),
                ],
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────
// PAGE 3: AI INSIGHTS
// ─────────────────────────────────────────────────────────────

class AiPage extends StatelessWidget {
  final List<Student> students;
  final double riskThreshold;
  const AiPage({super.key, required this.students, required this.riskThreshold});

  @override
  Widget build(BuildContext context) {
    final ml = kMl;
    final model = ml.model;
    final cl = ml.clusters;

    final finishers = students.where((s) => ml.forecasts[s.id - 1].at(20) >= 80).length;
    final highRisk = students
        .where((s) => s.progress < 80 && ml.completeProb[s.id - 1] < riskThreshold)
        .length;

    final absW = model.w.map((v) => v.abs()).toList();
    final totalW = absW.fold<double>(0, (a, b) => a + b);
    final importance = absW.map((v) => totalW == 0 ? 0.0 : v / totalW * 100).toList();

    final actualAvg =
    List.generate(kWeeks, (w) => avg(students.map((s) => s.weekly[w])));
    final forecastAvg = List.generate(
      20,
          (w) => w < kWeeks
          ? actualAvg[w]
          : avg(students.map((s) => ml.forecasts[s.id - 1].at(w + 1))),
    );
    final labels20 = List.generate(20, (w) => 'W${w + 1}');

    final watch = students.where((s) => s.progress < 80).toList()
      ..sort((a, b) => ml.completeProb[a.id - 1].compareTo(ml.completeProb[b.id - 1]));
    final topWatch = watch.take(8).toList();

    final scopeSizes = List.generate(
      4,
          (c) => students.where((s) => cl.assignment[s.id - 1] == c).length,
    );
    final maxSize = math.max(10, scopeSizes.reduce(math.max));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ResponsiveWrap(
          minWidth: 170,
          children: [
            KpiTile(label: 'Test accuracy', value: '${model.testAcc.last.toStringAsFixed(0)}%', icon: Icons.fact_check, color: kGreen),
            KpiTile(label: 'Train accuracy', value: '${model.trainAcc.last.toStringAsFixed(0)}%', icon: Icons.school, color: kBlue),
            KpiTile(label: 'Finish by wk 20', value: '$finishers', icon: Icons.flag, color: kOrange),
            KpiTile(label: 'High-risk', value: '$highRisk', icon: Icons.warning_amber_rounded, color: kRed),
          ],
        ),
        const SizedBox(height: 16),
        ResponsiveWrap(
          minWidth: 400,
          children: [
            const PredictorCard(),
            ChartPanel(
              title: 'Model learning curve',
              subtitle: 'Logistic regression accuracy (%) per training epoch',
              child: CustomPaint(
                size: Size.infinite,
                painter: NeonLinePainter(
                  series: [
                    LineSeries(model.trainAcc, kBlue),
                    LineSeries(model.testAcc, kOrange),
                  ],
                  xLabels: List.generate(model.trainAcc.length, (i) => '${(i + 1) * 20}'),
                ),
              ),
              footer: const Legend(
                labels: ['Train (105 students)', 'Test (45 students)'],
                colors: [kBlue, kOrange],
              ),
            ),
            ChartPanel(
              title: 'What drives completion?',
              subtitle: 'Feature importance (share of model weight)',
              height: 190,
              child: CustomPaint(
                size: Size.infinite,
                painter: HBarPainter(
                  labels: kFeatureNames,
                  values: importance,
                  color: kPurple,
                ),
              ),
            ),
            ChartPanel(
              title: 'Progress forecast to week 20',
              subtitle: 'Average of per-student linear regression trends',
              child: CustomPaint(
                size: Size.infinite,
                painter: NeonLinePainter(
                  series: [
                    LineSeries(forecastAvg, kOrange),
                    LineSeries(actualAvg, kCyan, fill: true),
                  ],
                  xLabels: labels20,
                ),
              ),
              footer: const Legend(
                labels: ['Actual (W1-W12)', 'Forecast (W13-W20)'],
                colors: [kCyan, kOrange],
              ),
            ),
            ChartPanel(
              title: 'K-means student groups',
              subtitle: 'Hours studied (x) vs test score (y), colored by cluster',
              child: CustomPaint(
                size: Size.infinite,
                painter: ScatterPainter(
                  points: students.map((s) => Offset(s.hours, s.score)).toList(),
                  colors: [
                    for (final s in students)
                      kClusterColors[cl.assignment[s.id - 1]].withAlpha(220)
                  ],
                  maxX: 200,
                ),
              ),
              footer: Legend(labels: kClusterNames, colors: kClusterColors),
            ),
            ChartPanel(
              title: 'Cluster sizes',
              subtitle: 'Students per group in this view, with group averages',
              height: 170,
              child: CustomPaint(
                size: Size.infinite,
                painter: NeonBarPainter(
                  values: scopeSizes.map((v) => v.toDouble()).toList(),
                  labels: kClusterShort,
                  maxY: ((maxSize / 10).ceil() * 10).toDouble(),
                  colors: kClusterColors,
                ),
              ),
              footer: Column(
                children: [
                  for (var c = 0; c < kClusterNames.length; c++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration:
                            BoxDecoration(color: kClusterColors[c], shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(kClusterNames[c], style: const TextStyle(fontSize: 12))),
                          Text(
                            '${cl.avgProgress[c].toStringAsFixed(0)}% · ${cl.avgScore[c].toStringAsFixed(0)} pts · ${cl.avgHours[c].toStringAsFixed(0)} h',
                            style: kMutedStyle,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            NeonCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('AI watchlist', style: kTitleStyle),
                  const Text('Students least likely to finish. Tap for details.',
                      style: kMutedStyle),
                  const SizedBox(height: 8),
                  for (final s in topWatch) WatchTile(student: s),
                ],
              ),
            ),
            const NeonCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('How the AI works', style: kTitleStyle),
                  SizedBox(height: 8),
                  Text('• Linear regression fits a trend line through each student\'s 12 weekly points and extends it to week 20.'),
                  SizedBox(height: 6),
                  Text('• Logistic regression learns from weeks 1-6 (progress, pace, hours, score) to predict who finishes at 80% or more. It trains on 105 students and is checked on 45 unseen students.'),
                  SizedBox(height: 6),
                  Text('• K-means groups all 150 students into 4 clusters by progress, score and hours.'),
                  SizedBox(height: 6),
                  Text('• Rules turn the results into coaching tips. Everything runs on-device with no packages and no server.'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class WatchTile extends StatelessWidget {
  final Student student;
  const WatchTile({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final i = student.id - 1;
    final risk = (1 - kMl.completeProb[i]) * 100;
    final f = kMl.forecasts[i];
    final eta = f.etaWeek;
    final etaText = eta == null
        ? 'no upward trend'
        : (eta > 52 ? 'finish after week 52' : 'finish ~week ${eta.ceil()}');
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      isThreeLine: true,
      onTap: () => showStudentSheet(context, student),
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: kRed.withAlpha(60),
        child: Text(student.initials, style: const TextStyle(fontSize: 11)),
      ),
      title: Text('#${student.id}  ${student.name}'),
      subtitle: Text(
        'Now ${student.progress.toStringAsFixed(0)}% · week 20: ${f.at(20).toStringAsFixed(0)}% · $etaText\n${coachTips(student).first}',
        style: const TextStyle(fontSize: 12, color: kMuted),
      ),
      trailing: Text('${risk.toStringAsFixed(0)}%\nrisk',
          textAlign: TextAlign.center,
          style: const TextStyle(color: kRed, fontWeight: FontWeight.bold)),
    );
  }
}

/// Interactive "what-if" predictor using the trained logistic model.
class PredictorCard extends StatefulWidget {
  const PredictorCard({super.key});

  @override
  State<PredictorCard> createState() => _PredictorCardState();
}

class _PredictorCardState extends State<PredictorCard> {
  double week6 = 35;
  double pace = 6;
  double hours = 100;
  double score = 70;

  Widget slider(String label, double value, double min, double max,
      ValueChanged<double> onChanged, String suffix) {
    return Row(
      children: [
        SizedBox(width: 108, child: Text(label, style: const TextStyle(fontSize: 12))),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: kCyan,
              inactiveTrackColor: Colors.white24,
              thumbColor: Colors.white,
              overlayColor: kCyan.withAlpha(50),
            ),
            child: Slider(value: value, min: min, max: max, onChanged: onChanged),
          ),
        ),
        SizedBox(
          width: 52,
          child: Text('${value.toStringAsFixed(0)}$suffix',
              textAlign: TextAlign.right, style: const TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final prob = kMl.model.predict([week6, pace, hours, score]);
    final color = prob >= 0.7 ? kGreen : (prob >= 0.4 ? kOrange : kRed);
    return NeonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Try the model', style: kTitleStyle),
          const Text('Move the sliders to predict a new student\'s chance of finishing',
              style: kMutedStyle),
          const SizedBox(height: 8),
          slider('Week-6 progress', week6, 0, 70, (v) => setState(() => week6 = v), '%'),
          slider('Weekly pace', pace, 0, 15, (v) => setState(() => pace = v), '%'),
          slider('Hours studied', hours, 0, 200, (v) => setState(() => hours = v), 'h'),
          slider('Test score', score, 30, 100, (v) => setState(() => score = v), ''),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('${(prob * 100).toStringAsFixed(0)}%',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('chance of completing (80%+)', style: TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                    ProgressSlider(value: prob * 100, color: color),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CHART PAINTERS (neon style)
// ─────────────────────────────────────────────────────────────

void drawText(
    Canvas canvas,
    String text,
    Offset offset, {
      double size = 10,
      Color color = kMuted,
      TextAlign align = TextAlign.left,
      double? maxWidth,
      FontWeight? weight,
    }) {
  final tp = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(fontSize: size, color: color, fontWeight: weight),
    ),
    textDirection: TextDirection.ltr,
    maxLines: 1,
    ellipsis: '…',
  )..layout(maxWidth: maxWidth ?? double.infinity);

  var dx = offset.dx;
  if (align == TextAlign.center) {
    dx -= tp.width / 2;
  } else if (align == TextAlign.right) {
    dx -= tp.width;
  }
  tp.paint(canvas, Offset(dx, offset.dy - tp.height / 2));
}

void drawYGrid(Canvas canvas, Rect plot, double maxY, int steps, {String suffix = ''}) {
  final paint = Paint()
    ..color = const Color(0x2A6F9BFF)
    ..strokeWidth = 1;
  for (var i = 0; i <= steps; i++) {
    final y = plot.bottom - plot.height * i / steps;
    canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), paint);
    drawText(canvas, '${(maxY * i / steps).round()}$suffix', Offset(plot.left - 6, y),
        align: TextAlign.right);
  }
}

class LineSeries {
  final List<double> values;
  final Color color;
  final bool fill;
  const LineSeries(this.values, this.color, {this.fill = false});
}

class NeonLinePainter extends CustomPainter {
  final List<LineSeries> series;
  final List<String> xLabels;
  final double maxY;
  final String suffix;

  NeonLinePainter({
    required this.series,
    required this.xLabels,
    this.maxY = 100,
    this.suffix = '%',
  });

  @override
  void paint(Canvas canvas, Size size) {
    final plot = Rect.fromLTRB(42, 10, size.width - 10, size.height - 24);
    drawYGrid(canvas, plot, maxY, 4, suffix: suffix);
    final n = xLabels.length;
    final step = n > 8 ? 2 : 1;
    double xAt(int i) => plot.left + plot.width * i / (n - 1);
    double yAt(double v) => plot.bottom - plot.height * (v / maxY).clamp(0.0, 1.0);

    for (var i = 0; i < n; i += step) {
      drawText(canvas, xLabels[i], Offset(xAt(i), plot.bottom + 12), align: TextAlign.center);
    }

    for (final s in series) {
      if (s.values.length < 2) continue;
      final path = Path();
      for (var i = 0; i < s.values.length; i++) {
        final x = xAt(i);
        final y = yAt(s.values[i]);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      if (s.fill) {
        final area = Path.from(path)
          ..lineTo(xAt(s.values.length - 1), plot.bottom)
          ..lineTo(xAt(0), plot.bottom)
          ..close();
        canvas.drawPath(
          area,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [s.color.withAlpha(110), s.color.withAlpha(0)],
            ).createShader(plot),
        );
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = s.color.withAlpha(55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..strokeJoin = StrokeJoin.round,
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = s.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeJoin = StrokeJoin.round,
      );
      for (var i = 0; i < s.values.length; i++) {
        canvas.drawCircle(Offset(xAt(i), yAt(s.values[i])), 3.5, Paint()..color = s.color);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class NeonBarPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final double maxY;
  final List<Color> colors;
  final String valueSuffix;

  NeonBarPainter({
    required this.values,
    required this.labels,
    required this.maxY,
    required this.colors,
    this.valueSuffix = '',
  });

  @override
  void paint(Canvas canvas, Size size) {
    final plot = Rect.fromLTRB(36, 14, size.width - 8, size.height - 26);
    drawYGrid(canvas, plot, maxY, 4);
    final n = values.length;
    final slot = plot.width / n;
    final barW = slot * 0.6;

    for (var i = 0; i < n; i++) {
      final x = plot.left + slot * i + (slot - barW) / 2;
      final h = plot.height * (values[i] / maxY).clamp(0.0, 1.0);
      final rect = Rect.fromLTWH(x, plot.bottom - h, barW, h);
      final color = colors[i % colors.length];
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          rect,
          topLeft: const Radius.circular(5),
          topRight: const Radius.circular(5),
        ),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color, color.withAlpha(70)],
          ).createShader(rect),
      );
      final text = values[i] % 1 == 0
          ? values[i].toStringAsFixed(0)
          : values[i].toStringAsFixed(1);
      drawText(canvas, '$text$valueSuffix', Offset(x + barW / 2, plot.bottom - h - 8),
          align: TextAlign.center, color: Colors.white);
      drawText(canvas, labels[i], Offset(x + barW / 2, plot.bottom + 12),
          align: TextAlign.center);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DonutPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  final String centerText;

  DonutPainter({required this.values, required this.colors, required this.centerText});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - 2;
    final stroke = radius * 0.3;
    final rect = Rect.fromCircle(center: center, radius: radius).deflate(stroke / 2);
    final total = values.fold<double>(0, (a, b) => a + b);
    if (total == 0) return;

    canvas.drawArc(
      rect,
      0,
      2 * math.pi,
      false,
      Paint()
        ..color = const Color(0x22FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );

    var start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = 2 * math.pi * values[i] / total;
      canvas.drawArc(
        rect,
        start,
        math.max(sweep - 0.04, 0.001),
        false,
        Paint()
          ..color = colors[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke,
      );
      start += sweep;
    }
    drawText(canvas, centerText, center,
        size: 14, color: Colors.white, align: TextAlign.center, weight: FontWeight.bold);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ScatterPainter extends CustomPainter {
  final List<Offset> points; // dx = hours, dy = score
  final List<Color> colors;
  final double maxX;

  ScatterPainter({required this.points, required this.colors, required this.maxX});

  @override
  void paint(Canvas canvas, Size size) {
    final plot = Rect.fromLTRB(36, 14, size.width - 12, size.height - 26);
    drawYGrid(canvas, plot, 100, 4);
    for (var i = 0; i <= 4; i++) {
      final x = plot.left + plot.width * i / 4;
      drawText(canvas, '${(maxX * i / 4).round()}h', Offset(x, plot.bottom + 12),
          align: TextAlign.center);
    }
    for (var i = 0; i < points.length; i++) {
      final x = plot.left + plot.width * (points[i].dx / maxX).clamp(0.0, 1.0);
      final y = plot.bottom - plot.height * (points[i].dy / 100).clamp(0.0, 1.0);
      canvas.drawCircle(Offset(x, y), 7, Paint()..color = colors[i].withAlpha(40));
      canvas.drawCircle(Offset(x, y), 3.5, Paint()..color = colors[i]);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class HBarPainter extends CustomPainter {
  final List<String> labels;
  final List<double> values;
  final Color color;

  HBarPainter({required this.labels, required this.values, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const labelW = 112.0;
    final plot = Rect.fromLTRB(labelW, 4, size.width - 40, size.height - 4);
    final n = values.length;
    final rowH = plot.height / n;
    final gridPaint = Paint()
      ..color = const Color(0x2A6F9BFF)
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final x = plot.left + plot.width * i / 4;
      canvas.drawLine(Offset(x, plot.top), Offset(x, plot.bottom), gridPaint);
    }
    for (var i = 0; i < n; i++) {
      final cy = plot.top + rowH * i + rowH / 2;
      final w = plot.width * (values[i] / 100).clamp(0.0, 1.0);
      final rect = Rect.fromLTWH(plot.left, cy - rowH * 0.28, w, rowH * 0.56);
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          rect,
          topRight: const Radius.circular(5),
          bottomRight: const Radius.circular(5),
        ),
        Paint()
          ..shader = LinearGradient(colors: [color.withAlpha(90), color]).createShader(rect),
      );
      drawText(canvas, labels[i], Offset(plot.left - 8, cy),
          align: TextAlign.right, maxWidth: labelW - 12, size: 11, color: Colors.white);
      drawText(canvas, '${values[i].toStringAsFixed(0)}%', Offset(plot.left + w + 6, cy),
          color: Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}