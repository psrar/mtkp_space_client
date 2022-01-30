import 'dart:convert';
import 'dart:io';

import 'package:diary/models.dart';
import 'package:path_provider/path_provider.dart' show getTemporaryDirectory;
import 'package:tuple/tuple.dart';

const cachePath = 'shedule.cache';

Future saveWeekshedule(String group, WeekShedule weekShedule) async {
  final file = await getCacheFilePath(cachePath);
  var saveModel = SaveModel(weekShedule.weekLessons.item1,
      weekShedule.weekLessons.item2, weekShedule.weekLessons.item3, group);

  return file.writeAsString(jsonEncode(saveModel));
}

Future<Tuple3<String, Timetable, WeekShedule?>?> loadWeekShedule() async {
  final file = await getCacheFilePath(cachePath);
  if (file.existsSync()) {
    final saveFileMap = jsonDecode(file.readAsStringSync());
    var save = SaveModel.fromJson(saveFileMap);
    return Tuple3(save.group, save.timetable,
        WeekShedule(Tuple3(save.timetable, save.upShedule, save.downShedule)));
  } else {
    return null;
  }
}

Future<File> getCacheFilePath(String fileName) async {
  final directory = await getTemporaryDirectory();
  return File(directory.path + '/$fileName');
}
