import 'package:flutter/material.dart';


class todo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _todoState();
  }
}

class _todoState extends State<todo>{

  final List<Task> _todolist = [];
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To do list'),
      ),
      body: ListView.builder(
        itemCount: _todolist.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(_todolist[index].title),
            subtitle: _todolist[index].subtasks.isNotEmpty ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ..._todolist[index].subtasks.asMap().entries.map((subtaskEntry) =>
                    Row(
                        children: [
                          Expanded(
                              child: Text('- ${subtaskEntry.value}')
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteSubtask(index, subtaskEntry.key),
                          ),
                        ]
                    )
                ).toList(),
              ],
            ) : null,
            onTap: () => _addSubtask(index),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteTask(index),
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

  void _addItem(String title) {
    setState(() {
      _todolist.add(Task(
        title: title,
        subtasks: [], // Ajout des sous-tâches initiales comme une List<String> vide
      ));
    });
    _textEditingController.clear();
    Navigator.of(context).pop();
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
              onPressed: () {
                setState(() {
                  _todolist[index].subtasks.add(subtaskTitle);
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

  void _deleteTask(int index) {
    setState(() {
      _todolist.removeAt(index);
    });
  }

  void _deleteSubtask(int taskIndex, int subtaskIndex) {
    setState(() {
      _todolist[taskIndex].subtasks.removeAt(subtaskIndex);
    });
  }

}

class Task {
  final String title;
  final List<String> subtasks;

  Task({required this.title, required this.subtasks});
}
