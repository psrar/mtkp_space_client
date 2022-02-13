import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tuple/tuple.dart';

import 'database/database_interface.dart';
import 'file_worker.dart';
import 'main.dart';
import 'models.dart';

const restApi =
    'https://api.vk.com/method/wall.get?domain=mtkp_bmstu&offset=1&count=6&filter=all&extended=0&v=5.131&access_token=733ba40e54ee97a4db5a478c0910346fda3da33db69bf2b6a478b780cbf74cc8bb947264e9390019aa35b';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

AndroidNotificationDetails importantAndroidNotification =
    const AndroidNotificationDetails('0', 'SpaceAndroidBackground',
        importance: Importance.max,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(''));

const AndroidNotificationDetails silentAndroidNotification =
    AndroidNotificationDetails('1', 'SpaceAndroidBackgroundSilent',
        importance: Importance.min,
        priority: Priority.min,
        playSound: false,
        enableLights: false,
        enableVibration: false);

NotificationDetails importantPlatformChannelSpecifics =
    NotificationDetails(android: importantAndroidNotification);
const NotificationDetails silentPlatformChannelSpecifics =
    NotificationDetails(android: silentAndroidNotification);

void stopDispatcher() {
  for (var i = 0; i < 20; i++) {
    AndroidAlarmManager.cancel(i);
  }
}

void startDispatcher() {
  initialization();
  stopDispatcher();
  AndroidAlarmManager.oneShot(const Duration(seconds: 10), 0, executeFetching,
      // allowWhileIdle: true,
      // exact: true,
      // wakeup: true,
      alarmClock: true,
      rescheduleOnReboot: true);
}

void executeFetching() async {
  var hour = DateTime.now().hour;
  int interval = (1 <= hour && hour <= 8) ? 10 : 10;
  await fetchReplacements();
  await AndroidAlarmManager.oneShot(
      Duration(seconds: interval), 0, executeFetching,
      // allowWhileIdle: true,
      // exact: true,
      // wakeup: true,
      alarmClock: true,
      rescheduleOnReboot: true);
}

Future fetchReplacements() async {
  var lastStamp = await getLastReplacementStamp();
  await getLastReplacementDate(lastStamp.item1).then((value) async {
    await saveLastReplacementStamp(value.item3, DateTime.now());
    if (value.item1[0] == '!') {}
    await flutterLocalNotificationsPlugin.show(
        0, 'МТКП Space', value.toString(), importantPlatformChannelSpecifics);
  });
}

Future<Tuple3<String, SimpleDate?, int>> getLastReplacementDate(
    int lastReplacementsID) async {
  try {
    var response = await http.get(Uri.parse(restApi));

    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      List<dynamic> entries = json['response']['items'];
      for (var i = 0; i < entries.length; i++) {
        var file = entries[i]?['attachments']?[0]?['doc'];
        if (file != null) {
          if (file['id'] <= lastReplacementsID) {
            return Tuple3('-', SimpleDate.fromDateTime(DateTime.now()),
                lastReplacementsID);
          } else {}
          return Tuple3('!', getReplacementDate(file['title']), file['id']);
        }
      }
    }

    return Tuple3(
        '${response.statusCode}, не удалось получить замены на завтра',
        null,
        lastReplacementsID);
  } catch (e) {
    return Tuple3('?: ' + e.toString(), null, lastReplacementsID);
  }
}

SimpleDate getReplacementDate(String fileName) {
  var date = RegExp(r'( [0-9]{1,2}[\.\,\_][0-9]{1,2} )')
      .stringMatch(fileName)!
      .trim()
      .split(RegExp(r'(\_|\.|\,)'));
  return SimpleDate(int.parse(date.first), Month.all[int.parse(date.last) - 1]);
}

void selectNotification(String? payload) async {
  runApp(const MyApp());
}

void initialization() async {
  if (!kIsWeb && Platform.isAndroid) {
    await AndroidAlarmManager.initialize();

// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    InitializationSettings initializationSettings =
        const InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (payload) => selectNotification(payload));
  }
}
