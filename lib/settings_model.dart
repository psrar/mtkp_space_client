import 'package:mtkp/workers/file_worker.dart';
import 'package:shared_preferences/shared_preferences.dart';

var settingsDefaults = {'background_enabled': false, 'resolve_domens': true};

Future saveSettings(Map<String, dynamic> settings) async {
  var prefs = await SharedPreferences.getInstance();
  for (var setting in settings.entries) {
    prefs.setBool(setting.key, setting.value);
  }
  // await saveJsonToFile('settings.data', settings);
}

Future<Map<String, dynamic>> loadSettings() async {
  var prefs = await SharedPreferences.getInstance();
  //Это очень уродливо все но у меня уже нет сил
  return {
    'background_enabled': prefs.getBool('background_enabled'),
    'resolve_domens': prefs.getBool('resolve_domens'),
  };
  // var settings = await getJsonFromFile('settings.data');
  // if (settings == null) return settingsDefaults;
  // if (settings.isEmpty) return settingsDefaults;
  // return settings;
}

Future saveSubscriptionToGroup(String group) async {
  await writeSimpleFile('subscription.txt', group);
}
