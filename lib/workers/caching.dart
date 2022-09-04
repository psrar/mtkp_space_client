import 'dart:convert';
import 'package:mtkp/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';

Future savePinnedTeachers(List<Tuple2<int, String>> pinnedTeachers) async {
  var prefs = await SharedPreferences.getInstance();
  await prefs.setString('pinned_teachers',
      pinnedTeachers.map((e) => e.item1.toString() + '~' + e.item2).join('\n'));
}

Future<List<Tuple2<int, String>>> loadPinnedTeachers() async {
  var prefs = await SharedPreferences.getInstance();
  String? pinnedTeachers = prefs.getString('pinned_teachers');
  if (pinnedTeachers == null) {
    return [];
  } else {
    return pinnedTeachers.split('\n').map((e) {
      var i = e.split('~');
      return Tuple2(int.parse(i[0]), i[1]);
    }).toList();
  }
}

Future savePinnedGroups(List<String> pinnedGroups) async {
  var prefs = await SharedPreferences.getInstance();
  await prefs.setString('pinned_groups', pinnedGroups.join('\n'));
}

Future<List<String>> loadPinnedGroups() async {
  var prefs = await SharedPreferences.getInstance();
  var pinnedGroups = prefs.getString('pinned_groups');

  if (pinnedGroups == null) {
    return [];
  } else {
    return pinnedGroups.split('\n');
  }
}

Future saveWeekshedule(String group, WeekShedule weekShedule,
    [bool inSearch = false]) async {
  var prefs = await SharedPreferences.getInstance();
  var saveModel = SaveModel(weekShedule.weekLessons.item1,
      weekShedule.weekLessons.item2, weekShedule.weekLessons.item3, group);

  String path = '';
  if (inSearch) {
    path = 'shedule_' + group;
  } else {
    path = 'weekshedule';
  }

  await prefs.setString(path, jsonEncode(saveModel));
}

Future<Tuple3<String, Timetable, WeekShedule?>?> loadWeekShedule(
    [String groupInSearch = '']) async {
  var prefs = await SharedPreferences.getInstance();

  String path = '';
  if (groupInSearch.isNotEmpty) {
    path = 'shedule_' + groupInSearch;
  } else {
    path = 'weekshedule';
  }

  var weekshedule = prefs.getString(path);
  if (weekshedule == null) {
    return null;
  } else {
    final saveFileMap = jsonDecode(weekshedule);
    var save = SaveModel.fromJson(saveFileMap);
    return Tuple3(save.group, save.timetable,
        WeekShedule(Tuple3(save.timetable, save.upShedule, save.downShedule)));
  }
}

Future saveReplacements(Replacements replacements, DateTime? lastReplacements,
    [String groupInSearch = '']) async {
  var prefs = await SharedPreferences.getInstance();

  if (replacements.count > 7) {
    replacements.cutDays(7);
  }

  String path = '';
  if (groupInSearch.isNotEmpty) {
    path = 'replacements_' + groupInSearch;
  } else {
    path = 'replacements';
  }
  String replacementsJson = (lastReplacements?.toString() ?? '...') +
      '!' +
      jsonEncode(replacements.toJson());
  prefs.setString(path, replacementsJson);
}

Future<Tuple2<DateTime?, Replacements>?> loadReplacements(
    [String groupInSearch = '']) async {
  var prefs = await SharedPreferences.getInstance();

  String path = '';
  if (groupInSearch.isNotEmpty) {
    path = 'replacements_' + groupInSearch;
  } else {
    path = 'replacements';
  }

  var replacementsJson = prefs.getString(path);
  if (replacementsJson == null) {
    return Tuple2(null, Replacements(null));
  } else {
    final repl = replacementsJson.split('!');
    DateTime? stamp = DateTime.tryParse(repl.first);
    Map<String, dynamic> json = jsonDecode(repl[1]);
    if (json.isEmpty) return Tuple2(stamp, Replacements(null));

    Replacements replacements = Replacements.fromJson(json);
    return Tuple2(stamp, replacements);
  }
}
