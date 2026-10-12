import 'package:aiml_app_navis/ai_chat/ai_chat_pkg.dart';
import 'package:aiml_app_navis/calender/calender.dart';
import 'package:aiml_app_navis/dashboard/dashboard.dart';
import 'package:aiml_app_navis/fill_in_the_blanks/fill_ups.dart';
import 'package:aiml_app_navis/foundation_mcq_quiz/foundation_mcq_quiz.dart';
import 'package:aiml_app_navis/omr_mcq/questions_mcq.dart';
import 'package:aiml_app_navis/progress_tracker_marks_tracker/progress_tracker.dart';
import 'package:aiml_app_navis/tampura_sruti/tanpura.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart' show GetIt;
import 'package:shared_preferences/shared_preferences.dart';

import '6_programs_compiler/6_programs_compiler.dart';
import 'group_discussion/gd_forum.dart';

class TuitionAiMlApp extends StatelessWidget {
  const TuitionAiMlApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tuition AI ML Super-App',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF0F0E17),
        colorScheme: const ColorScheme.dark(
          primary: Colors.deepPurpleAccent,
          secondary: Colors.cyanAccent,
        ),
      ),
      home: const MainNavigationShell(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({Key? key}) : super(key: key);

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentBottomIndex = 0;
  String _currentPageKey = 'dashboard';

  // Navigation categorization for the massive Menu Bar (Drawer)
  final Map<String, List<Map<String, dynamic>>> _menuCategories = {
    'Core Channels': [
      {'key': 'dashboard', 'title': 'Dashboard Hub', 'icon': Icons.dashboard},
      {'key': 'chatbot', 'title': 'AI Study Companion', 'icon': Icons.chat},
      {
        'key': 'progress',
        'title': 'Global Progress Tracker',
        'icon': Icons.analytics,
      },
      {
        'key': 'calender',
        'title': 'Academic Calendar',
        'icon': Icons.calendar_month,
      },
    ],
    'AI & Interview Prep Engine': [
      {
        'key': 'resume_ai',
        'title': 'AI Resume Smart-Upload',
        'icon': Icons.cloud_upload,
      },
      {
        'key': 'real_time_interview',
        'title': 'AI Real-Time Mock Interview',
        'icon': Icons.videocam,
      },
      {
        'key': 'hr_round',
        'title': 'AI HR Simulation Round',
        'icon': Icons.people_alt,
      },
      {
        'key': 'ai_visa_interview',
        'title': 'AI Visa Clearance Protocol',
        'icon': Icons.flight_takeoff,
      },
      {
        'key': 'precheck_interview',
        'title': 'Pre-Check Gatekeeper Assessment',
        'icon': Icons.verified_user,
      },
      {
        'key': 'group_discussion',
        'title': 'AI Group Discussion Arena',
        'icon': Icons.forum,
      },
    ],
    'Testing, Assessments & Practice': [
      {'key': 'coding', 'title': 'Cloud Compiler IDE', 'icon': Icons.code},
      {'key': 'mcq', 'title': 'Adaptive MCQ Simulator', 'icon': Icons.quiz},
      {
        'key': 'aptitude',
        'title': 'Quantitative Aptitude Matrix',
        'icon': Icons.functions,
      },
      {
        'key': 'foundation_mcq',
        'title': 'Foundation MCQ Generative Engine',
        'icon': Icons.auto_awesome,
      },
      {
        'key': 'fill_in_blanks',
        'title': 'Contextual Fill-in-the-Blanks',
        'icon': Icons.text_fields,
      },
      {
        'key': 'omr_test',
        'title': 'OMR Sheet Digital Scanner',
        'icon': Icons.camera_alt,
      },
      {
        'key': 'ocr_evaluation',
        'title': 'OCR Automated Handwritten Grading',
        'icon': Icons.document_scanner,
      },
    ],
    'Utility & Builders': [
      {
        'key': 'cover_letter',
        'title': 'AI Cover Letter Generator',
        'icon': Icons.description,
      },
      {
        'key': 'portfolio',
        'title': 'Dynamic Portfolio Generator',
        'icon': Icons.web,
      },
      {
        'key': 'documents',
        'title': 'Encrypted Credentials Vault',
        'icon': Icons.folder_special,
      },
      {
        'key': 'marks_tracker',
        'title': 'Granular Marks Gradebook',
        'icon': Icons.score,
      },
      {
        'key': 'answer_key',
        'title': 'Verified Explanatory Answer Keys',
        'icon': Icons.fact_check,
      },
      {
        'key': 'unlock_coins',
        'title': 'Gamified Token Loyalty Portal',
        'icon': Icons.monetization_on,
      },
    ],
    'E-Learning & Digital Library': [
      {
        'key': 'book_pdf',
        'title': 'E-Book PDF Interactive Reader',
        'icon': Icons.menu_book,
      },
      {
        'key': 'questions_from_book',
        'title': 'AI Book-Context Question Extractor',
        'icon': Icons.find_in_page,
      },
      {
        'key': 'video_classes',
        'title': 'VOD High-Definition Streaming Grid',
        'icon': Icons.smart_display,
      },
      {
        'key': 'class_recording',
        'title': 'Archived Lecture Playback Stream',
        'icon': Icons.video_library,
      },
      {
        'key': 'virtual_lab',
        'title': 'Interactive 3D Physics/Chemistry Lab',
        'icon': Icons.science,
      },
      {
        'key': 'typewriting',
        'title': 'Typing Speed KPM Engine',
        'icon': Icons.keyboard,
      },
      {
        'key': 'tanpura_droid',
        'title': 'Tanpura Droid Acoustic Engine',
        'icon': Icons.music_note,
      },
    ],
    'Support & Communications': [
      {
        'key': 'doubt_panel',
        'title': 'Peer-to-Peer Resolution Board',
        'icon': Icons.live_help,
      },
      {
        'key': 'doubt_chatbot',
        'title': '24/7 NLP Doubt-Buster Chatbot',
        'icon': Icons.support_agent,
      },
    ],
    'Management & Control Centers': [
      {
        'key': 'teacher_dashboard',
        'title': 'Educator Command Deck',
        'icon': Icons.assignment_ind,
      },
      {
        'key': 'student_monitor',
        'title': 'Real-Time Proctor & Attendance Monitor',
        'icon': Icons.visibility,
      },
      {
        'key': 'scheduling_events',
        'title': 'Live Class Institutional Scheduler',
        'icon': Icons.schedule,
      },
      {
        'key': 'center_teacher',
        'title': 'Geospatial Center-Teacher Evaluator',
        'icon': Icons.map,
      },
      {
        'key': 'exam_analytics',
        'title': 'Statistical Exam Multi-Graph Analytics',
        'icon': Icons.bar_chart,
      },
      {
        'key': 'usage_analytics',
        'title': 'Infrastructure Resource Usage Analytics',
        'icon': Icons.pie_chart,
      },
      {
        'key': 'parent_pane',
        'title': 'Parent Supervision Gateway',
        'icon': Icons.family_restroom,
      },
      {
        'key': 'admin_panel',
        'title': 'Global Enterprise Administration',
        'icon': Icons.admin_panel_settings,
      },
      {
        'key': 'superadmin_panel',
        'title': 'Root Configuration System Kernel',
        'icon': Icons.gavel,
      },
    ],
  };

  // Quick navigation mapping for the bottom navbar items
  final List<String> _bottomBarKeys = [
    'dashboard',
    'chatbot',
    'coding',
    'progress',
    'calender',
  ];

  Widget _renderActivePage() {
    switch (_currentPageKey) {
      case 'dashboard':
        return const StudentDashboardApp();
      case 'chatbot':
        return const LocalAIChatbotApp();
      case 'progress':
        return const ProgressApp();
      case 'calender':
        return Calender();
      case 'resume_ai':
        return const ResumeAiPage();
      case 'real_time_interview':
        return const RealTimeInterviewPage();
      case 'hr_round':
        return const HrRoundPage();
      case 'ai_visa_interview':
        return const AiVisaInterviewPage();
      case 'precheck_interview':
        return const PrecheckInterviewPage();
      case 'group_discussion':
        return const GDArenaApp();
      case 'coding':
        return const MultiCompilerApp();
      case 'mcq':
        return const MCQPage();
      case 'aptitude':
        return const AptitudePage();
      case 'foundation_mcq':
        return const QuizApp();
      case 'fill_in_blanks':
        return const FillBlankQuizApp();
      case 'omr_test':
        return const OmrExamApp();
      case 'ocr_evaluation':
        return const OcrEvaluationPage();
      case 'cover_letter':
        return const CoverLetterPage();
      case 'portfolio':
        return const PortfolioPage();
      case 'documents':
        return const DocumentsPage();
      case 'marks_tracker':
        return const MarksTrackerPage();
      case 'answer_key':
        return const AnswerKeyPage();
      case 'unlock_coins':
        return const UnlockCoinsPage();
      case 'book_pdf':
        return const BookPdfPage();
      case 'questions_from_book':
        return const QuestionsFromBookPage();
      case 'video_classes':
        return const VideoClassesPage();
      case 'class_recording':
        return const ClassRecordingPage();
      case 'virtual_lab':
        return const VirtualLabPage();
      case 'typewriting':
        return const TypewritingPage();
      case 'tanpura_droid':
        {
          final globalPrefs = GetIt.I<SharedPreferences>();

          return TanpuraDroidApp(prefs: globalPrefs);
        }

      case 'doubt_panel':
        return const DoubtPanelPage();
      case 'doubt_chatbot':
        return const DoubtChatbotPage();
      case 'teacher_dashboard':
        return const TeacherDashboardPage();
      case 'student_monitor':
        return const StudentMonitorPage();
      case 'scheduling_events':
        return const SchedulingEventsPage();
      case 'center_teacher':
        return const CenterTeacherPage();
      case 'exam_analytics':
        return const ExamAnalyticsPage();
      case 'usage_analytics':
        return const UsageAnalyticsPage();
      case 'parent_pane':
        return const ParentPanePage();
      case 'admin_panel':
        return const AdminPanelPage();
      case 'superadmin_panel':
        return const SuperadminPanelPage();
      default:
        return const DashboardPage();
    }
  }

  void _navigateToKey(String key) {
    setState(() {
      _currentPageKey = key;
      if (_bottomBarKeys.contains(key)) {
        _currentBottomIndex = _bottomBarKeys.indexOf(key);
      } else {
        _currentBottomIndex =
            0; // Fallback highlight on dashboard when deep navigation occurs
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentPageKey.replaceAll('_', ' ').toUpperCase(),
          style: const TextStyle(
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.stars, color: Colors.amber),
            onPressed: () => _navigateToKey('unlock_coins'),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => _navigateToKey('parent_pane'),
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: const Color(0xFF161424),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple, Colors.indigo],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'TUITION AI ML',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Omni-Channel Adaptive Learning Platform',
                      style: TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              ..._menuCategories.entries.map((category) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        top: 16,
                        bottom: 8,
                      ),
                      child: Text(
                        category.key.toUpperCase(),
                        style: TextStyle(
                          color: Colors.cyanAccent.withOpacity(0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    ...category.value.map((item) {
                      final bool isSelected = _currentPageKey == item['key'];
                      return ListTile(
                        dense: true,
                        leading: Icon(
                          item['icon'],
                          color: isSelected
                              ? Colors.cyanAccent
                              : Colors.white60,
                        ),
                        title: Text(
                          item['title'],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        selectedTileColor: Colors.deepPurple.withOpacity(0.3),
                        onTap: () {
                          Navigator.pop(context);
                          _navigateToKey(item['key']);
                        },
                      );
                    }).toList(),
                    const Divider(color: Colors.white10),
                  ],
                );
              }).toList(),
            ],
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _renderActivePage(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentBottomIndex,
        onTap: (index) {
          setState(() {
            _currentBottomIndex = index;
            _currentPageKey = _bottomBarKeys[index];
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF161424),
        selectedItemColor: Colors.cyanAccent,
        unselectedItemColor: Colors.white38,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'AI Chat'),
          BottomNavigationBarItem(
            icon: Icon(Icons.code),
            label: 'IDE Compiler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Metrics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
        ],
      ),
    );
  }
} // Global reusable modular card design pattern for pages

class ModuleCard extends StatelessWidget {
  final String title;
  final Widget child;
  const ModuleCard({Key? key, required this.title, required this.child})
    : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.cyanAccent,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// ==========================================
// 1. DASHBOARD PAGE
// ==========================================
class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const ModuleCard(
          title: "AI Adaptive Skill Matrix Status",
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.bolt, color: Colors.amber),
                title: Text("Current ML Skill Index: 84.6%"),
                subtitle: Text("Top Performance: Python & NLP Pipelines"),
              ),
            ],
          ),
        ),
        ModuleCard(
          title: "Quick Action Gateways",
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.5,
            children: [
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.model_training),
                label: const Text("Launch AI Mock"),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.bug_report),
                label: const Text("Debug Code Workspace"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==========================================
// 2. CHATBOT PAGE
// ==========================================
class ChatbotPage extends StatelessWidget {
  const ChatbotPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "[AI Model]: Welcome back! Paste your mathematical equations or code lines here for contextual verification.",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Query LLM Agent...",
              suffixIcon: const Icon(Icons.send),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// 3. PROGRESS PAGE
// ==========================================
class ProgressPage extends StatelessWidget {
  const ProgressPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: const [
          ModuleCard(
            title: "Velocity & Retention Vectors",
            child: Text(
              "Linear progression tracking shows a 14% retention delta increase through continuous reinforcement loops.",
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 4. CALENDAR PAGE
// ==========================================
class CalendarPage extends StatelessWidget {
  const CalendarPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: const [
          ModuleCard(
            title: "Chronological Class Maps",
            child: Text(
              "Next live sync: Deep Learning Architecture optimization session at 14:00 UTC.",
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 5. RESUME AI UPLOAD PAGE
// ==========================================
class ResumeAiPage extends StatelessWidget {
  const ResumeAiPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_done,
              size: 64,
              color: Colors.deepPurpleAccent,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text("Select PDF Resume for ATS Evaluation Matrix"),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 6. REAL TIME INTERVIEW PAGE
// ==========================================
class RealTimeInterviewPage extends StatelessWidget {
  const RealTimeInterviewPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 200,
            color: Colors.black54,
            child: const Center(
              child: Text(
                "Camera Feed Simulation [Active Target Verification State]",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ),
          const Expanded(
            child: ModuleCard(
              title: "AI Audio Prompter Queue",
              child: Text(
                "Question 1: Explain the structural architectural delta between transformer mechanisms and recurrent networks.",
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 7. HR ROUND PAGE
// ==========================================
class HrRoundPage extends StatelessWidget {
  const HrRoundPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Behavioral & Soft Skill Evaluation Environment Ready."),
      ),
    );
  }
}

// ==========================================
// 8. AI VISA INTERVIEW PAGE
// ==========================================
class AiVisaInterviewPage extends StatelessWidget {
  const AiVisaInterviewPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Consular Compliance Verification & Document Authentication Engine",
        ),
      ),
    );
  }
}

// ==========================================
// 9. PRECHECK INTERVIEW PAGE
// ==========================================
class PrecheckInterviewPage extends StatelessWidget {
  const PrecheckInterviewPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Initial Pre-Screening Clearance Pipeline Modules"),
      ),
    );
  }
}

// ==========================================
// 10. GROUP DISCUSSION PAGE
// ==========================================
class GroupDiscussionPage extends StatelessWidget {
  const GroupDiscussionPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Multi-Agent NLP Group Discussion Simulation Lobby"),
      ),
    );
  }
}

// ==========================================
// 11. CODING PAGE
// ==========================================
class CodingPage extends StatelessWidget {
  const CodingPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              color: const Color(0xFF09080F),
              child: const TextField(
                maxLines: null,
                style: TextStyle(
                  fontFamily: 'Courier',
                  color: Colors.greenAccent,
                ),
                decoration: InputDecoration.collapsed(
                  hintText:
                      "def train_model(data):\n    # Inject hyperparameter architecture matrix code...",
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text("Compile & Run Tests Across Remote Workers"),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 12. MCQ PAGE
// ==========================================
class MCQPage extends StatelessWidget {
  const MCQPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          const ModuleCard(
            title: "Problem Statement",
            child: Text(
              "Which optimization strategy prevents catastrophic gradient explosion anomalies?",
            ),
          ),
          RadioListTile(
            value: 1,
            groupValue: 0,
            onChanged: (v) {},
            title: const Text("Gradient Clipping Protocol"),
          ),
          RadioListTile(
            value: 2,
            groupValue: 0,
            onChanged: (v) {},
            title: const Text("Stochastic Dropout Injection"),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 13. APTITUDE PAGE
// ==========================================
class AptitudePage extends StatelessWidget {
  const AptitudePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Quantitative Logic Matrix Engine & Vector Calculus Modules",
        ),
      ),
    );
  }
}

// ==========================================
// 14. FOUNDATION MCQ PAGE
// ==========================================
class FoundationMcqPage extends StatelessWidget {
  const FoundationMcqPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Generative Model: Building custom fundamental baseline testing structures...",
        ),
      ),
    );
  }
}

