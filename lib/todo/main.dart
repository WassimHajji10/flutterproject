import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../identificcation/login.dart';
import 'package:get/get.dart';
import 'savetasks.dart';
import '../Provider/provider.dart';
void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
       home: Login(),
     ),

   );
  }
}

