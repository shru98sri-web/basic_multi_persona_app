import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// void main() {
//   runApp(const MultiCompilerApp());
// }

class CompilerLanguage {
  final String name;
  final String icon;
  final int judge0Id;
  final String starterCode;

  const CompilerLanguage({
    required this.name,
    required this.icon,
    required this.judge0Id,
    required this.starterCode,
  });
}

const languages = <CompilerLanguage>[
  CompilerLanguage(
    name: 'Rust',
    icon: '🦀',
    judge0Id: 73,
    starterCode: '''fn main() {
    println!("Hello from Rust!");
}''',
  ),
  CompilerLanguage(
    name: 'Go',
    icon: '🐹',
    judge0Id: 60,
    starterCode: '''package main

import "fmt"

func main() {
    fmt.Println("Hello from Go!")
}''',
  ),
  CompilerLanguage(
    name: 'PHP',
    icon: '🐘',
    judge0Id: 68,
    starterCode: '''<?php
\$name = "World";

echo "Hello, \$name!";

?>''',
  ),
  CompilerLanguage(
    name: 'Swift',
    icon: '🍎',
    judge0Id: 83,
    starterCode: '''import Foundation

print("Hello from Swift!")''',
  ),
  CompilerLanguage(
    name: 'Scala',
    icon: '🔷',
    judge0Id: 81,
    starterCode: '''object Main extends App {
    println("Hello from Scala!")
}''',
  ),
  CompilerLanguage(
    name: 'Ruby',
    icon: '💎',
    judge0Id: 72,
    starterCode: '''name = "World"

puts "Hello, #{name}!"''',
  ),
];

class MultiCompilerApp extends StatelessWidget {
  const MultiCompilerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Online Compiler',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF08111F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C3AED),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const CompilerPage(),
    );
  }
}

class CompilerPage extends StatefulWidget {
  const CompilerPage({super.key});

  @override
  State<CompilerPage> createState() => _CompilerPageState();
}

class _CompilerPageState extends State<CompilerPage> {
  static const String judge0Url = 'https://ce.judge0.com/submissions';

  int selectedIndex = 0;

  late TextEditingController codeController;
  final TextEditingController inputController = TextEditingController();

  String output = '';
  String error = '';

  bool running = false;

  int? executionTime;

  @override
  void initState() {
    super.initState();

    codeController = TextEditingController(text: languages[0].starterCode);
  }

  CompilerLanguage get selectedLanguage => languages[selectedIndex];

  @override
  void dispose() {
    codeController.dispose();
    inputController.dispose();
    super.dispose();
  }

  void changeLanguage(int index) {
    setState(() {
      selectedIndex = index;

      codeController.text = languages[index].starterCode;

      output = '';
      error = '';
      executionTime = null;
    });
  }

