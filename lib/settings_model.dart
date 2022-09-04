import 'package:mtkp/workers/file_worker.dart';

var settingsDefaults = {'background_enabled': false};

Future saveSettings(Map<String, dynamic> settings) async {
  await saveJsonToFile('settings.data', settings);
}

Future<Map<String, dynamic>> loadSettings() async {
  var settings = await getJsonFromFile('settings.data');
  if (settings == null) return settingsDefaults;
  if (settings.isEmpty) return settingsDefaults;
  return settings;
}

Future saveSubscriptionToGroup(String group) async {
  await writeSimpleFile('subscription.txt', group);
}
