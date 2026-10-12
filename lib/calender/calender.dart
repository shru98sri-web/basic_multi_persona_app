import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// void main() {
//   runApp(Calender());
// }

class Calender extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(home: Mycalender(), debugShowCheckedModeBanner: false);
  }
}

// Top-level widget to manage global Theme State
class Mycalender extends StatefulWidget {
  const Mycalender({super.key});

  @override
  State<Mycalender> createState() => _MycalenderState();
}

class _MycalenderState extends State<Mycalender> {
  // Keeps track of the current theme setting
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadThemeState();
  }

  Future<void> _loadThemeState() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('is_dark_mode') ?? false;
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  Future<void> _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_themeMode == ThemeMode.light) {
        _themeMode = ThemeMode.dark;
        prefs.setBool('is_dark_mode', true);
      } else {
        _themeMode = ThemeMode.light;
        prefs.setBool('is_dark_mode', false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Custom Almanac',
      theme: ThemeData.light(useMaterial3: true), // Light Mode Settings
      darkTheme: ThemeData.dark(useMaterial3: true), // Dark Mode Settings
      themeMode: _themeMode, // Controlled by the state
      home: CustomCalendarPage1(
        isDarkMode: _themeMode == ThemeMode.dark,
        onThemeToggle: _toggleTheme,
      ),
    );
  }
}

// Model class to hold reminder data
class Reminder {
  String id;
  String title;
  DateTime date;

  Reminder({required this.id, required this.title, required this.date});

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'date': date.toIso8601String()};
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      title: map['title'],
      date: DateTime.parse(map['date']),
    );
  }
}

