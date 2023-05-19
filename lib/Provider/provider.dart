import 'dart:async';



import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterproject/todo/savetasks.dart';
import 'package:flutterproject/todo/todo.dart';

class TaskProvider with ChangeNotifier {


  final TaskRepository _saveTask = TaskRepository();
  final List<Task> _taskList = [];
  List<Task> get taskList => _taskList;
  final TextEditingController _textEditingController = TextEditingController();

  void addItem(BuildContext context, String title) async {
    int newId = _taskList.isNotEmpty ? _taskList.last.id + 1 : 1;
    _taskList.add(
      Task(
        id: newId,
        title: title,
        subtasks: [],
        isCompleted: false,
      ),
    );

    notifyListeners();
    _textEditingController.clear();
    //Navigator.of(context).pop();

    await _saveTask.saveTask(
      Task(
        id: newId,
        title: title,
        subtasks: [],
        isCompleted: false,
      ),
    );
  }

  void deleteSubtask(BuildContext context,int taskIndex, int subtaskIndex) async {
    String taskId = _taskList[taskIndex].id.toString();
    _taskList[taskIndex].subtasks.removeAt(subtaskIndex);
    notifyListeners();

    Task updatedTask = _taskList[taskIndex];
    await _saveTask.saveTask(updatedTask);
  }

  void addSubtask(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String subtaskTitle = '';
        return AlertDialog(
          title: const Text('Ajouter une sous-tâche'),
          content: TextField(
            onChanged: (value) {
              subtaskTitle = value;
            },
            decoration: const InputDecoration(hintText: 'Entrer une sous-tâche'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Ajouter'),
              onPressed: () async {
                String taskId = _taskList[index].id.toString();
                Task task = await _saveTask.getTask(taskId);
                task.subtasks.add(subtaskTitle);
                await _saveTask.saveTask(task);
                _taskList[index] = task;
                notifyListeners();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        String taskTitle = '';
        return AlertDialog(
          title: const Text('Ajouter une tâche'),
          content: TextField(
            onChanged: (value) {
              taskTitle = value;
            },
            decoration: const InputDecoration(hintText: 'Entrer une tâche'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Ajouter'),
              onPressed: () {
                addItem(context, taskTitle);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void deleteTask(BuildContext context,int index) async {
    if (_taskList.isNotEmpty && index >= 0 && index < _taskList.length) {
      String taskId = _taskList[index].id.toString();
      _taskList.removeAt(index);
      notifyListeners();

      await TaskRepository.instance.deleteTask(taskId);
    }
  }

  void editsubTaskName(BuildContext context,int index,int subtaskindex) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newTitle = _taskList[index].title;
        return AlertDialog(
          title: const Text('Modifier le nom du sous-tâche'),
          content: TextField(
            onChanged: (value) {
              newTitle = value;
            },
            decoration: const InputDecoration(hintText: 'Entrer le nom du sous-tâche'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Enregistrer'),
              onPressed: () {
                _editSubtask(context,index, subtaskindex,newTitle);
              },
            ),
          ],
        );
      },
    );
  }
  void _editSubtask(BuildContext context, int taskIndex, int subtaskIndex, String newSubtaskTitle) async {
    Task oldTask = _taskList[taskIndex];
    List<String> oldSubtasks = List.from(oldTask.subtasks);
    oldSubtasks[subtaskIndex] = newSubtaskTitle;

    Task updatedTask = Task(
      id: oldTask.id,
      title: oldTask.title,
      subtasks: oldSubtasks,
      isCompleted: oldTask.isCompleted,
    );

    _taskList[taskIndex] = updatedTask;
    await _saveTask.saveTask(updatedTask);
    notifyListeners();
    Navigator.of(context).pop();
  }
  void editTaskName(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newTitle = _taskList[index].title;
        return AlertDialog(
          title: const Text('Changer le nom de la tâche'),
          content: TextField(
            onChanged: (value) {
              newTitle = value;
            },
            decoration: const InputDecoration(hintText: 'Entrer le nom de la tâche '),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Enregistrer'),
              onPressed: () {
                _editTask(context, index, newTitle);
              },
            ),
          ],
        );
      },
    );
  }


  void _editTask(BuildContext context, int index, String newTitle) async {
    Task oldTask = _taskList[index];
    Task updatedTask = Task(
      id: oldTask.id,
      title: newTitle,
      subtasks: oldTask.subtasks,
      isCompleted: oldTask.isCompleted,
    );

    _taskList[index] = updatedTask;
    await _saveTask.saveTask(updatedTask);
    notifyListeners();
    Navigator.of(context).pop();
  }
  void toggleTaskCompletion(int index) async {
    Task task = _taskList[index];
    task.isCompleted = !task.isCompleted;
    await _saveTask.saveTask(task);
    _taskList[index] = task;
    notifyListeners();
  }





}






