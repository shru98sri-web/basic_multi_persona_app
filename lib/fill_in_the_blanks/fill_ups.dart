import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

// void main() {
//   runApp(const FillBlankQuizApp());
// }

// ============================================================
// QUESTION MODEL
// ============================================================

enum Difficulty { easy, medium, hard }

class Question {
  final String category;
  final String question;
  final String answer;
  final String explanation;
  final Difficulty difficulty;
  final String hint;

  const Question({
    required this.category,
    required this.question,
    required this.answer,
    required this.explanation,
    required this.difficulty,
    required this.hint,
  });
}

// ============================================================
// 50 QUESTION BANK
// ============================================================

const List<Question> questionBank = [
  // ==========================================================
  // PHOTONICS - 10
  // ==========================================================
  Question(
    category: 'Photonics',
    difficulty: Difficulty.easy,
    question:
        'The basic particle of electromagnetic radiation is called a ______.',
    answer: 'photon',
    hint: 'It begins with "ph".',
    explanation:
        'A photon is the quantum or fundamental particle of electromagnetic radiation.',
  ),

  Question(
    category: 'Photonics',
    difficulty: Difficulty.easy,
    question:
        'LASER stands for Light Amplification by Stimulated Emission of ______.',
    answer: 'Radiation',
    hint: 'The last word in LASER.',
    explanation:
        'LASER means Light Amplification by Stimulated Emission of Radiation.',
  ),

  Question(
    category: 'Photonics',
    difficulty: Difficulty.medium,
    question:
        'The phenomenon in which light bends around obstacles is called ______.',
    answer: 'diffraction',
    hint: 'It is a wave phenomenon.',
    explanation:
        'Diffraction is the bending and spreading of waves around obstacles and openings.',
  ),

  Question(
    category: 'Photonics',
    difficulty: Difficulty.easy,
    question: 'The refractive index of vacuum is approximately ______.',
    answer: '1',
    hint: 'It is the reference refractive index.',
    explanation: 'The refractive index of vacuum is exactly 1.',
  ),

  Question(
    category: 'Photonics',
    difficulty: Difficulty.medium,
    question:
        'In an optical fiber, light is guided mainly by ______ internal reflection.',
    answer: 'total',
    hint: 'TIR stands for this.',
    explanation: 'Optical fibers guide light using total internal reflection.',
  ),

  Question(
    category: 'Photonics',
    difficulty: Difficulty.hard,
    question:
        'The process by which an excited atom emits a photon due to an incoming photon is called stimulated ______.',
    answer: 'emission',
    hint: 'It is one of the key processes in lasers.',
    explanation: 'Stimulated emission is fundamental to laser operation.',
  ),

  Question(
    category: 'Photonics',
    difficulty: Difficulty.easy,
    question:
        'The unit of wavelength commonly used for visible light is the ______.',
    answer: 'nanometer',
    hint: 'One billionth of a meter.',
    explanation: 'Visible wavelengths are commonly expressed in nanometers.',
  ),

  Question(
    category: 'Photonics',
    difficulty: Difficulty.easy,
    question:
        'A device that converts an optical signal into an electrical signal is called a photo______.',
    answer: 'detector',
    hint: 'It detects photons.',
    explanation:
        'Photodetectors convert incident optical radiation into electrical signals.',
  ),

  Question(
    category: 'Photonics',
    difficulty: Difficulty.medium,
    question: 'The speed of light in vacuum is approximately ______ m/s.',
    answer: '3 × 10^8',
    hint: 'Three hundred million meters per second.',
    explanation: 'The speed of light in vacuum is approximately 3 × 10^8 m/s.',
  ),

  Question(
    category: 'Photonics',
    difficulty: Difficulty.medium,
    question:
        'The phenomenon where two coherent light waves produce bright and dark fringes is called ______.',
    answer: 'interference',
    hint: 'Young used this phenomenon.',
    explanation: 'Interference results from superposition of coherent waves.',
  ),

  // ==========================================================
  // PHYSICS - 10
  // ==========================================================
  Question(
    category: 'Physics',
    difficulty: Difficulty.easy,
    question: 'Newton’s first law is also known as the law of ______.',
    answer: 'inertia',
    hint: 'Resistance to change in motion.',
    explanation:
        'Newton’s first law describes the tendency of objects to resist changes in motion.',
  ),

  Question(
    category: 'Physics',
    difficulty: Difficulty.easy,
    question: 'The SI unit of force is the ______.',
    answer: 'newton',
    hint: 'Named after Isaac Newton.',
    explanation: 'The SI unit of force is newton (N).',
  ),

  Question(
    category: 'Physics',
    difficulty: Difficulty.easy,
    question: 'The rate of change of velocity is called ______.',
    answer: 'acceleration',
    hint: 'It is measured in m/s².',
    explanation: 'Acceleration is the rate of change of velocity with time.',
  ),

  Question(
    category: 'Physics',
    difficulty: Difficulty.easy,
    question: 'The SI unit of electric current is the ______.',
    answer: 'ampere',
    hint: 'Symbol A.',
    explanation: 'Electric current is measured in amperes (A).',
  ),

  Question(
    category: 'Physics',
    difficulty: Difficulty.medium,
    question:
        'The force between two electric charges is described by ______ law.',
    answer: 'Coulomb',
    hint: 'Named after Charles-Augustin de Coulomb.',
    explanation: 'Coulomb’s law gives the electrostatic force between charges.',
  ),

  Question(
    category: 'Physics',
    difficulty: Difficulty.easy,
    question: 'The SI unit of energy is the ______.',
    answer: 'joule',
    hint: 'Symbol J.',
    explanation: 'Energy is measured in joules (J).',
  ),

  Question(
    category: 'Physics',
    difficulty: Difficulty.easy,
    question: 'The resistance of a conductor is measured in ______.',
    answer: 'ohms',
    hint: 'Symbol Ω.',
    explanation: 'Electrical resistance is measured in ohms (Ω).',
  ),

  Question(
    category: 'Physics',
    difficulty: Difficulty.easy,
    question:
        'The acceleration due to gravity on Earth is approximately ______ m/s².',
    answer: '9.8',
    hint: 'It is close to 10 m/s².',
    explanation: 'The standard approximate value is 9.8 m/s².',
  ),

  Question(
    category: 'Physics',
    difficulty: Difficulty.medium,
    question:
        'The momentum of an object is equal to mass multiplied by ______.',
    answer: 'velocity',
    hint: 'p = mv.',
    explanation: 'Momentum is p = mv.',
  ),

  Question(
    category: 'Physics',
    difficulty: Difficulty.easy,
    question: 'The SI unit of frequency is the ______.',
    answer: 'hertz',
    hint: 'Symbol Hz.',
    explanation: 'Frequency is measured in hertz (Hz).',
  ),

  // ==========================================================
  // MATHEMATICS - 10
  // ==========================================================
  Question(
    category: 'Mathematics',
    difficulty: Difficulty.easy,
    question: 'The value of π approximately equals ______.',
    answer: '3.14159',
    hint: 'The circle constant.',
    explanation: 'π is approximately 3.14159.',
  ),

  Question(
    category: 'Mathematics',
    difficulty: Difficulty.easy,
    question: 'The derivative of x² is ______.',
    answer: '2x',
    hint: 'Use the power rule.',
    explanation: 'Using the power rule, d(x²)/dx = 2x.',
  ),

  Question(
    category: 'Mathematics',
    difficulty: Difficulty.medium,
    question: 'The integral of 2x dx is ______.',
    answer: 'x² + C',
    hint: 'Reverse the derivative of x².',
    explanation: '∫2x dx = x² + C.',
  ),

  Question(
    category: 'Mathematics',
    difficulty: Difficulty.easy,
    question:
        'A triangle with all three sides equal is called an ______ triangle.',
    answer: 'equilateral',
    hint: 'Equal sides.',
    explanation: 'An equilateral triangle has three equal sides.',
  ),

  Question(
    category: 'Mathematics',
    difficulty: Difficulty.easy,
    question: 'The square root of 144 is ______.',
    answer: '12',
    hint: '12 × 12.',
    explanation: '12 × 12 = 144.',
  ),

  Question(
    category: 'Mathematics',
    difficulty: Difficulty.easy,
    question: 'The sum of angles in a triangle is ______ degrees.',
    answer: '180',
    hint: 'A straight angle has the same number.',
    explanation: 'The interior angles of a Euclidean triangle add up to 180°.',
  ),

  Question(
    category: 'Mathematics',
    difficulty: Difficulty.easy,
    question: 'The slope of a horizontal straight line is ______.',
    answer: '0',
    hint: 'There is no vertical change.',
    explanation: 'A horizontal line has slope zero.',
  ),

  Question(
    category: 'Mathematics',
    difficulty: Difficulty.easy,
    question: 'The factorial of 5, written as 5!, is ______.',
    answer: '120',
    hint: '5 × 4 × 3 × 2 × 1.',
    explanation: '5! = 120.',
  ),

  Question(
    category: 'Mathematics',
    difficulty: Difficulty.easy,
    question: 'The probability of an event that is certain is ______.',
    answer: '1',
    hint: 'Maximum probability.',
    explanation: 'A certain event has probability 1.',
  ),

  Question(
    category: 'Mathematics',
    difficulty: Difficulty.medium,
    question: 'The determinant of a 2 × 2 identity matrix is ______.',
    answer: '1',
    hint: 'Identity matrices have a special determinant.',
    explanation: 'The determinant of an identity matrix is 1.',
  ),

  // ==========================================================
  // PYTHON - 10
  // ==========================================================
  Question(
    category: 'Python',
    difficulty: Difficulty.easy,
    question:
        'The Python function used to display output on the screen is ______.',
    answer: 'print',
    hint: 'You use it like print("Hello").',
    explanation: 'The print() function displays output.',
  ),

  Question(
    category: 'Python',
    difficulty: Difficulty.easy,
    question: 'The keyword used to define a function in Python is ______.',
    answer: 'def',
    hint: 'Three letters.',
    explanation: 'Python functions are defined using def.',
  ),

  Question(
    category: 'Python',
    difficulty: Difficulty.easy,
    question:
        'A collection of ordered and changeable elements in Python is called a ______.',
    answer: 'list',
    hint: 'Written using square brackets.',
    explanation: 'Python lists are ordered and mutable collections.',
  ),

  Question(
    category: 'Python',
    difficulty: Difficulty.easy,
    question: 'The symbol used for a single-line comment in Python is ______.',
    answer: '#',
    hint: 'It is used before a comment.',
    explanation: 'Python uses # for single-line comments.',
  ),

  Question(
    category: 'Python',
    difficulty: Difficulty.easy,
    question:
        'The function used to find the length of a Python list is ______.',
    answer: 'len',
    hint: 'Three letters.',
    explanation: 'len() returns the number of elements.',
  ),

  Question(
    category: 'Python',
    difficulty: Difficulty.easy,
    question: 'A Python dictionary stores data using ______ and value pairs.',
    answer: 'key',
    hint: 'The first part of key-value.',
    explanation: 'Dictionaries store key-value pairs.',
  ),

  Question(
    category: 'Python',
    difficulty: Difficulty.easy,
    question: 'The keyword used to create a class in Python is ______.',
    answer: 'class',
    hint: 'class MyClass:',
    explanation: 'Python classes are declared using class.',
  ),

  Question(
    category: 'Python',
    difficulty: Difficulty.easy,
    question: 'The Boolean values in Python are True and ______.',
    answer: 'False',
    hint: 'Opposite of True.',
    explanation: 'Python has two Boolean values: True and False.',
  ),

  Question(
    category: 'Python',
    difficulty: Difficulty.medium,
    question: 'The operator used for exponentiation in Python is ______.',
    answer: '**',
    hint: '2 ? 3 = 8.',
    explanation: 'For example, 2 ** 3 gives 8.',
  ),

  Question(
    category: 'Python',
    difficulty: Difficulty.easy,
    question: 'The keyword used to import a module is ______.',
    answer: 'import',
    hint: 'Example: import math.',
    explanation: 'Python uses import to load modules.',
  ),

  // ==========================================================
  // DART & FLUTTER - 10
  // ==========================================================
  Question(
    category: 'Dart & Flutter',
    difficulty: Difficulty.easy,
    question:
        'Flutter applications are primarily written using the ______ programming language.',
    answer: 'Dart',
    hint: 'The language created by Google.',
    explanation: 'Flutter uses Dart as its programming language.',
  ),

  Question(
    category: 'Dart & Flutter',
    difficulty: Difficulty.easy,
    question: 'The function that starts a Dart program is called ______.',
    answer: 'main',
    hint: 'void ______() {}',
    explanation: 'Dart execution begins with main().',
  ),

  Question(
    category: 'Dart & Flutter',
    difficulty: Difficulty.easy,
    question:
        'The Flutter widget used for a basic screen layout is commonly called ______.',
    answer: 'Scaffold',
    hint: 'It provides appBar and body.',
    explanation: 'Scaffold provides a basic Material Design structure.',
  ),

  Question(
    category: 'Dart & Flutter',
    difficulty: Difficulty.easy,
    question:
        'A widget whose state can change during its lifetime is called a ______ widget.',
    answer: 'Stateful',
    hint: 'The opposite of Stateless.',
    explanation: 'StatefulWidget is used when UI state can change.',
  ),

  Question(
    category: 'Dart & Flutter',
    difficulty: Difficulty.easy,
    question:
        'A widget that does not maintain mutable state is called a ______ widget.',
    answer: 'Stateless',
    hint: 'It does not have mutable state.',
    explanation: 'StatelessWidget represents immutable UI.',
  ),

  Question(
    category: 'Dart & Flutter',
    difficulty: Difficulty.easy,
    question: 'The Flutter widget used to display text is ______.',
    answer: 'Text',
    hint: 'Text("Hello").',
    explanation: 'Text displays a string of text in Flutter.',
  ),

  Question(
    category: 'Dart & Flutter',
    difficulty: Difficulty.easy,
    question:
        'The Flutter widget used to arrange children vertically is ______.',
    answer: 'Column',
    hint: 'Vertical arrangement.',
    explanation: 'Column lays out its children vertically.',
  ),

  Question(
    category: 'Dart & Flutter',
    difficulty: Difficulty.easy,
    question:
        'The Flutter widget used to arrange children horizontally is ______.',
    answer: 'Row',
    hint: 'Horizontal arrangement.',
    explanation: 'Row lays out its children horizontally.',
  ),

  Question(
    category: 'Dart & Flutter',
    difficulty: Difficulty.medium,
    question:
        'The Dart keyword used to create a compile-time constant is ______.',
    answer: 'const',
    hint: 'Used frequently with Flutter widgets.',
    explanation: 'const creates compile-time constants.',
  ),

  Question(
    category: 'Dart & Flutter',
    difficulty: Difficulty.medium,
    question:
        'The Flutter function used to rebuild a StatefulWidget after changing state is ______.',
    answer: 'setState',
    hint: 'It tells Flutter the state changed.',
    explanation:
        'Calling setState() tells Flutter that the state has changed and the widget should rebuild.',
  ),
];

