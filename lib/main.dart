import 'package:flutter/material.dart';
import 'package:flutter_tutorial/Helpers/SyncService.dart';
import 'package:flutter_tutorial/Views/LoginPage.dart';
import 'package:get/get.dart';
import 'package:workmanager/workmanager.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    SyncService().syncData(); // تشغيل المزامنة تلقائيًا في الخلفية
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // تشغيل WorkManager
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

  // تسجيل مهمة المزامنة الدورية
  await Workmanager().registerPeriodicTask(
    "1",
    "syncTask",
    frequency: Duration(minutes: 15), // يتم تشغيل المزامنة كل 15 دقيقة
    initialDelay: Duration(minutes: 1), // تشغيلها بعد دقيقة من بدء التطبيق
  );
  // تشغيل مراقبة الإنترنت لبدء المزامنة عند عودة الاتصال
  SyncService syncService = SyncService();
  syncService.monitorInternetConnection();

  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home:LoginPage(),
    );
  }
}





