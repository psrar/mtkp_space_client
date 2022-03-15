import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mtkp/models.dart';
import 'package:path_provider/path_provider.dart' show getTemporaryDirectory;
import 'package:tuple/tuple.dart';

const sheduleCachePath = 'shedule.cache';
const replacementsCachePath = 'replacements.cache';

Future saveWeekshedule(String group, WeekShedule weekShedule) async {
  if (kIsWeb) return false;

  final file = await getCacheFilePath(sheduleCachePath);
  var saveModel = SaveModel(weekShedule.weekLessons.item1,
      weekShedule.weekLessons.item2, weekShedule.weekLessons.item3, group);

  return file.writeAsString(jsonEncode(saveModel));
}

Future saveReplacements(
    Replacements replacements, DateTime? lastReplacements) async {
  if (kIsWeb) return false;

  final file = await getCacheFilePath(replacementsCachePath);
  String fileContents = (lastReplacements?.toString() ?? '...') +
      '!' +
      jsonEncode(replacements.toJson());
  file.writeAsString(fileContents);
}

Future<Tuple3<String, Timetable, WeekShedule?>?> loadWeekSheduleCache() async {
  if (kIsWeb) return null;

  final file = await getCacheFilePath(sheduleCachePath);
  if (file.existsSync()) {
    final saveFileMap = jsonDecode(file.readAsStringSync());
    var save = SaveModel.fromJson(saveFileMap);
    return Tuple3(save.group, save.timetable,
        WeekShedule(Tuple3(save.timetable, save.upShedule, save.downShedule)));
  } else {
    return null;
  }
}

Future<Tuple2<DateTime?, Replacements>?> loadReplacementsCache() async {
  if (kIsWeb) return null;

  try {
    final file = await getCacheFilePath(replacementsCachePath);
    if (file.existsSync()) {
      final repl = (await file.readAsString()).split('!');
      if (repl.isNotEmpty) {
        DateTime? stamp = DateTime.tryParse(repl.first);
        Map<String, dynamic> json = jsonDecode(repl[1]);
        if (json.isEmpty) return Tuple2(stamp, Replacements(null));

        Replacements replacements = Replacements.fromJson(json);
        return Tuple2(stamp, replacements);
      }
    }
    return Tuple2(null, Replacements(null));
  } catch (e) {
    log(e.toString());
    return Tuple2(null, Replacements(null));
  }
}

Future<File> getCacheFilePath(String fileName) async {
  final directory = await getTemporaryDirectory();
  return File(directory.path + '/$fileName');
}
