// Progress Tracker + 7 charts for 100 demo people.
// Single file, NO extra packages: all charts are drawn with CustomPaint.
// Copy this over lib/main.dart and run:  flutter run -d chrome

import 'dart:math' as math;

import 'package:flutter/material.dart';

// void main() => runApp(const ProgressApp());

// ─────────────────────────────────────────────────────────────
// DEMO DATA (100 people, deterministic: same data on every run)
// ─────────────────────────────────────────────────────────────

const List<String> kBatches = ['Batch A', 'Batch B', 'Batch C', 'Batch D'];
const List<String> kStatuses = ['Completed', 'On track', 'Behind', 'At risk'];
const List<String> kSkills = [
  'MCQ',
  'Typing',
  'Coding',
  'Projects',
  'Revision',
];
const int kWeeks = 12;

const List<Color> kPalette = [
  Color(0xFF42A5F5),
  Color(0xFF66BB6A),
  Color(0xFFFFA726),
  Color(0xFFEF5350),
  Color(0xFFAB47BC),
  Color(0xFF26C6DA),
];

Color statusColor(String status) {
  switch (status) {
    case 'Completed':
      return const Color(0xFF66BB6A);
    case 'On track':
      return const Color(0xFF42A5F5);
    case 'Behind':
      return const Color(0xFFFFA726);
    default:
      return const Color(0xFFEF5350);
  }
}

class Person {
  final int id;
  final String name;
  final String batch;
  final List<double> weekly; // cumulative progress % for each of 12 weeks
  final double hours; // total hours studied
  final double score; // average test score
  final List<double> skills; // 5 skill levels (0..100)

