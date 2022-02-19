import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:diary/models.dart';
import 'package:path_provider/path_provider.dart' show getTemporaryDirectory;
import 'package:tuple/tuple.dart';

const sheduleCachePath = 'shedule.cache';
const replacementsCachePath = 'replacements.cache';

Future saveWeekshedule(String group, WeekShedule weekShedule) async {
  final file = await getCacheFilePath(sheduleCachePath);
  var saveModel = SaveModel(weekShedule.weekLessons.item1,
      weekShedule.weekLessons.item2, weekShedule.weekLessons.item3, group);

  return file.writeAsString(jsonEncode(saveModel));
}

Future saveReplacements(
    Replacements replacements, DateTime? lastReplacements) async {
  final file = await getCacheFilePath(replacementsCachePath);
  String fileContents = (lastReplacements?.toString() ?? '...') +
      '!' +
      jsonEncode(replacements.toJson());
  file.writeAsString(fileContents);
}

Future<Tuple3<String, Timetable, WeekShedule?>?> loadWeekSheduleCache() async {
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
  try {
    final file = await getCacheFilePath(replacementsCachePath);
    if (file.existsSync()) {
      final repl = (await file.readAsString()).split('!');
      if (repl.isNotEmpty) {
        DateTime? stamp = DateTime.tryParse(repl.first);
        var replacements = Replacements.fromJson(jsonDecode(repl[1]));
        return Tuple2(stamp, replacements);
      }
    }
    return null;
  } catch (e) {
    log(e.toString());
    return null;
  }
}

Future<File> getCacheFilePath(String fileName) async {
  final directory = await getTemporaryDirectory();
  return File(directory.path + '/$fileName');
}