  Future<void> runCode() async {
    if (codeController.text.trim().isEmpty) {
      setState(() {
        error = 'Please enter some code.';
        output = '';
      });
      return;
    }

    setState(() {
      running = true;
      output = '';
      error = '';
      executionTime = null;
    });

    final stopwatch = Stopwatch()..start();

    try {
      /*
       * SUBMIT CODE
       */

      final submitResponse = await http
          .post(
            Uri.parse('$judge0Url?base64_encoded=false&wait=false'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'language_id': selectedLanguage.judge0Id,
              'source_code': codeController.text,
              'stdin': inputController.text,
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (submitResponse.statusCode != 201) {
        throw Exception(
          'Submission failed.\n'
          'HTTP ${submitResponse.statusCode}\n'
          '${submitResponse.body}',
        );
      }

      final submission = jsonDecode(submitResponse.body);

      final token = submission['token'];

      if (token == null) {
        throw Exception('No submission token received.');
      }

      /*
       * WAIT FOR RESULT
       */

      Map<String, dynamic>? result;

      for (int i = 0; i < 30; i++) {
        await Future.delayed(const Duration(milliseconds: 800));

        final response = await http
            .get(Uri.parse('$judge0Url/$token?base64_encoded=false'))
            .timeout(const Duration(seconds: 10));

        if (response.statusCode != 200) {
          throw Exception(
            'Unable to retrieve result.\n'
            'HTTP ${response.statusCode}',
          );
        }

        final data = jsonDecode(response.body) as Map<String, dynamic>;

        final status = data['status'];

        if (status != null) {
          final id = status['id'];

          /*
           * 1 = In Queue
           * 2 = Processing
           * 3+ = Finished
           */

          if (id != 1 && id != 2) {
            result = data;
            break;
          }
        }
      }

      stopwatch.stop();

      if (result == null) {
        throw Exception('Execution timed out.');
      }

      final stdout = result['stdout'] ?? '';

      final stderr = result['stderr'] ?? '';

      final compileOutput = result['compile_output'] ?? '';

      final message = result['message'] ?? '';

      final status = result['status'];

      final statusDescription = status != null
          ? status['description'] ?? ''
          : '';

      final errors = <String>[];

      if (compileOutput.toString().isNotEmpty) {
        errors.add(compileOutput.toString());
      }

      if (stderr.toString().isNotEmpty) {
        errors.add(stderr.toString());
      }

      if (message.toString().isNotEmpty) {
        errors.add(message.toString());
      }

      if (errors.isEmpty &&
          statusDescription.toString().isNotEmpty &&
          statusDescription != 'Accepted') {
        errors.add(statusDescription.toString());
      }

      if (!mounted) return;

      setState(() {
        executionTime = stopwatch.elapsedMilliseconds;

        output = stdout.toString();

        error = errors.join('\n');
      });
    } on TimeoutException {
      if (!mounted) return;

      setState(() {
        error = 'Request timed out.';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString();
      });
    } finally {
      stopwatch.stop();

      if (!mounted) return;

      setState(() {
        running = false;
      });
    }
  }

  void clearEditor() {
    setState(() {
      codeController.clear();
      inputController.clear();
      output = '';
      error = '';
      executionTime = null;
    });
  }

  void loadExample() {
    final language = selectedLanguage.name;

    if (language == 'Rust') {
      codeController.text = '''fn main() {
    let a = 10;
    let b = 20;

    println!("Sum = {}", a + b);
}''';
    }

    if (language == 'Go') {
      codeController.text = '''package main

import "fmt"

func main() {
    a := 10
    b := 20

    fmt.Println("Sum =", a+b)
}''';
    }

    if (language == 'PHP') {
      codeController.text = '''<?php

\$a = 10;
\$b = 20;

echo "Sum = " . (\$a + \$b);

?>''';
    }

    if (language == 'Swift') {
      codeController.text = '''import Foundation

let a = 10
let b = 20

print("Sum = \\(a + b)")''';
    }

    if (language == 'Scala') {
      codeController.text = '''object Main extends App {

    val a = 10
    val b = 20

    println("Sum = " + (a + b))
}''';
    }

    if (language == 'Ruby') {
      codeController.text = '''a = 10
b = 20

puts "Sum = #{a + b}"''';
    }

    setState(() {
      output = '';
      error = '';
    });
  }

  Widget languageSelector() {
    return Container(
      width: 230,
      color: const Color(0xFF0B1626),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'ONLINE COMPILER',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: languages.length,
              itemBuilder: (context, index) {
                final language = languages[index];

                final selected = selectedIndex == index;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => changeLanguage(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF7C3AED)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            language.icon,
                            style: const TextStyle(fontSize: 22),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            language.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget editor() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0B1626),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  selectedLanguage.icon,
                  style: const TextStyle(fontSize: 22),
                ),
                const SizedBox(width: 10),
                Text(
                  '${selectedLanguage.name} Code',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Example',
                  onPressed: loadExample,
                  icon: const Icon(Icons.lightbulb_outline),
                ),
                IconButton(
                  tooltip: 'Clear',
                  onPressed: clearEditor,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ),
          Expanded(
            child: TextField(
              controller: codeController,
              expands: true,
              maxLines: null,
              minLines: null,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                height: 1.5,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
                hintText: 'Write your code here...',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget inputBox() {
    return Container(
      height: 145,
      decoration: BoxDecoration(
        color: const Color(0xFF0B1626),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Container(
            height: 45,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Row(
              children: [
                Icon(Icons.input, color: Color(0xFF22D3EE)),
                SizedBox(width: 8),
                Text(
                  'Standard Input',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Expanded(
            child: TextField(
              controller: inputController,
              maxLines: null,
              expands: true,
              style: const TextStyle(fontFamily: 'monospace'),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(14),
                hintText: 'Program input...',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget outputBox() {
    final hasError = error.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0B1626),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  hasError ? Icons.error_outline : Icons.terminal,
                  color: hasError ? Colors.redAccent : const Color(0xFF22D3EE),
                ),
                const SizedBox(width: 10),
                Text(
                  hasError ? 'Error' : 'Output',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (executionTime != null)
                  Text(
                    '${executionTime} ms',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                hasError
                    ? error
                    : output.isEmpty
                    ? 'Output will appear here...'
                    : output,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  height: 1.5,
                  color: hasError
                      ? Colors.redAccent
                      : output.isEmpty
                      ? Colors.white38
                      : Colors.greenAccent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget runButton() {
    return FilledButton.icon(
      onPressed: running ? null : runCode,
      icon: running
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.play_arrow),
      label: Text(running ? 'Running...' : 'Run Code'),
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF7C3AED),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            languageSelector(),
            Expanded(
              child: Column(
                children: [
                  Container(
                    height: 70,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B1626),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.code, color: Color(0xFF22D3EE)),
                        const SizedBox(width: 10),
                        Text(
                          selectedLanguage.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        runButton(),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth >= 900) {
                            return Row(
                              children: [
                                Expanded(
                                  flex: 6,
                                  child: Column(
                                    children: [
                                      Expanded(child: editor()),
                                      const SizedBox(height: 12),
                                      inputBox(),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(flex: 4, child: outputBox()),
                              ],
                            );
                          }

                          return SingleChildScrollView(
                            child: Column(
                              children: [
                                SizedBox(height: 500, child: editor()),
                                const SizedBox(height: 12),
                                inputBox(),
                                const SizedBox(height: 12),
                                SizedBox(height: 350, child: outputBox()),
                              ],
                            ),
                          );
                        },
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