  Person({
    required this.id,
    required this.name,
    required this.batch,
    required this.weekly,
    required this.hours,
    required this.score,
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

List<Person> generatePeople() {
  final rnd = math.Random(42);
  const first = [
    'Aarav',
    'Vivaan',
    'Aditya',
    'Diya',
    'Ananya',
    'Ishaan',
    'Kavya',
    'Rohan',
    'Meera',
    'Arjun',
    'Sneha',
    'Karthik',
    'Priya',
    'Rahul',
    'Divya',
    'Vikram',
    'Nisha',
    'Suresh',
    'Lakshmi',
    'Manoj',
  ];
  const last = [
    'Kumar',
    'Sharma',
    'Reddy',
    'Iyer',
    'Nair',
    'Patel',
    'Singh',
    'Menon',
    'Das',
    'Gupta',
    'Rao',
  ];

  return List.generate(100, (i) {
    final pace = 1.5 + rnd.nextDouble() * 8.5; // average % gained per week
    double current = 0;
    final weekly = <double>[];
    for (var w = 0; w < kWeeks; w++) {
      current += pace * (0.5 + rnd.nextDouble());
      if (current > 100) current = 100;
      weekly.add(current);
    }
    final progress = weekly.last;
    final hours = 20 + pace * 12 + rnd.nextDouble() * 40;
    final score = (35 + progress * 0.5 + rnd.nextDouble() * 15)
        .clamp(0.0, 100.0)
        .toDouble();
    final skills = List.generate(
      kSkills.length,
      (_) => (progress * 0.6 + 20 + rnd.nextDouble() * 20)
          .clamp(0.0, 100.0)
          .toDouble(),
    );
    return Person(
      id: i + 1,
      name:
          '${first[i % first.length]} ${last[(i * 3 + i ~/ 20) % last.length]}',
      batch: kBatches[i % kBatches.length],
      weekly: weekly,
      hours: hours,
      score: score,
      skills: skills,
    );
  });
}

final List<Person> kPeople = generatePeople();

double avg(Iterable<double> values) {
  if (values.isEmpty) return 0;
  return values.reduce((a, b) => a + b) / values.length;
}

// ─────────────────────────────────────────────────────────────
// APP + TABS
// ─────────────────────────────────────────────────────────────

class ProgressApp extends StatelessWidget {
  const ProgressApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Progress Tracker',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Progress Tracker · 100 learners'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.insights), text: 'Dashboard'),
              Tab(icon: Icon(Icons.people), text: 'Tracker'),
              Tab(icon: Icon(Icons.psychology), text: 'AI Insights'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [DashboardPage(), TrackerPage(), AiInsightsPage()],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// DASHBOARD: KPI cards + 7 charts
// ─────────────────────────────────────────────────────────────

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final people = kPeople;
    final sorted = [...people]
      ..sort((a, b) => b.progress.compareTo(a.progress));
    final top10 = sorted.take(10).toList();
    final bottom10 = sorted.reversed.take(10).toList();

    // Chart 1: average progress per batch
    final avgByBatch = kBatches
        .map(
          (b) => avg(people.where((p) => p.batch == b).map((p) => p.progress)),
        )
        .toList();

    // Chart 2: weekly average (all / top 10 / bottom 10)
    List<double> weeklyAvg(List<Person> group) =>
        List.generate(kWeeks, (w) => avg(group.map((p) => p.weekly[w])));
    final weekLabels = List.generate(kWeeks, (w) => 'W${w + 1}');

    // Chart 3: status counts
    final statusCounts = kStatuses
        .map((s) => people.where((p) => p.status == s).length.toDouble())
        .toList();

    // Chart 4: score histogram (30-40 ... 90-100)
    final buckets = List<double>.filled(7, 0);
    for (final p in people) {
      final idx = ((p.score - 30) / 10).floor().clamp(0, 6).toInt();
      buckets[idx] += 1;
    }
    final bucketLabels = List.generate(
      7,
      (i) => '${30 + i * 10}-${40 + i * 10}',
    );

    // Chart 5: scatter (hours vs score)
    final scatterPts = people.map((p) => Offset(p.hours, p.score)).toList();
    final scatterColors = people
        .map((p) => kPalette[kBatches.indexOf(p.batch)].withAlpha(190))
        .toList();

    // Chart 7: radar (skills: everyone vs top 10)
    final skillAll = List.generate(
      kSkills.length,
      (s) => avg(people.map((p) => p.skills[s])),
    );
    final skillTop = List.generate(
      kSkills.length,
      (s) => avg(top10.map((p) => p.skills[s])),
    );

    final completed = people.where((p) => p.status == 'Completed').length;
    final atRisk = people.where((p) => p.status == 'At risk').length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final twoCols = constraints.maxWidth >= 900;
        final cardWidth = twoCols
            ? (constraints.maxWidth - 16 * 3) / 2
            : constraints.maxWidth - 32;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                Kpi(
                  label: 'People',
                  value: '${people.length}',
                  icon: Icons.groups,
                  color: kPalette[0],
                ),
                Kpi(
                  label: 'Avg progress',
                  value:
                      '${avg(people.map((p) => p.progress)).toStringAsFixed(1)}%',
                  icon: Icons.trending_up,
                  color: kPalette[1],
                ),
                Kpi(
                  label: 'Completed',
                  value: '$completed',
                  icon: Icons.verified,
                  color: kPalette[2],
                ),
                Kpi(
                  label: 'At risk',
                  value: '$atRisk',
                  icon: Icons.warning_amber,
                  color: kPalette[3],
                ),
                Kpi(
                  label: 'Avg score',
                  value: avg(people.map((p) => p.score)).toStringAsFixed(1),
                  icon: Icons.grade,
                  color: kPalette[4],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                // 1. BAR
                SizedBox(
                  width: cardWidth,
                  child: ChartCard(
                    title: '1 · Bar chart',
                    subtitle: 'Average progress % by batch',
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: BarChartPainter(
                        values: avgByBatch,
                        labels: kBatches,
                        maxY: 100,
                        colors: kPalette,
                        valueSuffix: '%',
                      ),
                    ),
                  ),
                ),
                // 2. MULTI-LINE
                SizedBox(
                  width: cardWidth,
                  child: ChartCard(
                    title: '2 · Line chart',
                    subtitle:
                        'Weekly cumulative progress: all vs top 10 vs bottom 10',
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: LineChartPainter(
                        series: [
                          LineSeries('All', weeklyAvg(people), kPalette[0]),
                          LineSeries('Top 10', weeklyAvg(top10), kPalette[1]),
                          LineSeries(
                            'Bottom 10',
                            weeklyAvg(bottom10),
                            kPalette[3],
                          ),
                        ],
                        xLabels: weekLabels,
                        maxY: 100,
                      ),
                    ),
                    footer: Legend(
                      labels: const ['All', 'Top 10', 'Bottom 10'],
                      colors: [kPalette[0], kPalette[1], kPalette[3]],
                    ),
                  ),
                ),
                // 3. DONUT
                SizedBox(
                  width: cardWidth,
                  child: ChartCard(
                    title: '3 · Donut chart',
                    subtitle: 'Status distribution',
                    child: Row(
                      children: [
                        SizedBox(
                          width: 170,
                          child: CustomPaint(
                            size: Size.infinite,
                            painter: DonutPainter(
                              values: statusCounts,
                              colors: kStatuses.map(statusColor).toList(),
                              centerText: '${people.length}',
                              centerSub: 'people',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (var i = 0; i < kStatuses.length; i++)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: statusColor(kStatuses[i]),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(kStatuses[i])),
                                      Text(
                                        '${statusCounts[i].toInt()}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // 4. HISTOGRAM
                SizedBox(
                  width: cardWidth,
                  child: ChartCard(
                    title: '4 · Histogram',
                    subtitle:
                        'Test score distribution (number of people per score range)',
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: BarChartPainter(
                        values: buckets,
                        labels: bucketLabels,
                        maxY: ((buckets.reduce(math.max) / 5).ceil() * 5)
                            .toDouble(),
                        colors: [kPalette[5]],
                        gapFraction: 0.05,
                      ),
                    ),
                  ),
                ),
                // 5. SCATTER
                SizedBox(
                  width: cardWidth,
                  child: ChartCard(
                    title: '5 · Scatter plot',
                    subtitle:
                        'Hours studied (x) vs test score (y), colored by batch',
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: ScatterPainter(
                        points: scatterPts,
                        colors: scatterColors,
                        maxX: 200,
                      ),
                    ),
                    footer: Legend(
                      labels: kBatches,
                      colors: kPalette.take(4).toList(),
                    ),
                  ),
                ),
                // 6. HORIZONTAL BAR
                SizedBox(
                  width: cardWidth,
                  child: ChartCard(
                    title: '6 · Horizontal bar chart',
                    subtitle: 'Top 10 learners by progress %',
                    height: 300,
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: HBarPainter(
                        labels: top10.map((p) => p.name).toList(),
                        values: top10.map((p) => p.progress).toList(),
                        color: kPalette[1],
                      ),
                    ),
                  ),
                ),
                // 7. RADAR
                SizedBox(
                  width: cardWidth,
                  child: ChartCard(
                    title: '7 · Radar chart',
                    subtitle: 'Average skill levels: everyone vs top 10',
                    height: 300,
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: RadarPainter(
                        axes: kSkills,
                        series: [skillAll, skillTop],
                        colors: [kPalette[0], kPalette[2]],
                      ),
                    ),
                    footer: Legend(
                      labels: const ['Everyone', 'Top 10'],
                      colors: [kPalette[0], kPalette[2]],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TRACKER: searchable, filterable list of all 100 people
// ─────────────────────────────────────────────────────────────

class TrackerPage extends StatefulWidget {
  const TrackerPage({super.key});

  @override
  State<TrackerPage> createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage> {
  String query = '';
  String statusFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final list =
        kPeople
            .where(
              (p) =>
                  (statusFilter == 'All' || p.status == statusFilter) &&
                  p.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList()
          ..sort((a, b) => b.progress.compareTo(a.progress));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search name…',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (v) => setState(() => query = v),
          ),
        ),
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              for (final s in ['All', ...kStatuses])
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  child: ChoiceChip(
                    label: Text(s),
                    selected: statusFilter == s,
                    onSelected: (_) => setState(() => statusFilter = s),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${list.length} people',
              style: const TextStyle(color: Colors.white54),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (context, i) => PersonTile(person: list[i]),
          ),
        ),
      ],
    );
  }
}

class PersonTile extends StatelessWidget {
  final Person person;
  const PersonTile({super.key, required this.person});

  @override
  Widget build(BuildContext context) {
    final color = statusColor(person.status);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => showPersonSheet(context, person),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withAlpha(60),
                child: Text(person.initials),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '#${person.id}  ${person.name}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          '${person.progress.toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${person.batch} · ${person.status}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: person.progress / 100,
                        minHeight: 8,
                        color: color,
                        backgroundColor: Colors.white12,
                      ),
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

void showPersonSheet(BuildContext context, Person p) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            p.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '${p.batch} · ${p.status} · ${p.hours.toStringAsFixed(0)} h studied · score ${p.score.toStringAsFixed(1)}',
            style: const TextStyle(color: Colors.white60),
          ),
          const SizedBox(height: 16),
          const Text(
            'Weekly progress',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 180,
            width: double.infinity,
            child: CustomPaint(
              size: Size.infinite,
              painter: LineChartPainter(
                series: [
                  LineSeries('Progress', p.weekly, statusColor(p.status)),
                ],
                xLabels: List.generate(kWeeks, (w) => 'W${w + 1}'),
                maxY: 100,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Skills', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          for (var i = 0; i < kSkills.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(width: 80, child: Text(kSkills[i])),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: p.skills[i] / 100,
                        minHeight: 8,
                        color: kPalette[i % kPalette.length],
                        backgroundColor: Colors.white12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(p.skills[i].toStringAsFixed(0)),
                ],
              ),
            ),
          const SizedBox(height: 16),
          const Text(
            'AI insights',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Forecast at week 20: ${kMl.forecasts[p.id - 1].at(20).toStringAsFixed(0)}%  ·  '
            'completion probability: ${(kMl.completeProb[p.id - 1] * 100).toStringAsFixed(0)}%  ·  '
            'group: ${kClusterNames[kMl.clusters.assignment[p.id - 1]]}',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 6),
          for (final tip in coachTips(p))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    size: 16,
                    color: Colors.amber,
                  ),
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
// SMALL WIDGETS
// ─────────────────────────────────────────────────────────────

class Kpi extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const Kpi({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white60,
                      ),
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

class ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? footer;
  final double height;
  const ChartCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.footer,
    this.height = 240,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.white60),
            ),
            const SizedBox(height: 12),
            SizedBox(height: height, width: double.infinity, child: child),
            if (footer != null) ...[const SizedBox(height: 8), footer!],
          ],
        ),
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
                decoration: BoxDecoration(
                  color: colors[i],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(labels[i], style: const TextStyle(fontSize: 12)),
            ],
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ML / AI ENGINE (pure Dart, trains on-device in milliseconds)
//  1. Linear regression  -> forecast each person's progress
//  2. Logistic regression -> probability of completing the course
//  3. K-means clustering  -> group learners by behaviour
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

// ---- 1. Linear regression (least squares) ----

class Forecast {
  final double slope; // % progress gained per week
  final double intercept;
  const Forecast(this.slope, this.intercept);

