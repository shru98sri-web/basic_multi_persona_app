import 'package:flutter/material.dart';

// ============================================================
// APP
// ============================================================

class OmrExamApp extends StatelessWidget {
  const OmrExamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OMR Examination',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
      ),
      home: const OmrExamPage(),
    );
  }
}

// ============================================================
// QUESTION MODEL
// ============================================================

class OmrQuestion {
  final int number;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String explanation;
  final int marks;

  const OmrQuestion({
    required this.number,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    this.marks = 1,
  });
}

// ============================================================
// EXAM DATA
// ============================================================

class OmrExamData {
  static const List<OmrQuestion> questions = [
    OmrQuestion(
      number: 1,
      question: 'What is the SI unit of force?',
      options: ['Joule', 'Newton', 'Watt', 'Pascal'],
      correctAnswer: 1,
      explanation: 'The SI unit of force is Newton (N).',
    ),
    OmrQuestion(
      number: 2,
      question:
          'Which law states that every action has an equal and opposite reaction?',
      options: [
        'Newton First Law',
        'Newton Second Law',
        'Newton Third Law',
        'Law of Gravitation',
      ],
      correctAnswer: 2,
      explanation:
          'Newton Third Law states that every action has an equal and opposite reaction.',
    ),
    OmrQuestion(
      number: 3,
      question: 'What is the formula for force?',
      options: ['F = mv', 'F = ma', 'F = m/a', 'F = a/m'],
      correctAnswer: 1,
      explanation: 'According to Newton Second Law, F = ma.',
    ),
    OmrQuestion(
      number: 4,
      question: 'Which quantity is a vector quantity?',
      options: ['Mass', 'Temperature', 'Velocity', 'Time'],
      correctAnswer: 2,
      explanation: 'Velocity has both magnitude and direction.',
    ),
    OmrQuestion(
      number: 5,
      question:
          'What is the approximate acceleration due to gravity near Earth?',
      options: ['9.8 m/s²', '5.6 m/s²', '15.2 m/s²', '20 m/s²'],
      correctAnswer: 0,
      explanation:
          'The acceleration due to gravity near Earth is approximately 9.8 m/s².',
    ),
    OmrQuestion(
      number: 6,
      question: 'Which of the following is a scalar quantity?',
      options: ['Velocity', 'Force', 'Displacement', 'Mass'],
      correctAnswer: 3,
      explanation: 'Mass has magnitude but no direction, so it is a scalar.',
    ),
    OmrQuestion(
      number: 7,
      question: 'What is the SI unit of energy?',
      options: ['Newton', 'Joule', 'Watt', 'Volt'],
      correctAnswer: 1,
      explanation: 'The SI unit of energy is Joule (J).',
    ),
    OmrQuestion(
      number: 8,
      question: 'Which instrument is used to measure electric current?',
      options: ['Voltmeter', 'Ammeter', 'Barometer', 'Thermometer'],
      correctAnswer: 1,
      explanation: 'An ammeter measures electric current.',
    ),
    OmrQuestion(
      number: 9,
      question: 'What is the approximate speed of light in vacuum?',
      options: ['3 × 10⁸ m/s', '3 × 10⁶ m/s', '3 × 10⁴ m/s', '3 × 10² m/s'],
      correctAnswer: 0,
      explanation: 'The speed of light in vacuum is approximately 3 × 10⁸ m/s.',
    ),
    OmrQuestion(
      number: 10,
      question: 'Which particle has a negative electric charge?',
      options: ['Proton', 'Neutron', 'Electron', 'Photon'],
      correctAnswer: 2,
      explanation: 'An electron has a negative electric charge.',
    ),
  ];
}

// ============================================================
// MAIN EXAM PAGE
// ============================================================

class OmrExamPage extends StatefulWidget {
  const OmrExamPage({super.key});

  @override
  State<OmrExamPage> createState() => _OmrExamPageState();
}

class _OmrExamPageState extends State<OmrExamPage> {
  int currentQuestionIndex = 0;

  final Map<int, int> selectedAnswers = {};

  final Set<int> markedForReview = {};

  bool submitted = false;

  OmrQuestion get currentQuestion {
    return OmrExamData.questions[currentQuestionIndex];
  }

