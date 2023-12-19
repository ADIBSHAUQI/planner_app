/* --------------------------------------------------------
 * Program Name: planner_app
 * Author: Adib Shauqi
 * Date: 18 Dec 2023
 * -------------------------------------------------------
 */

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/task.dart';

void main() => runApp(MaterialApp(
      home: MyMainPage(),
      theme: ThemeData(
        appBarTheme:
            const AppBarTheme(backgroundColor: Color.fromRGBO(95, 111, 82, 50)),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color.fromARGB(185, 148, 112, 1)),
        textTheme: const TextTheme(
          headline4: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(254, 250, 224, 1),
          ),
          bodyText1: TextStyle(
            fontSize: 16,
          ),
        ),
        listTileTheme: const ListTileThemeData(
            tileColor: Color.fromRGBO(169, 179, 136, 1)),
      ),
    ));

class MyMainPage extends StatefulWidget {
  const MyMainPage({super.key});

  @override
  State<MyMainPage> createState() => _MyMainPageState();
}

class _MyMainPageState extends State<MyMainPage> {
  //initialize a to-do-list record
  List<Task> _todoRecords = [];
  Map<String, bool> _selectedToDo = {};
  Map<String, String> _notes = {};
  Map<String, DateTime> _dates = {};
  Map<String, TimeOfDay> _times = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daily Planner',
          style: Theme.of(context).textTheme.headline4,
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: _todoRecords.length,
        itemBuilder: (context, index) {
          final task = _todoRecords[index];
          return GestureDetector(
            onLongPress: () {
              _editingToDo(index);
            },
            child: ListTile(
              trailing: Checkbox(
                value: _selectedToDo[task.id],
                onChanged: (bool? value) {
                  setState(() {
                    _selectedToDo[task.id] = value ?? false;
                  });
                },
              ),
              //leading: Icon(Icons.note_alt_outlined),
              title: Text(
                task.name,
                style: Theme.of(context).textTheme.bodyText1,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_notes[task.id] ?? ''), //notes display
                  Text(DateFormat.yMMMd().format(
                      _dates[task.id] ?? DateTime.now())), //date display
                  Text((_times[task.id]?.format(context)) ?? ''), //time display
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
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _addingToDo,
      ),
    );
  }

  void _addingToDo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newToDo = '';
        String newNote = '';
        DateTime newDate = DateTime.now();
        TimeOfDay newTime = TimeOfDay.now();

        return AlertDialog(
          content: Column(
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
              ElevatedButton(
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: newDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null && picked != newDate) {
                    newDate = picked;
                  }
                },
                child: Text('Select date'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: newTime,
                  );
                  if (picked != null && picked != newTime) {
                    newTime = picked;
                  }
                },
                child: Text('Select time'),
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
                  setState(() {
                    String id = DateTime.now()
                        .toIso8601String(); // Generate a unique id
                    _todoRecords
                        .add(Task(id: id, name: newToDo)); // Add a new Task
                    _selectedToDo[id] = false;
                    _notes[id] = newNote;
                    _dates[id] = newDate;
                    _times[id] = newTime;
                  });
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Task cannot be empty')));
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
              ElevatedButton(
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: originalDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null && picked != originalDate) {
                    newDate = picked;
                  }
                },
                child: Text('Select date'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: originalTime,
                  );
                  if (picked != null && picked != originalTime) {
                    newTime = picked;
                  }
                },
                child: Text('Select time'),
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
                bool? originalValue = _selectedToDo.remove(originalId);
                _notes.remove(originalId);
                _dates.remove(originalId);
                _times.remove(originalId);
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