  double at(int week) =>
      (intercept + slope * week).clamp(0.0, 100.0).toDouble();

  /// Week in which the trend line reaches 100%, or null if there is no upward trend.
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

// ---- 2. Logistic regression (gradient descent) ----

/// Features use only the FIRST 6 WEEKS, to predict who finishes (>= 80%).
List<double> mlFeatures(Person p) => [
  p.weekly[5],
  fitLine(p.weekly.sublist(0, 6)).slope,
  p.hours,
  p.score,
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

TrainResult trainLogistic(List<Person> people) {
  final xs = people.map(mlFeatures).toList();
  final ys = people.map((p) => p.progress >= 80 ? 1.0 : 0.0).toList();

  // 70% train / 30% test split
  final trainIdx = <int>[];
  final testIdx = <int>[];
  for (var i = 0; i < people.length; i++) {
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

// ---- 3. K-means clustering ----

class ClusterResult {
  final List<int> assignment; // cluster rank per person (0 = best group)
  final List<int> sizes;
  final List<double> avgProgress;
  final List<double> avgScore;
  final List<double> avgHours;
  ClusterResult(
    this.assignment,
    this.sizes,
    this.avgProgress,
    this.avgScore,
    this.avgHours,
  );
}

ClusterResult kMeans(List<Person> people, int k) {
  const d = 3;
  final raw = people
      .map((p) => <double>[p.progress, p.score, p.hours])
      .toList();

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

  // Deterministic initial centroids: k distinct random people
  final rnd = math.Random(7);
  final chosen = <int>[];
  while (chosen.length < k) {
    final i = rnd.nextInt(people.length);
    if (!chosen.contains(i)) chosen.add(i);
  }
  final cent = chosen.map((i) => List<double>.from(z[i])).toList();
  final assign = List<int>.filled(people.length, 0);

  for (var iter = 0; iter < 30; iter++) {
    for (var i = 0; i < people.length; i++) {
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
    for (var i = 0; i < people.length; i++) {
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
      for (var i = 0; i < people.length; i++)
        if (assign[i] == c) people[i].progress,
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

  List<double> groupAvg(double Function(Person) pick) => List.generate(k, (r) {
    final members = [
      for (var i = 0; i < people.length; i++)
        if (ranked[i] == r) pick(people[i]),
    ];
    return avg(members);
  });

  return ClusterResult(
    ranked,
    List.generate(k, (r) => ranked.where((x) => x == r).length),
    groupAvg((p) => p.progress),
    groupAvg((p) => p.score),
    groupAvg((p) => p.hours),
  );
}

// ---- Run everything once ----

class MlResult {
  final List<Forecast> forecasts; // index = person id - 1
  final List<double> completeProb; // probability of finishing (>= 80%)
  final TrainResult model;
  final ClusterResult clusters;
  MlResult(this.forecasts, this.completeProb, this.model, this.clusters);
}

MlResult runMl(List<Person> people) {
  final model = trainLogistic(people);
  return MlResult(
    people.map((p) => fitLine(p.weekly)).toList(),
    people.map((p) => model.predict(mlFeatures(p))).toList(),
    model,
    kMeans(people, 4),
  );
}

final MlResult kMl = runMl(kPeople);

// ---- 4. Rule-based coach ----

List<String> coachTips(Person p) {
  final i = p.id - 1;
  final prob = kMl.completeProb[i];
  final f = kMl.forecasts[i];
  final tips = <String>[];

  if (p.progress < 80 && prob < 0.4) {
    tips.add(
      'High risk of not finishing (${((1 - prob) * 100).round()}%). Arrange a mentor check-in this week.',
    );
  }
  if (p.progress < 80 && f.slope < 5) {
    tips.add(
      'Pace is ${f.slope.toStringAsFixed(1)}% per week. Add about 30 minutes of daily practice.',
    );
  }
  var weakest = 0;
  for (var s = 1; s < kSkills.length; s++) {
    if (p.skills[s] < p.skills[weakest]) weakest = s;
  }
  if (p.skills[weakest] < 55) {
    tips.add(
      'Weakest skill is ${kSkills[weakest]} (${p.skills[weakest].toStringAsFixed(0)}). Give it extra practice.',
    );
  }
  if (p.progress >= 80) {
    tips.add(
      'Course nearly done. Suggest an advanced module or a peer-mentor role.',
    );
  }
  if (tips.isEmpty) {
    tips.add('Healthy pace. Keep the current routine.');
  }
  return tips;
}

// ─────────────────────────────────────────────────────────────
// AI INSIGHTS PAGE
// ─────────────────────────────────────────────────────────────

class AiInsightsPage extends StatelessWidget {
  const AiInsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final people = kPeople;
    final ml = kMl;
    final model = ml.model;

    final finishers = ml.forecasts.where((f) => f.at(20) >= 80).length;
    final highRisk = people
        .where((p) => p.progress < 80 && ml.completeProb[p.id - 1] < 0.4)
        .length;

    // Feature importance (share of |weight|)
    final absW = model.w.map((v) => v.abs()).toList();
    final totalW = absW.fold<double>(0, (a, b) => a + b);
    final importance = absW
        .map((v) => totalW == 0 ? 0.0 : v / totalW * 100)
        .toList();

    // Forecast chart: weeks 1-12 actual, 13-20 predicted
    final actualAvg = List.generate(
      kWeeks,
      (w) => avg(people.map((p) => p.weekly[w])),
    );
    final forecastAvg = List.generate(
      20,
      (w) =>
          w < kWeeks ? actualAvg[w] : avg(ml.forecasts.map((f) => f.at(w + 1))),
    );
    final labels20 = List.generate(20, (w) => 'W${w + 1}');

    // Watchlist: lowest completion probability among unfinished learners
    final watch = people.where((p) => p.progress < 80).toList()
      ..sort(
        (a, b) =>
            ml.completeProb[a.id - 1].compareTo(ml.completeProb[b.id - 1]),
      );
    final top = watch.take(10).toList();

    final cl = ml.clusters;
    final maxSize = cl.sizes.reduce(math.max);

    return LayoutBuilder(
      builder: (context, constraints) {
        final twoCols = constraints.maxWidth >= 900;
        final cardWidth = twoCols
            ? (constraints.maxWidth - 16 * 3) / 2
            : constraints.maxWidth - 32;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                Kpi(
                  label: 'Test accuracy',
                  value: '${model.testAcc.last.toStringAsFixed(0)}%',
                  icon: Icons.fact_check,
                  color: kPalette[1],
                ),
                Kpi(
                  label: 'Train accuracy',
                  value: '${model.trainAcc.last.toStringAsFixed(0)}%',
                  icon: Icons.school,
                  color: kPalette[0],
                ),
                Kpi(
                  label: 'Finish by wk 20',
                  value: '$finishers',
                  icon: Icons.flag,
                  color: kPalette[2],
                ),
                Kpi(
                  label: 'High-risk',
                  value: '$highRisk',
                  icon: Icons.warning_amber,
                  color: kPalette[3],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                // Interactive predictor
                SizedBox(width: cardWidth, child: const PredictorCard()),

                // Learning curve
                SizedBox(
                  width: cardWidth,
                  child: ChartCard(
                    title: 'Model learning curve',
                    subtitle:
                        'Logistic regression accuracy (%) vs training epoch',
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: LineChartPainter(
                        series: [
                          LineSeries('Train', model.trainAcc, kPalette[0]),
                          LineSeries('Test', model.testAcc, kPalette[2]),
                        ],
                        xLabels: List.generate(
                          model.trainAcc.length,
                          (i) => '${(i + 1) * 20}',
                        ),
                        maxY: 100,
                      ),
                    ),
                    footer: Legend(
                      labels: const ['Train (70 people)', 'Test (30 people)'],
                      colors: [kPalette[0], kPalette[2]],
                    ),
                  ),
                ),

                // Feature importance
                SizedBox(
                  width: cardWidth,
                  child: ChartCard(
                    title: 'What drives completion?',
                    subtitle: 'Feature importance (share of model weight)',
                    height: 200,
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: HBarPainter(
                        labels: kFeatureNames,
                        values: importance,
                        color: kPalette[4],
                      ),
                    ),
                  ),
                ),

                // Forecast
                SizedBox(
                  width: cardWidth,
                  child: ChartCard(
                    title: 'Progress forecast to week 20',
                    subtitle: 'Average of per-person linear regression trends',
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: LineChartPainter(
                        series: [
                          LineSeries('Forecast', forecastAvg, kPalette[2]),
                          LineSeries('Actual', actualAvg, kPalette[0]),
                        ],
                        xLabels: labels20,
                        maxY: 100,
                      ),
                    ),
                    footer: Legend(
                      labels: const ['Actual (W1-W12)', 'Forecast (W13-W20)'],
                      colors: [kPalette[0], kPalette[2]],
                    ),
                  ),
                ),

                // K-means scatter
                SizedBox(
                  width: cardWidth,
                  child: ChartCard(
                    title: 'K-means learner groups',
                    subtitle:
                        'Hours studied (x) vs test score (y), colored by cluster',
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: ScatterPainter(
                        points: people
                            .map((p) => Offset(p.hours, p.score))
                            .toList(),
                        colors: [
                          for (final c in cl.assignment)
                            kClusterColors[c].withAlpha(210),
                        ],
                        maxX: 200,
                      ),
                    ),
                    footer: Legend(
                      labels: kClusterNames,
                      colors: kClusterColors,
                    ),
                  ),
                ),

                // Cluster sizes + table
                SizedBox(
                  width: cardWidth,
                  child: ChartCard(
                    title: 'Cluster sizes',
                    subtitle: 'People per group, with group averages below',
                    height: 180,
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: BarChartPainter(
                        values: cl.sizes.map((s) => s.toDouble()).toList(),
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
                                  decoration: BoxDecoration(
                                    color: kClusterColors[c],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    kClusterNames[c],
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                Text(
                                  '${cl.avgProgress[c].toStringAsFixed(0)}% · ${cl.avgScore[c].toStringAsFixed(0)} pts · ${cl.avgHours[c].toStringAsFixed(0)} h',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Watchlist
                SizedBox(
                  width: cardWidth,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AI watchlist',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            '10 learners least likely to finish. Tap for details.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white60,
                            ),
                          ),
                          const SizedBox(height: 8),
                          for (final p in top) WatchTile(person: p),
                        ],
                      ),
                    ),
                  ),
                ),

                // How it works
                SizedBox(
                  width: cardWidth,
                  child: const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How the AI works',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '• Linear regression fits a trend line through each person\'s 12 weekly points and extends it to week 20.',
                          ),
                          SizedBox(height: 6),
                          Text(
                            '• Logistic regression learns from week-1 to week-6 data (progress, pace, hours, score) to predict who finishes at 80% or more. It trains on 70 people and is checked on 30 unseen people.',
                          ),
                          SizedBox(height: 6),
                          Text(
                            '• K-means groups people into 4 clusters by progress, score and hours.',
                          ),
                          SizedBox(height: 6),
                          Text(
                            '• Rules turn the results into coaching tips. Everything runs on-device, with no packages and no server.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class WatchTile extends StatelessWidget {
  final Person person;
  const WatchTile({super.key, required this.person});

  @override
  Widget build(BuildContext context) {
    final i = person.id - 1;
    final risk = (1 - kMl.completeProb[i]) * 100;
    final f = kMl.forecasts[i];
    final eta = f.etaWeek;
    final etaText = eta == null
        ? 'no upward trend'
        : (eta > 52 ? 'finish after week 52' : 'finish ~week ${eta.ceil()}');
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      onTap: () => showPersonSheet(context, person),
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: statusColor('At risk').withAlpha(60),
        child: Text(person.initials, style: const TextStyle(fontSize: 11)),
      ),
      title: Text('#${person.id}  ${person.name}'),
      subtitle: Text(
        'Now ${person.progress.toStringAsFixed(0)}% · week 20: ${f.at(20).toStringAsFixed(0)}% · $etaText\n${coachTips(person).first}',
        style: const TextStyle(fontSize: 12),
      ),
      isThreeLine: true,
      trailing: Text(
        '${risk.toStringAsFixed(0)}%\nrisk',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: statusColor('At risk'),
          fontWeight: FontWeight.bold,
        ),
      ),
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

  Widget slider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
    String suffix,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(label, style: const TextStyle(fontSize: 12)),
        ),
        Expanded(
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
        SizedBox(
          width: 56,
          child: Text(
            '${value.toStringAsFixed(0)}$suffix',
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final prob = kMl.model.predict([week6, pace, hours, score]);
    final color = prob >= 0.7
        ? statusColor('Completed')
        : (prob >= 0.4 ? statusColor('Behind') : statusColor('At risk'));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Try the model',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Move the sliders to predict a new learner\'s chance of finishing',
              style: TextStyle(fontSize: 12, color: Colors.white60),
            ),
            const SizedBox(height: 8),
            slider(
              'Week-6 progress',
              week6,
              0,
              70,
              (v) => setState(() => week6 = v),
              '%',
            ),
            slider(
              'Weekly pace',
              pace,
              0,
              15,
              (v) => setState(() => pace = v),
              '%',
            ),
            slider(
              'Hours studied',
              hours,
              0,
              200,
              (v) => setState(() => hours = v),
              'h',
            ),
            slider(
              'Test score',
              score,
              30,
              100,
              (v) => setState(() => score = v),
              '',
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${(prob * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'chance of completing (80%+)',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: prob,
                          minHeight: 10,
                          color: color,
                          backgroundColor: Colors.white12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CHART PAINTERS
// ─────────────────────────────────────────────────────────────

void drawText(
  Canvas canvas,
  String text,
  Offset offset, {
  double size = 10,
  Color color = const Color(0xB3FFFFFF),
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

void drawYGrid(
  Canvas canvas,
  Rect plot,
  double maxY,
  int steps, {
  String suffix = '',
}) {
  final paint = Paint()
    ..color = const Color(0x22FFFFFF)
    ..strokeWidth = 1;
  for (var i = 0; i <= steps; i++) {
    final y = plot.bottom - plot.height * i / steps;
    canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), paint);
    drawText(
      canvas,
      '${(maxY * i / steps).round()}$suffix',
      Offset(plot.left - 6, y),
      align: TextAlign.right,
    );
  }
}

/// Used for chart 1 (bar) and chart 4 (histogram).
class BarChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final double maxY;
  final List<Color> colors;
  final double gapFraction;
  final String valueSuffix;

  BarChartPainter({
    required this.values,
    required this.labels,
    required this.maxY,
    required this.colors,
    this.gapFraction = 0.35,
    this.valueSuffix = '',
  });

  @override
  void paint(Canvas canvas, Size size) {
    final plot = Rect.fromLTRB(36, 14, size.width - 8, size.height - 26);
    drawYGrid(canvas, plot, maxY, 4);
    final n = values.length;
    final slot = plot.width / n;
    final barW = slot * (1 - gapFraction);

    for (var i = 0; i < n; i++) {
      final x = plot.left + slot * i + (slot - barW) / 2;
      final h = plot.height * (values[i] / maxY).clamp(0.0, 1.0);
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, plot.bottom - h, barW, h),
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
      );
      canvas.drawRRect(rect, Paint()..color = colors[i % colors.length]);
      final text = values[i] % 1 == 0
          ? values[i].toStringAsFixed(0)
          : values[i].toStringAsFixed(1);
      drawText(
        canvas,
        '$text$valueSuffix',
        Offset(x + barW / 2, plot.bottom - h - 8),
        align: TextAlign.center,
        color: Colors.white,
      );
      drawText(
        canvas,
        labels[i],
        Offset(x + barW / 2, plot.bottom + 12),
        align: TextAlign.center,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class LineSeries {
  final String name;
  final List<double> values;
  final Color color;
  const LineSeries(this.name, this.values, this.color);
}

/// Used for chart 2 (multi-line) and the per-person weekly chart.
class LineChartPainter extends CustomPainter {
  final List<LineSeries> series;
  final List<String> xLabels;
  final double maxY;

  LineChartPainter({
    required this.series,
    required this.xLabels,
    required this.maxY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final plot = Rect.fromLTRB(40, 14, size.width - 12, size.height - 26);
    drawYGrid(canvas, plot, maxY, 4, suffix: '%');
    final n = xLabels.length;
    final step = n > 8 ? 2 : 1;
    double xAt(int i) => plot.left + plot.width * i / (n - 1);

    for (var i = 0; i < n; i += step) {
      drawText(
        canvas,
        xLabels[i],
        Offset(xAt(i), plot.bottom + 12),
        align: TextAlign.center,
      );
    }

    for (final s in series) {
      final path = Path();
      for (var i = 0; i < s.values.length; i++) {
        final y =
            plot.bottom - plot.height * (s.values[i] / maxY).clamp(0.0, 1.0);
        if (i == 0) {
          path.moveTo(xAt(i), y);
        } else {
          path.lineTo(xAt(i), y);
        }
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = s.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeJoin = StrokeJoin.round,
      );
      for (var i = 0; i < s.values.length; i++) {
        final y =
            plot.bottom - plot.height * (s.values[i] / maxY).clamp(0.0, 1.0);
        canvas.drawCircle(Offset(xAt(i), y), 3, Paint()..color = s.color);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Chart 3.
class DonutPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  final String centerText;
  final String centerSub;

  DonutPainter({
    required this.values,
    required this.colors,
    required this.centerText,
    required this.centerSub,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - 6;
    final stroke = radius * 0.35;
    final rect = Rect.fromCircle(
      center: center,
      radius: radius,
    ).deflate(stroke / 2);
    final total = values.fold<double>(0, (a, b) => a + b);
    if (total == 0) return;

    var start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = 2 * math.pi * values[i] / total;
      canvas.drawArc(
        rect,
        start,
        math.max(sweep - 0.03, 0.001),
        false,
        Paint()
          ..color = colors[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke,
      );
      start += sweep;
    }
    drawText(
      canvas,
      centerText,
      center.translate(0, -8),
      size: 24,
      color: Colors.white,
      align: TextAlign.center,
      weight: FontWeight.bold,
    );
    drawText(
      canvas,
      centerSub,
      center.translate(0, 14),
      size: 11,
      align: TextAlign.center,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Chart 5.
class ScatterPainter extends CustomPainter {
  final List<Offset> points; // dx = hours, dy = score
  final List<Color> colors;
  final double maxX;

  ScatterPainter({
    required this.points,
    required this.colors,
    required this.maxX,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final plot = Rect.fromLTRB(36, 14, size.width - 12, size.height - 26);
    drawYGrid(canvas, plot, 100, 4);
    for (var i = 0; i <= 4; i++) {
      final x = plot.left + plot.width * i / 4;
      drawText(
        canvas,
        '${(maxX * i / 4).round()}h',
        Offset(x, plot.bottom + 12),
        align: TextAlign.center,
      );
    }
    for (var i = 0; i < points.length; i++) {
      final x = plot.left + plot.width * (points[i].dx / maxX).clamp(0.0, 1.0);
      final y =
          plot.bottom - plot.height * (points[i].dy / 100).clamp(0.0, 1.0);
      canvas.drawCircle(Offset(x, y), 4, Paint()..color = colors[i]);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Chart 6.
class HBarPainter extends CustomPainter {
  final List<String> labels;
  final List<double> values;
  final Color color;

  HBarPainter({
    required this.labels,
    required this.values,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const labelW = 104.0;
    final plot = Rect.fromLTRB(labelW, 4, size.width - 40, size.height - 4);
    final n = values.length;
    final rowH = plot.height / n;
    final gridPaint = Paint()
      ..color = const Color(0x22FFFFFF)
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final x = plot.left + plot.width * i / 4;
      canvas.drawLine(Offset(x, plot.top), Offset(x, plot.bottom), gridPaint);
    }
    for (var i = 0; i < n; i++) {
      final cy = plot.top + rowH * i + rowH / 2;
      final w = plot.width * (values[i] / 100).clamp(0.0, 1.0);
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(plot.left, cy - rowH * 0.3, w, rowH * 0.6),
        topRight: const Radius.circular(4),
        bottomRight: const Radius.circular(4),
      );
      canvas.drawRRect(rect, Paint()..color = color);
      drawText(
        canvas,
        labels[i],
        Offset(plot.left - 8, cy),
        align: TextAlign.right,
        maxWidth: labelW - 12,
        size: 11,
      );
      drawText(
        canvas,
        '${values[i].toStringAsFixed(0)}%',
        Offset(plot.left + w + 6, cy),
        color: Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Chart 7.
class RadarPainter extends CustomPainter {
  final List<String> axes;
  final List<List<double>> series;
  final List<Color> colors;

  RadarPainter({
    required this.axes,
    required this.series,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - 32;
    final n = axes.length;

    Offset point(int i, double fraction) {
      final angle = -math.pi / 2 + 2 * math.pi * i / n;
      return center +
          Offset(math.cos(angle), math.sin(angle)) * (radius * fraction);
    }

    final ringPaint = Paint()
      ..color = const Color(0x33FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var ring = 1; ring <= 4; ring++) {
      final path = Path();
      for (var i = 0; i < n; i++) {
        final p = point(i, ring / 4);
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      path.close();
      canvas.drawPath(path, ringPaint);
    }

    for (var i = 0; i < n; i++) {
      canvas.drawLine(center, point(i, 1), ringPaint);
      drawText(
        canvas,
        axes[i],
        point(i, 1 + 18 / radius),
        align: TextAlign.center,
        size: 11,
        color: Colors.white,
      );
    }

    for (var s = 0; s < series.length; s++) {
      final path = Path();
      for (var i = 0; i < n; i++) {
        final p = point(i, (series[s][i] / 100).clamp(0.0, 1.0));
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      path.close();
      canvas.drawPath(path, Paint()..color = colors[s].withAlpha(60));
      canvas.drawPath(
        path,
        Paint()
          ..color = colors[s]
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
