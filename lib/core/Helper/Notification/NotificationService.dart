import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../AppConstant/AppColorConstant.dart';
import 'dart:io' show File, Platform;

import 'package:rxdart/subjects.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationServices {
  //
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final BehaviorSubject<ReceivedNotification>
      didReceivedLocalNotificationSubject =
      BehaviorSubject<ReceivedNotification>();
  var initializationSettings;

  NotificationServices._() {
    init();
  }

  init() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    if (Platform.isIOS) {
      _requestIOSPermission();
    }

    initializePlatformSpecifics();
    tz.initializeTimeZones();
    // tz.setLocalLocation(tz.getLocation(DateTime.now().toLocal().timeZoneName));
  }

  tz.TZDateTime _nextInstanceOfTenAM(DateTime date) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, date.year, date.month, date.day, 10);
    if (scheduledDate.isBefore(date)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    print("mmmmmmmmmmmmmmmmmmmmmmmm$scheduledDate");
    return scheduledDate;
  }

  void initializePlatformSpecifics() {
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('app_icon');

    var initializationSettingsIOS = const DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true, // يمكنك تغييره حسب الحاجة
    );

    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        String? payload = notificationResponse.payload;
        // معالجة عند الضغط على الإشعار
      },
    );
  }

  _requestIOSPermission() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()!
        .requestPermissions(
          alert: false,
          badge: true,
          sound: true,
        );
  }

  setListenerForLowerVersions(Function onNotificationInLowerVersions) {
    didReceivedLocalNotificationSubject.listen((receivedNotification) {
      onNotificationInLowerVersions(receivedNotification);
    });
  }

  setOnNotificationClick(Function onNotificationClick) async {
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {
      String? payload = notificationResponse.payload;
      onNotificationClick(payload);
    });
  }

  Future<void> showNotification({String? title, String? body, var code}) async {
    var androidChannelSpecifics = AndroidNotificationDetails(
      'CHANNEL_ID',
      'CHANNEL_NAME',
      // "CHANNEL_DESCRIPTION",
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      timeoutAfter: 50000,
      styleInformation: DefaultStyleInformation(true, true),
    );
    var iosChannelSpecifics = DarwinNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidChannelSpecifics, iOS: iosChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      code,
      title,
      body, //null
      platformChannelSpecifics,
      payload: 'New Payload',
    );
  }

  Future<void> showDailyAtTime(
      {String? title, String? body, required tz.TZDateTime setTime}) async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    // **إعدادات Android**
    var androidChannelSpecifics = const AndroidNotificationDetails(
      'CHANNEL_ID_4',
      'CHANNEL_NAME_4',
      channelDescription: 'الوصف التفصيلي للقناة',
      importance: Importance.max,
      priority: Priority.high,
    );

    // **إعدادات iOS**
    var iosChannelSpecifics = const DarwinNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
      android: androidChannelSpecifics,
      iOS: iosChannelSpecifics,
    );

    // **تهيئة المنطقة الزمنية**
    tz.initializeTimeZones();

    // **تحديد موعد التكرار اليومي**
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      setTime.hour,
      setTime.minute,
      setTime.second,
    );

    // **إذا كان الوقت المحدد قد فات اليوم، جدوله ليوم غد**
    final scheduledTime = scheduledDate.isBefore(now)
        ? scheduledDate.add(const Duration(days: 1))
        : scheduledDate;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // معرف الإشعار
      '$title ${setTime.hour}:${setTime.minute}.${setTime.second}', // عنوان الإشعار
      body, // محتوى الإشعار
      scheduledTime, // وقت الإشعار
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // لتكرار يومي
    );
  }

  Future<void> showWeeklyAtDayTime(
      {required tz.TZDateTime setTime,
      String? title,
      String? body,
      required int dayOfWeek}) async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    // **إعدادات Android**
    var androidChannelSpecifics = const AndroidNotificationDetails(
      'CHANNEL_ID_5',
      'CHANNEL_NAME_5',
      channelDescription: 'الوصف التفصيلي للقناة',
      importance: Importance.max,
      priority: Priority.high,
    );

    // **إعدادات iOS**
    var iosChannelSpecifics = const DarwinNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
      android: androidChannelSpecifics,
      iOS: iosChannelSpecifics,
    );

    // **تهيئة المنطقة الزمنية**
    tz.initializeTimeZones();

    final now = tz.TZDateTime.now(tz.local);

    // **تحديد موعد التكرار الأسبوعي**
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      setTime.hour,
      setTime.minute,
      setTime.second,
    );

    // **حساب اليوم الصحيح للإشعار الأسبوعي**
    while (scheduledDate.weekday != dayOfWeek) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // **إذا كان الوقت المحدد قد فات اليوم، جدوله للأسبوع القادم**
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // معرف الإشعار
      '$title ${setTime.hour}:${setTime.minute}.${setTime.second}', // عنوان الإشعار
      body, // محتوى الإشعار
      scheduledDate, // وقت الإشعار
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents:
          DateTimeComponents.dayOfWeekAndTime, // تكرار أسبوعي
    );
  }

  Future<void> repeatNotification(
      {String? title,
      String? body,
      required RepeatInterval repeatInterval}) async {
    var androidChannelSpecifics = AndroidNotificationDetails(
      'CHANNEL_ID 3',
      'CHANNEL_NAME 3',
      // "CHANNEL_DESCRIPTION 3",
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: DefaultStyleInformation(true, true),
    );
    var iosChannelSpecifics = DarwinNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidChannelSpecifics, iOS: iosChannelSpecifics);
    await flutterLocalNotificationsPlugin.periodicallyShow(
      0,
      title,
      body,
      repeatInterval,
      platformChannelSpecifics,
      payload: 'Test Payload',
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  scheduleNotification(
      {required DateTime? setDateTime, String? title, String? body}) {
//     // The device's timezone.
//     String timeZoneName = await setDateTime!.timeZoneName;
// print(timeZoneName);
//     // Find the 'current location'
//     final location = await tz.getLocation(timeZoneName);
//
//     final scheduledDate = tz.TZDateTime.from(setDateTime, location);
//   //  var scheduleNotificationDateTime = setDateTime.timeZoneOffset;//DateTime.now().add(Duration(seconds: 5));
    var time = tz.TZDateTime.from(
      setDateTime!,
      tz.local,
    );
    print("zzzzzzzzzzzzzzzzzzzzzz$time");

    var androidChannelSpecifics = AndroidNotificationDetails(
      'CHANNEL_ID 1',
      'CHANNEL_NAME 1',
      // "CHANNEL_DESCRIPTION 1",
      //  icon: 'app_icon',
      // sound: RawResourceAndroidNotificationSound('my_sound'),
      //   largeIcon: DrawableResourceAndroidBitmap('app_icon'),
      enableLights: true,
      color: AppColor.secondaryColor,
      ledColor: AppColor.activeColor,
      ledOnMs: 1000,
      ledOffMs: 500,
      importance: Importance.defaultImportance,
      priority: Priority.low,
      playSound: true,
      timeoutAfter: 10000,
      styleInformation: DefaultStyleInformation(true, true),
    );
    var iosChannelSpecifics = DarwinNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      android: androidChannelSpecifics,
      iOS: iosChannelSpecifics,
    );
    flutterLocalNotificationsPlugin.zonedSchedule(
        0, title, body, time, platformChannelSpecifics,
        payload: body,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime);
  }
  //
  // Future<void> showNotificationWithAttachment() async {
  //   var attachmentPicturePath = await _downloadAndSaveFile(
  //       'https://via.placeholder.com/800x200', 'attachment_img.jpg');
  //   var iOSPlatformSpecifics = IOSNotificationDetails(
  //     attachments: [IOSNotificationAttachment(attachmentPicturePath)],
  //   );
  //   var bigPictureStyleInformation = BigPictureStyleInformation(
  //     FilePathAndroidBitmap(attachmentPicturePath),
  //     contentTitle: '<b>Attached Image</b>',
  //     htmlFormatContentTitle: true,
  //     summaryText: 'Test Image',
  //     htmlFormatSummaryText: true,
  //   );
  //   var androidChannelSpecifics = AndroidNotificationDetails(
  //     'CHANNEL ID 2',
  //     'CHANNEL NAME 2',
  //     'CHANNEL DESCRIPTION 2',
  //     importance: Importance.high,
  //     priority: Priority.high,
  //     styleInformation: bigPictureStyleInformation,
  //   );
  //   var notificationDetails =
  //   NotificationDetails(android: androidChannelSpecifics, iOS: iOSPlatformSpecifics);
  //   await flutterLocalNotificationsPlugin.show(
  //     0,
  //     'Title with attachment',
  //     'Body with Attachment',
  //     notificationDetails,
  //   );
  // }
  //
  // _downloadAndSaveFile(String url, String fileName) async {
  //   var directory = await getApplicationDocumentsDirectory();
  //   var filePath = '${directory.path}/$fileName';
  //   var response = await http.get(Uri.parse(url));
  //   var file = File(filePath);
  //   await file.writeAsBytes(response.bodyBytes);
  //   return filePath;
  // }

  Future<int> getPendingNotificationCount() async {
    List<PendingNotificationRequest> p =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    return p.length;
  }

  Future<void> cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }

  Future<void> cancelAllNotification() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  // sendNotification(name, message, fBToken) async {
  //   // HelperFunctions.getUserUid()
  //   var res = await Dio().post(
  //       "$baseUrl/FCMPushNotification/sendNotification?title=$name&body=$message&deviceId=$fBToken");
  //   print(res);
  // }
}

NotificationServices notificationServices = NotificationServices._();

class ReceivedNotification {
  final int? id;
  final String? title;
  final String? body;
  final String? payload;

  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });
}