// ==========================================
// 15. FILL IN BLANKS PAGE
// ==========================================
class FillInBlanksPage extends StatelessWidget {
  const FillInBlanksPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Natural Language Processing Cloze Deletion Evaluation Environment.",
        ),
      ),
    );
  }
}

// ==========================================
// 16. OMR TEST PAGE
// ==========================================
class OmrTestPage extends StatelessWidget {
  const OmrTestPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("Computer Vision OMR Matrix Scanner Interface")),
    );
  }
}

// ==========================================
// 17. OCR EVALUATION PAGE
// ==========================================
class OcrEvaluationPage extends StatelessWidget {
  const OcrEvaluationPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Handwritten Script Recognition & Automated Scoring Infrastructure",
        ),
      ),
    );
  }
}

// ==========================================// 18. COVER LETTER PAGE// ==========================================
class CoverLetterPage extends StatelessWidget {
  const CoverLetterPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Context-Aware AI Narrative Application Generator Engine"),
      ),
    );
  }
}
// ==========================================// 19. PORTFOLIO PAGE// ==========================================

class PortfolioPage extends StatelessWidget {
  const PortfolioPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Automated Repository Exporter & Static Website Engine"),
      ),
    );
  }
}
// ==========================================// 20. DOCUMENTS PAGE// ==========================================

