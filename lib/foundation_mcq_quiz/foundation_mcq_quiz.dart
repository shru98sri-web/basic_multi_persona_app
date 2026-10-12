import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuizQuestion {
  final int id;
  final String question;
  final List<String> options;
  final int correctIndex;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    final rawOptions = (json['options'] as List).cast<Map<String, dynamic>>();
    final correct = rawOptions.indexWhere((o) => o['isCorrect'] == true);

    return QuizQuestion(
      id: json['id'] as int,
      question: json['question'] as String,
      options: rawOptions.map((o) => o['label'] as String).toList(),
      correctIndex: correct,
    );
  }
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '100 Question Quiz',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const QuizLoader(),
    );
  }
}

class QuizLoader extends StatefulWidget {
  const QuizLoader({super.key});

  @override
  State<QuizLoader> createState() => _QuizLoaderState();
}

class _QuizLoaderState extends State<QuizLoader> {
  late Future<List<QuizQuestion>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadQuestions();
  }

  Future<List<QuizQuestion>> _loadQuestions() async {
    final text = await rootBundle.loadString('assets/questions.json');
    final list = jsonDecode(text) as List;
    return list
        .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<QuizQuestion>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Could not load questions:\n${snapshot.error}'),
              ),
            ),
          );
        }
        return QuizPage(questions: snapshot.data!);
      },
    );
  }
}

class QuizPage extends StatefulWidget {
  final List<QuizQuestion> questions;

  const QuizPage({super.key, required this.questions});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int current = 0;
  int score = 0;
  bool finished = false;
  final Map<int, int> answers = {};

  QuizQuestion get question => widget.questions[current];

  void selectAnswer(int index) {
    setState(() {
      answers[question.id] = index;
    });
  }

  void next() {
    if (current == widget.questions.length - 1) {
      _finish();
    } else {
      setState(() => current++);
    }
  }

  void previous() {
    if (current > 0) {
      setState(() => current--);
    }
  }

  void _finish() {
    int result = 0;
    for (final q in widget.questions) {
      if (answers[q.id] == q.correctIndex) result++;
    }
    setState(() {
      score = result;
      finished = true;
    });
  }

  void restart() {
    setState(() {
      current = 0;
      score = 0;
      finished = false;
      answers.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (finished) {
      return ResultPage(
        questions: widget.questions,
        answers: answers,
        score: score,
        onRestart: restart,
      );
    }

    final selected = answers[question.id];
    final progress = (current + 1) / widget.questions.length;

    return Scaffold(
      appBar: AppBar(title: const Text('100 Question Quiz'), centerTitle: true),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(value: progress, minHeight: 6),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${current + 1} of ${widget.questions.length}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text('${answers.length} answered'),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          question.question,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(question.options.length, (index) {
                      final isSelected = selected == index;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: RadioListTile<int>(
                            value: index,
                            groupValue: selected,
                            onChanged: (value) {
                              if (value != null) selectAnswer(value);
                            },
                            title: Text(question.options[index]),
                            subtitle: Text(String.fromCharCode(65 + index)),
                            selected: isSelected,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (current > 0)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: previous,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Previous'),
                      ),
                    ),
                  if (current > 0) const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: selected == null ? null : next,
                      icon: Icon(
                        current == widget.questions.length - 1
                            ? Icons.check
                            : Icons.arrow_forward,
                      ),
                      label: Text(
                        current == widget.questions.length - 1
                            ? 'Submit Quiz'
                            : 'Next',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultPage extends StatelessWidget {
  final List<QuizQuestion> questions;
  final Map<int, int> answers;
  final int score;
  final VoidCallback onRestart;

  const ResultPage({
    super.key,
    required this.questions,
    required this.answers,
    required this.score,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = score / questions.length * 100;

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Result'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(Icons.emoji_events, size: 64),
                    const SizedBox(height: 12),
                    Text(
                      '$score / ${questions.length}',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(_message(percentage)),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final q = questions[index];
                final userAnswer = answers[q.id];
                final correct = userAnswer == q.correctIndex;

                return ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(q.question),
                  subtitle: Text(
                    userAnswer == null
                        ? 'Not answered\nCorrect: ${q.options[q.correctIndex]}'
                        : correct
                        ? 'Your answer: ${q.options[userAnswer]}'
                        : 'Your answer: ${q.options[userAnswer]}\n'
                              'Correct: ${q.options[q.correctIndex]}',
                  ),
                  isThreeLine: true,
                  trailing: Icon(
                    correct ? Icons.check_circle : Icons.cancel,
                    color: correct ? Colors.green : Colors.red,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onRestart,
                icon: const Icon(Icons.refresh),
                label: const Text('Retake Quiz'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _message(double percentage) {
    if (percentage >= 90) return 'Excellent performance!';
    if (percentage >= 75) return 'Great job!';
    if (percentage >= 60) return 'Good effort!';
    if (percentage >= 40) return 'Keep practicing!';
    return 'Practice and try again!';
  }
}
