import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mtkp/workers/file_worker.dart';

var settingsDefaults = {'background_enabled': false};

Future saveSettings(Map<String, dynamic> settings) async {
  if (kIsWeb || !Platform.isAndroid) return false;

  await saveJsonToFile('settings.data', settings);
}

Future<Map<String, dynamic>> loadSettings() async {
  if (kIsWeb || !Platform.isAndroid) return settingsDefaults;

  var settings = await getJsonFromFile('settings.data');
  if (settings == null) return settingsDefaults;
  if (settings.isEmpty) return settingsDefaults;
  return settings;
}
