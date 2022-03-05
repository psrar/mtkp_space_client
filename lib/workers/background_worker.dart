import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:mtkp/utils/notification_utils.dart';

const int helloAlarmID = 0;

void backgroundFunc() async {
  try {} catch (e) {
  } finally {
    await AndroidAlarmManager.oneShot(
        const Duration(seconds: 90), helloAlarmID, backgroundFunc,
        exact: true, alarmClock: true, allowWhileIdle: true, wakeup: true);
  }
}

Future<bool> initAlarmManager() async {
  return await AndroidAlarmManager.initialize();
}

void startShedule() async {
  await NotificationHandler().showNotification('MTKP AlarmService',
      'AlarmManager запущен. Первый запуск черех 10 секунд, последующие с интервалом в 1 минуту');
  await AndroidAlarmManager.oneShot(
      const Duration(seconds: 10), helloAlarmID, backgroundFunc,
      exact: true, alarmClock: true, allowWhileIdle: true, wakeup: true);
}

void stopShedule() async {
  await NotificationHandler()
      .showNotification('MTKP AlarmService', 'AlarmManager остановлен');
  await AndroidAlarmManager.cancel(helloAlarmID);
}
