import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../identificcation/login.dart';
import 'package:get/get.dart';
import 'savetasks.dart';
import '../Provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../todo/todo.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
Future<void> backroundHandler(RemoteMessage message) async {
  print(" This is message from background");
  print(message.notification!.title);
  print(message.notification!.body);
}
void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(backroundHandler);
  Get.put(TaskRepository());
  Get.put(TaskProvider());

  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context)=>TaskProvider(),
      child: MaterialApp(

        home:  Login(),
      ),

    );
  }
}