class DocumentsPage extends StatelessWidget {
  const DocumentsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Cryptographically Secured Academic Credential Repository"),
      ),
    );
  }
}
// ==========================================// 21. MARKS TRACKER PAGE// ==========================================

class MarksTrackerPage extends StatelessWidget {
  const MarksTrackerPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Historical Academic Grade Distribution Matrices"),
      ),
    );
  }
}
// ==========================================// 22. ANSWER KEY PAGE// ==========================================

class AnswerKeyPage extends StatelessWidget {
  const AnswerKeyPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("System Step-by-Step Rationale & Verification Solutions"),
      ),
    );
  }
}
// ==========================================// 23. UNLOCK COINS PAGE// ==========================================

class UnlockCoinsPage extends StatelessWidget {
  const UnlockCoinsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Gamification Engine Loyalty Vault: Claim Resource Tokens"),
      ),
    );
  }
}

// ==========================================// 24. BOOK PDF PAGE// ==========================================
class BookPdfPage extends StatelessWidget {
  const BookPdfPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("PDF Core Reader Subsystem Engine Active")),
    );
  }
}
// ==========================================// 25. QUESTIONS FROM BOOK PAGE// ==========================================

class QuestionsFromBookPage extends StatelessWidget {
  const QuestionsFromBookPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Retrieval-Augmented Generation (RAG) Document Query Engine",
        ),
      ),
    );
  }
}
// ==========================================// 26. VIDEO CLASSES PAGE// ==========================================

