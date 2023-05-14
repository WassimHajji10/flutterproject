import 'package:flutter/material.dart';
import 'package:flutterproject/provider.dart';
import 'package:provider/provider.dart';
import 'savetasks.dart';


class todo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {



    return _todoState();
  }

}

class _todoState extends State<todo> {
  final TextEditingController _textEditingController = TextEditingController();

  final TaskProvider _taskProvider = TaskProvider();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() async {
    List<Task> tasks = await _taskProvider.getAllTasks();
    _taskProvider.setTasks(tasks);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To do list'),
      ),
      body: ListView.builder(
        itemCount: _taskProvider.tasks.length,
        itemBuilder: (BuildContext context, int index) {
          Task task = _taskProvider.tasks[index];
          return ListTile(
            title: Text(task.title),
            subtitle: task.subtasks.isNotEmpty
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: task.subtasks
                  .asMap()
                  .entries
                  .map((subtaskEntry) => Row(
                children: [
                  Expanded(child: Text('- ${subtaskEntry.value}')),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () =>
                        _deleteSubtask(task, subtaskEntry.key),
                  ),
                ],
              ))
                  .toList(),
            )
                : Container(),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: task.isCompleted,
                  onChanged: (value) => _toggleCompleted(task),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteTask(index),
                ),
              ],
            ),
            onTap: () => _addSubtask(task as Task),
            leading: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => _showEditDialog(task),
            ),
          );
        },
      ),


      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDialog(),
        child: Icon(Icons.add),
      ),
    );
  }

  void _toggleCompleted(Task task) {
    setState(() {
      task.isCompleted = !task.isCompleted;
    });
  }

  void _addItem(String title) async {
    int newId = _taskProvider.tasks.isNotEmpty
        ? _taskProvider.tasks.last.id + 1
        : 1;
    Task newTask = Task(
      id: newId,
      title: title,
      subtasks: [],
      isCompleted: false,
    );
    _taskProvider.addTask(newTask);
    _textEditingController.clear();
    Navigator.of(context).pop();
    setState(() {});
  }


  void _addSubtask(Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String subtaskTitle = '';
        return AlertDialog(
          title: Text('Add a subtask'),
          content: TextField(
            onChanged: (value) {
              subtaskTitle = value;
            },
            decoration: InputDecoration(hintText: 'Enter subtask'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                task.subtasks.insert(0, subtaskTitle); // Insert the new subtask at index 0

                _taskProvider.updateTask(task);
                setState(() {});
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  void _showEditDialog(Task task) {
    TextEditingController controller =
    TextEditingController(text: task.title);
    String newTitle = task.title;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit task'),
          content: TextField(
            onChanged: (value) {
              newTitle = value;
            },
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter task'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                Task updatedTask = Task(
                  id: task.id,
                  title: newTitle,
                  subtasks: task.subtasks,
                  isCompleted: task.isCompleted,
                );
                _taskProvider.updateTask(updatedTask);
                setState(() {}); // <-- Add this line to rebuild the widget tree
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  void _markTaskAsFinished(Task task) async {
    task.isCompleted = true;
    await _taskProvider.updateTask(task);
    setState(() {});
  }




  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add a task'),
          content: TextField(
            controller: _textEditingController,
            decoration: InputDecoration(hintText: 'Enter task'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                _addItem(_textEditingController.text);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteTask(int index) async {
    if (_taskProvider.tasks.isNotEmpty && index >= 0 &&
        index < _taskProvider.tasks.length) {
      String taskId = _taskProvider.tasks[index].id.toString();
      setState(() {
        _taskProvider.tasks.removeAt(index);
      });
      await TaskRepository.instance.deleteTask(taskId);
    }
  }



  void _deleteSubtask(Task task, int subtaskIndex) async {
    setState(() {
      task.subtasks.removeAt(subtaskIndex);
    });
    await _taskProvider.updateTask(task);
    setState(() {});
  }

}

  class Task {
  final int id;
  final String title;
  bool isCompleted;
  late final List<String> subtasks;

  Task({required this.id, required this.title,required this.isCompleted, required this.subtasks});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtasks': subtasks,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory Task.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      throw ArgumentError.value(json, 'json', 'Expected a map');
    }
    final subtasks = (json['subtasks'] as List<dynamic>)
        .cast<String>()
        .toList();
    return Task(
      id: json['id'] as int,
      title: json['title'] as String,
      subtasks: subtasks,
      isCompleted: json['isCompleted'] as bool,

    );
  }
}