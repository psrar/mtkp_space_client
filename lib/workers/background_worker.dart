import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:mtkp/utils/notification_utils.dart';

const int helloAlarmID = 0;

void _backgroundFunc() async {
  try {
    NotificationHandler().showNotification('title', 'body');
  } catch (e) {
  } finally {
    await AndroidAlarmManager.oneShot(
        const Duration(seconds: 90), helloAlarmID, _backgroundFunc,
        exact: true, alarmClock: true, allowWhileIdle: true, wakeup: true);
  }
}

Future<bool> initAlarmManager() async {
  return await AndroidAlarmManager.initialize();
}

void startShedule() async {
  await AndroidAlarmManager.oneShot(
      const Duration(seconds: 10), helloAlarmID, _backgroundFunc,
      exact: true, alarmClock: true, allowWhileIdle: true, wakeup: true);
}

void stopShedule() async {
  await AndroidAlarmManager.cancel(helloAlarmID);
}