  // ==========================================================
  // ANSWER
  // ==========================================================

  void selectAnswer(int optionIndex) {
    if (submitted) return;

    setState(() {
      selectedAnswers[currentQuestionIndex] = optionIndex;
    });
  }

  void clearAnswer() {
    if (submitted) return;

    setState(() {
      selectedAnswers.remove(currentQuestionIndex);
    });
  }

  // ==========================================================
  // REVIEW
  // ==========================================================

  void toggleReview() {
    if (submitted) return;

    setState(() {
      if (markedForReview.contains(currentQuestionIndex)) {
        markedForReview.remove(currentQuestionIndex);
      } else {
        markedForReview.add(currentQuestionIndex);
      }
    });
  }

  // ==========================================================
  // NAVIGATION
  // ==========================================================

  void nextQuestion() {
    if (currentQuestionIndex < OmrExamData.questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    }
  }

  void previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
    }
  }

  void goToQuestion(int index) {
    setState(() {
      currentQuestionIndex = index;
    });
  }

  // ==========================================================
  // CALCULATIONS
  // ==========================================================

  int calculateScore() {
    int score = 0;

    for (int i = 0; i < OmrExamData.questions.length; i++) {
      final selected = selectedAnswers[i];

      if (selected != null &&
          selected == OmrExamData.questions[i].correctAnswer) {
        score += OmrExamData.questions[i].marks;
      }
    }

    return score;
  }

  int calculateCorrect() {
    int count = 0;

    for (int i = 0; i < OmrExamData.questions.length; i++) {
      final selected = selectedAnswers[i];

      if (selected != null &&
          selected == OmrExamData.questions[i].correctAnswer) {
        count++;
      }
    }

    return count;
  }

  int calculateWrong() {
    int count = 0;

    for (int i = 0; i < OmrExamData.questions.length; i++) {
      final selected = selectedAnswers[i];

      if (selected != null &&
          selected != OmrExamData.questions[i].correctAnswer) {
        count++;
      }
    }

    return count;
  }

  int calculateUnanswered() {
    return OmrExamData.questions.length - selectedAnswers.length;
  }

  // ==========================================================
  // SUBMIT
  // ==========================================================

  void showSubmitDialog() {
    final answered = selectedAnswers.length;

    final total = OmrExamData.questions.length;

    final unanswered = total - answered;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Submit Examination',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dialogRow(Icons.quiz_outlined, 'Total Questions', '$total'),
              _dialogRow(Icons.check_circle_outline, 'Answered', '$answered'),
              _dialogRow(Icons.help_outline, 'Unanswered', '$unanswered'),
              _dialogRow(
                Icons.bookmark_outline,
                'Marked for Review',
                '${markedForReview.length}',
              ),
              const SizedBox(height: 15),
              const Text(
                'Are you sure you want to submit the examination?',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                setState(() {
                  submitted = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
              ),
              child: const Text('SUBMIT'),
            ),
          ],
        );
      },
    );
  }

  Widget _dialogRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF2563EB)),
          const SizedBox(width: 10),
          Expanded(child: Text(title)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ==========================================================
  // RESET
  // ==========================================================

  void restartExam() {
    setState(() {
      currentQuestionIndex = 0;
      selectedAnswers.clear();
      markedForReview.clear();
      submitted = false;
    });
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    if (submitted) {
      return buildResultScreen();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 16,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Physics Examination',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'OMR Test',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Question Palette',
            onPressed: showQuestionPalette,
            icon: const Icon(Icons.grid_view_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            buildMobileHeader(),

            Expanded(child: buildQuestionArea()),

            buildMobileBottomNavigation(),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // MOBILE HEADER
  // ==========================================================

  Widget buildMobileHeader() {
    final total = OmrExamData.questions.length;

    final answered = selectedAnswers.length;

    final progress = answered / total;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Physics',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Question ${currentQuestion.number} of $total',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              _headerStat('Answered', '$answered', const Color(0xFF2563EB)),
              const SizedBox(width: 16),
              _headerStat(
                'Review',
                '${markedForReview.length}',
                const Color(0xFFF59E0B),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF2563EB)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerStat(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  // ==========================================================
  // QUESTION AREA
  // ==========================================================

  Widget buildQuestionArea() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
      child: Column(children: [buildQuestionCard()]),
    );
  }

  Widget buildQuestionCard() {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    'Question ${currentQuestion.number}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${currentQuestion.marks} Mark',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            Text(
              currentQuestion.question,
              style: const TextStyle(
                fontSize: 19,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 22),

            ...List.generate(currentQuestion.options.length, (index) {
              return buildMobileOption(index, currentQuestion.options[index]);
            }),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: clearAnswer,
                    icon: const Icon(Icons.clear, size: 18),
                    label: const Text('Clear'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: toggleReview,
                    icon: Icon(
                      markedForReview.contains(currentQuestionIndex)
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      size: 18,
                    ),
                    label: Text(
                      markedForReview.contains(currentQuestionIndex)
                          ? 'Reviewed'
                          : 'Review',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          markedForReview.contains(currentQuestionIndex)
                          ? const Color(0xFFF59E0B)
                          : null,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // MOBILE OMR OPTION
  // ==========================================================

  Widget buildMobileOption(int optionIndex, String optionText) {
    final selected = selectedAnswers[currentQuestionIndex] == optionIndex;

    final letter = String.fromCharCode(65 + optionIndex);

    return GestureDetector(
      onTap: () {
        selectAnswer(optionIndex);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEFF6FF) : Colors.white,
          border: Border.all(
            color: selected ? const Color(0xFF2563EB) : const Color(0xFFD1D5DB),
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(13),
          boxShadow: selected
              ? [
                  const BoxShadow(
                    color: Color(0x142563EB),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? const Color(0xFF2563EB) : Colors.white,
                border: Border.all(
                  color: selected
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF9CA3AF),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  letter,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: selected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Text(
                optionText,
                style: const TextStyle(fontSize: 16, height: 1.3),
              ),
            ),

            if (selected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF2563EB),
                size: 23,
              ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // MOBILE BOTTOM NAVIGATION
  // ==========================================================

  Widget buildMobileBottomNavigation() {
    final isLast = currentQuestionIndex == OmrExamData.questions.length - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: currentQuestionIndex == 0 ? null : previousQuestion,
              icon: const Icon(Icons.arrow_back, size: 19),
              label: const Text('Previous'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: isLast
                ? ElevatedButton.icon(
                    onPressed: showSubmitDialog,
                    icon: const Icon(Icons.send, size: 18),
                    label: const Text('Submit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: nextQuestion,
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: const Text('Next'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // QUESTION PALETTE BOTTOM SHEET
  // ==========================================================

  void showQuestionPalette() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.62,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                children: [
                  Center(
                    child: Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Question Palette',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '${selectedAnswers.length}/${OmrExamData.questions.length}',
                        style: const TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: OmrExamData.questions.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemBuilder: (context, index) {
                      return buildPaletteButton(index);
                    },
                  ),

                  const SizedBox(height: 25),

                  buildLegend(const Color(0xFF2563EB), 'Answered'),
                  buildLegend(const Color(0xFFF59E0B), 'Marked for Review'),
                  buildLegend(const Color(0xFFE5E7EB), 'Not Answered'),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget buildPaletteButton(int index) {
    final answered = selectedAnswers.containsKey(index);

    final review = markedForReview.contains(index);

    final active = currentQuestionIndex == index;

    Color background;

    if (review) {
      background = const Color(0xFFF59E0B);
    } else if (answered) {
      background = const Color(0xFF2563EB);
    } else {
      background = const Color(0xFFE5E7EB);
    }

    return GestureDetector(
      onTap: () {
        goToQuestion(index);
        Navigator.pop(context);
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
          border: active ? Border.all(color: Colors.black, width: 3) : null,
        ),
        child: Center(
          child: Text(
            '${index + 1}',
            style: TextStyle(
              color: answered || review ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLegend(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 9),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  // ==========================================================
  // RESULT SCREEN
  // ==========================================================

  Widget buildResultScreen() {
    final score = calculateScore();

    final correct = calculateCorrect();

    final wrong = calculateWrong();

    final unanswered = calculateUnanswered();

    final totalMarks = OmrExamData.questions.fold<int>(
      0,
      (sum, question) => sum + question.marks,
    );

    final percentage = totalMarks == 0 ? 0.0 : score / totalMarks * 100;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Exam Result',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // SCORE CARD
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    children: [
                      Container(
                        width: 75,
                        height: 75,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7D6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.emoji_events,
                          size: 45,
                          color: Colors.amber,
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        'Examination Completed',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 18),

                      Text(
                        '$score / $totalMarks',
                        style: const TextStyle(
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                        ),
                      ),

                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // STATISTICS
              Row(
                children: [
                  Expanded(
                    child: buildResultStat(
                      'Correct',
                      '$correct',
                      Colors.green,
                      Icons.check_circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: buildResultStat(
                      'Wrong',
                      '$wrong',
                      Colors.red,
                      Icons.cancel,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: buildResultStat(
                      'Unanswered',
                      '$unanswered',
                      Colors.grey,
                      Icons.remove_circle,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OmrAnswerReviewPage(
                          answers: selectedAnswers,
                          markedForReview: markedForReview,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.rate_review),
                  label: const Text('Review All Answers'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: restartExam,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Take Examination Again'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildResultStat(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 7),
            Text(
              value,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ANSWER REVIEW PAGE
// ============================================================

class OmrAnswerReviewPage extends StatelessWidget {
  final Map<int, int> answers;

  final Set<int> markedForReview;

  const OmrAnswerReviewPage({
    super.key,
    required this.answers,
    required this.markedForReview,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Answer Review',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: OmrExamData.questions.length,
        itemBuilder: (context, index) {
          final question = OmrExamData.questions[index];

          final selected = answers[index];

          final isAnswered = selected != null;

          final isCorrect = isAnswered && selected == question.correctAnswer;

          final isMarked = markedForReview.contains(index);

          return buildReviewCard(
            question,
            selected,
            isCorrect,
            isAnswered,
            isMarked,
          );
        },
      ),
    );
  }

  Widget buildReviewCard(
    OmrQuestion question,
    int? selectedAnswer,
    bool isCorrect,
    bool isAnswered,
    bool marked,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 19,
                  backgroundColor: !isAnswered
                      ? Colors.grey
                      : isCorrect
                      ? Colors.green
                      : Colors.red,
                  child: Text(
                    '${question.number}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 11),

                Expanded(
                  child: Text(
                    question.question,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                if (marked)
                  const Padding(
                    padding: EdgeInsets.only(left: 5),
                    child: Icon(Icons.bookmark, color: Colors.orange),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            ...List.generate(question.options.length, (optionIndex) {
              return buildReviewOption(question, optionIndex, selectedAnswer);
            }),

            const SizedBox(height: 8),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: !isAnswered
                    ? const Color(0xFFF3F4F6)
                    : isCorrect
                    ? const Color(0xFFF0FDF4)
                    : const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                !isAnswered
                    ? 'Not Answered'
                    : isCorrect
                    ? 'Correct Answer'
                    : 'Wrong Answer',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: !isAnswered
                      ? Colors.grey
                      : isCorrect
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Explanation',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    question.explanation,
                    style: const TextStyle(height: 1.35),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildReviewOption(
    OmrQuestion question,
    int optionIndex,
    int? selectedAnswer,
  ) {
    final isCorrect = optionIndex == question.correctAnswer;

    final isSelected = optionIndex == selectedAnswer;

    Color background = Colors.white;

    Color border = Colors.grey.shade300;

    if (isCorrect) {
      background = const Color(0xFFEFFAF1);
      border = Colors.green;
    } else if (isSelected && !isCorrect) {
      background = const Color(0xFFFFF1F2);
      border = Colors.red;
    }

    final letter = String.fromCharCode(65 + optionIndex);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: border),
            ),
            child: Center(
              child: Text(
                letter,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Text(
              question.options[optionIndex],
              style: const TextStyle(fontSize: 14),
            ),
          ),

          if (isCorrect)
            const Icon(Icons.check_circle, color: Colors.green, size: 21)
          else if (isSelected)
            const Icon(Icons.cancel, color: Colors.red, size: 21),
        ],
      ),
    );
  }
}
