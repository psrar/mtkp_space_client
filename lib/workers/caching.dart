import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mtkp/models.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;
import 'package:tuple/tuple.dart';

const pinnedTeachersCachePath = 'pinnedTeachers.cache';
const pinnedGroupsCachePath = 'pinnedGroups.cache';
const sheduleCachePath = 'shedule.cache';
const replacementsCachePath = 'replacements.cache';

Future savePinnedTeachers(List<Tuple2<int, String>> pinnedTeachers) async {
  final File file = await getCacheFilePath(pinnedTeachersCachePath);
  return file.writeAsString(
      pinnedTeachers.map((e) => e.item1.toString() + '~' + e.item2).join('\n'));
}

Future<List<Tuple2<int, String>>> loadPinnedTeachers() async {
  final File file = await getCacheFilePath(pinnedTeachersCachePath);
  if (file.existsSync()) {
    return (await file.readAsLines()).map((e) {
      var i = e.split('~');
      return Tuple2(int.parse(i[0]), i[1]);
    }).toList();
  } else {
    return [];
  }
}

Future savePinnedGroups(List<String> pinnedGroups) async {
  final File file = await getCacheFilePath(pinnedGroupsCachePath);
  return file.writeAsString(pinnedGroups.join('\n'));
}

Future<List<String>> loadPinnedGroups() async {
  final File file = await getCacheFilePath(pinnedGroupsCachePath);
  if (file.existsSync()) {
    return await file.readAsLines();
  } else {
    return [];
  }
}

Future saveWeekshedule(String group, WeekShedule weekShedule,
    [bool inSearch = false]) async {
  if (kIsWeb) return false;

  final File file;
  if (inSearch) {
    file = await getCacheFilePath('shedule_' + group + '.cache');
  } else {
    file = await getCacheFilePath(sheduleCachePath);
  }
  var saveModel = SaveModel(weekShedule.weekLessons.item1,
      weekShedule.weekLessons.item2, weekShedule.weekLessons.item3, group);

  return file.writeAsString(jsonEncode(saveModel));
}

Future saveReplacements(Replacements replacements, DateTime? lastReplacements,
    [String groupInSearch = '']) async {
  if (kIsWeb) return false;

  if (replacements.count > 7) {
    replacements.cutDays(7);
  }

  final File file;
  if (groupInSearch.isNotEmpty) {
    file = await getCacheFilePath('replacements_' + groupInSearch + '.cache');
  } else {
    file = await getCacheFilePath(replacementsCachePath);
  }
  String fileContents = (lastReplacements?.toString() ?? '...') +
      '!' +
      jsonEncode(replacements.toJson());
  file.writeAsString(fileContents);
}

Future<Tuple3<String, Timetable, WeekShedule?>?> loadWeekSheduleCache(
    [String groupInSearch = '']) async {
  if (kIsWeb) return null;

  final File file;
  if (groupInSearch.isNotEmpty) {
    file = await getCacheFilePath('shedule_' + groupInSearch + '.cache');
  } else {
    file = await getCacheFilePath(sheduleCachePath);
  }

  if (file.existsSync()) {
    final saveFileMap = jsonDecode(file.readAsStringSync());
    var save = SaveModel.fromJson(saveFileMap);
    return Tuple3(save.group, save.timetable,
        WeekShedule(Tuple3(save.timetable, save.upShedule, save.downShedule)));
  } else {
    return null;
  }
}

Future<Tuple2<DateTime?, Replacements>?> loadReplacementsCache(
    [String groupInSearch = '']) async {
  if (kIsWeb) return null;

  try {
    final File file;
    if (groupInSearch.isNotEmpty) {
      file = await getCacheFilePath('replacements_' + groupInSearch + '.cache');
    } else {
      file = await getCacheFilePath(replacementsCachePath);
    }

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
  final directory = await getApplicationDocumentsDirectory();
  return File(directory.path + '/$fileName');
}