class VideoClassesPage extends StatelessWidget {
  const VideoClassesPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("HD Multi-Bitrate HLS Video Delivery Grid Network"),
      ),
    );
  }
}
// ==========================================// 27. CLASS RECORDING PAGE// ==========================================

class ClassRecordingPage extends StatelessWidget {
  const ClassRecordingPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Cold Storage Cloud Video Lecture Storage Vault"),
      ),
    );
  }
}
// ==========================================// 28. VIRTUAL LAB PAGE// ==========================================

class VirtualLabPage extends StatelessWidget {
  const VirtualLabPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Vector Animation Laboratory Physics Workbench Canvas"),
      ),
    );
  }
}
// ==========================================// 29. TYPEWRITING PAGE// ==========================================

class TypewritingPage extends StatelessWidget {
  const TypewritingPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Typing Performance telemetry tracking active (WPM/Accuracy metrics).",
        ),
      ),
    );
  }
}
// ==========================================// 30. TANPURA DROID PAGE// ==========================================

class TanpuraDroidPage extends StatelessWidget {
  const TanpuraDroidPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Algorithmic Fine Acoustic Tanpura Synthesis System Engine Running",
        ),
      ),
    );
  }
}
// ==========================================// 31. DOUBT PANEL PAGE// ==========================================

