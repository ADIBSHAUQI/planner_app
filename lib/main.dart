/* --------------------------------------------------------
 * Program Name: planner_app
 * Author: Adib Shauqi
 * Date: 18 Dec 2023
 * -------------------------------------------------------
 */

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/cupertino.dart';

import 'models/task.dart';

void main() => runApp(MaterialApp(
      home: MyMainPage(),
      theme: ThemeData(
        primaryColor: Color.fromRGBO(95, 111, 82, 1), // Dark green
        hintColor: Color.fromRGBO(185, 148, 112, 1), // Light brown
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromRGBO(95, 111, 82, 1),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color.fromRGBO(185, 148, 112, 1),
        ),
        textTheme: const TextTheme(
          headline4: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyText1: TextStyle(
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
      ),
    ));

class MyMainPage extends StatefulWidget {
  const MyMainPage({Key? key}) : super(key: key);

  @override
  State<MyMainPage> createState() => _MyMainPageState();
}

class _MyMainPageState extends State<MyMainPage> {
  List<Task> _todoRecords = [];
  Map<String, bool> _selectedToDo = {};
  Map<String, String> _notes = {};
  Map<String, DateTime> _dates = {};
  Map<String, TimeOfDay> _times = {};

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _removeTasksFromPastDays();
  }

  void _removeTasksFromPastDays() {
    DateTime currentDate = DateTime.now();
    setState(() {
      _todoRecords.removeWhere((task) => _getDateTime(task).isBefore(
          DateTime(currentDate.year, currentDate.month, currentDate.day)));
    });
  }

  @override
  Widget build(BuildContext context) {
    _sortTasksByDateTime();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'DayScape',
          style: Theme.of(context).textTheme.headline4,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          TableCalendar(
            calendarFormat: _calendarFormat,
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            calendarStyle: const CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Colors.pinkAccent, // Customize color as needed
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.blueGrey, // Customize color for today's date
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonShowsNext: false,
              formatButtonDecoration: BoxDecoration(
                  color: Colors.blueGrey,
                  borderRadius: BorderRadius.circular(5)),
              formatButtonTextStyle: TextStyle(color: Colors.white),
            ),
            selectedDayPredicate: (DateTime day) {
              return isSameDay(day, _selectedDay ?? DateTime.now());
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = selectedDay;
              });
            },
          ),
          _selectedDay != null
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Selected Date: ${DateFormat.yMMMd().format(_selectedDay!)}',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : Container(),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(175, 189, 149, 1), // Light green
                    Colors.white,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: _buildTaskList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _addingToDo,
      ),
    );
  }

  Widget _buildTaskList() {
    List<Task> tasksForSelectedDate = _getTasksForSelectedDate();

    return tasksForSelectedDate.isEmpty
        ? Center(
            child: Text(
              'No task added',
              style: TextStyle(fontSize: 20),
            ),
          )
        : ListView.builder(
            itemCount: tasksForSelectedDate.length,
            itemBuilder: (context, index) {
              final task = tasksForSelectedDate[index];
              final isOddItem = index.isOdd;

              return GestureDetector(
                onLongPress: () {
                  _editingToDo(index);
                },
                child: ListTile(
                  tileColor: isOddItem
                      ? Color.fromRGBO(169, 179, 136, 1) // Odd item color
                      : Color.fromRGBO(150, 160, 120, 1), // Even item color
                  trailing: Checkbox(
                    value: _selectedToDo[task.id],
                    onChanged: (bool? value) {
                      setState(() {
                        _selectedToDo[task.id] = value ?? false;
                      });
                    },
                    activeColor: Colors.amber, // background color
                    checkColor: Colors.white, // tick color
                    splashRadius: 0,
                  ),
                  title: Text(
                    task.name,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_notes[task.id] ?? ''),
                      Text(DateFormat.yMMMd()
                          .format(_dates[task.id] ?? DateTime.now())),
                      Text((_times[task.id]?.format(context)) ?? ''),
                    ],
                  ),
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _editingToDo(index);
                                },
                                child: Text('Edit'),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedToDo.remove(task.id);
                                    _notes.remove(task.id);
                                    _dates.remove(task.id);
                                    _times.remove(task.id);
                                    _todoRecords.removeAt(index);
                                  });
                                  Navigator.of(context).pop();
                                },
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          );
  }

  List<Task> _getTasksForSelectedDate() {
    if (_selectedDay != null) {
      DateTime selectedDate = _selectedDay!;
      return _todoRecords
          .where((task) =>
              _getDateTime(task).year == selectedDate.year &&
              _getDateTime(task).month == selectedDate.month &&
              _getDateTime(task).day == selectedDate.day)
          .toList();
    } else {
      return [];
    }
  }

  void _sortTasksByDateTime() {
    _todoRecords.sort((a, b) {
      DateTime dateTimeA = _getDateTime(a);
      DateTime dateTimeB = _getDateTime(b);
      return dateTimeA.compareTo(dateTimeB);
    });
  }

  DateTime _getDateTime(Task task) {
    return (_dates[task.id] ?? DateTime.now()).add(
      Duration(
        hours: _times[task.id]?.hour ?? 0,
        minutes: _times[task.id]?.minute ?? 0,
      ),
    );
  }

  void _addingToDo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newToDo = '';
        String newNote = '';
        TimeOfDay newTime = TimeOfDay.now(); // Default to the current time

        return AlertDialog(
          content: Column(
            mainAxisSize:
                MainAxisSize.min, // Ensure the content takes minimum space
            children: [
              TextField(
                onChanged: (value) {
                  newToDo = value;
                },
                decoration: InputDecoration(
                  labelText: 'Task',
                ),
              ),
              TextField(
                onChanged: (value) {
                  newNote = value;
                },
                decoration: InputDecoration(
                  labelText: 'Note',
                ),
              ),
              Container(
                height: 150.0, // Adjust the height as needed
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime:
                      DateTime(2001, 1, 1, newTime.hour, newTime.minute),
                  onDateTimeChanged: (DateTime newDateTime) {
                    newTime = TimeOfDay.fromDateTime(newDateTime);
                  },
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (newToDo.isNotEmpty) {
                  // Use the selected date (_selectedDay) instead of newDate
                  DateTime newDate = _selectedDay ?? DateTime.now();

                  setState(() {
                    String id = DateTime.now().toIso8601String();
                    _todoRecords.add(Task(id: id, name: newToDo));
                    _selectedToDo[id] = false;
                    _notes[id] = newNote;
                    _dates[id] = newDate;
                    _times[id] = newTime;
                  });

                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Task cannot be empty')),
                  );
                }
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _editingToDo(int index) {
    String originalId = _todoRecords[index].id;
    String newToDo = _todoRecords[index].name;
    String originalNote = _notes[originalId] ?? '';
    String newNote = originalNote;
    DateTime originalDate = _dates[originalId] ?? DateTime.now();
    DateTime newDate = originalDate;
    TimeOfDay originalTime = _times[originalId] ?? TimeOfDay.now();
    TimeOfDay newTime = originalTime;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Task and Note Below'),
          content: Column(
            mainAxisSize:
                MainAxisSize.min, // Ensure the content takes minimum space
            children: <Widget>[
              TextField(
                controller: TextEditingController(text: newToDo),
                onChanged: (value) {
                  newToDo = value;
                },
                decoration: InputDecoration(
                  labelText: 'Task',
                ),
              ),
              TextField(
                controller: TextEditingController(text: newNote),
                onChanged: (value) {
                  newNote = value;
                },
                decoration: InputDecoration(
                  labelText: 'Note',
                ),
              ),
              Container(
                height: 150.0,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime:
                      DateTime(2001, 1, 1, newTime.hour, newTime.minute),
                  onDateTimeChanged: (DateTime newDateTime) {
                    newTime = TimeOfDay.fromDateTime(newDateTime);
                  },
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                bool? originalValue = _selectedToDo[originalId];
                setState(() {
                  _todoRecords[index] = Task(id: originalId, name: newToDo);
                  _selectedToDo[originalId] = originalValue ?? false;
                  _notes[originalId] = newNote;
                  _dates[originalId] = newDate;
                  _times[originalId] = newTime;
                });
                Navigator.of(context).pop();
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}
