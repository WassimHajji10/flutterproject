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

class _todoState extends State<todo>{

  final List<Task> _todolist = [];
  final TextEditingController _textEditingController = TextEditingController();

  final TaskRepository  _saveTask = TaskRepository ();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() async {
    TaskRepository taskRepository = TaskRepository();
    List<Task> tasks = await taskRepository.getAllTasks();

    //List<Task> tasks = await TaskRepository.getAllTasks();
    setState(() {
      _todolist.clear();
      _todolist.addAll(tasks);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To do list'),
      ),
      backgroundColor: Colors.white,
      body: ListView.builder(
        itemCount: _todolist.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(
              _todolist[index].title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            subtitle: _todolist[index].subtasks.isNotEmpty
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ..._todolist[index].subtasks.asMap().entries.map(
                      (subtaskEntry) => Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _editsubTaskName(
                            index,
                            subtaskEntry.key,

                          ),
                          child: Text(
                            '- ${subtaskEntry.value}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () =>
                            _deleteSubtask(index, subtaskEntry.key),
                      ),
                    ],
                  ),
                ).toList(),
              ],
            )
                : null,
            onTap: () => _addSubtask(index),
            onLongPress: () => _editTaskName(index),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: _todolist[index].isCompleted
                      ? Icon(Icons.check_box)
                      : Icon(Icons.check_box_outline_blank),
                  onPressed: () => _toggleTaskCompletion(index),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteTask(index),
                ),
              ],
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

  void _addItem(String title) async {
    int newId = _todolist.isNotEmpty ? _todolist.last.id + 1 : 1;
    setState(() {
      _todolist.add(Task(
        id: newId,
        title: title,
        subtasks: [], isCompleted: false,
      ));
    });
    _textEditingController.clear();
    Navigator.of(context).pop();


    await _saveTask.saveTask(Task(
      id: newId,
      title: title,
      subtasks: [], isCompleted: false,
    ));
  }





  void _addSubtask(int index) {
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
              onPressed: () async {
                String taskId = _todolist[index].id.toString();
                Task task = await _saveTask.getTask(taskId);
                task.subtasks.add(subtaskTitle);
                await _saveTask.saveTask(task);
                setState(() {
                  _todolist[index] = task;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
    if (_todolist.isNotEmpty && index >= 0 && index < _todolist.length) {
      String taskId = _todolist[index].id.toString();
      setState(() {
        _todolist.removeAt(index);
      });
      await TaskRepository.instance.deleteTask(taskId);
    }
  }

  void _editsubTaskName(int index,int subtaskindex) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newTitle = _todolist[index].title;
        return AlertDialog(
          title: Text('Edit SubTask Name'),
          content: TextField(
            onChanged: (value) {
              newTitle = value;
            },
            decoration: InputDecoration(hintText: 'Enter subtask name'),
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
                _editSubtask(index, subtaskindex,newTitle);
              },
            ),
          ],
        );
      },
    );
  }
  void _editTaskName(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newTitle = _todolist[index].title;
        return AlertDialog(
          title: Text('Edit Task Name'),
          content: TextField(
            onChanged: (value) {
              newTitle = value;
            },
            decoration: InputDecoration(hintText: 'Enter task name'),
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
                _editTask(index, newTitle);
              },
            ),
          ],
        );
      },
    );
  }

  void _toggleTaskCompletion(int index) async {
    Task task = _todolist[index];
    task.isCompleted = !task.isCompleted;
    await _saveTask.saveTask(task);
    setState(() {
      _todolist[index] = task;
    });
  }




  void _deleteSubtask(int taskIndex, int subtaskIndex) async {
    String taskId = _todolist[taskIndex].id.toString();
    setState(() {
      _todolist[taskIndex].subtasks.removeAt(subtaskIndex);
    });
    Task updatedTask = _todolist[taskIndex];
    await TaskRepository.instance.saveTask(updatedTask);
  }
  void _editTask(int index, String newTitle) async {
    Task oldTask = _todolist[index];
    Task updatedTask = Task(
      id: oldTask.id,
      title: newTitle,
      subtasks: oldTask.subtasks,
      isCompleted: oldTask.isCompleted,
    );

    _todolist[index] = updatedTask;
    await _saveTask.saveTask(updatedTask);
    setState(() {

    });
    Navigator.of(context).pop();
  }
  void _editSubtask(int taskIndex, int subtaskIndex, String newSubtaskTitle) async {
    Task oldTask = _todolist[taskIndex];
    List<String> oldSubtasks = List.from(oldTask.subtasks);
    oldSubtasks[subtaskIndex] = newSubtaskTitle;

    Task updatedTask = Task(
      id: oldTask.id,
      title: oldTask.title,
      subtasks: oldSubtasks,
      isCompleted: oldTask.isCompleted,
    );

    _todolist[taskIndex] = updatedTask;
    await _saveTask.saveTask(updatedTask);
    setState(() {

    });
    Navigator.of(context).pop();
  }



}

class Task {
  final int id;
  final String title;
  final List<String> subtasks;
  bool isCompleted;

  Task({required this.id, required this.title, required this.subtasks,required this.isCompleted});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtasks': subtasks,
      'isCompleted':isCompleted,
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