class CustomCalendarPage1 extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const CustomCalendarPage1({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<CustomCalendarPage1> createState() => _CustomCalendarPage1State();
}

class _CustomCalendarPage1State extends State<CustomCalendarPage1> {
  late DateTime _focusedDate;
  late DateTime _selectedDate;
  List<Reminder> _reminders = [];
  List<Reminder>? _previousRemindersState;
  bool _showRemindersEnabled = true;

  final List<String> _daysOfWeek = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
  final List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    _focusedDate = DateTime.now();
    _selectedDate = DateTime(
      _focusedDate.year,
      _focusedDate.month,
      _focusedDate.day,
    );
    _loadReminders();
    _loadReminderToggleState();
  }

  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  int _getStartingDayOfWeek(int year, int month) {
    int weekday = DateTime(year, month, 1).weekday;
    return weekday - 1;
  }

  // SharedPreferences मधून रिमाइंडर टॉगल स्टेट लोड करणे
  Future<void> _loadReminderToggleState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showRemindersEnabled = prefs.getBool('show_reminders_enabled') ?? true;
    });
  }

  // रिमाइंडर टॉगल बदलणे आणि SharedPreferences मध्ये सेव्ह करणे
  Future<void> _toggleReminderSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showRemindersEnabled = !_showRemindersEnabled;
      prefs.setBool('show_reminders_enabled', _showRemindersEnabled);
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _showRemindersEnabled
              ? 'Reminders Visibility On'
              : 'Reminders Visibility Off',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _saveRemindersToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = _reminders
        .map((r) => jsonEncode(r.toMap()))
        .toList();
    await prefs.setStringList('saved_reminders', jsonList);
  }

  Future<void> _loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList('saved_reminders');
    if (jsonList != null) {
      setState(() {
        _reminders = jsonList
            .map((item) => Reminder.fromMap(jsonDecode(item)))
            .toList();
      });
    }
  }

  void _saveStateForUndo() {
    _previousRemindersState = _reminders
        .map((r) => Reminder(id: r.id, title: r.title, date: r.date))
        .toList();
  }

  void _undo() {
    if (_previousRemindersState != null) {
      setState(() {
        _reminders = List.from(_previousRemindersState!);
        _previousRemindersState = null;
      });
      _saveRemindersToStorage();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Action undone successfully!')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nothing to undo!')));
    }
  }

  void _showReminderDialog({Reminder? existingReminder}) {
    final titleController = TextEditingController(
      text: existingReminder?.title ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          existingReminder == null ? 'New Reminder' : 'Edit Reminder',
        ),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            hintText: 'Enter reminder title...',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty) return;

              setState(() {
                if (existingReminder != null) {
                  existingReminder.title = titleController.text.trim();
                } else {
                  _reminders.add(
                    Reminder(
                      id: DateTime.now().toString(),
                      title: titleController.text.trim(),
                      date: _selectedDate,
                    ),
                  );
                }
              });
              _saveRemindersToStorage();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteReminder(Reminder reminder) {
    _saveStateForUndo();
    setState(() {
      _reminders.remove(reminder);
    });
    _saveRemindersToStorage();
  }

  @override
  Widget build(BuildContext context) {
    final int daysInMonth = _getDaysInMonth(
      _focusedDate.year,
      _focusedDate.month,
    );
    final int startingEmptySlots = _getStartingDayOfWeek(
      _focusedDate.year,
      _focusedDate.month,
    );
    final int totalGridItems = daysInMonth + startingEmptySlots;

    final currentDayReminders = _showRemindersEnabled
        ? _reminders
              .where(
                (r) =>
                    r.date.year == _selectedDate.year &&
                    r.date.month == _selectedDate.month &&
                    r.date.day == _selectedDate.day,
              )
              .toList()
        : <Reminder>[];

    // Theme color references for clean styling
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Almanac'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              _showRemindersEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_off,
            ),
            onPressed: _toggleReminderSetting,
            tooltip: _showRemindersEnabled
                ? 'Hide Reminders'
                : 'Show Reminders',
          ),
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: _undo,
            tooltip: 'Undo last action',
          ),
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onThemeToggle,
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => setState(
                  () => _focusedDate = DateTime(
                    _focusedDate.year,
                    _focusedDate.month - 1,
                  ),
                ),
              ),
              Text(
                '${_months[_focusedDate.month - 1]} ${_focusedDate.year}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => setState(
                  () => _focusedDate = DateTime(
                    _focusedDate.year,
                    _focusedDate.month + 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _daysOfWeek
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 10),

          Expanded(
            flex: 3,
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
              ),
              itemCount: totalGridItems,
              itemBuilder: (context, index) {
                if (index < startingEmptySlots) {
                  return const SizedBox.shrink();
                }

                final int dayNumber = index - startingEmptySlots + 1;
                final DateTime cellDate = DateTime(
                  _focusedDate.year,
                  _focusedDate.month,
                  dayNumber,
                );
                final bool isSelected =
                    cellDate.year == _selectedDate.year &&
                    cellDate.month == _selectedDate.month &&
                    cellDate.day == _selectedDate.day;

                final bool hasReminder =
                    _showRemindersEnabled &&
                    _reminders.any(
                      (r) =>
                          r.date.year == cellDate.year &&
                          r.date.month == cellDate.month &&
                          r.date.day == cellDate.day,
                    );

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedDate = cellDate;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue.withOpacity(0.3) : null,
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          '$dayNumber',
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        if (hasReminder)
                          Positioned(
                            bottom: 5,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(),

          Expanded(
            flex: 2,
            child: currentDayReminders.isEmpty
                ? const Center(child: Text('No reminders for this day.'))
                : ListView.builder(
                    itemCount: currentDayReminders.length,
                    itemBuilder: (context, index) {
                      final reminder = currentDayReminders[index];
                      return ListTile(
                        // Expanded आणि Ellipsis वापरून मजकूर सुरक्षित केला आहे
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                reminder.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showReminderDialog(
                                existingReminder: reminder,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteReminder(reminder),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showReminderDialog(),
        tooltip: 'Add Reminder',
        child: const Icon(Icons.add),
      ),
    );
  }
}
