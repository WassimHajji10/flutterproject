import 'package:flutter/cupertino.dart';
import 'package:flutterproject/savetasks.dart';
import 'package:flutterproject/todo.dart';

class TaskProvider with ChangeNotifier {
   List<Task> _tasks = [];

  final TaskRepository _taskRepository = TaskRepository();

  List<Task> get tasks => _tasks;

  Future<void> saveTask(Task task) async {
    await _taskRepository.saveTask(task);
    notifyListeners();
  }

   Future<void> updateTask(Task task) async {
     await _taskRepository.saveTask(task);
     List<Task> updatedTasks = (await _taskRepository.getAllTasks());
     _tasks = updatedTasks;
    notifyListeners();
   }

  void addTask(Task task) {
    _tasks.add(task);
    _taskRepository.saveTask(task);
    notifyListeners();
  }

   void setTasks(List<Task> tasks) {
     _tasks = tasks;
     notifyListeners();
   }

   Future<void> deleteTask(int index) async {
     if (index >= 0 && index < _tasks.length) {
       _tasks.removeAt(index);
       notifyListeners();
     }
   }

   Future<List<Task>> getAllTasks() async {
     return await _taskRepository.getAllTasks();

   }

   Future<Task> getTask(String taskId) async {
    Task task = await _taskRepository.getTask(taskId);
    return task;
  }


  void deleteSubtask(int taskId, int subtaskId) async {
    await _taskRepository.deleteSubtask(taskId, subtaskId);
    _tasks = await _taskRepository.getAllTasks();
    notifyListeners();
  }

}
