import 'dart:developer';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:mtkp/database/database_interface.dart';
import 'package:mtkp/utils/notification_utils.dart';
import 'package:mtkp/workers/file_worker.dart';

const int helloAlarmID = 0;

void _backgroundFunc() async {
  try {
    var lastStamp = await getLastMessageStamp();
    var group = await readSimpleFile('subscription.txt');
    var result =
        await DatabaseWorker().getAllMessages(from: lastStamp, group: group);
    if (result.item1.isNotEmpty) {
      log(result.item1);
    } else if (result.item2.isNotEmpty) {
      await NotificationHandler().showNotification(
          result.item2.first.item3.substring(1), result.item2.first.item4);
      await saveLastMessageStamp(result.item2.first.item1, DateTime.now());
    }
  } catch (e) {
    log(e.toString());
  } finally {
    await AndroidAlarmManager.oneShot(
        Duration(minutes: DateTime.now().hour < 8 ? 60 : 2),
        helloAlarmID,
        _backgroundFunc,
        exact: true,
        alarmClock: false,
        allowWhileIdle: true,
        wakeup: true,
        rescheduleOnReboot: true);
  }
}

Future<bool> initAlarmManager() async {
  return await AndroidAlarmManager.initialize();
}

void startShedule() async {
  await AndroidAlarmManager.oneShot(
      const Duration(seconds: 10), helloAlarmID, _backgroundFunc,
      exact: true,
      alarmClock: false,
      allowWhileIdle: true,
      wakeup: true,
      rescheduleOnReboot: true);
}

void stopShedule() async {
  await AndroidAlarmManager.cancel(helloAlarmID);
}