// ============================================================
// APP
// ============================================================

class FillBlankQuizApp extends StatelessWidget {
  const FillBlankQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Fill-in-the-Blanks',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF08111F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C3AED),
          brightness: Brightness.dark,
        ),
      ),
      home: const SetupPage(),
    );
  }
}

// ============================================================
// SETUP PAGE
// ============================================================

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  String selectedCategory = 'All';
  Difficulty? selectedDifficulty;

  int questionCount = 10;

  int timePerQuestion = 30;

  bool negativeMarking = true;
  bool showHints = true;

  final categories = const [
    'All',
    'Photonics',
    'Physics',
    'Mathematics',
    'Python',
    'Dart & Flutter',
  ];

  List<Question> get availableQuestions {
    return questionBank.where((q) {
      final categoryOK =
          selectedCategory == 'All' || q.category == selectedCategory;

      final difficultyOK =
          selectedDifficulty == null || q.difficulty == selectedDifficulty;

      return categoryOK && difficultyOK;
    }).toList();
  }

  void startQuiz() {
    if (availableQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No questions match your selected filters.'),
        ),
      );
      return;
    }

    final questions = List<Question>.from(availableQuestions)..shuffle();

    final count = min(questionCount, questions.length);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizPage(
          questions: questions.take(count).toList(),
          timePerQuestion: timePerQuestion,
          negativeMarking: negativeMarking,
          showHints: showHints,
        ),
      ),
    );
  }

  String difficultyName(Difficulty d) {
    switch (d) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Fill-in-the-Blanks',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // HEADER
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1717A8), Color(0xFF7C3AED)],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.quiz, size: 45),
                      SizedBox(height: 15),
                      Text(
                        'Smart Fill-in-the-Blanks',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Photonics • Physics • Mathematics • Python • Dart & Flutter',
                        style: TextStyle(color: Colors.white70, fontSize: 15),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // CATEGORY
                const Text(
                  '1. Choose Category',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: categories.map((category) {
                    final selected = selectedCategory == category;

                    return ChoiceChip(
                      label: Text(category),
                      selected: selected,
                      onSelected: (_) {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 30),

                // DIFFICULTY
                const Text(
                  '2. Difficulty',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                Wrap(
                  spacing: 10,
                  children: [
                    ChoiceChip(
                      label: const Text('All Levels'),
                      selected: selectedDifficulty == null,
                      onSelected: (_) {
                        setState(() {
                          selectedDifficulty = null;
                        });
                      },
                    ),
                    ...Difficulty.values.map((d) {
                      return ChoiceChip(
                        label: Text(difficultyName(d)),
                        selected: selectedDifficulty == d,
                        onSelected: (_) {
                          setState(() {
                            selectedDifficulty = d;
                          });
                        },
                      );
                    }),
                  ],
                ),

                const SizedBox(height: 30),

                // QUESTION COUNT
                const Text(
                  '3. Number of Questions',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                Wrap(
                  spacing: 10,
                  children: [10, 25, 50].map((count) {
                    return ChoiceChip(
                      label: Text('$count Questions'),
                      selected: questionCount == count,
                      onSelected: (_) {
                        setState(() {
                          questionCount = count;
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 30),

                // TIMER
                const Text(
                  '4. Time Per Question',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                DropdownButtonFormField<int>(
                  value: timePerQuestion,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF0B1626),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 15, child: Text('15 seconds')),
                    DropdownMenuItem(value: 30, child: Text('30 seconds')),
                    DropdownMenuItem(value: 60, child: Text('60 seconds')),
                    DropdownMenuItem(value: 120, child: Text('2 minutes')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        timePerQuestion = value;
                      });
                    }
                  },
                ),

                const SizedBox(height: 25),

                // OPTIONS
                const Text(
                  '5. Quiz Options',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Negative Marking'),
                  subtitle: const Text('Wrong answer = -0.25 marks'),
                  value: negativeMarking,
                  onChanged: (value) {
                    setState(() {
                      negativeMarking = value;
                    });
                  },
                ),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Hints'),
                  subtitle: const Text('Allow one hint per question'),
                  value: showHints,
                  onChanged: (value) {
                    setState(() {
                      showHints = value;
                    });
                  },
                ),

                const SizedBox(height: 20),

                // AVAILABLE
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B1626),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.library_books, color: Colors.cyan),
                      const SizedBox(width: 12),
                      Text(
                        '${availableQuestions.length} questions available',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // START
                SizedBox(
                  height: 58,
                  child: ElevatedButton.icon(
                    onPressed: startQuiz,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text(
                      'START QUIZ',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// QUIZ PAGE
// ============================================================

class QuizPage extends StatefulWidget {
  final List<Question> questions;
  final int timePerQuestion;
  final bool negativeMarking;
  final bool showHints;

  const QuizPage({
    super.key,
    required this.questions,
    required this.timePerQuestion,
    required this.negativeMarking,
    required this.showHints,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late List<Question> questions;

  late List<String> answers;
  late List<bool> answered;
  late List<bool> correctAnswers;
  late List<bool> hintUsed;

  int currentIndex = 0;

  late int remainingSeconds;

  Timer? timer;

  bool finished = false;

  int correct = 0;
  int wrong = 0;
  int skipped = 0;
  int hintsUsed = 0;

  double marks = 0;

  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    questions = widget.questions;

    answers = List<String>.filled(questions.length, '');

    answered = List<bool>.filled(questions.length, false);

    correctAnswers = List<bool>.filled(questions.length, false);

    hintUsed = List<bool>.filled(questions.length, false);

    remainingSeconds = widget.timePerQuestion;

    startTimer();
  }

  // ==========================================================
  // TIMER
  // ==========================================================

  void startTimer() {
    timer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || finished) return;

      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
      } else {
        submitCurrentAndMove();
      }
    });
  }

  void resetTimer() {
    remainingSeconds = widget.timePerQuestion;
    startTimer();
  }

  // ==========================================================
  // ANSWER CHECKING
  // ==========================================================

  bool checkAnswer(String user, String correctAnswer) {
    String normalize(String value) {
      return value
          .trim()
          .toLowerCase()
          .replaceAll(' ', '')
          .replaceAll('−', '-');
    }

    return normalize(user) == normalize(correctAnswer);
  }

  void saveCurrentAnswer() {
    answers[currentIndex] = controller.text.trim();
  }

  // ==========================================================
  // NEXT
  // ==========================================================

  void nextQuestion() {
    saveCurrentAnswer();

    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        controller.text = answers[currentIndex];
      });

      resetTimer();
    } else {
      finishQuiz();
    }
  }

  // ==========================================================
  // PREVIOUS
  // ==========================================================

  void previousQuestion() {
    saveCurrentAnswer();

    if (currentIndex > 0) {
      setState(() {
        currentIndex--;

        controller.text = answers[currentIndex];

        remainingSeconds = widget.timePerQuestion;
      });

      resetTimer();
    }
  }

  // ==========================================================
  // AUTO MOVE WHEN TIME ENDS
  // ==========================================================

  void submitCurrentAndMove() {
    saveCurrentAnswer();

    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;

        controller.text = answers[currentIndex];

        remainingSeconds = widget.timePerQuestion;
      });

      resetTimer();
    } else {
      finishQuiz();
    }
  }

  // ==========================================================
  // HINT
  // ==========================================================

  void showHint() {
    if (!widget.showHints) return;

    if (hintUsed[currentIndex]) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hint already used for this question.')),
      );
      return;
    }

    hintUsed[currentIndex] = true;
    hintsUsed++;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('💡 Hint'),
          content: Text(
            questions[currentIndex].hint,
            style: const TextStyle(fontSize: 18),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('CLOSE'),
            ),
          ],
        );
      },
    );

    setState(() {});
  }

  // ==========================================================
  // FINISH
  // ==========================================================

  void finishQuiz() {
    if (finished) return;

    saveCurrentAnswer();

    timer?.cancel();

    correct = 0;
    wrong = 0;
    skipped = 0;
    marks = 0;

    for (int i = 0; i < questions.length; i++) {
      final answer = answers[i].trim();

      if (answer.isEmpty) {
        skipped++;
        continue;
      }

      if (checkAnswer(answer, questions[i].answer)) {
        correctAnswers[i] = true;
        correct++;
        marks += 1;
      } else {
        correctAnswers[i] = false;
        wrong++;

        if (widget.negativeMarking) {
          marks -= 0.25;
        }
      }
    }

    if (marks < 0) {
      marks = 0;
    }

    setState(() {
      finished = true;
    });
  }

  // ==========================================================
  // CATEGORY COLOR
  // ==========================================================

  Color categoryColor(String category) {
    switch (category) {
      case 'Photonics':
        return Colors.cyan;
      case 'Physics':
        return Colors.orange;
      case 'Mathematics':
        return Colors.green;
      case 'Python':
        return Colors.yellow;
      default:
        return Colors.purpleAccent;
    }
  }

  // ==========================================================
  // DIFFICULTY
  // ==========================================================

  String difficultyName(Difficulty d) {
    switch (d) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    if (finished) {
      return buildResults();
    }

    final q = questions[currentIndex];

    final progress = (currentIndex + 1) / questions.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fill-in-the-Blanks'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: Center(
              child: Text(
                '${currentIndex + 1}/${questions.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  // PROGRESS
                  LinearProgressIndicator(value: progress, minHeight: 9),

                  const SizedBox(height: 15),

                  // TIMER
                  buildTimer(),

                  const SizedBox(height: 15),

                  // QUESTION
                  Expanded(child: buildQuestionCard(q)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // TIMER UI
  // ==========================================================

  Widget buildTimer() {
    final warning = remainingSeconds <= 10;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: warning ? Colors.red.withOpacity(.15) : const Color(0xFF0B1626),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: warning ? Colors.red : Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer, color: warning ? Colors.red : Colors.cyan),
          const SizedBox(width: 10),
          Text(
            formatTime(remainingSeconds),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: warning ? Colors.red : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }

  // ==========================================================
  // QUESTION CARD
  // ==========================================================

  Widget buildQuestionCard(Question q) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1626),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CATEGORY + DIFFICULTY
          Wrap(
            spacing: 10,
            children: [
              Chip(
                avatar: const Icon(Icons.category, size: 17),
                label: Text(q.category),
                side: BorderSide(color: categoryColor(q.category)),
              ),
              Chip(
                avatar: const Icon(Icons.bar_chart, size: 17),
                label: Text(difficultyName(q.difficulty)),
              ),
            ],
          ),

          const SizedBox(height: 25),

          Text(
            'Question ${currentIndex + 1}',
            style: const TextStyle(color: Colors.white54),
          ),

          const SizedBox(height: 15),

          Text(
            q.question,
            style: const TextStyle(
              fontSize: 24,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 30),

          TextField(
            controller: controller,
            autofocus: true,
            onChanged: (value) {
              answers[currentIndex] = value;
            },
            style: const TextStyle(fontSize: 19),
            decoration: InputDecoration(
              labelText: 'Enter your answer',
              hintText: 'Fill in the blank...',
              prefixIcon: const Icon(Icons.edit),
              filled: true,
              fillColor: const Color(0xFF111D2E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // HINT
          if (widget.showHints)
            OutlinedButton.icon(
              onPressed: hintUsed[currentIndex] ? null : showHint,
              icon: const Icon(Icons.lightbulb_outline),
              label: Text(hintUsed[currentIndex] ? 'Hint Used' : 'Show Hint'),
            ),

          const Spacer(),

          // NAVIGATION
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: currentIndex == 0 ? null : previousQuestion,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Previous'),
              ),
              const Spacer(),
              if (currentIndex < questions.length - 1)
                ElevatedButton.icon(
                  onPressed: nextQuestion,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                )
              else
                ElevatedButton.icon(
                  onPressed: finishQuiz,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Submit Quiz'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // RESULTS
  // ==========================================================

  Widget buildResults() {
    final total = questions.length;

    final percentage = (marks / total * 100).clamp(0, 100).toDouble();

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Analytics')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: ListView(
              padding: const EdgeInsets.all(22),
              children: [
                // SCORE CARD
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1717A8), Color(0xFF7C3AED)],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.emoji_events, size: 55),
                      const SizedBox(height: 15),
                      const Text(
                        'Quiz Completed!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        '${marks.toStringAsFixed(2)} / $total',
                        style: const TextStyle(
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: const TextStyle(fontSize: 22),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // ANALYTICS
                const Text(
                  'Performance Analytics',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 15),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.7,
                  children: [
                    analyticsCard(
                      'Correct',
                      '$correct',
                      Colors.green,
                      Icons.check_circle,
                    ),
                    analyticsCard('Wrong', '$wrong', Colors.red, Icons.cancel),
                    analyticsCard(
                      'Skipped',
                      '$skipped',
                      Colors.orange,
                      Icons.skip_next,
                    ),
                    analyticsCard(
                      'Hints Used',
                      '$hintsUsed',
                      Colors.cyan,
                      Icons.lightbulb,
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // NEGATIVE MARKING
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B1626),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.cyan),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.negativeMarking
                              ? 'Negative marking was enabled: -0.25 for each wrong answer.'
                              : 'Negative marking was disabled.',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // CATEGORY ANALYTICS
                const Text(
                  'Category Performance',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 15),

                ...buildCategoryAnalytics(),

                const SizedBox(height: 30),

                // QUESTION REVIEW
                const Text(
                  'Question Review',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 15),

                ...List.generate(questions.length, (index) {
                  return buildReviewCard(index);
                }),

                const SizedBox(height: 25),

                // RESTART
                SizedBox(
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('START NEW QUIZ'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // ANALYTICS CARD
  // ==========================================================

  Widget analyticsCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1626),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(.35)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: const TextStyle(color: Colors.white60)),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // CATEGORY ANALYTICS
  // ==========================================================

  List<Widget> buildCategoryAnalytics() {
    final Map<String, int> categoryTotal = {};
    final Map<String, int> categoryCorrect = {};

    for (int i = 0; i < questions.length; i++) {
      final category = questions[i].category;

      categoryTotal[category] = (categoryTotal[category] ?? 0) + 1;

      if (correctAnswers[i]) {
        categoryCorrect[category] = (categoryCorrect[category] ?? 0) + 1;
      }
    }

    return categoryTotal.entries.map((entry) {
      final total = entry.value;

      final correctCount = categoryCorrect[entry.key] ?? 0;

      final percentage = total == 0 ? 0.0 : correctCount / total;

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1626),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    entry.key,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text('$correctCount / $total'),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: percentage, minHeight: 8),
          ],
        ),
      );
    }).toList();
  }

  // ==========================================================
  // REVIEW CARD
  // ==========================================================

  Widget buildReviewCard(int index) {
    final q = questions[index];

    final correct = correctAnswers[index];

    final userAnswer = answers[index].isEmpty ? 'Not answered' : answers[index];

    return Card(
      color: const Color(0xFF0B1626),
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: correct ? Colors.green : Colors.red,
          child: Icon(correct ? Icons.check : Icons.close, color: Colors.white),
        ),
        title: Text('Q${index + 1} • ${q.category}'),
        subtitle: Text(
          correct ? 'Correct' : 'Incorrect',
          style: TextStyle(color: correct ? Colors.green : Colors.red),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  q.question,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your answer: $userAnswer',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  'Correct answer: ${q.answer}',
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  q.explanation,
                  style: const TextStyle(color: Colors.white60),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    controller.dispose();
    super.dispose();
  }
}
