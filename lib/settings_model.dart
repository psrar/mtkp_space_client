import 'package:flutter/foundation.dart';
import 'package:mtkp/workers/file_worker.dart';

var settingsDefaults = {'background_enabled': false};

Future saveSettings(Map<String, dynamic> settings) async {
  if (kIsWeb) return false;

  await saveJsonToFile('settings.data', settings);
}

Future<Map<String, dynamic>> loadSettings() async {
  if (kIsWeb) return settingsDefaults;

  var settings = await getJsonFromFile('settings.data');
  if (settings == null) return settingsDefaults;
  if (settings.isEmpty) return settingsDefaults;
  return settings;
}

Future saveSubscriptionToGroup(String group) async {
  if (kIsWeb) {
    return 'Подписки на рассылки сообщений работает только на Android';
  }
  await writeSimpleFile('subscription.txt', group);
}