class DoubtPanelPage extends StatelessWidget {
  const DoubtPanelPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("Global Shared Resolution Forum Hub Pipeline")),
    );
  }
}
// ==========================================// 32. DOUBT CHATBOT PAGE// ==========================================

class DoubtChatbotPage extends StatelessWidget {
  const DoubtChatbotPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "High-Availability Real-Time Dedicated Math/Code Transformer Chatbot Agent",
        ),
      ),
    );
  }
}
// ==========================================// 33. TEACHER DASHBOARD PAGE// ==========================================

class TeacherDashboardPage extends StatelessWidget {
  const TeacherDashboardPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Educator Core Assignment Engine & Grading Pipelines"),
      ),
    );
  }
}
// ==========================================// 34. STUDENT MONITOR PAGE// ==========================================

class StudentMonitorPage extends StatelessWidget {
  const StudentMonitorPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Real-Time Automated Proctor Verification Protocol Panel Mode",
        ),
      ),
    );
  }
}
// ==========================================// 35. SCHEDULING EVENTS PAGE// ==========================================

class SchedulingEventsPage extends StatelessWidget {
  const SchedulingEventsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Live Sync Multi-Tenant Calendar Management Platform Configuration",
        ),
      ),
    );
  }
}
// ==========================================// 36. CENTER TEACHER PAGE// ==========================================

