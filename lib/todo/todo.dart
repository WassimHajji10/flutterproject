import 'package:flutter/material.dart';
import 'package:flutterproject/Provider/provider.dart';
import 'package:provider/provider.dart';
import 'savetasks.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutterproject/services/local_notifications.dart';


class todo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {


    return _todoState();
  }

}

class _todoState extends State<todo>{


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
      Provider.of<TaskProvider>(context,listen: false).taskList.clear();

      Provider.of<TaskProvider>(context,listen: false).taskList.addAll(tasks);
    });
  }

  @override
  Widget build(BuildContext context) {
    // final TaskProvider  _taskProvider= TaskProvider ();
    return Scaffold(
      appBar: AppBar(
        title: Text('To do list'),
      ),
      backgroundColor: Colors.white,
      body: ListView.builder(
        itemCount:  Provider.of<TaskProvider>(context).taskList.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(
              Provider.of<TaskProvider>(context).taskList[index].title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            subtitle:  Provider.of<TaskProvider>(context, listen: false).taskList[index].subtasks.isNotEmpty
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ... Provider.of<TaskProvider>(context, listen: false).taskList[index].subtasks.asMap().entries.map(
                      (subtaskEntry) => Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>  Provider.of<TaskProvider>(context,listen: false).editsubTaskName(context,index
                              , subtaskEntry.key),
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
                            Provider.of<TaskProvider>(context,listen: false).deleteSubtask(context,index, subtaskEntry.key),
                      ),
                    ],
                  ),
                ).toList(),
              ],
            )
                : null,
            onTap: () =>  Provider.of<TaskProvider>(context,listen: false).addSubtask(context,index),
            onLongPress: () => Provider.of<TaskProvider>(context,listen: false).editTaskName(context, index),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon:  Provider.of<TaskProvider>(context, listen: false).taskList[index].isCompleted
                      ? Icon(Icons.check_box)
                      : Icon(Icons.check_box_outline_blank),
                  onPressed: () => Provider.of<TaskProvider>(context, listen: false).toggleTaskCompletion(index) ,
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => Provider.of<TaskProvider>(context,listen: false).deleteTask(context,index),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>  Provider.of<TaskProvider>(context,listen: false).showAddTaskDialog(context),
        child: Icon(Icons.add),
      ),
    );
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