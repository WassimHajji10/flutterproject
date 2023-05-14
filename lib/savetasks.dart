import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'todo.dart';


class TaskRepository extends GetxController {
  static TaskRepository get instance => Get.find();
  final _db = FirebaseFirestore.instance;

  Future<void> saveTask(Task task) async {
    final CollectionReference tasks = FirebaseFirestore.instance.collection('tasks');
    await tasks.doc(task.id.toString()).set(task.toJson());
  }
  Future<void> deleteTask(String taskId) async {
    await _db.collection('tasks').doc(taskId).delete();
  }

  Future<void> deleteSubtask(int taskId, int subtaskId) async {
    final DocumentReference taskRef = _db.collection('tasks').doc(taskId.toString());
    final DocumentSnapshot<Map<String, dynamic>> doc =
    await taskRef.get() as DocumentSnapshot<Map<String, dynamic>>;

    if (!doc.exists) {
      throw Exception('Task not found!');
    }

    final Map<String, dynamic> data = doc.data()!;
    final List<String> subtasks = List<String>.from(data['subtasks']);

    if (subtaskId < subtasks.length) {
      subtasks.removeAt(subtaskId);
      await taskRef.update({'subtasks': subtasks});
    }
  }

  Future<Task> getTask(String taskId) async {
    final DocumentSnapshot<Map<String, dynamic>> doc =
    await _db.collection('tasks').doc(taskId).get();

    if (!doc.exists) {
      throw Exception('Task not found!');
    }

    final Map<String, dynamic> data = doc.data()!;
    final List<String> subtasks = List<String>.from(data['subtasks']);

    return Task(
      id: int.parse(doc.id),
      title: data['title'],
      subtasks: subtasks,
      isCompleted: false,

    );
  }
  Future<List<Task>> getAllTasks() async {
    QuerySnapshot snapshot = await _db.collection('tasks').get();
    List<Task> tasks = snapshot.docs.map((doc) => Task.fromJson(doc.data())).toList();
    return tasks;
  }


}