class CenterTeacherPage extends StatelessWidget {
  const CenterTeacherPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Geospatial Resource Distribution & Institutional Location Matrix Mapping",
        ),
      ),
    );
  }
}
// ==========================================// 37. EXAM ANALYTICS PAGE// ==========================================

class ExamAnalyticsPage extends StatelessWidget {
  const ExamAnalyticsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Advanced Performance Metric Distributions & Graph Engines",
        ),
      ),
    );
  }
}
// ==========================================// 38. USAGE ANALYTICS PAGE// ==========================================

class UsageAnalyticsPage extends StatelessWidget {
  const UsageAnalyticsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Infrastructure Computing Resource & Storage Telemetry Metrics",
        ),
      ),
    );
  }
}
// ==========================================// 39. PARENT PANE PAGE// ==========================================

class ParentPanePage extends StatelessWidget {
  const ParentPanePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Parent Supervisory Tracking, Progress Auditing & Gateway Permissions",
        ),
      ),
    );
  }
}
// ==========================================// 40. ADMIN PANEL PAGE// ==========================================

class AdminPanelPage extends StatelessWidget {
  const AdminPanelPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "System Settings Control Base, DB Query Routers & User Authorizations",
        ),
      ),
    );
  }
}
// ==========================================// 41. SUPERADMIN PANEL PAGE// ==========================================

class SuperadminPanelPage extends StatelessWidget {
  const SuperadminPanelPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Kernel Level Control, Tenant Allocations & System API Firewalls Instance",
        ),
      ),
    );
  }
}
// ==========================================// 42. FALLBACK/UNKNOWN ROUTE ROUTER STATE// ==========================================

class UnknownFallbackPage extends StatelessWidget {
  const UnknownFallbackPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Error 404: The specified AI module structure could not be resolved safely.",
        ),
      ),
    );
  }
}
