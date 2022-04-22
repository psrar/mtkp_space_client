import 'package:mtkp/models.dart';

Map<String, String> buildDomensMap(WeekShedule? inputShedule) {
  if (inputShedule != null) {
    var result = <String, String>{};
    var pairs = inputShedule.weekLessons.item2 + inputShedule.weekLessons.item3;
    for (var element in pairs) {
      for (var pair in element) {
        if (pair != null) {
          String? mdk =
              RegExp(r'([А-Я]+.\d{1,2}.\d{1,2})').stringMatch(pair.name);
          if (mdk != null) {
            String match = result.keys.firstWhere(
                (element) => element.contains(mdk),
                orElse: (() => ''));
            if (match.isNotEmpty) {
              if (match.length < pair.name.length) {
                result.remove(match);
                result[pair.name] = pair.teacherReadable;
              }
            } else {
              result[pair.name] = pair.teacherReadable;
            }
          } else {
            result[pair.name] = pair.teacherReadable;
          }
        }
      }
    }

    return result;
  } else {
    return {};
  }
}
